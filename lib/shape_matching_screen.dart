import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'ad_manager.dart';
import 'firebase_rewards_manager.dart';

enum ShapeType {
  circle, square, triangle, star, heart,
  diamond, oval, crescent, hexagon, pentagon,
  bunny, bear, fish, bird, cat
}

class ShapeModel {
  final ShapeType type;
  final String name;
  final Color color;
  final Color darkColor;

  const ShapeModel({
    required this.type,
    required this.name,
    required this.color,
    required this.darkColor,
  });
}

class ShapeMatchingScreen extends StatefulWidget {
  const ShapeMatchingScreen({super.key});

  @override
  State<ShapeMatchingScreen> createState() => _ShapeMatchingScreenState();
}

class _ShapeMatchingScreenState extends State<ShapeMatchingScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const List<ShapeModel> _basicShapes = [
    ShapeModel(type: ShapeType.triangle, name: "Triangle", color: Color(0xFFFF8A80), darkColor: Color(0xFFD32F2F)),
    ShapeModel(type: ShapeType.circle, name: "Circle", color: Color(0xFFFFD54F), darkColor: Color(0xFFF57F17)),
    ShapeModel(type: ShapeType.square, name: "Square", color: Color(0xFF81D4FA), darkColor: Color(0xFF0288D1)),
    ShapeModel(type: ShapeType.star, name: "Star", color: Color(0xFFA5D6A7), darkColor: Color(0xFF388E3C)),
    ShapeModel(type: ShapeType.heart, name: "Heart", color: Color(0xFFCE93D8), darkColor: Color(0xFF7B1FA2)),
  ];

  static const List<ShapeModel> _advancedShapes = [
    ShapeModel(type: ShapeType.diamond, name: "Diamond", color: Color(0xFFFFB74D), darkColor: Color(0xFFE65100)),
    ShapeModel(type: ShapeType.oval, name: "Oval", color: Color(0xFF4DD0E1), darkColor: Color(0xFF00838F)),
    ShapeModel(type: ShapeType.crescent, name: "Moon", color: Color(0xFFFFF176), darkColor: Color(0xFFFBC02D)),
    ShapeModel(type: ShapeType.hexagon, name: "Hexagon", color: Color(0xFFBA68C8), darkColor: Color(0xFF6A1B9A)),
    ShapeModel(type: ShapeType.pentagon, name: "Pentagon", color: Color(0xFFAED581), darkColor: Color(0xFF33691E)),
  ];

  static const List<ShapeModel> _animalShapes = [
    ShapeModel(type: ShapeType.bunny, name: "Bunny", color: Color(0xFFF48FB1), darkColor: Color(0xFFC2185B)),
    ShapeModel(type: ShapeType.bear, name: "Bear", color: Color(0xFFBCAAA4), darkColor: Color(0xFF4E342E)),
    ShapeModel(type: ShapeType.fish, name: "Fish", color: Color(0xFF80DEEA), darkColor: Color(0xFF00838F)),
    ShapeModel(type: ShapeType.bird, name: "Bird", color: Color(0xFFFFCC80), darkColor: Color(0xFFEF6C00)),
    ShapeModel(type: ShapeType.cat, name: "Cat", color: Color(0xFFB0BEC5), darkColor: Color(0xFF37474F)),
  ];

  late List<ShapeModel> _levelQueue;
  int _currentLevelIndex = 0;
  int _starsEarned = 0;
  static const int _totalLevelsInRound = 5;
  late ShapeModel _targetShape;
  late List<ShapeModel> _bottomOptions;

  bool _isMatched = false;
  bool _isSpeaking = false;
  String? _lastDraggedWrong;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _setupLevel();
  }

  Future<void> _playAudio(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {}
  }

  void _setupLevel() {
    setState(() {
      _isMatched = false;
      _lastDraggedWrong = null;

      // Select pool based on current level progress
      List<ShapeModel> currentPool;
      if (_currentLevelIndex < 2) {
        currentPool = _basicShapes;
      } else if (_currentLevelIndex < 4) {
        currentPool = _advancedShapes;
      } else {
        currentPool = [..._basicShapes, ..._advancedShapes, ..._animalShapes];
      }

      _levelQueue = List.from(currentPool)..shuffle();
      _targetShape = _levelQueue[_currentLevelIndex % _levelQueue.length];
      
      // Bottom options contain target shape + options from current pool
      final options = List<ShapeModel>.from(currentPool)..shuffle();
      _bottomOptions = options.take(5).toList();
      if (!_bottomOptions.contains(_targetShape)) {
        _bottomOptions[0] = _targetShape;
        _bottomOptions.shuffle();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playInstruction();
    });
  }

  Future<void> _playInstruction() async {
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    await _playAudio('Find the matching shape! Drag it to its shadow!.mp3');
    // Wait for audio to finish (approx duration)
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _handleSuccess() async {
    setState(() {
      _isMatched = true;
      _starsEarned++;
    });

    // Play cheer audio
    await _playAudio('Yay! Great job!.mp3');
    await FirebaseRewardsManager.addStars(2);
    await FirebaseRewardsManager.recordShapeMatched(1);

    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    if ((_currentLevelIndex + 1) % _totalLevelsInRound == 0) {
      _showRoundCompletedDialog();
    } else {
      setState(() {
        _currentLevelIndex++;
        _setupLevel();
      });
    }
  }

  void _showRoundCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/mascot.json',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 12),
                Text(
                  "Round Complete! 🎉",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF880E4F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You matched 5 shapes and earned $_starsEarned stars! Super star!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentLevelIndex++;
                      _setupLevel();
                    });
                  },
                  child: Text(
                    "Play Next Round! ▶",
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
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final currentStep = (_currentLevelIndex % _totalLevelsInRound) + 1;
    final progress = currentStep / _totalLevelsInRound;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Level $currentStep of $_totalLevelsInRound",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF880E4F),
                ),
              ),
              Row(
                children: List.generate(_totalLevelsInRound, (index) {
                  final isDone = index < currentStep - 1;
                  final isCurrent = index == currentStep - 1;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      isDone || (isCurrent && _isMatched)
                          ? Icons.star_rounded
                          : (isCurrent ? Icons.star_half_rounded : Icons.star_outline_rounded),
                      size: 20,
                      color: isDone || (isCurrent && _isMatched)
                          ? const Color(0xFFFFB300)
                          : (isCurrent ? const Color(0xFFFFC107) : Colors.black26),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF8BBD0).withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4081)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleWrongDrop(ShapeModel dropped) async {
    setState(() {
      _lastDraggedWrong = dropped.name;
    });
    await _playAudio('Oops! Let\'s try that one again!.mp3');
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      setState(() {
        _lastDraggedWrong = null;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF880E4F), size: 22),
                        onPressed: () {
                          AdManager.showInterstitial(context);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Spacer(),
                    // Large Speaker Audio Button
                    GestureDetector(
                      onTap: _playInstruction,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = _isSpeaking ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4081),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF4081).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Listen",
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    // Star Counter Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFE65100), size: 22),
                          const SizedBox(width: 4),
                          Text(
                            "$_starsEarned",
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFE65100),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              _buildProgressBar(),

              const SizedBox(height: 8),

              // Short Text
              Text(
                "Find the Matching Shape!",
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2C1034),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _lastDraggedWrong != null
                    ? "Oops! That is a $_lastDraggedWrong. Find the ${_targetShape.name}!"
                    : "Drag the ${_targetShape.name} to its shadow!",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _lastDraggedWrong != null
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF880E4F).withValues(alpha: 0.8),
                ),
              ),

              // Center Shadow Target Area
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Target Shadow (DragTarget)
                      DragTarget<ShapeModel>(
                        onWillAcceptWithDetails: (details) => true,
                        onAcceptWithDetails: (details) {
                          if (details.data.type == _targetShape.type) {
                            _handleSuccess();
                          } else {
                            _handleWrongDrop(details.data);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovering = candidateData.isNotEmpty;
                          return AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final glowScale = 1.0 + (isHovering ? 0.08 : (_pulseController.value * 0.03));
                              return Transform.scale(
                                scale: glowScale,
                                child: Container(
                                  width: 210,
                                  height: 210,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _targetShape.color.withValues(alpha: isHovering ? 0.45 : 0.25),
                                        blurRadius: 30,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: _isMatched
                                      ? _buildCuteShape(_targetShape, size: 170, happy: true)
                                      : _buildShapeShadow(_targetShape, size: 170, isHovering: isHovering),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Success celebration stars
                      if (_isMatched)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Lottie.asset(
                              'assets/lottie/mascot.json',
                              width: 250,
                              height: 250,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Draggable Pieces
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Drag a shape up!",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _bottomOptions.map((shape) {
                          final isTargetAndMatched = _isMatched && shape.type == _targetShape.type;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Draggable<ShapeModel>(
                              data: shape,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.15,
                                  child: _buildCuteShape(shape, size: 85, happy: true),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.25,
                                child: _buildCuteShape(shape, size: 75),
                              ),
                              child: isTargetAndMatched
                                  ? Opacity(
                                      opacity: 0.3,
                                      child: _buildCuteShape(shape, size: 75),
                                    )
                                  : _buildCuteShape(shape, size: 75),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeShadow(ShapeModel shape, {required double size, bool isHovering = false}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShapeShadowPainter(
        type: shape.type,
        color: shape.color.withValues(alpha: isHovering ? 0.45 : 0.22),
        borderColor: shape.darkColor.withValues(alpha: isHovering ? 0.9 : 0.5),
      ),
    );
  }

  Widget _buildCuteShape(ShapeModel shape, {required double size, bool happy = true}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ShapeSolidPainter(
              type: shape.type,
              color: shape.color,
              borderColor: shape.darkColor,
            ),
          ),
          _buildCuteFace(size: size, happy: happy),
        ],
      ),
    );
  }

  Widget _buildCuteFace({required double size, bool happy = true}) {
    final eyeSize = size * 0.16;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left eye
          Positioned(
            top: size * 0.36,
            left: size * 0.26,
            child: _buildEye(eyeSize),
          ),
          // Right eye
          Positioned(
            top: size * 0.36,
            right: size * 0.26,
            child: _buildEye(eyeSize),
          ),
          // Cheeks
          Positioned(
            top: size * 0.48,
            left: size * 0.20,
            child: Container(
              width: size * 0.14,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Positioned(
            top: size * 0.48,
            right: size * 0.20,
            child: Container(
              width: size * 0.14,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          // Cute Smile
          Positioned(
            top: size * 0.50,
            child: Container(
              width: size * 0.24,
              height: size * 0.13,
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size * 0.15),
                  bottomRight: Radius.circular(size * 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Color(0xFF263238),
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.4),
        child: Container(
          width: eyeSize * 0.42,
          height: eyeSize * 0.42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ShapeSolidPainter extends CustomPainter {
  final ShapeType type;
  final Color color;
  final Color borderColor;

  _ShapeSolidPainter({required this.type, required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final path = _getPathForShape(type, size);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ShapeShadowPainter extends CustomPainter {
  final ShapeType type;
  final Color color;
  final Color borderColor;

  _ShapeShadowPainter({required this.type, required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = _getPathForShape(type, size);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Path _getPathForShape(ShapeType type, Size size) {
  final w = size.width;
  final h = size.height;
  final path = Path();

  switch (type) {
    case ShapeType.circle:
      path.addOval(Rect.fromLTWH(0, 0, w, h));
      break;
    case ShapeType.square:
      path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.22)));
      break;
    case ShapeType.triangle:
      path.moveTo(w * 0.5, h * 0.05);
      path.lineTo(w * 0.95, h * 0.92);
      path.lineTo(w * 0.05, h * 0.92);
      path.close();
      break;
    case ShapeType.star:
      final cx = w * 0.5;
      final cy = h * 0.5;
      final outerR = w * 0.48;
      final innerR = w * 0.22;
      for (int i = 0; i < 10; i++) {
        final r = (i % 2 == 0) ? outerR : innerR;
        final angle = (i * 36 - 90) * pi / 180;
        final x = cx + r * cos(angle);
        final y = cy + r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      break;
    case ShapeType.heart:
      path.moveTo(w * 0.5, h * 0.85);
      path.cubicTo(w * 0.15, h * 0.60, 0, h * 0.35, w * 0.25, h * 0.15);
      path.cubicTo(w * 0.40, h * 0.05, w * 0.5, h * 0.25, w * 0.5, h * 0.25);
      path.cubicTo(w * 0.5, h * 0.25, w * 0.60, h * 0.05, w * 0.75, h * 0.15);
      path.cubicTo(w, h * 0.35, w * 0.85, h * 0.60, w * 0.5, h * 0.85);
      path.close();
      break;
    case ShapeType.diamond:
      path.moveTo(w * 0.5, h * 0.05);
      path.lineTo(w * 0.92, h * 0.5);
      path.lineTo(w * 0.5, h * 0.95);
      path.lineTo(w * 0.08, h * 0.5);
      path.close();
      break;
    case ShapeType.oval:
      path.addOval(Rect.fromLTWH(w * 0.1, h * 0.05, w * 0.8, h * 0.9));
      break;
    case ShapeType.crescent:
      path.addArc(Rect.fromLTWH(0, 0, w, h), 0.5, 5.0);
      path.arcTo(Rect.fromLTWH(w * 0.2, 0, w * 0.8, h), 5.5, -5.0, false);
      path.close();
      break;
    case ShapeType.hexagon:
      for (int i = 0; i < 6; i++) {
        final a = i * pi / 3;
        final x = w * 0.5 + w * 0.45 * cos(a);
        final y = h * 0.5 + h * 0.45 * sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      break;
    case ShapeType.pentagon:
      for (int i = 0; i < 5; i++) {
        final a = (i * 72 - 90) * pi / 180;
        final x = w * 0.5 + w * 0.45 * cos(a);
        final y = h * 0.5 + h * 0.45 * sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      break;
    case ShapeType.bunny:
      path.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.60), radius: w * 0.32));
      path.addOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.20), width: w * 0.14, height: h * 0.34));
      path.addOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.20), width: w * 0.14, height: h * 0.34));
      break;
    case ShapeType.bear:
      path.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.55), radius: w * 0.34));
      path.addOval(Rect.fromCircle(center: Offset(w * 0.26, h * 0.26), radius: w * 0.14));
      path.addOval(Rect.fromCircle(center: Offset(w * 0.74, h * 0.26), radius: w * 0.14));
      break;
    case ShapeType.fish:
      path.addOval(Rect.fromCenter(center: Offset(w * 0.42, h * 0.5), width: w * 0.58, height: h * 0.48));
      path.moveTo(w * 0.65, h * 0.5);
      path.lineTo(w * 0.95, h * 0.25);
      path.lineTo(w * 0.95, h * 0.75);
      path.close();
      break;
    case ShapeType.bird:
      path.addOval(Rect.fromCircle(center: Offset(w * 0.45, h * 0.5), radius: w * 0.32));
      path.moveTo(w * 0.70, h * 0.44);
      path.lineTo(w * 0.92, h * 0.50);
      path.lineTo(w * 0.70, h * 0.56);
      path.close();
      break;
    case ShapeType.cat:
      path.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.58), radius: w * 0.34));
      path.moveTo(w * 0.22, h * 0.40);
      path.lineTo(w * 0.28, h * 0.18);
      path.lineTo(w * 0.44, h * 0.32);
      path.close();
      path.moveTo(w * 0.78, h * 0.40);
      path.lineTo(w * 0.72, h * 0.18);
      path.lineTo(w * 0.56, h * 0.32);
      path.close();
      break;
  }
  return path;
}
