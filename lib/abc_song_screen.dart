import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'music_manager.dart';
import 'ad_manager.dart';

class ABCSongScreen extends StatefulWidget {
  const ABCSongScreen({super.key});

  @override
  State<ABCSongScreen> createState() => _ABCSongScreenState();
}

class _ABCSongScreenState extends State<ABCSongScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _musicController;
  bool _isPlaying = false;
  bool _isRepeat = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  int _currentSongIndex = 0;
  final List<Map<String, String>> _songs = [
    {
      "title": "Sing Along A-B-C",
      "file": "audio/Sing Along A-B-C.mp3",
      "lyrics": "A B C D E F G\nH I J K L M N O P\nQ R S T U V\nW X Y and Z\nNow I know my ABCs\nNext time won't you sing with me!"
    },
    {
      "title": "My Little Letter Friends",
      "file": "audio/My Little Letter Friends.mp3",
      "lyrics": "Hello friends, let's learn today\nABC is the fun way!\nA for Apple, B for Ball\nWe love letters, one and all!"
    },
    {
      "title": "Classic ABC Song",
      "file": "audio/Classic ABC Song.mp3",
      "lyrics": "A B C D E F G\nH I J K L M N O P\nQ R S T U V\nW X Y and Z\nHappy, happy we shall be\nWhen we learn our ABC!"
    }
  ];

  @override
  void initState() {
    super.initState();
    _musicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        if (_isRepeat) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play(AssetSource(_songs[_currentSongIndex]['file']!));
        } else {
          _nextSong();
        }
      }
    });

    _loadSong();
  }

  void _loadSong() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = true);
    await _audioPlayer.play(AssetSource(_songs[_currentSongIndex]['file']!));
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
    });
    _loadSong();
  }

  void _prevSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + _songs.length) % _songs.length;
    });
    _loadSong();
  }

  @override
  void dispose() {
    _musicController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.playlist_play_rounded, color: Color(0xFFFF4FA2), size: 35),
              onPressed: _showPlaylist,
            ),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: const Color(0xFFFF4FA2), size: 20),
              onPressed: () {
                AdManager.showInterstitial(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF0F7), Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  _songs[_currentSongIndex]['title']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF11153B),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Dancing Mascot
                Center(
                  child: AnimatedBuilder(
                    animation: _musicController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPlaying ? 1.0 + (_musicController.value * 0.1) : 1.0,
                        child: Transform.rotate(
                          angle: _isPlaying ? (_musicController.value - 0.5) * 0.2 : 0,
                          child: Lottie.asset(
                            'assets/mascot.lottie.json',
                            width: 220,
                            height: 220,
                            animate: _isPlaying,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Lyrics Section
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _songs[_currentSongIndex]['lyrics']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Music Controls
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          activeTrackColor: const Color(0xFFFF4FA2),
                          inactiveTrackColor: const Color(0xFFFF4FA2).withOpacity(0.1),
                          thumbColor: const Color(0xFFFF4FA2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          min: 0,
                          max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                          value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_position), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(_formatDuration(_duration), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(_isRepeat ? Icons.repeat_one_rounded : Icons.repeat_rounded, 
                                       color: _isRepeat ? const Color(0xFFFF4FA2) : Colors.grey),
                            onPressed: () => setState(() => _isRepeat = !_isRepeat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, size: 45),
                            onPressed: _prevSong,
                          ),
                          GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4FA2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 45),
                            onPressed: _nextSong,
                          ),
                          IconButton(
                            icon: const Icon(Icons.shuffle_rounded, color: Colors.grey),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose a Song", style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...List.generate(_songs.length, (index) {
                final isCurrent = _currentSongIndex == index;
                return ListTile(
                  leading: Icon(Icons.music_note_rounded, color: isCurrent ? const Color(0xFFFF4FA2) : Colors.grey),
                  title: Text(_songs[index]['title']!, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  trailing: isCurrent ? const Icon(Icons.play_circle_fill, color: Color(0xFFFF4FA2)) : null,
                  onTap: () {
                    setState(() => _currentSongIndex = index);
                    _loadSong();
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
