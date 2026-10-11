import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'home_menu_screen.dart';
import 'music_manager.dart';
import 'firebase_rewards_manager.dart';
import 'ad_manager.dart';
import 'notification_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'billing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Rewards Manager (SharedPreferences)
  try {
    await FirebaseRewardsManager.initialize();
  } catch (e) {
    debugPrint("RewardsManager init note: $e");
  }
  
  // Initialize Billing Service (SharedPreferences & Amazon IAP)
  try {
    await BillingService.instance.initializeBilling();
  } catch (e) {
    debugPrint("BillingService init note: $e");
  }

  // Initialize Ads (no-op)
  try {
    await AdManager.initialize();
  } catch (e) {
    debugPrint("AdManager init note: $e");
  }
  
  // Initialize local notifications
  try {
    if (!kIsWeb) {
      await NotificationManager.initialize();
    }
  } catch (e) {
    debugPrint("NotificationManager init note: $e");
  }
  
  try {
    MusicManager.init();
  } catch (e) {
    debugPrint("MusicManager init note: $e");
  }
  runApp(const LittleGenApp());
}

class LittleGenApp extends StatelessWidget {
  const LittleGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BillingService>.value(
      value: BillingService.instance,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Little Gen',
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(),
        ),
        home: const SplashAnimatedScreen(),
      ),
    );
  }
}

class SplashAnimatedScreen extends StatefulWidget {
  const SplashAnimatedScreen({super.key});

  @override
  State<SplashAnimatedScreen> createState() => _SplashAnimatedScreenState();
}

class _SplashAnimatedScreenState extends State<SplashAnimatedScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    
    MusicManager.playBgm('backgroud music 1.mp3');
    
    _videoController = VideoPlayerController.asset('assets/animate_this_splash_screen_202605120859.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController.setLooping(true);
          _videoController.play();
        }
      }).catchError((e) {
        debugPrint("Splash video init error: $e");
      });
    
    // Play splash screen voice with ducking after a delay
    Future.delayed(const Duration(milliseconds: 800), () async {
      try {
        await MusicManager.playVoiceover(_audioPlayer, 'audio/splash screen voice .mp3');
      } catch (e) {
        debugPrint("Error playing splash voice: $e");
      }
    });
    
    // Cloud and Star slow drift animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Star pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // ABC idle bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Button fade-up animation (Option 2)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Delay start button appearance
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _fadeController.forward();
    });
  }



  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Background or Loading UI
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Lottie.asset('assets/lottie/mascot.json'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Preparing Adventure...",
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF11153B)),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mascot at bottom left (only show after video initialized to avoid overlap with loading UI)
          if (_isVideoInitialized)
            Positioned(
              bottom: 20,
              left: 20,
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -5 + (_bounceController.value * 10)),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 120, // Reduced size
                  height: 120,
                  child: Lottie.asset(
                    'assets/lottie/mascot.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

          // Start Adventure Button at bottom center
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11153B),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 60),
                      elevation: 8,
                      shadowColor: const Color(0xFF11153B).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeMenuScreen()),
                      );
                    },
                    child: const Text(
                      "Start Adventure",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
