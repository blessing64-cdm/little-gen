import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'build_the_word_screen.dart';
import 'ad_manager.dart';

class BuildTheWordMenuScreen extends StatelessWidget {
  const BuildTheWordMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEAD9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: const Color(0xFF11153B)),
                      onPressed: () {
                        AdManager.showInterstitial(context);
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    Text(
                      "Build the Word!",
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Choose your challenge!",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF11153B).withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Menu Grid
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _LevelCard(
                      title: "2 Letters",
                      color: const Color(0xFFFFE5E5),
                      icon: "🅰️🅱️",
                      onTap: () => _navigateToGame(context, 2),
                    ),
                    _LevelCard(
                      title: "3 Letters",
                      color: const Color(0xFFE2F6E1),
                      icon: "🐱🐶",
                      onTap: () => _navigateToGame(context, 3),
                    ),
                    _LevelCard(
                      title: "4 Letters",
                      color: const Color(0xFFFFF7CC),
                      icon: "🦁🐸",
                      onTap: () => _navigateToGame(context, 4),
                    ),
                    _LevelCard(
                      title: "5 Letters",
                      color: const Color(0xFFD9F1FF),
                      icon: "🦓🐍",
                      onTap: () => _navigateToGame(context, 5),
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

  void _navigateToGame(BuildContext context, int wordLength) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildTheWordScreen(wordLength: wordLength),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF11153B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
