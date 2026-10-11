import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'music_manager.dart';
import 'firebase_rewards_manager.dart';
import 'package:lottie/lottie.dart';

class TracingGameDialog extends StatefulWidget {
  final List<String> lettersToMatch; // Exactly 3 letters, e.g., ['A', 'B', 'C']
  const TracingGameDialog({super.key, required this.lettersToMatch});

  @override
  State<TracingGameDialog> createState() => _TracingGameDialogState();
}

class _TracingGameDialogState extends State<TracingGameDialog> {
  final AudioPlayer _dialogAudioPlayer = AudioPlayer();
  
  // Mapping of letters to emojis and words
  final Map<String, Map<String, String>> _matchMap = {
    'A': {'emoji': '🍎', 'name': 'Apple'},
    'B': {'emoji': '⚽', 'name': 'Ball'},
    'C': {'emoji': '🐱', 'name': 'Cat'},
    'D': {'emoji': '🐶', 'name': 'Dog'},
    'E': {'emoji': '🐘', 'name': 'Elephant'},
    'F': {'emoji': '🐟', 'name': 'Fish'},
    'G': {'emoji': '🐐', 'name': 'Goat'},
    'H': {'emoji': '🎩', 'name': 'Hat'},
    'I': {'emoji': '❄️', 'name': 'Igloo'},
    'J': {'emoji': '🧃', 'name': 'Juice'},
    'K': {'emoji': '🪁', 'name': 'Kite'},
    'L': {'emoji': '🦁', 'name': 'Lion'},
    'M': {'emoji': '🐒', 'name': 'Monkey'},
    'N': {'emoji': '🪺', 'name': 'Nest'},
    'O': {'emoji': '🍊', 'name': 'Orange'},
    'P': {'emoji': '🐷', 'name': 'Pig'},
    'Q': {'emoji': '👑', 'name': 'Queen'},
    'R': {'emoji': '🐰', 'name': 'Rabbit'},
    'S': {'emoji': '☀️', 'name': 'Sun'},
    'T': {'emoji': '🐯', 'name': 'Tiger'},
    'U': {'emoji': '☂️', 'name': 'Umbrella'},
    'V': {'emoji': '🚐', 'name': 'Van'},
    'W': {'emoji': '🐋', 'name': 'Whale'},
    'X': {'emoji': '🎹', 'name': 'Xylophone'},
    'Y': {'emoji': '🪀', 'name': 'Yo-yo'},
    'Z': {'emoji': '🦓', 'name': 'Zebra'},
  };

  late List<String> _shuffledTargets;
  late List<String> _shuffledDraggables;
  final Map<String, String?> _matched = {}; // targetLetter -> matched DraggableLetter
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _shuffledTargets = List.from(widget.lettersToMatch)..shuffle();
    _shuffledDraggables = List.from(widget.lettersToMatch)..shuffle();
    
    for (var letter in widget.lettersToMatch) {
      _matched[letter] = null;
    }
  }

  void _onMatchSuccess(String letter) {
    setState(() {
      _matched[letter] = letter;
      
      // If all matched!
      if (_matched.values.every((v) => v != null)) {
        _isFinished = true;
        _triggerVictory();
      }
    });
  }

  void _dismiss() {
    if (mounted) Navigator.pop(context, true);
  }

  void _triggerVictory() async {
    // Fire-and-forget Firebase — never block the victory flow on network
    FirebaseRewardsManager.incrementStars();
    FirebaseRewardsManager.recordLetterTraced(1);

    // Play celebration voiceover (non-blocking)
    MusicManager.playVoiceover(_dialogAudioPlayer, 'audio/Amazing writing!_You did it!.mp3');

    // Auto-dismiss after 4 seconds as a safe fallback
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _dialogAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFFFF9E6), // Light garden yellow
      child: SafeArea(
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: 50,
              left: 40,
              child: Icon(Icons.star_outline_rounded, size: 60, color: Colors.amber.shade200),
            ),
            Positioned(
              bottom: 60,
              right: 40,
              child: Icon(Icons.star_outline_rounded, size: 80, color: Colors.amber.shade200),
            ),

            // Main Columns
            Column(
              children: [
                const SizedBox(height: 20),
                
                // Top Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  color: Colors.white.withOpacity(0.95),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          "Match-up Game!",
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF6F61),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Drag the item to the correct letter!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF11153B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Drag and Drop Grid Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT SIDE: Drag Targets (Boxes)
                      Column(
                        children: _shuffledTargets.map((letter) {
                          final isMatched = _matched[letter] != null;
                          final matchData = _matchMap[letter] ?? {'emoji': '❓', 'name': 'Item'};
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: DragTarget<String>(
                              onWillAccept: (data) => data == letter,
                              onAcceptWithDetails: (details) {
                                _onMatchSuccess(letter);
                              },
                              builder: (context, candidateData, rejectedData) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 130,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? const Color(0xFF4CAF50).withOpacity(0.15)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isMatched
                                          ? const Color(0xFF4CAF50)
                                          : (candidateData.isNotEmpty
                                              ? const Color(0xFFFF6F61)
                                              : Colors.grey.shade300),
                                      width: isMatched || candidateData.isNotEmpty ? 4 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: isMatched
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              matchData['emoji']!,
                                              style: const TextStyle(fontSize: 40),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Letter $letter",
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF4CAF50),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          letter,
                                          style: GoogleFonts.nunito(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF11153B),
                                          ),
                                        ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      // RIGHT SIDE: Draggables (Items)
                      Column(
                        children: _shuffledDraggables.map((letter) {
                          final isMatched = _matched.values.contains(letter);
                          final matchData = _matchMap[letter] ?? {'emoji': '❓', 'name': 'Item'};
                          
                          if (isMatched) {
                            // Render hollowed/empty spot as feedback
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.values[0] /* dashed style fallback */),
                                ),
                              ),
                            );
                          }

                          final itemCard = Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6F61).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFFF6F61), width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  matchData['emoji']!,
                                  style: const TextStyle(fontSize: 38),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  matchData['name']!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF11153B),
                                  ),
                                ),
                              ],
                            ),
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Draggable<String>(
                              data: letter,
                              feedback: Material(
                                color: Colors.transparent,
                                child: itemCard,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: itemCard,
                              ),
                              child: itemCard,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),

            // Victory Pop-up Overlay
            if (_isFinished)
              Container(
                color: Colors.black.withOpacity(0.4),
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
                              color: const Color(0xFFFF6F61),
                            ),
                          ),
                          Text(
                            "You matched them all!",
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "+1 Real Gold Star Earned",
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
                                color: const Color(0xFFFF6F61),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6F61)
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
