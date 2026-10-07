import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'music_manager.dart';
import 'package:lottie/lottie.dart';

class PhonicsGameDialog extends StatefulWidget {
  final List<String> learnedLetters;
  const PhonicsGameDialog({super.key, required this.learnedLetters});

  @override
  State<PhonicsGameDialog> createState() => _PhonicsGameDialogState();
}

class _PhonicsGameDialogState extends State<PhonicsGameDialog> with TickerProviderStateMixin {
  late String _targetLetter;
  late List<String> _poolLetters;
  final List<_Balloon> _balloons = [];
  final List<_Particle> _particles = [];
  final AudioPlayer _dialogAudioPlayer = AudioPlayer();
  
  late Ticker _ticker;
  int _score = 0;
  bool _isFinished = false;
  late Size _screenSize;

  final List<Color> _balloonColors = [
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.pink.shade400,
  ];

  @override
  void initState() {
    super.initState();
    // Choose random target letter from recently learned ones
    final random = Random();
    _targetLetter = widget.learnedLetters[random.nextInt(widget.learnedLetters.length)];
    
    // Pool of other letters to mix in
    _poolLetters = ['X', 'Y', 'Z', 'W', 'K', 'S', 'P', 'T', 'O', 'M', 'N', 'L']
        .where((l) => !_targetLetter.contains(l))
        .toList();

    _ticker = createTicker(_updatePhysics);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenSize = MediaQuery.of(context).size;
      _spawnInitialBalloons();
      _ticker.start();
    });
  }

  void _spawnInitialBalloons() {
    final random = Random();
    for (int i = 0; i < 6; i++) {
      _balloons.add(
        _Balloon(
          x: random.nextDouble() * (_screenSize.width - 80) + 40,
          y: _screenSize.height + (i * 120.0) + 100,
          speed: random.nextDouble() * 2.0 + 1.5,
          letter: random.nextDouble() < 0.35 ? _targetLetter : _getRandomPoolLetter(),
          color: _balloonColors[random.nextInt(_balloonColors.length)],
        ),
      );
    }
  }

  String _getRandomPoolLetter() {
    final random = Random();
    return _poolLetters[random.nextInt(_poolLetters.length)];
  }

  void _updatePhysics(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      final random = Random();
      
      // Update balloons Y
      for (var balloon in _balloons) {
        if (!balloon.isPopped) {
          balloon.y -= balloon.speed;
          // Respawn at bottom if floats off top
          if (balloon.y < -120) {
            balloon.y = _screenSize.height + 50;
            balloon.x = random.nextDouble() * (_screenSize.width - 80) + 40;
            balloon.letter = random.nextDouble() < 0.4 ? _targetLetter : _getRandomPoolLetter();
            balloon.speed = random.nextDouble() * 2.0 + 1.5;
          }
        }
      }

      // Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.2; // gravity effect
        p.life -= 0.03;
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _popBalloon(int index) {
    if (_isFinished) return;
    final balloon = _balloons[index];
    if (balloon.isPopped) return;

    setState(() {
      balloon.isPopped = true;
      _triggerPopParticles(balloon.x, balloon.y, balloon.color);
      
      // Gentle Haptic / Audio Pop feedback
      _dialogAudioPlayer.play(AssetSource('audio/happy garden .mp3'), volume: 0.0); // Wake up player if needed, or simply visual feedback

      if (balloon.letter == _targetLetter) {
        _score++;
        if (_score >= 6) {
          _isFinished = true;
          _ticker.stop();
          _triggerPopParticles(balloon.x, balloon.y, balloon.color);
          _triggerVictory();
        } else {
          // Immediately respawn popped balloon at bottom
          final random = Random();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              balloon.isPopped = false;
              balloon.y = _screenSize.height + 50;
              balloon.x = random.nextDouble() * (_screenSize.width - 80) + 40;
              balloon.letter = random.nextDouble() < 0.4 ? _targetLetter : _getRandomPoolLetter();
            });
          });
        }
      } else {
        // Shaking feedback or simple visual wrong pop
        final random = Random();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            balloon.isPopped = false;
            balloon.y = _screenSize.height + 50;
            balloon.x = random.nextDouble() * (_screenSize.width - 80) + 40;
            balloon.letter = random.nextDouble() < 0.4 ? _targetLetter : _getRandomPoolLetter();
          });
        });
      }
    });
  }

  void _triggerPopParticles(double cx, double cy, Color color) {
    final random = Random();
    for (int i = 0; i < 12; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 4 + 2;
      _particles.add(
        _Particle(
          x: cx,
          y: cy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: color,
          life: 1.0,
        ),
      );
    }
  }

  void _dismiss() {
    if (mounted) Navigator.pop(context, true);
  }

  void _triggerVictory() {
    // Play the victory voiceover (non-blocking)
    MusicManager.playVoiceover(_dialogAudioPlayer, 'audio/Amazing writing!_You did it!.mp3');

    // Auto-dismiss after 4 seconds as a safe fallback
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _dialogAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFD9F1FF),
      child: SafeArea(
        child: Stack(
          children: [
            // Sky Background Elements (Clouds etc)
            Positioned(
              top: 40,
              left: 30,
              child: Icon(Icons.cloud_queue_rounded, size: 80, color: Colors.white.withOpacity(0.6)),
            ),
            Positioned(
              top: 150,
              right: 40,
              child: Icon(Icons.cloud_queue_rounded, size: 100, color: Colors.white.withOpacity(0.6)),
            ),

            // Particles Painting
            CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(_particles),
            ),

            // Balloons
            ...List.generate(_balloons.length, (index) {
              final b = _balloons[index];
              if (b.isPopped) return const SizedBox.shrink();
              return Positioned(
                left: b.x - 40,
                top: b.y - 50,
                child: GestureDetector(
                  onTap: () => _popBalloon(index),
                  child: _BalloonWidget(balloon: b),
                ),
              );
            }),

            // Top Status Bar (Score Card)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bubble Pop Game!",
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tap all the $_targetLetter balloons!",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Stars Tracker
                      Row(
                        children: List.generate(6, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 26,
                            color: i < _score ? const Color(0xFFFFD700) : Colors.grey.shade300,
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Victory Pop-up Overlay
            if (_isFinished)
              Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    color: Colors.white,
                    child: Container(
                      width: 340,
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: Lottie.asset(
                                'assets/CELEBRATE LOTTIE.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            "Amazing!",
                            style: GoogleFonts.nunito(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          Text(
                            "You did it!",
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "+1 Gold Star Earned",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ── Continue button ──────────────────────────────
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Keep Learning! 🚀",
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Balloon {
  double x;
  double y;
  double speed;
  String letter;
  Color color;
  bool isPopped = false;

  _Balloon({
    required this.x,
    required this.y,
    required this.speed,
    required this.letter,
    required this.color,
  });
}

class _BalloonWidget extends StatelessWidget {
  final _Balloon balloon;
  const _BalloonWidget({required this.balloon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Balloon String
          Positioned(
            bottom: 0,
            child: Container(
              width: 2,
              height: 35,
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Balloon Body
          Positioned(
            top: 0,
            child: Container(
              width: 75,
              height: 90,
              decoration: BoxDecoration(
                color: balloon.color,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.elliptical(37.5, 45)),
                boxShadow: [
                  BoxShadow(
                    color: balloon.color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                balloon.letter,
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Little Balloon Tie at Bottom
          Positioned(
            bottom: 28,
            child: CustomPaint(
              size: const Size(12, 8),
              painter: _TiePainter(balloon.color),
            ),
          )
        ],
      ),
    );
  }
}

class _TiePainter extends CustomPainter {
  final Color color;
  _TiePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double life; // 1.0 down to 0.0

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.life,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), 6.0 * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RotatingStar extends StatefulWidget {
  const _RotatingStar();

  @override
  State<_RotatingStar> createState() => _RotatingStarState();
}

class _RotatingStarState extends State<_RotatingStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.star_rounded,
        size: 100,
        color: Color(0xFFFFD700),
      ),
    );
  }
}
