import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_rewards_manager.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseRewardsManager.rewardsNotifier.addListener(_onRewardsUpdated);
  }

  @override
  void dispose() {
    FirebaseRewardsManager.rewardsNotifier.removeListener(_onRewardsUpdated);
    super.dispose();
  }

  void _onRewardsUpdated() {
    setState(() {}); // Rebuild to show newly unlocked emojis
  }

  Future<void> _unlockEmojiWithStars() async {
    if (FirebaseRewardsManager.starsEarned < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Need 10 🌟 to unlock a new sticker!",
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          backgroundColor: const Color(0xFFFF6F61),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await FirebaseRewardsManager.spendStars(10);
    if (success) {
      final newSticker = await FirebaseRewardsManager.unlockRandomEmoji();
      if (newSticker != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎉 Unlocked new sticker: $newSticker!",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            backgroundColor: const Color(0xFF2EC4B6),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "All stickers are already unlocked! 🌟",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            backgroundColor: const Color(0xFF6C63FF),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEmojis = FirebaseRewardsManager.allEmojis;
    final unlockedEmojis = FirebaseRewardsManager.unlockedEmojis;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7CC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11153B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "My Rewards",
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            "${FirebaseRewardsManager.starsEarned}",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect Stickers (${unlockedEmojis.length}/${allEmojis.length})",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF11153B).withOpacity(0.8),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB703),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 2,
                      ),
                      onPressed: _unlockEmojiWithStars,
                      icon: const Icon(Icons.stars_rounded, size: 18),
                      label: Text(
                        "Unlock (10 🌟)",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Grid of emojis
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: allEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = allEmojis[index];
                    final isUnlocked = unlockedEmojis.contains(emoji);
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isUnlocked ? Colors.white : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isUnlocked ? [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: isUnlocked 
                          ? Text(emoji, style: const TextStyle(fontSize: 40))
                          : const Icon(Icons.lock, color: Colors.grey, size: 30),
                      ),
                    );
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
