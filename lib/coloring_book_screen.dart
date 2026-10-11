import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'billing_service.dart';
import 'music_manager.dart';
import 'parent_gate_dialog.dart';
import 'paywall_screen.dart';
import 'firebase_rewards_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOUR PALETTE (12 vibrant toddler colors)
// ─────────────────────────────────────────────────────────────────────────────

const List<Color> _kPalette = [
  Color(0xFFE63946), // red
  Color(0xFFFF9F1C), // orange
  Color(0xFFFFBF00), // yellow
  Color(0xFF2DC653), // green
  Color(0xFF00B4D8), // cyan
  Color(0xFF4361EE), // blue
  Color(0xFF7B2D8B), // purple
  Color(0xFFFF6B9D), // pink
  Color(0xFF8B5E3C), // brown
  Color(0xFF06D6A0), // mint
  Color(0xFFFF5E5B), // coral
  Color(0xFF2A2A2A), // black
];

enum PaintMode { bucket, brush, eraser }

// ─────────────────────────────────────────────────────────────────────────────
// STROKE MODEL (Freehand Brush Painting)
// ─────────────────────────────────────────────────────────────────────────────

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;

  _Stroke({
    required this.points,
    required this.color,
    required this.width,
    this.isEraser = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ZONE MODEL – tap-fillable region
// ─────────────────────────────────────────────────────────────────────────────

class _Zone {
  final String id;
  final Path Function(Size) buildPath;
  Color color;
  bool filled;

  _Zone({
    required this.id,
    required this.buildPath,
    Color? color,
    bool? filled,
  })  : color = color ?? const Color(0xFFF5F3EE),
        filled = filled ?? false;

  void reset() {
    color = const Color(0xFFF5F3EE);
    filled = false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _Page {
  final String name;
  final String emoji;
  final String category;
  final List<_Zone> zones;
  final List<_Stroke> strokes = [];

  _Page({
    required this.name,
    required this.emoji,
    required this.category,
    required this.zones,
  });

  bool get isComplete => zones.every((z) => z.filled);

  void reset() {
    for (final z in zones) {
      z.reset();
    }
    strokes.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PATH HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Path _arcBand(Size s, double outerR, double innerR) {
  final cx = s.width * 0.5;
  final cy = s.height * 0.75;
  final c = Offset(cx, cy);
  return Path()
    ..moveTo(cx - outerR, cy)
    ..arcTo(Rect.fromCircle(center: c, radius: outerR), pi, -pi, false)
    ..lineTo(cx + innerR, cy)
    ..arcTo(Rect.fromCircle(center: c, radius: innerR), 0, pi, false)
    ..close();
}

Path _petalPath(Size s, double angleDeg) {
  final angle = angleDeg * pi / 180;
  final cx = s.width * 0.5;
  final cy = s.height * 0.44;
  final dist = s.width * 0.19;

  final px = cx + dist * cos(angle);
  final py = cy + dist * sin(angle);

  final raw = Path()
    ..addOval(Rect.fromCenter(
      center: Offset.zero,
      width: s.width * 0.165,
      height: s.width * 0.30,
    ));

  final m = Matrix4.translationValues(px, py, 0)..rotateZ(angle - pi / 2);
  return raw.transform(m.storage);
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE DEFINITIONS (12 Detailed Outlines)
// ─────────────────────────────────────────────────────────────────────────────

List<_Page> _buildPages() {
  return [
    // ── 1. LITTLE BEAR (CHARACTER) ───────────────────────────
    _Page(name: 'Little Bear', emoji: '🧸', category: 'Characters', zones: [
      _Zone(
        id: 'ear_left_outer',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.26, s.height * 0.22),
            radius: s.width * 0.13,
          )),
      ),
      _Zone(
        id: 'ear_left_inner',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.26, s.height * 0.22),
            radius: s.width * 0.07,
          )),
      ),
      _Zone(
        id: 'ear_right_outer',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.74, s.height * 0.22),
            radius: s.width * 0.13,
          )),
      ),
      _Zone(
        id: 'ear_right_inner',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.74, s.height * 0.22),
            radius: s.width * 0.07,
          )),
      ),
      _Zone(
        id: 'head',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.50, s.height * 0.44),
            radius: s.width * 0.30,
          )),
      ),
      _Zone(
        id: 'snout',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.50),
            width: s.width * 0.26,
            height: s.width * 0.19,
          )),
      ),
      _Zone(
        id: 'bowtie',
        buildPath: (s) {
          final p = Path();
          final cx = s.width * 0.5;
          final cy = s.height * 0.76;
          p.moveTo(cx - s.width * 0.18, cy - s.height * 0.05);
          p.lineTo(cx, cy);
          p.lineTo(cx - s.width * 0.18, cy + s.height * 0.05);
          p.close();
          p.moveTo(cx + s.width * 0.18, cy - s.height * 0.05);
          p.lineTo(cx, cy);
          p.lineTo(cx + s.width * 0.18, cy + s.height * 0.05);
          p.close();
          p.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: s.width * 0.04));
          return p;
        },
      ),
    ]),

    // ── 2. PLAYFUL PUPPY (CHARACTER) ─────────────────────────
    _Page(name: 'Playful Puppy', emoji: '🐶', category: 'Characters', zones: [
      _Zone(
        id: 'ear_left',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.20, s.height * 0.38),
            width: s.width * 0.18,
            height: s.height * 0.32,
          )),
      ),
      _Zone(
        id: 'ear_right',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.80, s.height * 0.38),
            width: s.width * 0.18,
            height: s.height * 0.32,
          )),
      ),
      _Zone(
        id: 'head',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.50, s.height * 0.42),
            radius: s.width * 0.27,
          )),
      ),
      _Zone(
        id: 'snout',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.50),
            width: s.width * 0.28,
            height: s.width * 0.20,
          )),
      ),
      _Zone(
        id: 'collar',
        buildPath: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(
              s.width * 0.32,
              s.height * 0.68,
              s.width * 0.36,
              s.height * 0.07,
            ),
            const Radius.circular(12),
          )),
      ),
    ]),

    // ── 3. FRIENDLY GIRAFFE (ANIMALS) ────────────────────────
    _Page(name: 'Friendly Giraffe', emoji: '🦒', category: 'Animals', zones: [
      _Zone(
        id: 'head',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.22),
            width: s.width * 0.28,
            height: s.height * 0.18,
          )),
      ),
      _Zone(
        id: 'neck',
        buildPath: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.42, s.height * 0.30, s.width * 0.16, s.height * 0.42),
            const Radius.circular(16),
          )),
      ),
      _Zone(
        id: 'snout',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.28),
            width: s.width * 0.20,
            height: s.height * 0.09,
          )),
      ),
      _Zone(
        id: 'spots',
        buildPath: (s) {
          final p = Path();
          p.addOval(Rect.fromCircle(center: Offset(s.width * 0.47, s.height * 0.38), radius: 14));
          p.addOval(Rect.fromCircle(center: Offset(s.width * 0.53, s.height * 0.48), radius: 16));
          p.addOval(Rect.fromCircle(center: Offset(s.width * 0.46, s.height * 0.58), radius: 15));
          return p;
        },
      ),
    ]),

    // ── 4. LITTLE LION (ANIMALS) ─────────────────────────────
    _Page(name: 'Little Lion', emoji: '🦁', category: 'Animals', zones: [
      _Zone(
        id: 'mane',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.50, s.height * 0.44),
            radius: s.width * 0.38,
          )),
      ),
      _Zone(
        id: 'face',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.50, s.height * 0.44),
            radius: s.width * 0.25,
          )),
      ),
      _Zone(
        id: 'snout',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.50),
            width: s.width * 0.22,
            height: s.height * 0.12,
          )),
      ),
    ]),

    // ── 5. ZOOMING CAR (VEHICLES) ───────────────────────────
    _Page(name: 'Zooming Car', emoji: '🚗', category: 'Vehicles', zones: [
      _Zone(
        id: 'body',
        buildPath: (s) {
          final p = Path();
          final w = s.width;
          final h = s.height;
          p.moveTo(w * 0.15, h * 0.60);
          p.lineTo(w * 0.28, h * 0.42);
          p.lineTo(w * 0.68, h * 0.42);
          p.lineTo(w * 0.85, h * 0.60);
          p.lineTo(w * 0.90, h * 0.72);
          p.lineTo(w * 0.10, h * 0.72);
          p.close();
          return p;
        },
      ),
      _Zone(
        id: 'windows',
        buildPath: (s) {
          final p = Path();
          final w = s.width;
          final h = s.height;
          p.moveTo(w * 0.32, h * 0.45);
          p.lineTo(w * 0.48, h * 0.45);
          p.lineTo(w * 0.48, h * 0.58);
          p.lineTo(w * 0.22, h * 0.58);
          p.close();
          p.moveTo(w * 0.52, h * 0.45);
          p.lineTo(w * 0.66, h * 0.45);
          p.lineTo(w * 0.76, h * 0.58);
          p.lineTo(w * 0.52, h * 0.58);
          p.close();
          return p;
        },
      ),
      _Zone(
        id: 'wheel_left',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.28, s.height * 0.72),
            radius: s.width * 0.11,
          )),
      ),
      _Zone(
        id: 'wheel_right',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.72, s.height * 0.72),
            radius: s.width * 0.11,
          )),
      ),
    ]),

    // ── 6. SPACE ROCKET (VEHICLES) ───────────────────────────
    _Page(name: 'Space Rocket', emoji: '🚀', category: 'Vehicles', zones: [
      _Zone(
        id: 'cone',
        buildPath: (s) => Path()
          ..moveTo(s.width * 0.50, s.height * 0.12)
          ..lineTo(s.width * 0.68, s.height * 0.32)
          ..lineTo(s.width * 0.32, s.height * 0.32)
          ..close(),
      ),
      _Zone(
        id: 'body',
        buildPath: (s) => Path()
          ..addRect(Rect.fromLTRB(
            s.width * 0.32, s.height * 0.32,
            s.width * 0.68, s.height * 0.68,
          )),
      ),
      _Zone(
        id: 'window',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.50, s.height * 0.46),
            radius: s.width * 0.12,
          )),
      ),
      _Zone(
        id: 'fin_left',
        buildPath: (s) => Path()
          ..moveTo(s.width * 0.32, s.height * 0.55)
          ..lineTo(s.width * 0.15, s.height * 0.72)
          ..lineTo(s.width * 0.32, s.height * 0.68)
          ..close(),
      ),
      _Zone(
        id: 'fin_right',
        buildPath: (s) => Path()
          ..moveTo(s.width * 0.68, s.height * 0.55)
          ..lineTo(s.width * 0.85, s.height * 0.72)
          ..lineTo(s.width * 0.68, s.height * 0.68)
          ..close(),
      ),
    ]),

    // ── 7. LITTLE DINO (CHARACTER) ───────────────────────────
    _Page(name: 'Little Dino', emoji: '🦕', category: 'Characters', zones: [
      _Zone(
        id: 'body',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.50, s.height * 0.52),
            width: s.width * 0.55,
            height: s.height * 0.36,
          )),
      ),
      _Zone(
        id: 'head',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.35, s.height * 0.28),
            radius: s.width * 0.18,
          )),
      ),
      _Zone(
        id: 'belly',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCenter(
            center: Offset(s.width * 0.52, s.height * 0.56),
            width: s.width * 0.34,
            height: s.height * 0.22,
          )),
      ),
      _Zone(
        id: 'spikes',
        buildPath: (s) {
          final p = Path();
          final centers = [
            Offset(s.width * 0.40, s.height * 0.34),
            Offset(s.width * 0.52, s.height * 0.34),
            Offset(s.width * 0.64, s.height * 0.36),
          ];
          for (final c in centers) {
            p.moveTo(c.dx - 12, c.dy);
            p.lineTo(c.dx, c.dy - 24);
            p.lineTo(c.dx + 12, c.dy);
            p.close();
          }
          return p;
        },
      ),
    ]),

    // ── 8. HAPPY SUN (NATURE) ────────────────────────────────
    _Page(name: 'Happy Sun', emoji: '☀️', category: 'Nature', zones: [
      _Zone(
        id: 'rays',
        buildPath: (s) {
          final cx = s.width * 0.5;
          final cy = s.height * 0.44;
          final p = Path();
          for (int i = 0; i < 8; i++) {
            final a = i * pi / 4;
            const half = pi / 18;
            final inner = s.width * 0.26;
            final outer = s.width * 0.415;
            p.moveTo(cx + inner * cos(a - half), cy + inner * sin(a - half));
            p.lineTo(cx + outer * cos(a), cy + outer * sin(a));
            p.lineTo(cx + inner * cos(a + half), cy + inner * sin(a + half));
            p.close();
          }
          return p;
        },
      ),
      _Zone(
        id: 'face',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.5, s.height * 0.44),
            radius: s.width * 0.245,
          )),
      ),
    ]),

    // ── 9. RAINBOW (NATURE) ──────────────────────────────────
    _Page(name: 'Rainbow', emoji: '🌈', category: 'Nature', zones: [
      _Zone(id: 'arc_red',    buildPath: (s) => _arcBand(s, s.width * 0.46, s.width * 0.39)),
      _Zone(id: 'arc_orange', buildPath: (s) => _arcBand(s, s.width * 0.39, s.width * 0.32)),
      _Zone(id: 'arc_yellow', buildPath: (s) => _arcBand(s, s.width * 0.32, s.width * 0.25)),
      _Zone(id: 'arc_blue',   buildPath: (s) => _arcBand(s, s.width * 0.25, s.width * 0.19)),
    ]),

    // ── 10. BUTTERFLY (NATURE) ───────────────────────────────
    _Page(name: 'Butterfly', emoji: '🦋', category: 'Nature', zones: [
      _Zone(
        id: 'left_upper',
        buildPath: (s) => Path()
          ..addOval(Rect.fromLTWH(
            s.width * 0.03, s.height * 0.18, s.width * 0.41, s.height * 0.30)),
      ),
      _Zone(
        id: 'left_lower',
        buildPath: (s) => Path()
          ..addOval(Rect.fromLTWH(
            s.width * 0.08, s.height * 0.46, s.width * 0.33, s.height * 0.23)),
      ),
      _Zone(
        id: 'right_upper',
        buildPath: (s) => Path()
          ..addOval(Rect.fromLTWH(
            s.width * 0.56, s.height * 0.18, s.width * 0.41, s.height * 0.30)),
      ),
      _Zone(
        id: 'right_lower',
        buildPath: (s) => Path()
          ..addOval(Rect.fromLTWH(
            s.width * 0.59, s.height * 0.46, s.width * 0.33, s.height * 0.23)),
      ),
      _Zone(
        id: 'body',
        buildPath: (s) => Path()
          ..addOval(Rect.fromLTWH(
            s.width * 0.445, s.height * 0.22, s.width * 0.11, s.height * 0.46)),
      ),
    ]),

    // ── 11. MY HOUSE (PLACES) ────────────────────────────────
    _Page(name: 'My House', emoji: '🏠', category: 'Places', zones: [
      _Zone(
        id: 'roof',
        buildPath: (s) => Path()
          ..moveTo(s.width * 0.50, s.height * 0.10)
          ..lineTo(s.width * 0.87, s.height * 0.42)
          ..lineTo(s.width * 0.13, s.height * 0.42)
          ..close(),
      ),
      _Zone(
        id: 'wall',
        buildPath: (s) => Path()
          ..addRect(Rect.fromLTRB(
            s.width * 0.16, s.height * 0.42,
            s.width * 0.84, s.height * 0.84,
          )),
      ),
      _Zone(
        id: 'door',
        buildPath: (s) => Path()
          ..addRRect(RRect.fromRectAndCorners(
            Rect.fromLTWH(
                s.width * 0.42, s.height * 0.58,
                s.width * 0.16, s.height * 0.26),
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
          )),
      ),
      _Zone(
        id: 'win_left',
        buildPath: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.20, s.height * 0.50,
                s.width * 0.15, s.height * 0.14),
            const Radius.circular(5),
          )),
      ),
      _Zone(
        id: 'win_right',
        buildPath: (s) => Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * 0.65, s.height * 0.50,
                s.width * 0.15, s.height * 0.14),
            const Radius.circular(5),
          )),
      ),
    ]),

    // ── 12. PRETTY FLOWER (NATURE) ───────────────────────────
    _Page(name: 'Pretty Flower', emoji: '🌸', category: 'Nature', zones: [
      _Zone(id: 'p0', buildPath: (s) => _petalPath(s, -90)),
      _Zone(id: 'p1', buildPath: (s) => _petalPath(s, -30)),
      _Zone(id: 'p2', buildPath: (s) => _petalPath(s,  30)),
      _Zone(id: 'p3', buildPath: (s) => _petalPath(s,  90)),
      _Zone(id: 'p4', buildPath: (s) => _petalPath(s, 150)),
      _Zone(id: 'p5', buildPath: (s) => _petalPath(s, 210)),
      _Zone(
        id: 'center',
        buildPath: (s) => Path()
          ..addOval(Rect.fromCircle(
            center: Offset(s.width * 0.5, s.height * 0.44),
            radius: s.width * 0.12,
          )),
      ),
      _Zone(
        id: 'stem_leaves',
        buildPath: (s) {
          final cx = s.width * 0.5;
          final p = Path();
          p.addRect(Rect.fromLTRB(
            cx - s.width * 0.025, s.height * 0.57,
            cx + s.width * 0.025, s.height * 0.84,
          ));
          p.addOval(Rect.fromCenter(
            center: Offset(cx - s.width * 0.13, s.height * 0.68),
            width: s.width * 0.21,
            height: s.height * 0.09,
          ));
          p.addOval(Rect.fromCenter(
            center: Offset(cx + s.width * 0.13, s.height * 0.74),
            width: s.width * 0.21,
            height: s.height * 0.09,
          ));
          return p;
        },
      ),
    ]),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// RIPPLE MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _Ripple {
  final Offset position;
  final Color color;
  final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  _Ripple({
    required this.position,
    required this.color,
    required this.controller,
  }) {
    scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    opacity = Tween<double>(begin: 0.85, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class ColoringBookScreen extends StatefulWidget {
  const ColoringBookScreen({super.key});

  @override
  State<ColoringBookScreen> createState() => _ColoringBookScreenState();
}

class _ColoringBookScreenState extends State<ColoringBookScreen>
    with TickerProviderStateMixin {
  late final List<_Page> _pages;
  int _pageIdx = 0;
  Color _selectedColor = _kPalette.first;
  PaintMode _paintMode = PaintMode.brush;
  double _brushWidth = 14.0;

  _Stroke? _activeStroke;
  final List<_Ripple> _ripples = [];
  late final ConfettiController _confetti;
  final AudioPlayer _audio = AudioPlayer();

  _Page get _page => _pages[_pageIdx];

  @override
  void initState() {
    super.initState();
    _pages = _buildPages();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    Future.delayed(const Duration(milliseconds: 700), () {
      MusicManager.playVoiceover(_audio, 'audio/coloring book .mp3')
          .catchError((_) {});
    });
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    _confetti.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _nextPage() {
    setState(() {
      _pageIdx = (_pageIdx + 1) % _pages.length;
    });
  }

  void _prevPage() {
    setState(() {
      _pageIdx = (_pageIdx - 1 + _pages.length) % _pages.length;
    });
  }

  void _undo() {
    setState(() {
      if (_page.strokes.isNotEmpty) {
        _page.strokes.removeLast();
      }
    });
  }

  void _clearPage() {
    setState(() {
      _page.reset();
    });
  }

  void _onTapCanvas(Offset position, Size canvasSize) {
    if (_paintMode == PaintMode.bucket) {
      for (final zone in _page.zones.reversed) {
        if (zone.buildPath(canvasSize).contains(position)) {
          setState(() {
            zone.color = _selectedColor;
            zone.filled = true;
          });
          _spawnRipple(position);
          if (_page.isComplete) _onPageComplete();
          return;
        }
      }
    }
  }

  void _spawnRipple(Offset pos) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final ripple = _Ripple(position: pos, color: _selectedColor, controller: ctrl);
    setState(() => _ripples.add(ripple));

    ctrl.forward().then((_) {
      if (mounted) {
        setState(() => _ripples.remove(ripple));
        ctrl.dispose();
      }
    });
  }

  void _onPageComplete() {
    _confetti.play();
    _audio.play(AssetSource('Yay! Great job!.mp3')).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingService>(
      builder: (context, billing, child) {
        final isPageLocked = (_pageIdx >= 3) && !billing.isPremiumUnlocked;
        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    _buildPageSelector(),
                    _buildToolControls(),
                    Expanded(child: _buildCanvas()),
                    _buildPalette(),
                  ],
                ),
                if (isPageLocked)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.94),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3E0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 56,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Unlock All Coloring Pages! 🎨",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF11153B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "First 3 pages are free! Unlock Full Version to color all pages.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4081),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 6,
                              ),
                              onPressed: () {
                                ParentGateDialog.show(
                                  context,
                                  onSuccess: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PaywallScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                              label: Text(
                                "Unlock Full Version 👑",
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    numberOfParticles: 45,
                    emissionFrequency: 0.04,
                    gravity: 0.2,
                    colors: _kPalette,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header Bar ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF880E4F), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Text(
              '🎨 Coloring Book',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: 'Undo last stroke',
            icon: const Icon(Icons.undo_rounded, color: Color(0xFF5D4037), size: 26),
            onPressed: _page.strokes.isNotEmpty ? _undo : null,
          ),
          IconButton(
            tooltip: 'Clear page',
            icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFD32F2F), size: 26),
            onPressed: _clearPage,
          ),
        ],
      ),
    );
  }

  // ── Page Selection Bar ───────────────────────────────────────────────────

  Widget _buildPageSelector() {
    final isUnlocked = BillingService.instance.isPremiumUnlocked;
    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: _pages.length,
        itemBuilder: (_, i) {
          final sel = i == _pageIdx;
          final page = _pages[i];
          final isPageLocked = (i >= 3) && !isUnlocked;
          return GestureDetector(
            onTap: () {
              if (isPageLocked) {
                ParentGateDialog.show(
                  context,
                  onSuccess: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  },
                );
              } else {
                setState(() => _pageIdx = i);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (sel ? const Color(0xFF6C63FF) : Colors.black)
                        .withValues(alpha: sel ? 0.28 : 0.08),
                    blurRadius: sel ? 10 : 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(page.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    page.name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : const Color(0xFF555555),
                    ),
                  ),
                  if (isPageLocked) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_rounded, size: 14, color: Colors.amber),
                  ] else if (page.isComplete) ...[
                    const SizedBox(width: 4),
                    const Text('✅', style: TextStyle(fontSize: 11)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tool Controls (Paint vs Bucket & Brush Size) ──────────────────────────

  Widget _buildToolControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              children: [
                _buildModeBtn(
                  mode: PaintMode.brush,
                  label: "Brush 🖌️",
                  icon: Icons.brush_rounded,
                ),
                const SizedBox(width: 4),
                _buildModeBtn(
                  mode: PaintMode.bucket,
                  label: "Bucket 🪣",
                  icon: Icons.format_paint_rounded,
                ),
                const SizedBox(width: 4),
                _buildModeBtn(
                  mode: PaintMode.eraser,
                  label: "Eraser 🧹",
                  icon: Icons.cleaning_services_rounded,
                ),
              ],
            ),
          ),

          if (_paintMode != PaintMode.bucket)
            Row(
              children: [6.0, 14.0, 26.0].map((w) {
                final sel = _brushWidth == w;
                return GestureDetector(
                  onTap: () => setState(() => _brushWidth = w),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFFF4081) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Center(
                      child: Container(
                        width: w * 0.6,
                        height: w * 0.6,
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : const Color(0xFF333333),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildModeBtn({
    required PaintMode mode,
    required String label,
    required IconData icon,
  }) {
    final sel = _paintMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _paintMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFFF4081) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: sel ? Colors.white : const Color(0xFF666666)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: sel ? Colors.white : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Canvas Widget ──────────────────────────────────────────────────────────

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _onTapCanvas(d.localPosition, canvasSize),
                  onPanStart: (d) {
                    if (_paintMode != PaintMode.bucket) {
                      setState(() {
                        _activeStroke = _Stroke(
                          points: [d.localPosition],
                          color: _paintMode == PaintMode.eraser
                              ? const Color(0xFFFFFDF8)
                              : _selectedColor,
                          width: _brushWidth,
                          isEraser: _paintMode == PaintMode.eraser,
                        );
                      });
                    }
                  },
                  onPanUpdate: (d) {
                    if (_paintMode != PaintMode.bucket && _activeStroke != null) {
                      setState(() {
                        _activeStroke!.points.add(d.localPosition);
                      });
                    }
                  },
                  onPanEnd: (d) {
                    if (_activeStroke != null) {
                      setState(() {
                        _page.strokes.add(_activeStroke!);
                        _activeStroke = null;
                      });
                      FirebaseRewardsManager.addStars(2);
                      FirebaseRewardsManager.recordDrawingColored(1);
                    }
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ColoringPainter(
                        zones: _page.zones,
                        strokes: _page.strokes,
                        currentStroke: _activeStroke,
                      ),
                      size: canvasSize,
                    ),
                  ),
                ),

                ..._ripples.map((r) => _RippleWidget(ripple: r)),

                Positioned(
                  left: 6,
                  top: canvasSize.height * 0.45,
                  child: GestureDetector(
                    onTap: _prevPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF6C63FF), size: 20),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: canvasSize.height * 0.45,
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF6C63FF), size: 20),
                    ),
                  ),
                ),

                if (_page.isComplete)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, v, child) => Transform.scale(
                            scale: v,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF)
                                        .withValues(alpha: 0.45),
                                    blurRadius: 22,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '🎉 Super Artist!',
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_page.zones.every((z) => !z.filled) && _page.strokes.isEmpty)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _paintMode == PaintMode.brush
                                ? 'Drag your finger to paint! 🖌️'
                                : 'Tap shapes to color! 🪣',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Palette Bar ────────────────────────────────────────────────────────────

  Widget _buildPalette() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _kPalette.map((c) {
          final isSel = c == _selectedColor && _paintMode != PaintMode.eraser;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = c;
                if (_paintMode == PaintMode.eraser) {
                  _paintMode = PaintMode.brush;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSel ? 44 : 34,
              height: isSel ? 44 : 34,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSel ? const Color(0xFF222222) : Colors.grey.shade300,
                  width: isSel ? 3.0 : 1.5,
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.55),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: isSel
                  ? Icon(
                      Icons.check_rounded,
                      color: c == Colors.white ? Colors.black54 : Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _ColoringPainter extends CustomPainter {
  final List<_Zone> zones;
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;

  const _ColoringPainter({
    required this.zones,
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFFDF8),
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final zone in zones) {
      fillPaint.color = zone.color;
      canvas.drawPath(zone.buildPath(size), fillPaint);
    }

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final zone in zones) {
      canvas.drawPath(zone.buildPath(size), outlinePaint);
    }
  }

  void _drawStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.length < 2) return;
    final paint = Paint()
      ..color = stroke.isEraser ? const Color(0xFFFFFDF8) : stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ColoringPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// RIPPLE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _RippleWidget extends StatelessWidget {
  final _Ripple ripple;

  const _RippleWidget({required this.ripple});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ripple.controller,
      builder: (context, child) {
        final r = ripple.scale.value * 58;
        return Positioned(
          left: ripple.position.dx - r,
          top: ripple.position.dy - r,
          width: r * 2,
          height: r * 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: ripple.opacity.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ripple.color.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
