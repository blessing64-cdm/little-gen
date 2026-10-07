import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'phonics_sound_screen.dart';
import 'letter_tracing_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'music_manager.dart';

class ABCLearningMethodsScreen extends StatefulWidget {
  const ABCLearningMethodsScreen({super.key});

  @override
  State<ABCLearningMethodsScreen> createState() => _ABCLearningMethodsScreenState();
}

class _ABCLearningMethodsScreenState extends State<ABCLearningMethodsScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    MusicManager.playBgm('backgroud music 2.mp3');
    
    // Play greeting voice after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      MusicManager.playVoiceover(_audioPlayer, 'audio/Menu voice .mp3');
    });
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildFloatingShape({
    required double top,
    required double left,
    required double size,
    required Color color,
    required Widget shape,
    double speed = 1.0,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final offset = math.sin(_floatController.value * 2 * math.pi * speed) * 12;
        return Positioned(
          top: top + offset,
          left: left + offset,
          child: Opacity(
            opacity: 0.4,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SizedBox(
                width: size,
                height: size,
                child: shape,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 48) / 3; // 48 horizontal padding, 48 total spacing (24 * 2)

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              // Lottie Background
              Positioned.fill(
                child: Lottie.asset(
                  'assets/lottie/background.json',
                  fit: BoxFit.cover,
                ),
              ),
              // Subtle Cloud Hints
              Positioned(
                top: 50,
                left: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 150,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -30,
                child: Opacity(
                  opacity: 0.15,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Shapes
              _buildFloatingShape(
                top: 80,
                left: screenWidth - 60,
                size: 40,
                color: const Color(0xFFFF7FC3),
                shape: Container(decoration: const BoxDecoration(color: Color(0xFFFF7FC3), shape: BoxShape.circle)),
                speed: 1.2,
              ),
              _buildFloatingShape(
                top: 250,
                left: 20,
                size: 50,
                color: const Color(0xFFB884FF),
                shape: Container(color: const Color(0xFFB884FF)),
                speed: 0.8,
              ),
              _buildFloatingShape(
                top: 400,
                left: screenWidth - 100,
                size: 60,
                color: const Color(0xFF67D7FF),
                shape: Container(decoration: const BoxDecoration(color: Color(0xFF67D7FF), shape: BoxShape.circle)),
                speed: 1.0,
              ),

              // Greeting Mascot and Text at the bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Hi friends, let's learn!",
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16153A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: Lottie.asset(
                        'assets/lottie/mascot.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30), // Reduced top padding to fit grid
                    
                    // Mascot and Title overlapping
                    SizedBox(
                      height: 280, // Height for mascot + text area
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 180, // Position text
                            left: 0,
                            right: 0,
                            child: Text(
                              "How do you want to learn?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 32,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF16153A),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Lottie.asset(
                              'assets/mascot.lottie.json',
                              width: 250, // Very big
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Grid of Cards
                    SizedBox(
                      height: (cardWidth * 2) + 24, // Height for 2 rows plus spacing
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLearningCard(
                            title: "Phonics\nSounds",
                            color: const Color(0xFF2897FF),
                            icon: Icons.volume_up,
                            width: cardWidth,
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/phonics voice .mp3'));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PhonicsSoundScreen()),
                              );
                            },
                          ),
                          _buildLearningCard(
                            title: "Trace &\nWrite",
                            color: const Color(0xFF49D84F),
                            icon: Icons.edit,
                            width: cardWidth,
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/Trace & write .mp3'));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LetterTracingScreen()),
                              );
                            },
                          ),
                          _buildLearningCard(
                            title: "ABC\nSong",
                            color: const Color(0xFFFF4FA2),
                            icon: Icons.music_note,
                            width: cardWidth,
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/ABC song .mp3'));
                            },
                          ),
                          _buildLearningCard(
                            title: "Story\nTime",
                            color: const Color(0xFF9C58FF),
                            icon: Icons.book,
                            width: cardWidth,
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/story time .mp3'));
                            },
                          ),
                          _buildLearningCard(
                            title: "Sign\nLanguage",
                            color: const Color(0xFF24D5D5),
                            icon: Icons.back_hand,
                            width: cardWidth,
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/letter signs.mp3'));
                            },
                          ),
                          _buildLearningCard(
                            title: "Word\nBuilder",
                            color: const Color(0xFFFFC107),
                            icon: Icons.category,
                            width: cardWidth,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningCard({
    required String title,
    required Color color,
    required IconData icon,
    required double width,
    required VoidCallback onTap,
  }) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: width,
        height: width, // Square cards
        decoration: BoxDecoration(
          color: color, // Solid bold color
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glossy Highlight
            Positioned(
              top: -width * 0.2,
              left: -width * 0.2,
              child: Container(
                width: width * 0.6,
                height: width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
