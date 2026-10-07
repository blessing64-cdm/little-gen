import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'music_manager.dart';
import 'tracing_game_dialog.dart';
import 'ad_manager.dart';

class LetterTracingScreen extends StatefulWidget {
  const LetterTracingScreen({super.key});

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> with TickerProviderStateMixin {
  bool isUppercase = true;
  String currentLetter = 'A';
  // Stores all drawn points. null = pen lift (stroke separator)
  List<Offset?> points = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _dragPlayer = AudioPlayer();
  Color selectedColor = Colors.blue;
  bool isFilled = false;
  final ScrollController _scrollController = ScrollController();

  int _currentStrokeIndex = 0;
  late AnimationController _guideController;
  late Animation<double> _guideAnimation;
  late ConfettiController _confettiController;
  late AnimationController _mascotJumpController;

  // --- Sequential Tracing State ---
  // Index of the next path waypoint the finger needs to reach
  int _nextTargetIndex = 0;
  // Whether the current active gesture has successfully started near the stroke's first waypoint
  bool _gestureStartedOnStroke = false;
  // Whether the current active gesture completed the full stroke
  bool _currentGestureCompleted = false;
  // Snapshot of points.length at the start of the current gesture (for rollback)
  int _rollbackLength = 0;
  // Canvas size captured during layout for coordinate mapping
  Size _canvasSize = Size.zero;

  // Dynamic backgrounds for each letter
  final Map<String, List<Color>> letterBackgrounds = {
    'A': [Color(0xFFFFE58A), Color(0xFFFFD95F)], // Apple/Garden
    'B': [Color(0xFFA1FFCE), Color(0xFFFAFFD1)], // Ball/Classroom
    'C': [Color(0xFFE0C3FC), Color(0xFF8EC5FC)], // Cat/Playroom
    'D': [Color(0xFFFF9A8B), Color(0xFFFF6A88)], // Dog/Park
    'E': [Color(0xFF64E8DE), Color(0xFF82BBFF)], // Elephant/Zoo
    'F': [Color(0xFFFFE29F), Color(0xFFFFA99F)], // Fish/Ocean
    'G': [Color(0xFF86E3CE), Color(0xFFD0E6A5)], // Goat/Grass
    'H': [Color(0xFFFFB6C1), Color(0xFFFF69B4)], // Hat/Pink
    'I': [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], // Igloo/Ice
    'J': [Color(0xFFFFF9C4), Color(0xFFFFF176)], // Juice/Yellow
    'K': [Color(0xFFFFCCBC), Color(0xFFFFAB91)], // Kite/Orange
    'L': [Color(0xFFF1F8E9), Color(0xFFDCEDC8)], // Lion/Savanna
    'M': [Color(0xFFE1BEE7), Color(0xFFCE93D8)], // Monkey/Jungle
    'N': [Color(0xFFF5F5F5), Color(0xFFEEEEEE)], // Nest/Neutral
    'O': [Color(0xFFFFE0B2), Color(0xFFFFB74D)], // Orange/Bright
    'P': [Color(0xFFF8BBD0), Color(0xFFF48FB1)], // Pig/Soft Pink
    'Q': [Color(0xFFD1C4E9), Color(0xFFB39DDB)], // Queen/Royal
    'R': [Color(0xFFFFCDD2), Color(0xFFEF9A9A)], // Rabbit/Soft Red
    'S': [Color(0xFFFFF9C4), Color(0xFFFFF59D)], // Sun/Golden
    'T': [Color(0xFFB2DFDB), Color(0xFF80CBC4)], // Tiger/Teal
    'U': [Color(0xFFE1F5FE), Color(0xFFB3E5FC)], // Umbrella/Blue
    'V': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)], // Van/Violet
    'W': [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Whale/Aqua
    'X': [Color(0xFFFFEBEE), Color(0xFFFFCDD2)], // Xylophone/Pink
    'Y': [Color(0xFFFFFDE7), Color(0xFFFFF9C4)], // Yo-yo/Bright Yellow
    'Z': [Color(0xFFEFEBE9), Color(0xFFD7CCC8)], // Zebra/Monochrome
  };

  // Tracing paths (normalized 0.0 to 1.0)
  final Map<String, List<List<Offset>>> letterPathsUpper = {
    'A': [
      [Offset(0.5, 0.2), Offset(0.2, 0.8)], // Left stroke
      [Offset(0.5, 0.2), Offset(0.8, 0.8)], // Right stroke
      [Offset(0.35, 0.55), Offset(0.65, 0.55)], // Crossbar
    ],
    'B': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Vertical line
      [Offset(0.25, 0.2), Offset(0.7, 0.35), Offset(0.25, 0.5)], // Top curve
      [Offset(0.25, 0.5), Offset(0.7, 0.65), Offset(0.25, 0.8)], // Bottom curve
    ],
    'C': [
      [Offset(0.75, 0.3), Offset(0.4, 0.2), Offset(0.25, 0.5), Offset(0.4, 0.8), Offset(0.75, 0.7)], // Main curve
    ],
    'D': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Vertical line
      [Offset(0.25, 0.2), Offset(0.8, 0.5), Offset(0.25, 0.8)], // Large curve
    ],
    'E': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Vertical line
      [Offset(0.25, 0.2), Offset(0.75, 0.2)], // Top bar
      [Offset(0.25, 0.5), Offset(0.65, 0.5)], // Middle bar
      [Offset(0.25, 0.8), Offset(0.75, 0.8)], // Bottom bar
    ],
    'F': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Vertical line
      [Offset(0.25, 0.2), Offset(0.75, 0.2)], // Top bar
      [Offset(0.25, 0.5), Offset(0.65, 0.5)], // Middle bar
    ],
    'G': [
      [Offset(0.75, 0.3), Offset(0.4, 0.2), Offset(0.25, 0.5), Offset(0.4, 0.8), Offset(0.75, 0.7), Offset(0.75, 0.5), Offset(0.55, 0.5)], // Main curve + bar
    ],
    'H': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Left vertical
      [Offset(0.75, 0.2), Offset(0.75, 0.8)], // Right vertical
      [Offset(0.25, 0.5), Offset(0.75, 0.5)], // Crossbar
    ],
    'I': [
      [Offset(0.3, 0.2), Offset(0.7, 0.2)], // Top bar
      [Offset(0.5, 0.2), Offset(0.5, 0.8)], // Stem
      [Offset(0.3, 0.8), Offset(0.7, 0.8)], // Bottom bar
    ],
    'J': [
      [Offset(0.3, 0.2), Offset(0.7, 0.2)], // Top bar
      [Offset(0.5, 0.2), Offset(0.5, 0.7), Offset(0.4, 0.8), Offset(0.25, 0.7)], // Stem + hook
    ],
    'K': [
      [Offset(0.25, 0.2), Offset(0.25, 0.8)], // Vertical
      [Offset(0.7, 0.2), Offset(0.25, 0.5)], // Top slant
      [Offset(0.25, 0.5), Offset(0.7, 0.8)], // Bottom slant
    ],
    'L': [
      [Offset(0.3, 0.2), Offset(0.3, 0.8)], // Vertical
      [Offset(0.3, 0.8), Offset(0.7, 0.8)], // Horizontal
    ],
    'M': [
      [Offset(0.2, 0.8), Offset(0.2, 0.2)], // Left stem
      [Offset(0.2, 0.2), Offset(0.5, 0.5)], // First slant
      [Offset(0.5, 0.5), Offset(0.8, 0.2)], // Second slant
      [Offset(0.8, 0.2), Offset(0.8, 0.8)], // Right stem
    ],
    'N': [
      [Offset(0.25, 0.8), Offset(0.25, 0.2)], // Left stem
      [Offset(0.25, 0.2), Offset(0.75, 0.8)], // Slant
      [Offset(0.75, 0.8), Offset(0.75, 0.2)], // Right stem
    ],
    'O': [
      [Offset(0.5, 0.2), Offset(0.25, 0.5), Offset(0.5, 0.8), Offset(0.75, 0.5), Offset(0.5, 0.2)], // Oval
    ],
    'P': [
      [Offset(0.3, 0.8), Offset(0.3, 0.2)], // Stem
      [Offset(0.3, 0.2), Offset(0.7, 0.35), Offset(0.3, 0.5)], // Bowl
    ],
    'Q': [
      [Offset(0.5, 0.2), Offset(0.25, 0.5), Offset(0.5, 0.8), Offset(0.75, 0.5), Offset(0.5, 0.2)], // Oval
      [Offset(0.6, 0.6), Offset(0.8, 0.8)], // Tail
    ],
    'R': [
      [Offset(0.3, 0.8), Offset(0.3, 0.2)], // Stem
      [Offset(0.3, 0.2), Offset(0.7, 0.35), Offset(0.3, 0.5)], // Bowl
      [Offset(0.3, 0.5), Offset(0.7, 0.8)], // Leg
    ],
    'S': [
      [Offset(0.7, 0.3), Offset(0.4, 0.2), Offset(0.25, 0.4), Offset(0.75, 0.6), Offset(0.6, 0.8), Offset(0.3, 0.7)], // S-curve
    ],
    'T': [
      [Offset(0.2, 0.2), Offset(0.8, 0.2)], // Top bar
      [Offset(0.5, 0.2), Offset(0.5, 0.8)], // Stem
    ],
    'U': [
      [Offset(0.25, 0.2), Offset(0.25, 0.7), Offset(0.5, 0.8), Offset(0.75, 0.7), Offset(0.75, 0.2)], // U-shape
    ],
    'V': [
      [Offset(0.25, 0.2), Offset(0.5, 0.8)], // Left slant
      [Offset(0.5, 0.8), Offset(0.75, 0.2)], // Right slant
    ],
    'W': [
      [Offset(0.2, 0.2), Offset(0.35, 0.8)], // First down
      [Offset(0.35, 0.8), Offset(0.5, 0.4)], // First up
      [Offset(0.5, 0.4), Offset(0.65, 0.8)], // Second down
      [Offset(0.65, 0.8), Offset(0.8, 0.2)], // Second up
    ],
    'X': [
      [Offset(0.25, 0.2), Offset(0.75, 0.8)], // First slant
      [Offset(0.75, 0.2), Offset(0.25, 0.8)], // Second slant
    ],
    'Y': [
      [Offset(0.25, 0.2), Offset(0.5, 0.5)], // Left branch
      [Offset(0.75, 0.2), Offset(0.5, 0.5)], // Right branch
      [Offset(0.5, 0.5), Offset(0.5, 0.8)], // Stem
    ],
    'Z': [
      [Offset(0.25, 0.2), Offset(0.75, 0.2)], // Top bar
      [Offset(0.75, 0.2), Offset(0.25, 0.8)], // Diagonal
      [Offset(0.25, 0.8), Offset(0.75, 0.8)], // Bottom bar
    ],
  };

  final Map<String, List<List<Offset>>> letterPathsLower = {
    'A': [
      [Offset(0.7, 0.4), Offset(0.3, 0.4), Offset(0.3, 0.8), Offset(0.7, 0.8), Offset(0.7, 0.4)], // Circle
      [Offset(0.7, 0.4), Offset(0.7, 0.8)], // Tail
    ],
    'B': [
      [Offset(0.3, 0.2), Offset(0.3, 0.8)], // Stem
      [Offset(0.3, 0.5), Offset(0.7, 0.65), Offset(0.3, 0.8)], // Bowl
    ],
    'C': [
      [Offset(0.7, 0.5), Offset(0.4, 0.4), Offset(0.3, 0.6), Offset(0.4, 0.8), Offset(0.7, 0.7)], // Curve
    ],
    'D': [
      [Offset(0.7, 0.2), Offset(0.7, 0.8)], // Stem
      [Offset(0.7, 0.8), Offset(0.3, 0.65), Offset(0.7, 0.5)], // Bowl
    ],
    'E': [
      [Offset(0.3, 0.6), Offset(0.7, 0.6)], // Bar
      [Offset(0.7, 0.6), Offset(0.7, 0.4), Offset(0.3, 0.4), Offset(0.3, 0.8), Offset(0.7, 0.8)], // Loop
    ],
    'F': [
      [Offset(0.6, 0.2), Offset(0.4, 0.2), Offset(0.4, 0.8)], // Hook and stem
      [Offset(0.25, 0.45), Offset(0.55, 0.45)], // Crossbar
    ],
    'G': [
      [Offset(0.7, 0.4), Offset(0.3, 0.4), Offset(0.3, 0.7), Offset(0.7, 0.7), Offset(0.7, 0.4)], // Bowl
      [Offset(0.7, 0.4), Offset(0.7, 0.9), Offset(0.3, 0.9)], // Tail
    ],
    'H': [
      [Offset(0.3, 0.2), Offset(0.3, 0.8)], // Stem
      [Offset(0.3, 0.5), Offset(0.5, 0.4), Offset(0.7, 0.5), Offset(0.7, 0.8)], // Arch
    ],
    'I': [
      [Offset(0.5, 0.4), Offset(0.5, 0.8)], // Stem
      [Offset(0.5, 0.25)], // Dot
    ],
    'J': [
      [Offset(0.5, 0.4), Offset(0.5, 0.8), Offset(0.35, 0.9)], // Stem + hook
      [Offset(0.5, 0.25)], // Dot
    ],
    'K': [
      [Offset(0.3, 0.2), Offset(0.3, 0.8)], // Stem
      [Offset(0.6, 0.5), Offset(0.3, 0.65)], // Arm
      [Offset(0.3, 0.65), Offset(0.6, 0.8)], // Leg
    ],
    'L': [
      [Offset(0.5, 0.2), Offset(0.5, 0.8)], // Stem
    ],
    'M': [
      [Offset(0.2, 0.5), Offset(0.2, 0.8)], // Stem
      [Offset(0.2, 0.5), Offset(0.35, 0.4), Offset(0.5, 0.5), Offset(0.5, 0.8)], // First arch
      [Offset(0.5, 0.5), Offset(0.65, 0.4), Offset(0.8, 0.5), Offset(0.8, 0.8)], // Second arch
    ],
    'N': [
      [Offset(0.3, 0.5), Offset(0.3, 0.8)], // Stem
      [Offset(0.3, 0.5), Offset(0.5, 0.4), Offset(0.7, 0.5), Offset(0.7, 0.8)], // Arch
    ],
    'O': [
      [Offset(0.5, 0.4), Offset(0.3, 0.5), Offset(0.5, 0.7), Offset(0.7, 0.5), Offset(0.5, 0.4)], // Circle
    ],
    'P': [
      [Offset(0.3, 0.4), Offset(0.3, 0.9)], // Stem
      [Offset(0.3, 0.4), Offset(0.7, 0.55), Offset(0.3, 0.7)], // Bowl
    ],
    'Q': [
      [Offset(0.7, 0.4), Offset(0.7, 0.9)], // Stem
      [Offset(0.7, 0.4), Offset(0.3, 0.55), Offset(0.7, 0.7)], // Bowl
    ],
    'R': [
      [Offset(0.3, 0.5), Offset(0.3, 0.8)], // Stem
      [Offset(0.3, 0.6), Offset(0.5, 0.5), Offset(0.7, 0.55)], // Hook
    ],
    'S': [
      [Offset(0.7, 0.55), Offset(0.4, 0.45), Offset(0.3, 0.6), Offset(0.7, 0.7), Offset(0.3, 0.8)], // S-curve
    ],
    'T': [
      [Offset(0.4, 0.3), Offset(0.4, 0.8), Offset(0.6, 0.8)], // Stem + hook
      [Offset(0.25, 0.5), Offset(0.55, 0.5)], // Crossbar
    ],
    'U': [
      [Offset(0.3, 0.5), Offset(0.3, 0.75), Offset(0.5, 0.85), Offset(0.7, 0.75), Offset(0.7, 0.5)], // Cup
      [Offset(0.7, 0.5), Offset(0.7, 0.85)], // Stem
    ],
    'V': [
      [Offset(0.3, 0.5), Offset(0.5, 0.8)], // Left
      [Offset(0.5, 0.8), Offset(0.7, 0.5)], // Right
    ],
    'W': [
      [Offset(0.2, 0.5), Offset(0.35, 0.8)], // First down
      [Offset(0.35, 0.8), Offset(0.5, 0.6)], // First up
      [Offset(0.5, 0.6), Offset(0.65, 0.8)], // Second down
      [Offset(0.65, 0.8), Offset(0.8, 0.5)], // Second up
    ],
    'X': [
      [Offset(0.3, 0.5), Offset(0.7, 0.8)], // First slant
      [Offset(0.7, 0.5), Offset(0.3, 0.8)], // Second slant
    ],
    'Y': [
      [Offset(0.3, 0.5), Offset(0.3, 0.75), Offset(0.5, 0.85), Offset(0.7, 0.75), Offset(0.7, 0.5)], // Top
      [Offset(0.7, 0.5), Offset(0.7, 0.9), Offset(0.4, 0.9)], // Tail
    ],
    'Z': [
      [Offset(0.3, 0.5), Offset(0.7, 0.5)], // Top bar
      [Offset(0.7, 0.5), Offset(0.3, 0.8)], // Diagonal
      [Offset(0.3, 0.8), Offset(0.7, 0.8)], // Bottom bar
    ],
  };

  @override
  void initState() {
    super.initState();
    MusicManager.playBgm('sigmamusicart-kids-happy-background-music-401734.mp3');
    MusicManager.setVolume(0.15); 
    
    _guideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _guideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _guideController, curve: Curves.easeInOut),
    );

    _startStrokeGuide();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _mascotJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Play initial intro
    Future.delayed(const Duration(milliseconds: 500), () {
      MusicManager.playVoiceover(_audioPlayer, 'audio/Let’s write the letter A!.mp3');
    });
  }

  void _startStrokeGuide() {
    _guideController.reset();
    _guideController.repeat();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dragPlayer.dispose();
    _scrollController.dispose();
    _guideController.dispose();
    _confettiController.dispose();
    _mascotJumpController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helper: get physical-pixel waypoints for the active stroke on the canvas
  // ---------------------------------------------------------------------------
  List<Offset> _getPhysicalWaypoints() {
    if (_canvasSize == Size.zero) return [];
    final paths = isUppercase
        ? (letterPathsUpper[currentLetter] ?? [])
        : (letterPathsLower[currentLetter] ?? []);
    if (paths.isEmpty || _currentStrokeIndex >= paths.length) return [];
    final stroke = paths[_currentStrokeIndex];
    return stroke
        .map((p) => Offset(p.dx * _canvasSize.width, p.dy * _canvasSize.height))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Called once all waypoints of the current stroke are successfully hit
  // ---------------------------------------------------------------------------
  void _onStrokeComplete() {
    final paths = isUppercase
        ? (letterPathsUpper[currentLetter] ?? [])
        : (letterPathsLower[currentLetter] ?? []);

    if (_currentStrokeIndex < paths.length - 1) {
      setState(() {
        _currentStrokeIndex++;
        _nextTargetIndex = 0;
        _gestureStartedOnStroke = false;
        _currentGestureCompleted = false;
      });
      _startStrokeGuide();
      MusicManager.playVoiceover(_audioPlayer, 'audio/Great tracing!.mp3');
    } else {
      // All strokes done – letter complete!
      setState(() {
        isFilled = true;
      });
      _confettiController.play();
      _mascotJumpController.repeat(reverse: true);
      MusicManager.playVoiceover(_audioPlayer, 'audio/Amazing writing!_You did it!.mp3');
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _mascotJumpController.stop();
      });
    }
  }

  void _resetTrace() {
    setState(() {
      points.clear();
      isFilled = false;
      _currentStrokeIndex = 0;
      _nextTargetIndex = 0;
      _gestureStartedOnStroke = false;
      _currentGestureCompleted = false;
      _rollbackLength = 0;
    });
    _startStrokeGuide();
  }

  void _nextLetter() async {
    final letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    // Check if they completed E, J, or O successfully
    if (isFilled && (currentLetter == 'E' || currentLetter == 'J' || currentLetter == 'O')) {
      List<String> matchLetters;
      if (currentLetter == 'E') {
        matchLetters = ['A', 'B', 'C'];
      } else if (currentLetter == 'J') {
        matchLetters = ['F', 'G', 'H'];
      } else {
        matchLetters = ['K', 'L', 'M'];
      }

      final gameCompleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => TracingGameDialog(lettersToMatch: matchLetters),
      );

      if (gameCompleted == true && mounted) {
        int nextIdx = (letters.indexOf(currentLetter) + 1) % 26;
        setState(() {
          currentLetter = letters[nextIdx];
        });
        _resetTrace();
        MusicManager.playVoiceover(_audioPlayer, 'audio/Let’s write the letter ${letters[nextIdx]}!.mp3');
      }
    } else {
      int nextIdx = (letters.indexOf(currentLetter) + 1) % 26;
      setState(() {
        currentLetter = letters[nextIdx];
      });
      _resetTrace();
      MusicManager.playVoiceover(_audioPlayer, 'audio/Let’s write the letter ${letters[nextIdx]}!.mp3');
    }
  }

  Widget _buildColorOption(Color color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final bgColors = letterBackgrounds[currentLetter] ?? [Color(0xFFFFE58A), Color(0xFFFFD95F)];

    // Symmetrical square canvas dimension that scales perfectly on Fire tablets, phones, and web
    final double canvasDim = math.min(screenWidth * 0.86, screenHeight - 270).clamp(240.0, 460.0);
    final double letterFontSize = canvasDim * 0.88;
    final double startTolerance = (canvasDim * 0.22).clamp(70.0, 95.0);
    final double trackTolerance = (canvasDim * 0.20).clamp(60.0, 85.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Trace the Letter!",
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF11153B),
                    ),
                  ),
                ),
              ),

              // Letter Selector
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 26,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final letter = String.fromCharCode(65 + index);
                      final isSelected = currentLetter == letter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentLetter = letter;
                          });
                          _resetTrace();
                          MusicManager.playVoiceover(_audioPlayer, 'audio/Let’s write the letter $letter!.mp3');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF11153B) : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF11153B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Controls: Color Picker
              Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorOption(Colors.red),
                      _buildColorOption(Colors.blue),
                      _buildColorOption(Colors.green),
                      _buildColorOption(Colors.orange),
                      _buildColorOption(Colors.purple),
                    ],
                  ),
                ),
              ),

              // Main Tracing Area (Square canvas centered)
              Center(
                child: Container(
                  width: canvasDim,
                  height: canvasDim,
                  margin: const EdgeInsets.only(top: 80),
                  child: Stack(
                    children: [
                      // Gray Outline (Scales exactly with letterFontSize)
                      Center(
                        child: Opacity(
                          opacity: 0.2,
                          child: Text(
                            isUppercase ? currentLetter : currentLetter.toLowerCase(),
                            style: GoogleFonts.fredoka(
                              fontSize: letterFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // User Trace
                      GestureDetector(
                        onPanStart: (details) {
                          if (isFilled) return;
                          final targets = _getPhysicalWaypoints();
                          if (targets.isEmpty) return;

                          final distToStart = (details.localPosition - targets.first).distance;
                          final startedOnStroke = distToStart <= startTolerance;

                          setState(() {
                            _rollbackLength = points.length;
                            _gestureStartedOnStroke = startedOnStroke;
                            _currentGestureCompleted = false;
                            _nextTargetIndex = startedOnStroke ? 1 : 0;
                            points.add(details.localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          if (isFilled || !_gestureStartedOnStroke) return;
                          final targets = _getPhysicalWaypoints();

                          setState(() {
                            points.add(details.localPosition);
                          });

                          if (!_currentGestureCompleted && _nextTargetIndex < targets.length) {
                            while (_nextTargetIndex < targets.length) {
                              final dist = (details.localPosition - targets[_nextTargetIndex]).distance;
                              if (dist <= trackTolerance) {
                                _nextTargetIndex++;
                              } else {
                                break;
                              }
                            }
                            if (_nextTargetIndex >= targets.length) {
                              setState(() => _currentGestureCompleted = true);
                            }
                          }
                        },
                        onPanEnd: (details) {
                          if (isFilled) return;

                          if (_gestureStartedOnStroke && _currentGestureCompleted) {
                            // ✅ Stroke successfully traced – commit and advance
                            setState(() => points.add(null));
                            _onStrokeComplete();
                          } else {
                            // ❌ Stroke incomplete – roll back all scribbles from this gesture
                            setState(() {
                              if (_rollbackLength <= points.length) {
                                points.removeRange(_rollbackLength, points.length);
                              }
                            });
                          }

                          setState(() {
                            _gestureStartedOnStroke = false;
                            _currentGestureCompleted = false;
                          });
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_canvasSize != constraints.biggest) {
                                _canvasSize = constraints.biggest;
                              }
                            });
                            return CustomPaint(
                              painter: TracePainter(
                                points: List.from(points),
                                color: selectedColor,
                                letter: isUppercase ? currentLetter : currentLetter.toLowerCase(),
                                isFilled: isFilled,
                                fontSize: letterFontSize,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),

                      // Stroke Guide & Bee (Topmost, must ignore pointers)
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _guideAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: PathGuidePainter(
                                paths: isUppercase 
                                  ? (letterPathsUpper[currentLetter] ?? [])
                                  : (letterPathsLower[currentLetter] ?? []),
                                currentStrokeIndex: _currentStrokeIndex,
                                animationValue: _guideAnimation.value,
                                isComplete: isFilled,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions: Restart & Next
              Positioned(
                bottom: 45,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _3DButton(
                      text: "Restart",
                      color: const Color(0xFFFF6B6B),
                      textColor: Colors.white,
                      width: 90,
                      height: 45,
                      fontSize: 16,
                      onTap: _resetTrace,
                    ),
                    const SizedBox(width: 30),
                    _3DButton(
                      text: "Next",
                      color: const Color(0xFF49D84F),
                      textColor: Colors.white,
                      width: 90,
                      height: 45,
                      fontSize: 16,
                      onTap: _nextLetter,
                    ),
                  ],
                ),
              ),

              // Case Selector (Side-by-side buttons)
              Positioned(
                bottom: 110,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => isUppercase = true);
                        _resetTrace();
                      },
                      child: _3DButton(
                        text: "ABC",
                        color: isUppercase ? const Color(0xFFFF4FA2) : Colors.white,
                        textColor: isUppercase ? Colors.white : const Color(0xFF11153B),
                        width: 70,
                        height: 45,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => isUppercase = false);
                        _resetTrace();
                      },
                      child: _3DButton(
                        text: "abc",
                        color: !isUppercase ? const Color(0xFFFF4FA2) : Colors.white,
                        textColor: !isUppercase ? Colors.white : const Color(0xFF11153B),
                        width: 70,
                        height: 45,
                      ),
                    ),
                  ],
                ),
              ),

              // Mascot
              Positioned(
                bottom: 10,
                right: 10,
                child: SlideTransition(
                  position: _mascotJumpController.drive(
                    Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.5))
                        .chain(CurveTween(curve: Curves.elasticOut)),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Lottie.asset('assets/lottie/mascot.json', fit: BoxFit.contain),
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
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),

              // Back Button
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 28, color: const Color(0xFF11153B)),
                  onPressed: () {
                    AdManager.showInterstitial(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PathGuidePainter extends CustomPainter {
  final List<List<Offset>> paths;
  final int currentStrokeIndex;
  final double animationValue;
  final bool isComplete;

  PathGuidePainter({
    required this.paths,
    required this.currentStrokeIndex,
    required this.animationValue,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isComplete || paths.isEmpty) return;

    // Paint for already-completed strokes (faint dashed-style outline)
    final completedPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Paint for the active stroke guide
    final activePaint = Paint()
      ..color = Colors.orange.withOpacity(0.85)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw completed strokes (index 0 .. currentStrokeIndex-1) as faint outlines
    for (int i = 0; i < currentStrokeIndex && i < paths.length; i++) {
      final stroke = paths[i];
      final path = Path();
      path.moveTo(stroke[0].dx * size.width, stroke[0].dy * size.height);
      for (var p in stroke) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, completedPaint);
    }

    // Draw only the current active stroke guide – future strokes are hidden
    if (currentStrokeIndex < paths.length) {
      final stroke = paths[currentStrokeIndex];
      final path = Path();
      path.moveTo(stroke[0].dx * size.width, stroke[0].dy * size.height);
      for (var p in stroke) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, activePaint);

      // Draw start-dot so child knows exactly where to put their finger
      final startPos = Offset(stroke[0].dx * size.width, stroke[0].dy * size.height);
      canvas.drawCircle(
        startPos,
        14,
        Paint()..color = Colors.greenAccent.shade400..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        startPos,
        14,
        Paint()
          ..color = Colors.green.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      // Animated bee guide dot travelling along the active stroke
      if (stroke.length >= 2) {
        final metrics = path.computeMetrics().first;
        final pos =
            metrics.getTangentForOffset(metrics.length * animationValue)?.position ?? Offset.zero;

        // Bee emoji label
        final textPainter = TextPainter(
          text: const TextSpan(text: '🐝', style: TextStyle(fontSize: 26)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, pos - const Offset(13, 16));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TracePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final String letter;
  final bool isFilled;
  final double fontSize;

  TracePainter({
    required this.points,
    required this.color,
    required this.letter,
    required this.isFilled,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isFilled) {
       final textPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: GoogleFonts.fredoka(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
      return;
    }

    // Use a layer for BlendMode.srcIn
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw the Mask (The Letter) matching fredoka font perfectly
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Opaque color for mask
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));

    // 2. Draw the Trace (Only where it overlaps the Mask)
    final tracePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(48.0, size.width * 0.15) // Responsive stroke thickness
      ..color = color
      ..blendMode = BlendMode.srcIn;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, tracePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TracePainter oldDelegate) => true;
}

class _3DButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double fontSize;

  const _3DButton({
    required this.text,
    required this.color,
    required this.textColor,
    this.onTap,
    this.width = 120,
    this.height = 55,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Darker bottom shadow for 3D effect
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            // Lighter top highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(0, -2),
              blurRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.fredoka(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
