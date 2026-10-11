import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'ad_manager.dart';
import 'firebase_rewards_manager.dart';

class CountingItem {
  final int id;
  final Offset position;
  final Color color;
  bool isTapped;
  int? orderNumber;

  CountingItem({
    required this.id,
    required this.position,
    required this.color,
    this.isTapped = false,
    this.orderNumber,
  });
}

class CountingNumbersScreen extends StatefulWidget {
  const CountingNumbersScreen({super.key});

  @override
  State<CountingNumbersScreen> createState() => _CountingNumbersScreenState();
}

class _CountingNumbersScreenState extends State<CountingNumbersScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // Secondary player for balloon taps

  final List<Color> _balloonColors = const [
    Color(0xFFFF5252), // Coral Red
    Color(0xFFFFB300), // Amber
    Color(0xFF42A5F5), // Sky Blue
    Color(0xFF66BB6A), // Leaf Green
    Color(0xFFAB47BC), // Violet
    Color(0xFFFF4081), // Pink
  ];

  final List<String> _numberWords = const [
    "Zero", "One!", "Two!", "Three!", "Four!", "Five!", "Six!", "Seven!", "Eight!", "Nine!", "Ten!"
  ];

  late int _targetCount;
  List<CountingItem> _items = [];
  int _currentTappedCount = 0;
  List<int> _answerChoices = [];
  bool _isSuccess = false;
  int? _selectedAnswer;
  bool _isSpeaking = false;
  String? _unlockedRewardEmoji;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _setupRound();
  }

  Future<void> _playAudio(String assetPath, {AudioPlayer? player}) async {
    final ap = player ?? _audioPlayer;
    try {
      await ap.stop();
      await ap.play(AssetSource(assetPath));
    } catch (_) {}
  }

  void _setupRound() {
    final random = Random();
    // Count between 2 and 5 for toddlers
    _targetCount = 2 + random.nextInt(4); // 2, 3, 4, or 5
    _currentTappedCount = 0;
    _isSuccess = false;
    _selectedAnswer = null;
    _unlockedRewardEmoji = null;

    // Generate scatter positions for balloons in center area
    _items = [];
    final availableColors = List.from(_balloonColors)..shuffle();
    
    // Distribute nicely across grid slots with slight randomness
    final slots = [
      const Offset(0.25, 0.25),
      const Offset(0.75, 0.25),
      const Offset(0.50, 0.50),
      const Offset(0.25, 0.72),
      const Offset(0.75, 0.72),
    ];
    slots.shuffle();

    for (int i = 0; i < _targetCount; i++) {
      final baseSlot = slots[i % slots.length];
      final jitterX = (random.nextDouble() - 0.5) * 0.08;
      final jitterY = (random.nextDouble() - 0.5) * 0.08;
      _items.add(CountingItem(
        id: i,
        position: Offset(
          (baseSlot.dx + jitterX).clamp(0.18, 0.82),
          (baseSlot.dy + jitterY).clamp(0.18, 0.82),
        ),
        color: availableColors[i % availableColors.length],
      ));
    }

    // Generate 3 answer choices including the correct target count
    final Set<int> choices = {_targetCount};
    while (choices.length < 3) {
      final candidate = 1 + random.nextInt(5);
      choices.add(candidate);
    }
    _answerChoices = choices.toList()..sort();

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playPrompt();
    });
  }

  Future<void> _playPrompt() async {
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    await _playAudio("Let's count! How many balloons do you see.mp3");
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _onItemTapped(CountingItem item) async {
    if (item.isTapped || _isSuccess) return;

    setState(() {
      _currentTappedCount++;
      item.isTapped = true;
      item.orderNumber = _currentTappedCount;
    });

    // Play the counting audio file — contains "One!, Two!, Three!, Four!, Five!"
    // We seek to the approximate position for each number (~1.6s per number)
    if (_currentTappedCount >= 1 && _currentTappedCount <= 5) {
      final seekMs = (_currentTappedCount - 1) * 1650; // approx offset per word
      try {
        await _sfxPlayer.stop();
        await _sfxPlayer.play(AssetSource("One!, Two!, Three!, Four!, Five!.mp3"));
        if (seekMs > 0) {
          await _sfxPlayer.seek(Duration(milliseconds: seekMs));
        }
      } catch (_) {}
    }
  }

  Future<void> _checkAnswer(int choice) async {
    if (_isSuccess) return;

    setState(() {
      _selectedAnswer = choice;
    });

    if (choice == _targetCount) {
      // Correct!
      final newEmoji = await FirebaseRewardsManager.unlockRandomEmoji();
      await FirebaseRewardsManager.addStars(1);
      await FirebaseRewardsManager.recordNumberCounted(1);
      setState(() {
        _isSuccess = true;
        _unlockedRewardEmoji = newEmoji ?? "⭐";
      });

      _celebrationController.forward(from: 0.0);
      await _playAudio('Yay! Great job!.mp3');

      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;

      _setupRound();
    } else {
      // Wrong choice: play oops audio
      await _playAudio('Oops! Let\'s try that one again!.mp3');
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _sfxPlayer.stop();
    _audioPlayer.dispose();
    _sfxPlayer.dispose();
    _celebrationController.dispose();
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
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
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
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF006064), size: 22),
                        onPressed: () {
                          AdManager.showInterstitial(context);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Spacer(),
                    // Large Speaker Audio Button
                    GestureDetector(
                      onTap: _playPrompt,
                      child: AnimatedScale(
                        scale: _isSpeaking ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isSpeaking ? const Color(0xFF00838F) : const Color(0xFF00ACC1),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00ACC1).withValues(alpha: 0.35),
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
                                _isSpeaking ? "Speaking..." : "Listen",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance back button
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Short Text
              Text(
                "Count the Balloons!",
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap each balloon to count, then tap the number below!",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00695C).withValues(alpha: 0.8),
                ),
              ),

              // Middle Item Placement Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final areaWidth = constraints.maxWidth;
                    final areaHeight = constraints.maxHeight;

                    return Stack(
                      children: [
                        // Floating balloons
                        for (final item in _items)
                          Positioned(
                            left: (item.position.dx * areaWidth) - 45,
                            top: (item.position.dy * areaHeight) - 55,
                            child: GestureDetector(
                              onTap: () => _onItemTapped(item),
                              child: _buildBalloon(item),
                            ),
                          ),

                        // Success Celebration mascot
                        if (_isSuccess)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 25,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset(
                                    'assets/lottie/mascot.json',
                                    width: 140,
                                    height: 140,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Yay! You Counted $_targetCount!",
                                    style: GoogleFonts.nunito(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFE65100),
                                    ),
                                  ),
                                  if (_unlockedRewardEmoji != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _unlockedRewardEmoji!,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Reward Badge Earned!",
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Large Answer Buttons (at least 15% of screen height)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      "How many balloons?",
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _answerChoices.map((choice) {
                        final isSelected = _selectedAnswer == choice;
                        final isCorrect = _isSuccess && choice == _targetCount;

                        Color btnColor = const Color(0xFF00ACC1);
                        if (isSelected && !isCorrect) {
                          btnColor = const Color(0xFFFF7043);
                        } else if (isCorrect) {
                          btnColor = const Color(0xFF4CAF50);
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SizedBox(
                              // Covers at least 15% screen height (~100px)
                              height: 105,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnColor,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  shadowColor: btnColor.withValues(alpha: 0.45),
                                ),
                                onPressed: () => _checkAnswer(choice),
                                child: Text(
                                  "$choice",
                                  style: GoogleFonts.nunito(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildBalloon(CountingItem item) {
    final scale = item.isTapped ? 1.15 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Balloon Body with string
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 94,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.45),
                    radius: 0.8,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      item.color,
                      item.color.withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: item.isTapped
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${item.orderNumber}",
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: item.color,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              // Little knot
              Container(
                width: 12,
                height: 8,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // String
              Container(
                width: 2.5,
                height: 24,
                color: Colors.black26,
              ),
            ],
          ),

          // Tap Tracking Indicator Badge above balloon
          if (item.isTapped && item.orderNumber != null)
            Positioned(
              top: -24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  "#${item.orderNumber}",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
