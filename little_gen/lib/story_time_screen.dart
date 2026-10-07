import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'music_manager.dart';
import 'ad_manager.dart';
import 'firebase_rewards_manager.dart';

class StoryTimeScreen extends StatefulWidget {
  const StoryTimeScreen({super.key});

  @override
  State<StoryTimeScreen> createState() => _StoryTimeScreenState();
}

class _StoryTimeScreenState extends State<StoryTimeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _selectedAgeGroup = "All";

  final List<Map<String, dynamic>> _stories = [
    {
      "title": "The Brave Lion",
      "color": const Color(0xFFFFE5E5),
      "image": "🦁",
      "cover": "assets/Cartoon_lion_helping_ladybug_tree_202605142037.jpeg",
      "audio": "lion story .mp3",
      "ageGroup": "2-3",
      "script": "L is for Lion.\n\nLeo the Lion lived in a lovely land full of long green leaves.\n\nLeo liked to look at the sky and listen to little birds sing.\n\nHe loved to leap over logs and run across the land.\n\nOne day, Leo saw a little ladybug looking lost.\n\n\"Let’s look together,\" said Leo.\n\nThey walked left and right, looking under leaves and near logs.\n\nSuddenly, Leo saw a large leafy tree.\n\n\"Look,\" said Leo. \"Your home!\"\n\nThe ladybug laughed and landed on a leaf.\n\n\"Thank you, Leo!\"\n\nLeo smiled. He loved helping his little friends.\n\nL is for Lion.\nL is for Love.\nL is for Let’s help.",
    },
    {
      "title": "Happy Garden",
      "color": const Color(0xFFE2F6E1),
      "image": "🌸",
      "cover": "assets/Cartoon_girl_playing_with_goat_202605142037.jpeg",
      "audio": "happy garden .mp3",
      "ageGroup": "2-3",
      "script": "G is for Garden.\n\nGigi went to a green garden full of growing plants.\n\nShe saw green grass, big grapes, and golden flowers.\n\nA giggling goat came to say hello.\n\n\"Let’s go play,\" said Gigi.\n\nThey gathered together and played fun garden games.\n\nA grasshopper jumped and made Gigi giggle.\n\n\"Good job jumping,\" said the goat.\n\nGigi picked a glowing golden flower gently.\n\nThe garden was full of joy and happy sounds.\n\nEveryone smiled and played together.\n\nG is for Garden.\nG is for Grow.\nG is for Giggle.",
    },
    {
      "title": "A Day at Sea",
      "color": const Color(0xFFD9F1FF),
      "image": "🌊",
      "cover": "assets/Seal_swimming_with_turtle_202605142037.jpeg",
      "audio": "A day at the sea.mp3",
      "ageGroup": "3-5",
      "script": "S is for Sea.\n\nSam the Seal swam in the shiny blue sea.\n\nSplash splash, the water moved softly.\n\nSam saw a small ship sailing slowly.\n\nHe waved at a smiling starfish.\n\nA sea turtle swam slowly beside him.\n\n\"Swim with me,\" said Sam.\n\nThey swirled and spun in the sea.\n\nSuddenly, everything became still.\n\nA soft sound whispered, sssss.\n\nThe sea sang a gentle song.\n\nSam smiled and floated calmly.\n\nS is for Sea.\nS is for Swim.\nS is for Splash.",
    },
    {
      "title": "Starry Night",
      "color": const Color(0xFFE5DEFF),
      "image": "✨",
      "cover": "assets/Cartoon_fox_sitting_under_sky_202605142037.jpeg",
      "audio": "starry night .mp3",
      "ageGroup": "3-5",
      "script": "S is for Star.\n\nThe sky was soft and full of shining stars.\n\nA small fox sat quietly and looked up.\n\nThe stars sparkled slowly in the sky.\n\nEverything felt still and calm.\n\n\"See the stars,\" whispered the fox.\n\nA soft wind said, \"shhhh.\"\n\nThe night felt safe and peaceful.\n\nThe fox smiled and closed its eyes.\n\nThe stars continued to shine softly.\n\nS is for Star.\nS is for Shine.\nS is for Sleep.",
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _openStory(Map<String, dynamic> story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: story),
      ),
    );
  }

  Widget _buildAgeChip(String group, String label) {
    final sel = _selectedAgeGroup == group;
    return GestureDetector(
      onTap: () {
        MusicManager.playClickSound();
        setState(() => _selectedAgeGroup = group);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF9C58FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (sel ? const Color(0xFF9C58FF) : Colors.black).withValues(alpha: sel ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: sel ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStories = _selectedAgeGroup == "All"
        ? _stories
        : _stories.where((s) => s["ageGroup"] == _selectedAgeGroup).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF9C58FF), size: 20),
              onPressed: () {
                AdManager.showInterstitial(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        title: Text(
          "Story Time",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF11153B),
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4E8FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Age Group Selector Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAgeChip("All", "All Ages 📚"),
                        const SizedBox(width: 8),
                        _buildAgeChip("2-3", "Ages 2-3 🧸"),
                        const SizedBox(width: 8),
                        _buildAgeChip("3-5", "Ages 3-5+ 🎈"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredStories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == filteredStories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 40),
                            child: Center(
                              child: Text(
                                "More stories coming soon! 📚✨",
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF11153B).withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        final story = filteredStories[index];
                        return _StoryCard(
                          title: story['title'],
                          color: story['color'],
                          emoji: story['image'],
                          onTap: () => _openStory(story),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Mascot at bottom
            Positioned(
              bottom: 20,
              right: 20,
              child: Lottie.asset(
                'assets/lottie/mascot.json',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _mascotController;
  final ScrollController _scrollController = ScrollController();
  Duration? _totalDuration;

  @override
  void initState() {
    super.initState();
    FirebaseRewardsManager.addStars(3);
    FirebaseRewardsManager.recordStoryRead(1);
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) _totalDuration = d;
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (_isPlaying && _totalDuration != null && _totalDuration!.inMilliseconds > 0 && _scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          final double progress = p.inMilliseconds / _totalDuration!.inMilliseconds;
          final double targetScroll = maxScroll * progress;
          _scrollController.animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _mascotController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAudio() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      MusicManager.playVoiceover(_audioPlayer, widget.story['audio']);
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTabletOrLandscape = screenSize.width > 600 || screenSize.width > screenSize.height;
    final double maxImgHeight = isTabletOrLandscape 
        ? (screenSize.height * 0.30).clamp(140.0, 220.0) 
        : (screenSize.height * 0.32).clamp(180.0, 280.0);

    return Scaffold(
      body: Stack(
        children: [
          // Background color for the whole screen (Milky color)
          Container(color: const Color(0xFFFFFDF5)),

          Column(
            children: [
              // Upper Part: Bounded Image for tablets & phones
              Container(
                height: maxImgHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.story['color'],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  child: Image.asset(
                    widget.story['cover'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("Error loading image: ${widget.story['cover']} - $error");
                      return Center(
                        child: Text(
                          widget.story['image'],
                          style: const TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Middle: Story Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3), width: 3),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          Text(
                            widget.story['title'],
                            style: GoogleFonts.fredoka(
                              fontSize: isTabletOrLandscape ? 30 : 34,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.story['script'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: isTabletOrLandscape ? 22 : 24,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                              color: const Color(0xFF11153B).withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Area: Mascot and Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 20, right: 20, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mascot at bottom left with wiggle animation
                    AnimatedBuilder(
                      animation: _mascotController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: math.sin(_mascotController.value * math.pi * 2) * 0.05,
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: isTabletOrLandscape ? 70 : 90,
                        height: isTabletOrLandscape ? 70 : 90,
                        child: Lottie.asset(
                          'assets/lottie/mascot.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Audio Button and Prompt (Horizontal compact layout)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toggleAudio,
                          child: Container(
                            width: isTabletOrLandscape ? 58 : 68,
                            height: isTabletOrLandscape ? 58 : 68,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: isTabletOrLandscape ? 38 : 46,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isPlaying ? "Playing Story 🎵" : "Tap to Listen 🔊",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900,
                            color: Colors.orange,
                            fontSize: isTabletOrLandscape ? 15 : 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Back Button (Ensured visibility)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: const Color(0xFF11153B), size: 20),
                onPressed: () {
                  AdManager.showInterstitial(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final String emoji;
  final VoidCallback onTap;

  const _StoryCard({
    required this.title,
    required this.color,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.3)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap to start",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF11153B).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
