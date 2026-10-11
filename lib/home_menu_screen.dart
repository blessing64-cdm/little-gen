import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'phonics_sound_screen.dart';
import 'letter_tracing_screen.dart';
import 'spelling_a_z_screen.dart';
import 'abc_song_screen.dart';
import 'story_time_screen.dart';
import 'build_the_word_menu_screen.dart';
import 'my_progress_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';
import 'music_manager.dart';
import 'firebase_rewards_manager.dart';
import 'surprise_box_dialog.dart';
import 'parental_time_manager.dart';
import 'time_limit_lock_screen.dart';
import 'ad_manager.dart';
import 'notification_manager.dart';
import 'create_profile_screen.dart';
import 'shape_matching_screen.dart';
import 'coloring_book_screen.dart';
import 'counting_numbers_screen.dart';
import 'parent_gate_dialog.dart';
import 'billing_service.dart';
import 'paywall_screen.dart';
import 'package:provider/provider.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatController;
  late AnimationController _textPulseController;
  late Animation<double> _textPulseAnimation;
  int _currentNavIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openFeature(BuildContext context, String featureName, Widget screen, {bool isFree = false, String? voiceoverAsset}) {
    if (voiceoverAsset != null) {
      MusicManager.playVoiceover(_audioPlayer, voiceoverAsset);
    }
    
    final isUnlocked = BillingService.instance.isPremiumUnlocked;
    
    if (isFree || isUnlocked) {
      if (!isFree) {
        AdManager.showInterstitial(context);
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      ParentGateDialog.show(
        context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaywallScreen(nextScreen: screen),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    
    MusicManager.playBgm('backgroud music 2.mp3');
    MusicManager.setVolume(0.5);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      MusicManager.playVoiceover(_audioPlayer, 'audio/Menu voice .mp3');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRewards();
    });
    
    // Parental Screen Time setup
    ParentalTimeManager.initialize().then((_) {
      if (mounted) {
        if (ParentalTimeManager.isLocked) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TimeLimitLockScreen()),
            (route) => false,
          );
        } else {
          ParentalTimeManager.startMonitoring(context);
        }
      }
    });

    // Show app entry interstitial ad after splash screen
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        AdManager.showInterstitial(context);
      }
    });
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _textPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _textPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _textPulseController, curve: Curves.easeInOut),
    );

    // Register widgets binding observer for local notifications
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ParentalTimeManager.stopMonitoring();
    _floatController.dispose();
    _textPulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // User minimized/left the app: schedule background reminders
      NotificationManager.scheduleBackgroundReminders();
    } else if (state == AppLifecycleState.resumed) {
      // User returned to the app: clear pending notification triggers
      NotificationManager.cancelAllNotifications();
    }
  }

  Future<void> _checkRewards() async {
    final shouldShow = await FirebaseRewardsManager.shouldShowReward();
    if (shouldShow && mounted) {
      await FirebaseRewardsManager.updateLastRewardTime();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SurpriseBoxDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background Lottie (Preserved)
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/Untitled file.json',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row with Both Mascots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu & Parents Gate Buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: Color(0xFF6C63FF), size: 28),
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Parent Gate quick button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  ParentGateDialog.show(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_rounded, color: Color(0xFF6C63FF), size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Parents",
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF11153B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Mascots Container
                      Row(
                        children: [
                          // Jumping Mascot
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Lottie.asset(
                              'assets/mascot.lottie.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Winking Mascot
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: Lottie.asset(
                              'assets/lottie/mascot.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Greeting Section (Smaller and moved up)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaleTransition(
                        scale: _textPulseAnimation,
                        child: Row(
                          children: [
                            Text(
                              "Hi, Little Learner!",
                              style: GoogleFonts.nunito(
                                fontSize: 28, // Smaller
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF11153B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "👋",
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        "What do you want to learn today?",
                        style: GoogleFonts.nunito(
                          fontSize: 16, // Smaller
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF11153B).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15), // Less space to move everything up

                // Menu Grid
                Expanded(
                  child: Consumer<BillingService>(
                    builder: (context, billing, child) {
                      final isUnlocked = billing.isPremiumUnlocked;
                      return GridView.count(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.88,
                        children: [
                          _MenuCard(
                            title: "Phonics Sounds",
                            color: const Color(0xFFE5DEFF),
                            textColor: const Color(0xFF4A148C),
                            imagePath: "assets/images/menu_phonics.png",
                            animationDelay: 0,
                            isLocked: false,
                            onTap: () {
                              _openFeature(
                                context,
                                "Phonics Sounds",
                                const PhonicsSoundScreen(),
                                isFree: true,
                                voiceoverAsset: 'audio/phonics voice .mp3',
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Trace & Write",
                            color: const Color(0xFFE2F6E1),
                            textColor: const Color(0xFF4E342E),
                            imagePath: "assets/images/menu_trace.png",
                            animationDelay: 200,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "Trace & Write",
                                const LetterTracingScreen(),
                                voiceoverAsset: 'audio/Trace & write .mp3',
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Spelling A to Z",
                            color: const Color(0xFFD9F1FF),
                            textColor: const Color(0xFF0D47A1),
                            imagePath: "assets/images/menu_animal_spelling.png",
                            animationDelay: 400,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "Spelling A to Z",
                                const SpellingAZScreen(),
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Build the Word",
                            color: const Color(0xFFFFEAD9),
                            textColor: const Color(0xFF5D4037),
                            imagePath: "assets/images/menu_blocks.png",
                            animationDelay: 600,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "Build the Word",
                                const BuildTheWordMenuScreen(),
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Story Time",
                            color: const Color(0xFFFFE5E5),
                            textColor: const Color(0xFF8B0000),
                            imagePath: "assets/images/menu_story.png",
                            animationDelay: 800,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "Story Time",
                                const StoryTimeScreen(),
                              );
                            },
                          ),
                          _MenuCard(
                            title: "ABC Song",
                            color: const Color(0xFFFFF7CC),
                            textColor: const Color(0xFFBF360C),
                            imagePath: "assets/images/menu_song.png",
                            animationDelay: 1000,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "ABC Song",
                                const ABCSongScreen(),
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Counting Numbers",
                            color: const Color(0xFFE0F7FA),
                            textColor: const Color(0xFF006064),
                            imagePath: "assets/images/menu_numbers.png",
                            animationDelay: 1200,
                            isLocked: false,
                            onTap: () {
                              _openFeature(
                                context,
                                "Counting Numbers",
                                CountingNumbersScreen(),
                                isFree: true,
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Shape Matching",
                            color: const Color(0xFFFCE4EC),
                            textColor: const Color(0xFF880E4F),
                            imagePath: "assets/images/menu_shapes.png",
                            animationDelay: 1400,
                            isLocked: !isUnlocked,
                            onTap: () {
                              _openFeature(
                                context,
                                "Shape Matching",
                                const ShapeMatchingScreen(),
                              );
                            },
                          ),
                          _MenuCard(
                            title: "Coloring Book",
                            color: const Color(0xFFFFF3E0),
                            textColor: const Color(0xFFE65100),
                            imagePath: "assets/images/menu_coloring.png",
                            animationDelay: 1600,
                            isLocked: false,
                            onTap: () {
                              _openFeature(
                                context,
                                "Coloring Book",
                                const ColoringBookScreen(),
                                isFree: true,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF6C63FF), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Parents Area",
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF11153B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Protected by Adult Math Lock",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6C63FF)),
              title: Text(
                "Parental Controls",
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF11153B),
                ),
              ),
              subtitle: Text(
                "All settings, screen limits & safety",
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
              onTap: () {
                Navigator.pop(context); // Close drawer
                ParentGateDialog.show(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6C63FF)),
              title: Text(
                "Child Profile",
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF11153B),
                ),
              ),
              subtitle: Text(
                "Manage child name, age & avatar",
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final result = await ParentGateDialog.show(context);
                if (result == true && context.mounted) {
                  if (!FirebaseRewardsManager.isProfileCreated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateProfileScreen(
                          nextScreen: ProfileScreen(),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }
                }
              },
            ),
            Consumer<BillingService>(
              builder: (context, billing, child) {
                return ListTile(
                  leading: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                  title: Text(
                    billing.isPremiumUnlocked ? "Full Version Unlocked 🎉" : "Unlock Full Version 👑",
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF11153B),
                    ),
                  ),
                  subtitle: Text(
                    billing.isPremiumUnlocked
                        ? "Thank you for supporting Little Gen!"
                        : "Unlock 6 extra learning activities",
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await ParentGateDialog.show(context);
                    if (result == true && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.timer_outlined, color: Color(0xFF6C63FF)),
              title: Text(
                "Screen Time Limit",
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF11153B),
                ),
              ),
              subtitle: Text(
                "Daily play timer & breaks",
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final result = await ParentGateDialog.show(context);
                if (result == true && context.mounted) {
                  _showTimeLimitSettings(context);
                }
              },
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                "Background Music",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF11153B),
                ),
              ),
              value: MusicManager.isBgmEnabled,
              activeColor: const Color(0xFF6C63FF),
              onChanged: (value) {
                setState(() {
                  MusicManager.isBgmEnabled = value;
                  if (value) {
                    MusicManager.resumeBgm();
                  } else {
                    MusicManager.stopBgm();
                  }
                });
              },
            ),
            SwitchListTile(
              title: Text(
                "Voiceover",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF11153B),
                ),
              ),
              value: MusicManager.isVoiceoverEnabled,
              activeColor: const Color(0xFF6C63FF),
              onChanged: (value) {
                setState(() {
                  MusicManager.isVoiceoverEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeLimitSettings(BuildContext context) {
    int selectedMinutes = ParentalTimeManager.screenTimeLimitMinutes;
    final options = [0, 1, 5, 15, 30, 45, 60];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text(
                "Screen Time Limit 🕒",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: const Color(0xFF11153B)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set session usage time limits. Once reached, the app shuts down and enters a 30-minute break.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: selectedMinutes,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                    items: options.map((mins) {
                      final label = mins == 0 ? "Disabled" : "$mins Minutes";
                      return DropdownMenuItem<int>(
                        value: mins,
                        child: Text(
                          label,
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedMinutes = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49D84F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    ParentalTimeManager.saveSettings(selectedMinutes);
                    Navigator.pop(context);
                    
                    // Show confirmation SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedMinutes == 0 
                            ? "Screen time limits disabled!" 
                            : "Screen time limit set to $selectedMinutes minutes!",
                          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF49D84F),
                      ),
                    );
                  },
                  child: Text(
                    "Save Settings",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildNavItem(0, Icons.home_rounded, "Home")),
          Expanded(child: _buildNavItem(1, Icons.bar_chart_rounded, "My Progress")),
          Expanded(child: _buildNavItem(2, Icons.stars_rounded, "Rewards")),
          Expanded(child: _buildNavItem(3, Icons.person_rounded, "Profile")),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 0) return; // Already on home
        
        // Show ad before navigating to bottom nav screens
        AdManager.showInterstitial(context);

        if (!FirebaseRewardsManager.isProfileCreated) {
          Widget nextScreen;
          if (index == 1) {
            nextScreen = const MyProgressScreen();
          } else if (index == 2) {
            nextScreen = const RewardsScreen();
          } else {
            nextScreen = const ProfileScreen();
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateProfileScreen(nextScreen: nextScreen)),
          );
          return;
        }

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProgressScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RewardsScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 36,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF7E7E92),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF7E7E92),
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final String imagePath;
  final int animationDelay;
  final VoidCallback onTap;
  final bool isLocked;

  const _MenuCard({
    required this.title,
    required this.color,
    required this.textColor,
    required this.imagePath,
    required this.animationDelay,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BreathingAnimatedButton(
      delay: animationDelay,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            "🎨",
                            style: TextStyle(fontSize: 44),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreathingAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final int delay;
  
  const _BreathingAnimatedButton({
    required this.child, 
    required this.onTap,
    required this.delay,
  });

  @override
  State<_BreathingAnimatedButton> createState() => _BreathingAnimatedButtonState();
}

class _BreathingAnimatedButtonState extends State<_BreathingAnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.stop(),
      onTapUp: (_) {
        _controller.reverse().then((_) {
          if (mounted) _controller.repeat(reverse: true);
        });
      },
      onTapCancel: () {
        if (mounted) _controller.repeat(reverse: true);
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
