import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'music_manager.dart';
import 'ad_manager.dart';
import 'phonics_game_dialog.dart';
import 'firebase_rewards_manager.dart';

class SpellingAZScreen extends StatefulWidget {
  const SpellingAZScreen({super.key});

  @override
  State<SpellingAZScreen> createState() => _SpellingAZScreenState();
}

class _SpellingAZScreenState extends State<SpellingAZScreen> {
  final List<Map<String, String>> _spellingData = [
    {"letter": "A", "word": "APPLE", "image": "🍎", "audio": "A for apple .mp3", "animal": "Alligator", "animalEmoji": "🐊"},
    {"letter": "B", "word": "BALL", "image": "⚽", "audio": "B is for Ball.mp3", "animal": "Bear", "animalEmoji": "🐻"},
    {"letter": "C", "word": "CAT", "image": "🐱", "audio": "C is for cat.mp3", "animal": "Cat", "animalEmoji": "🐱"},
    {"letter": "D", "word": "DOG", "image": "🐶", "audio": "D is for Dog.mp3", "animal": "Puppy", "animalEmoji": "🐶"},
    {"letter": "E", "word": "ELEPHANT", "image": "🐘", "audio": "E is for Elephants.mp3", "animal": "Elephant", "animalEmoji": "🐘"},
    {"letter": "F", "word": "FISH", "image": "🐟", "audio": "F is for Fish!_F says… Fuh_Can you say Fuh.mp3", "animal": "Fish", "animalEmoji": "🐟"},
    {"letter": "G", "word": "GOAT", "image": "🐐", "audio": "G is for Goat!_G says… Guh!_Can you say Guh_.mp3", "animal": "Goat", "animalEmoji": "🐐"},
    {"letter": "H", "word": "HAT", "image": "🎩", "audio": "H is for Hat!_H says… Huh_Can you say Huh_.mp3", "animal": "Hippo", "animalEmoji": "🦛"},
    {"letter": "I", "word": "IGLOO", "image": "🍦", "audio": "I is for Igloo!_I says… Ih!_Can you says Ih!.mp3", "animal": "Iguana", "animalEmoji": "🦎"},
    {"letter": "J", "word": "JUICE", "image": "🧃", "audio": "J is for Juice!_J says… Juh!_Can you say Juh_.mp3", "animal": "Jaguar", "animalEmoji": "🐆"},
    {"letter": "K", "word": "KITE", "image": "🪁", "audio": "K is for Kite!_K says… Kuh!_Can you say Kuh_.mp3", "animal": "Koala", "animalEmoji": "🐨"},
    {"letter": "L", "word": "LION", "image": "🦁", "audio": "L is for Lion!_L says… Luh!_Can you say Luh!.mp3", "animal": "Lion", "animalEmoji": "🦁"},
    {"letter": "M", "word": "MONKEY", "image": "🐒", "audio": "M is for Monkey!_M says… Mmmm!_Can you say Mmmm_.mp3", "animal": "Monkey", "animalEmoji": "🐒"},
    {"letter": "N", "word": "NEST", "image": "🪺", "audio": "N is for Nest!_N says… Nnnn!_Can you say Nnnn_.mp3", "animal": "Narwhal", "animalEmoji": "🦄"},
    {"letter": "O", "word": "ORANGE", "image": "🍊", "audio": "O is for Orange!_O says… Ohhhh!_Can you say Ohhhh_.mp3", "animal": "Owl", "animalEmoji": "🦉"},
    {"letter": "P", "word": "PIG", "image": "🐷", "audio": "P is for Pig!_P says… Puh!_Can you say Puh_.mp3", "animal": "Piggy", "animalEmoji": "🐷"},
    {"letter": "Q", "word": "QUEEN", "image": "👑", "audio": "Q is for Queen!_Q says… Kwuh!_Can you say Kwuh_.mp3", "animal": "Queen Bee", "animalEmoji": "🐝"},
    {"letter": "R", "word": "RABBIT", "image": "🐰", "audio": "R is for Rabbit!_R says… Ruh!_Can you say Ruh.mp3", "animal": "Rabbit", "animalEmoji": "🐰"},
    {"letter": "S", "word": "SUN", "image": "☀️", "audio": "S is for Sun!_S says… Sss!_Can you say Sss_.mp3", "animal": "Snail", "animalEmoji": "🐌"},
    {"letter": "T", "word": "TIGER", "image": "🐯", "audio": "T is for Tiger!_T says… Tuh!_Can you say Tuh_.mp3", "animal": "Tiger", "animalEmoji": "🐯"},
    {"letter": "U", "word": "UMBRELLA", "image": "☂️", "audio": "U is for Umbrella!_U says… Uh!_Can you say Uh_.mp3", "animal": "Unicorn", "animalEmoji": "🦄"},
    {"letter": "V", "word": "VAN", "image": "🚐", "audio": "V is for Van!_V says… Vuh!_Can you say Vuh_.mp3", "animal": "Vole", "animalEmoji": "🦔"},
    {"letter": "W", "word": "WHALE", "image": "🐋", "audio": "W is for Whale!_W says… Wuh!_Can you say Wuh_.mp3", "animal": "Whale", "animalEmoji": "🐋"},
    {"letter": "X", "word": "XYLOPHONE", "image": "🎹", "audio": "X is for Xylophone!_X says… Eks!_Can you say Eks_.mp3", "animal": "Fox", "animalEmoji": "🦊"},
    {"letter": "Y", "word": "YO-YO", "image": "🪀", "audio": "Y is for Yo-yo!_Y says… Yuh!_Can you say Yuh_.mp3", "animal": "Yak", "animalEmoji": "🐂"},
    {"letter": "Z", "word": "ZEBRA", "image": "🦓", "audio": "Z is for Zebra!_Z says… Zzz!_Can you say Zzz_.mp3", "animal": "Zebra", "animalEmoji": "🦓"},
  ];

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new, color: const Color(0xFF6C63FF), size: 20),
              onPressed: () {
                AdManager.showInterstitial(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        title: Text(
          "Spelling A to Z",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF11153B),
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD9F1FF), Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _spellingData.length,
              itemBuilder: (context, index) {
                final data = _spellingData[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpellingDetailScreen(data: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data['image']!, style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 6),
                        Text(
                          data['letter']!,
                          style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF11153B)),
                        ),
                        const SizedBox(height: 8),
                        // Animal Pairing Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "${data['animalEmoji']} ${data['animal']}",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0277BD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SpellingDetailScreen extends StatefulWidget {
  final Map<String, String> data;
  const SpellingDetailScreen({super.key, required this.data});

  @override
  State<SpellingDetailScreen> createState() => _SpellingDetailScreenState();
}

class _SpellingDetailScreenState extends State<SpellingDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpelling = false;
  bool _gameShown = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSpellingSequence();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4); // Slow for kids
    await _flutterTts.setPitch(1.2); // Child-friendly pitch
    
    _flutterTts.setCompletionHandler(() {
      // Logic handled in sequence
    });
  }

  Future<void> _startSpellingSequence() async {
    setState(() => _isSpelling = true);
    final word = widget.data['word']!;
    
    // 1. Spell letter by letter
    for (int i = 0; i < word.length; i++) {
      if (!mounted) return;
      await _flutterTts.speak(word[i]);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // 2. Say the full word
    if (!mounted) return;
    await _flutterTts.speak(word);
    await Future.delayed(const Duration(milliseconds: 1200));

    // 3. Play the recorded phonics audio
    if (!mounted) return;
    setState(() => _isSpelling = false);
    await MusicManager.playVoiceover(_audioPlayer, 'audio/${widget.data['audio']}');
    await FirebaseRewardsManager.addStars(1);

    // 4. Trigger balloon game once per session for specific checkpoint letters
    final currentLetter = widget.data['letter']!;
    final checkpointLetters = ['E', 'J', 'O', 'T', 'Y'];
    
    if (!_gameShown && checkpointLetters.contains(currentLetter) && mounted) {
      _gameShown = true;
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PhonicsGameDialog(learnedLetters: [currentLetter]),
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFFFFDF5)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 28),
                      onPressed: () {
                        AdManager.showInterstitial(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Big Image
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30)],
                  ),
                  child: Center(
                    child: Text(widget.data['image']!, style: const TextStyle(fontSize: 140)),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Big Spelling
                Text(
                  widget.data['word']!,
                  style: GoogleFonts.nunito(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: const Color(0xFF11153B),
                  ),
                ),

                // Animal Friend Pairing Card
                if (widget.data['animal'] != null)
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFFBBDEFB), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.data['animalEmoji']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          "Animal Friend: ${widget.data['animal']}",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Active Letter Indicator (Optional, but let's keep it simple)
                if (_isSpelling)
                  Lottie.asset('assets/lottie/mascot.json', width: 100, height: 100),

                const Spacer(),
                
                // Replay Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: _startSpellingSequence,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 15)],
                      ),
                      child: Text(
                        "Listen Again",
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
