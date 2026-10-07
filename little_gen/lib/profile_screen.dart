import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_rewards_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entranceController;
  
  String _currentAvatar = "🦁";
  List<String> get _avatars => FirebaseRewardsManager.unlockedEmojis;

  @override
  void initState() {
    super.initState();
    
    // Floating animation for the main avatar
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Entrance animation for the cards
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
    
    FirebaseRewardsManager.rewardsNotifier.addListener(_onRewardsUpdated);
  }

  @override
  void dispose() {
    FirebaseRewardsManager.rewardsNotifier.removeListener(_onRewardsUpdated);
    _floatController.dispose();
    _entranceController.dispose();
    super.dispose();
  }
  
  void _onRewardsUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD9F1FF), Color(0xFFFFF7CC), Colors.white],
            stops: [0.0, 0.5, 1.0],
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11153B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      "My Profile",
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
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Main Animated Avatar
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 10 * math.sin(_floatController.value * math.pi * 2)),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF6C63FF), width: 4),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Text(
                                _currentAvatar,
                                key: ValueKey<String>(_currentAvatar),
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Name
                      Text(
                        "Little Learner",
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF11153B),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Choose Avatar Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Choose your buddy!",
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B).withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Avatar Selection List
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _avatars.length,
                          itemBuilder: (context, index) {
                            final avatar = _avatars[index];
                            final isSelected = avatar == _currentAvatar;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentAvatar = avatar;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 70,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                  ],
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    avatar,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _SlideInCard(
                              animation: _entranceController,
                              interval: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
                              child: _StatCard(
                                title: "Stars Earned",
                                value: "${FirebaseRewardsManager.starsEarned} 🌟",
                                color: const Color(0xFFFFF7CC),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SlideInCard(
                              animation: _entranceController,
                              interval: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
                              child: _StatCard(
                                title: "Current Level",
                                value: "Level 5 🏆",
                                color: const Color(0xFFE2F6E1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SlideInCard(
                              animation: _entranceController,
                              interval: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
                              child: _StatCard(
                                title: "Words Learned",
                                value: "45 📚",
                                color: const Color(0xFFFFE5E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF11153B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF11153B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideInCard extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const _SlideInCard({
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: interval);
        final slideValue = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).evaluate(curvedAnimation);
        final fadeValue = Tween<double>(begin: 0.0, end: 1.0).evaluate(curvedAnimation);

        return FractionalTranslation(
          translation: slideValue,
          child: Opacity(
            opacity: fadeValue,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
