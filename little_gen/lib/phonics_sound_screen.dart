import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'music_manager.dart';
import 'phonics_game_dialog.dart';
import 'ad_manager.dart';

class PhonicsSoundScreen extends StatefulWidget {
  const PhonicsSoundScreen({super.key});

  @override
  State<PhonicsSoundScreen> createState() => _PhonicsSoundScreenState();
}

class _PhonicsSoundScreenState extends State<PhonicsSoundScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _letterBounceController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentIndex = 0;
  int _currentStep = 0; // 0: Letter, 1: Object, 2: "A is for Apple", 3: "Ah", 4: "Apple"
  bool _isSpeaking = false;
  Timer? _autoAdvanceTimer;
  late ConfettiController _confettiController;
  late AnimationController _mascotJumpController;

  final List<Map<String, String>> _alphabetData = [
    {"letter": "A", "word": "Apple", "phonics": "Ah", "image": "assets/images/apple.png", "audio": "A for apple .mp3"},
    {"letter": "B", "word": "Ball", "phonics": "Buh", "image": "assets/images/ball.png", "audio": "B is for Ball.mp3"},
    {"letter": "C", "word": "Cat", "phonics": "Cuh", "image": "assets/images/cat.png", "audio": "C is for cat.mp3"},
    {"letter": "D", "word": "Dog", "phonics": "Duh", "image": "assets/images/dog.png", "audio": "D is for Dog.mp3"},
    {"letter": "E", "word": "Elephant", "phonics": "Ehhh", "image": "assets/images/elephant.png", "audio": "E is for Elephants.mp3"},
    {"letter": "F", "word": "Fish", "phonics": "Fff", "image": "assets/images/fish.png", "audio": "F is for Fish!_F says… Fuh_Can you say Fuh.mp3"},
    {"letter": "G", "word": "Goat", "phonics": "Guh", "image": "assets/images/goat.png", "audio": "G is for Goat!_G says… Guh!_Can you say Guh_.mp3"},
    {"letter": "H", "word": "Hat", "phonics": "Hhh", "image": "assets/images/hat.png", "audio": "H is for Hat!_H says… Huh_Can you say Huh_.mp3"},
    {"letter": "I", "word": "Igloo", "phonics": "Ihhh", "image": "assets/images/igloo.png", "audio": "I is for Igloo!_I says… Ih!_Can you says Ih!.mp3"},
    {"letter": "J", "word": "Juice", "phonics": "Juh", "image": "assets/images/juice.png", "audio": "J is for Juice!_J says… Juh!_Can you say Juh_.mp3"},
    {"letter": "K", "word": "Kite", "phonics": "Kuh", "image": "assets/images/kite.png", "audio": "K is for Kite!_K says… Kuh!_Can you say Kuh_.mp3"},
    {"letter": "L", "word": "Lion", "phonics": "Lll", "image": "assets/images/lion.png", "audio": "L is for Lion!_L says… Luh!_Can you say Luh!.mp3"},
    {"letter": "M", "word": "Monkey", "phonics": "Mmm", "image": "assets/images/monkey.png", "audio": "M is for Monkey!_M says… Mmmm!_Can you say Mmmm_.mp3"},
    {"letter": "N", "word": "Nest", "phonics": "Nnn", "image": "assets/images/nest.png", "audio": "N is for Nest!_N says… Nnnn!_Can you say Nnnn_.mp3"},
    {"letter": "O", "word": "Orange", "phonics": "Ohhh", "image": "assets/images/orange.png", "audio": "O is for Orange!_O says… Ohhhh!_Can you say Ohhhh_.mp3"},
    {"letter": "P", "word": "Pig", "phonics": "Puh", "image": "assets/images/pig.png", "audio": "P is for Pig!_P says… Puh!_Can you say Puh_.mp3"},
    {"letter": "Q", "word": "Queen", "phonics": "Quh", "image": "assets/images/queen.png", "audio": "Q is for Queen!_Q says… Kwuh!_Can you say Kwuh_.mp3"},
    {"letter": "R", "word": "Rabbit", "phonics": "Rrr", "image": "assets/images/rabbit.png", "audio": "R is for Rabbit!_R says… Ruh!_Can you say Ruh.mp3"},
    {"letter": "S", "word": "Sun", "phonics": "Sss", "image": "assets/images/sun.png", "audio": "S is for Sun!_S says… Sss!_Can you say Sss_.mp3"},
    {"letter": "T", "word": "Tiger", "phonics": "Tuh", "image": "assets/images/tiger.png", "audio": "T is for Tiger!_T says… Tuh!_Can you say Tuh_.mp3"},
    {"letter": "U", "word": "Umbrella", "phonics": "Uhhh", "image": "assets/images/umbrella.png", "audio": "U is for Umbrella!_U says… Uh!_Can you say Uh_.mp3"},
    {"letter": "V", "word": "Van", "phonics": "Vvv", "image": "assets/images/van.png", "audio": "V is for Van!_V says… Vuh!_Can you say Vuh_.mp3"},
    {"letter": "W", "word": "Whale", "phonics": "Wuh", "image": "assets/images/whale.png", "audio": "W is for Whale!_W says… Wuh!_Can you say Wuh_.mp3"},
    {"letter": "X", "word": "Xylophone", "phonics": "Xks", "image": "assets/images/xylophone.png", "audio": "X is for Xylophone!_X says… Eks!_Can you say Eks_.mp3"},
    {"letter": "Y", "word": "Yo-yo", "phonics": "Yyy", "image": "assets/images/yoyo.png", "audio": "Y is for Yo-yo!_Y says… Yuh!_Can you say Yuh_.mp3"},
    {"letter": "Z", "word": "Zebra", "phonics": "Zzz", "image": "assets/images/zebra.png", "audio": "Z is for Zebra!_Z says… Zzz!_Can you say Zzz_.mp3"},
  ];

  final List<Color> _letterColors = [
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.pink.shade400,
    Colors.teal.shade400,
  ];

  @override
  void initState() {
    super.initState();
    
    MusicManager.playBgm('backgroud music 3.mp3');
    MusicManager.setVolume(0.2); // Lower volume in learning interface
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _letterBounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _mascotJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isSpeaking = false;
        _waveController.stop();
      });
      _onSpeechComplete();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFlow();
    });
  }

  void _startFlow() async {
    _autoAdvanceTimer?.cancel();
    setState(() {
      _currentStep = 0;
      _isSpeaking = false;
    });
    
    // Step 1: Giant letter is shown
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 2: Show object
    setState(() {
      _currentStep = 1;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 3: Play audio file
    _playAudio();
  }

  void _playAudio() async {
    setState(() {
      _currentStep = 2;
      _isSpeaking = true;
      _waveController.repeat(); // Start sound waves
    });
    final data = _alphabetData[_currentIndex];
    await MusicManager.playVoiceover(_audioPlayer, 'audio/${data['audio']}');
  }

  void _onSpeechComplete() async {
    setState(() {
      _currentStep = 4;
    });
    
    // If it's the last letter, play the completion voice
    if (_currentIndex == _alphabetData.length - 1) {
      await Future.delayed(const Duration(seconds: 1));
      _confettiController.play();
      _mascotJumpController.repeat(reverse: true);
      await MusicManager.playVoiceover(_audioPlayer, 'audio/Amazing writing!_You did it!.mp3');
      Future.delayed(const Duration(seconds: 4), () {
        _mascotJumpController.stop();
      });
    } else {
      // Auto-advance after 3 seconds
      _autoAdvanceTimer = Timer(const Duration(seconds: 3), () {
        _nextLetter();
      });
    }
  }

  void _nextLetter() async {
    _autoAdvanceTimer?.cancel();
    
    // Check if we just completed index 4 (E), 9 (J), or 14 (O)
    if (_currentIndex == 4 || _currentIndex == 9 || _currentIndex == 14) {
      final start = _currentIndex == 4 ? 0 : (_currentIndex == 9 ? 5 : 10);
      final learned = _alphabetData
          .sublist(start, _currentIndex + 1)
          .map((data) => data['letter']!)
          .toList();

      final gameCompleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PhonicsGameDialog(learnedLetters: learned),
      );

      if (gameCompleted == true && mounted) {
        if (_currentIndex < _alphabetData.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _startFlow();
        }
      }
    } else {
      if (_currentIndex < _alphabetData.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _startFlow();
      }
    }
  }

  void _prevLetter() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startFlow();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _letterBounceController.dispose();
    _autoAdvanceTimer?.cancel();
    _audioPlayer.dispose();
    _confettiController.dispose();
    _mascotJumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _alphabetData[_currentIndex];
    final letter = data['letter']!;
    final word = data['word']!;
    final phonics = data['phonics']!;
    final imagePath = data['image']!;
    
    final letterColor = _letterColors[_currentIndex % _letterColors.length];
    const bgColor = Color(0xFFD9F1FF); // Matches menu background for consistency

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // TOP: Large animated letter
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Giant Letter
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                              CurvedAnimation(
                                parent: _letterBounceController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Text(
                              letter,
                              style: GoogleFonts.nunito(
                                fontSize: 180,
                                fontWeight: FontWeight.w900,
                                color: letterColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 18,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // MIDDLE: Large object image
                  Expanded(
                    flex: 5, // Bigger flex for bigger image
                    child: AnimatedOpacity(
                      opacity: _currentStep >= 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 320, // Bigger image
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildObjectImage(imagePath, bgColor),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTTOM: Text
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          "$letter is for $word",
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedOpacity(
                          opacity: _currentStep >= 2 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            phonics,
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM BELOW: Play sound button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        if (!_isSpeaking) {
                          _startFlow();
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20,
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                          size: 45,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Mascots
              Positioned(
                bottom: 10,
                right: 10,
                child: SlideTransition(
                  position: _mascotJumpController.drive(
                    Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.5))
                        .chain(CurveTween(curve: Curves.elasticOut)),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset(
                      'assets/lottie/mascot.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),

              // Exit Button
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF6C63FF), size: 24),
                    onPressed: () {
                      AdManager.showInterstitial(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Previous Letter Button
              Positioned(
                top: 10,
                left: 70,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6C63FF), size: 20),
                    onPressed: _prevLetter,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6C63FF), size: 24),
                    onPressed: _nextLetter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectImage(String path, Color blendColor) {
    // Mapping for emoji fallback if image is missing
    final Map<String, String> emojiMap = {
      "Apple": "🍎", "Ball": "⚽", "Cat": "🐱", "Dog": "🐶", "Elephant": "🐘",
      "Fish": "🐟", "Goat": "🐐", "Hat": "🎩", "Igloo": "❄️", "Juice": "🧃",
      "Kite": "🪁", "Lion": "🦁", "Monkey": "🐒", "Nest": "🪺", "Orange": "🍊",
      "Pig": "🐷", "Queen": "👑", "Rabbit": "🐰", "Sun": "☀️", "Tiger": "🐯",
      "Umbrella": "☂️", "Van": "🚐", "Whale": "🐋", "Xylophone": "🎹", "Yo-yo": "🪀", "Zebra": "🦓"
    };

    final word = _alphabetData[_currentIndex]['word']!;

    return Image.asset(
      path,
      fit: BoxFit.contain,
      color: blendColor,
      colorBlendMode: BlendMode.multiply, // Blends white background into screen color
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            emojiMap[word] ?? "❓",
            style: const TextStyle(fontSize: 160),
          ),
        );
      },
    );
  }
}
