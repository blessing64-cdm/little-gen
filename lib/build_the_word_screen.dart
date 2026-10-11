import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'surprise_box_dialog.dart';
import 'firebase_rewards_manager.dart';
import 'ad_manager.dart';

class BuildTheWordScreen extends StatefulWidget {
  final int wordLength;
  const BuildTheWordScreen({super.key, required this.wordLength});

  @override
  State<BuildTheWordScreen> createState() => _BuildTheWordScreenState();
}

class _BuildTheWordScreenState extends State<BuildTheWordScreen> {
  final Map<int, List<String>> _wordDatabase = {
    2: [
      "UP", "IN", "ON", "TO", "GO", "ME", "WE", "HI", "AS", "AT", 
      "BE", "BY", "DO", "HE", "IF", "IS", "IT", "NO", "OF", "OR", 
      "SO", "US", "AM", "AN", "MY", "OX", "AX", "EX", "OH", "AH"
    ],
    3: [
      "CAT", "DOG", "SUN", "BEE", "PIG", "COW", "ANT", "BAT", "FOX", "OWL",
      "HAT", "RAT", "MAT", "PAT", "FAT", "SAT", "PEN", "HEN", "TEN", "MEN",
      "RED", "BED", "LEG", "PEG", "BUG", "RUG", "MUG", "JUG", "CUP", "PUP"
    ],
    4: [
      "BIRD", "FISH", "BEAR", "FROG", "LION", "WOLF", "CRAB", "DUCK", "GOAT", "SWAN",
      "TREE", "LEAF", "DIRT", "SAND", "ROCK", "STAR", "MOON", "FIRE", "SNOW", "WIND",
      "RAIN", "DROP", "BALL", "DOLL", "KITE", "BIKE", "BOAT", "CARS", "TRUC", "SHIP",
      "DESK", "BOOK", "PAGE", "READ", "DRAW", "PLAY", "JUMP", "WALK", "RUNS", "FAST"
    ],
    5: [
      "HORSE", "ZEBRA", "TIGER", "WHALE", "SNAKE", "SHARK", "SHEEP", "PANDA", "MOUSE", "GOOSE",
      "APPLE", "GRAPE", "PEACH", "MELON", "BERRY", "LEMON", "MANGO", "JUICE", "WATER", "BREAD",
      "TOAST", "PIZZA", "PASTA", "SALAD", "CANDY", "SUGAR", "SWEET", "HEART", "SMILE", "HAPPY",
      "LAUGH", "FUNNY", "SILLY", "CLOWN", "DANCE", "MUSIC", "SOUND", "NOISE", "QUIET", "SLEEP",
      "DREAM", "NIGHT", "CLOUD", "STORM", "FLASH", "LIGHT", "SHINE", "SPARK", "TRAIN", "PLANE"
    ],
  };

  late List<String> _availableWords;
  List<String> _currentWords = [];
  List<List<String?>> _guesses = [];
  List<List<bool>> _hintsUnlocked = [];
  List<String> _lettersPool = [];
  List<bool> _letterUsed = [];
  
  bool _isSuccess = false;
  bool _hasErrors = false;
  int _roundsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _availableWords = List.from(_wordDatabase[widget.wordLength] ?? _wordDatabase[3]!);
    _availableWords.shuffle();
    _startNewRound();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const SurpriseBoxDialog(),
          );
        }
      });
    });
  }

  void _startNewRound() {
    setState(() {
      _isSuccess = false;
      _hasErrors = false;
      
      // Need 3 words for this round
      if (_availableWords.length < 3) {
        _availableWords = List.from(_wordDatabase[widget.wordLength] ?? _wordDatabase[3]!);
        _availableWords.shuffle();
      }

      _currentWords = [];
      for (int i = 0; i < 3; i++) {
        _currentWords.add(_availableWords.removeLast());
      }

      _guesses = List.generate(
        3, 
        (_) => List.filled(widget.wordLength, null)
      );

      _hintsUnlocked = List.generate(
        3,
        (_) => List.filled(widget.wordLength, false)
      );

      _lettersPool = [];
      for (var word in _currentWords) {
        _lettersPool.addAll(word.split(""));
      }
      _lettersPool.shuffle();
      _letterUsed = List.filled(_lettersPool.length, false);
    });
  }

  void _updateUsedLetters() {
    setState(() {
      _letterUsed = List.filled(_lettersPool.length, false);
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < widget.wordLength; c++) {
          final char = _guesses[r][c];
          if (char != null) {
            for (int i = 0; i < _lettersPool.length; i++) {
              if (!_letterUsed[i] && _lettersPool[i] == char) {
                _letterUsed[i] = true;
                break;
              }
            }
          }
        }
      }
    });
  }

  bool _isRowValid(int r) {
    for (int c = 0; c < widget.wordLength; c++) {
      if (_guesses[r][c] == null) return false;
    }
    String word = _guesses[r].join("");
    return _wordDatabase[widget.wordLength]?.contains(word) ?? false;
  }

  void _onPoolLetterTap(int poolIndex) {
    if (_letterUsed[poolIndex] || _isSuccess || _hasErrors) return;

    setState(() {
      // Find first empty slot
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < widget.wordLength; c++) {
          if (_guesses[r][c] == null) {
            _guesses[r][c] = _lettersPool[poolIndex];
            _letterUsed[poolIndex] = true;
            _checkCompletion();
            return;
          }
        }
      }
    });
  }

  void _onGuessLetterTap(int r, int c) {
    if (_guesses[r][c] == null || _isSuccess || _hasErrors || _hintsUnlocked[r][c]) return;

    setState(() {
      String letterToReturn = _guesses[r][c]!;
      _guesses[r][c] = null;
      
      // Find this letter in the pool that is marked as used and unmark it
      for (int i = 0; i < _lettersPool.length; i++) {
        if (_letterUsed[i] && _lettersPool[i] == letterToReturn) {
          _letterUsed[i] = false;
          break;
        }
      }
    });
  }

  void _buyHint() async {
    if (FirebaseRewardsManager.starsEarned < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Need 5 🌟 to buy a hint!",
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: const Color(0xFFFF6F61),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    int targetR = -1;
    int targetC = 0;

    for (int r = 0; r < 3; r++) {
      if (!_hintsUnlocked[r][0] && !_isRowValid(r)) {
        targetR = r;
        targetC = 0;
        break;
      }
    }

    if (targetR == -1) {
      for (int r = 0; r < 3; r++) {
        if (_isRowValid(r)) continue;
        for (int c = 1; c < widget.wordLength; c++) {
          if (!_hintsUnlocked[r][c]) {
            targetR = r;
            targetC = c;
            break;
          }
        }
        if (targetR != -1) break;
      }
    }

    if (targetR == -1) return;

    final success = await FirebaseRewardsManager.spendStars(5);
    if (!success) return;

    setState(() {
      final correctLetter = _currentWords[targetR][targetC];
      
      if (_guesses[targetR][targetC] != null) {
        final wrongLetter = _guesses[targetR][targetC]!;
        _guesses[targetR][targetC] = null;
        for (int i = 0; i < _lettersPool.length; i++) {
          if (_letterUsed[i] && _lettersPool[i] == wrongLetter) {
            _letterUsed[i] = false;
            break;
          }
        }
      }

      bool poolFound = false;
      for (int i = 0; i < _lettersPool.length; i++) {
        if (!_letterUsed[i] && _lettersPool[i] == correctLetter) {
          _letterUsed[i] = true;
          poolFound = true;
          break;
        }
      }

      if (!poolFound) {
        for (int i = 0; i < _lettersPool.length; i++) {
          if (_lettersPool[i] == correctLetter) {
            _letterUsed[i] = true;
            break;
          }
        }
      }

      _guesses[targetR][targetC] = correctLetter;
      _hintsUnlocked[targetR][targetC] = true;
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    bool allFilled = true;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < widget.wordLength; c++) {
        if (_guesses[r][c] == null) {
          allFilled = false;
          break;
        }
      }
    }

    if (!allFilled) return;

    bool allValid = true;
    for (int r = 0; r < 3; r++) {
      if (!_isRowValid(r)) {
        allValid = false;
        break;
      }
    }

    if (allValid) {
      setState(() {
        _isSuccess = true;
        _hasErrors = false;
      });
      FirebaseRewardsManager.addStars(3);
      FirebaseRewardsManager.recordWordBuilt(3);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _roundsCompleted++;
        if (_roundsCompleted % 2 == 0) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const SurpriseBoxDialog(),
          ).then((_) {
            if (mounted) _startNewRound();
          });
        } else {
          _startNewRound();
        }
      });
    } else {
      setState(() {
        _hasErrors = true;
      });
      
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _hasErrors = false;
          for (int r = 0; r < 3; r++) {
            if (!_isRowValid(r)) {
              for (int c = 0; c < widget.wordLength; c++) {
                if (!_hintsUnlocked[r][c]) {
                  _guesses[r][c] = null;
                }
              }
            }
          }
          _updateUsedLetters();
        });
      });
    }
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
            colors: [Color(0xFFD9F1FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Beautiful Header with real stars and custom Hint shop
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: const Color(0xFF11153B)),
                      onPressed: () {
                        AdManager.showInterstitial(context);
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "Build!",
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    const Spacer(),
                    
                    // Star Counter Dynamic Display
                    ValueListenableBuilder<int>(
                      valueListenable: FirebaseRewardsManager.rewardsNotifier,
                      builder: (context, val, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade200, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${FirebaseRewardsManager.starsEarned}",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF11153B),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Hint Shop Button
                    GestureDetector(
                      onTap: _buyHint,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F43),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9F43).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "Hint (5 🌟)",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
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
              ),

              const SizedBox(height: 20),

              // 3 Words Grid
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (r) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.wordLength, (c) {
                        final val = _guesses[r][c];
                        final isHint = _hintsUnlocked[r][c];
                        
                        return GestureDetector(
                          onTap: () => _onGuessLetterTap(r, c),
                          child: Container(
                            width: widget.wordLength > 4 ? 45 : 55,
                            height: widget.wordLength > 4 ? 55 : 65,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _isSuccess 
                                  ? Colors.green 
                                  : (_hasErrors && !_isRowValid(r)
                                      ? Colors.red 
                                      : (_isRowValid(r)
                                          ? Colors.green
                                          : (isHint 
                                              ? const Color(0xFFFF9F43) 
                                              : const Color(0xFF6C63FF).withOpacity(0.3)))),
                                width: 3,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: val != null
                                ? Text(
                                    val,
                                    style: GoogleFonts.nunito(
                                      fontSize: widget.wordLength > 4 ? 24 : 28,
                                      fontWeight: FontWeight.w900,
                                      color: isHint ? const Color(0xFFFF9F43) : const Color(0xFF11153B),
                                    ),
                                  )
                                // COMPLETELY BLANK! NO DEFAULT OUTLINE SHADOWS
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),

              // Letters Pool
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(_lettersPool.length, (index) {
                    final isUsed = _letterUsed[index];
                    return GestureDetector(
                      onTap: () => _onPoolLetterTap(index),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isUsed ? 0.3 : 1.0,
                        child: Container(
                          width: widget.wordLength > 4 ? 40 : 50,
                          height: widget.wordLength > 4 ? 50 : 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isUsed ? [] : [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                                    ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _lettersPool[index],
                            style: GoogleFonts.nunito(
                              fontSize: widget.wordLength > 4 ? 20 : 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
