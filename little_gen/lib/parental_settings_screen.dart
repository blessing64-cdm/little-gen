import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_rewards_manager.dart';
import 'parental_time_manager.dart';
import 'music_manager.dart';
import 'profile_screen.dart';
import 'create_profile_screen.dart';
import 'billing_service.dart';
import 'paywall_screen.dart';

class ParentalSettingsScreen extends StatefulWidget {
  const ParentalSettingsScreen({super.key});

  @override
  State<ParentalSettingsScreen> createState() => _ParentalSettingsScreenState();
}

class _ParentalSettingsScreenState extends State<ParentalSettingsScreen> {
  int _selectedMinutes = ParentalTimeManager.screenTimeLimitMinutes;
  bool _bgmEnabled = MusicManager.isBgmEnabled;
  bool _voiceoverEnabled = MusicManager.isVoiceoverEnabled;

  @override
  Widget build(BuildContext context) {
    final hasProfile = FirebaseRewardsManager.isProfileCreated;
    final childName = FirebaseRewardsManager.childName.isEmpty
        ? "Little Explorer"
        : FirebaseRewardsManager.childName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11153B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Parental Controls",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF11153B),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  "Parent Zone",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: FirebaseRewardsManager.rewardsNotifier,
          builder: (context, _, __) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Safe Mode Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Adult-Only Protected Zone",
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Manage your child's profile, adjust playtime limits, and customize learning features.",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Full Version Unlock (Amazon In-App Purchase)
                Consumer<BillingService>(
                  builder: (context, billing, _) {
                    final isUnlocked = billing.isPremiumUnlocked;
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUnlocked
                              ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                              : [const Color(0xFFFF8008), const Color(0xFFFFC837)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isUnlocked ? Colors.green : Colors.orange).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isUnlocked ? '🎉' : '👑',
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUnlocked
                                          ? "Full Version Unlocked"
                                          : "Full Version Unlock (\$3.99)",
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      isUnlocked
                                          ? "All activities & future updates unlocked!"
                                          : "Unlock 6 extra learning activities",
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: isUnlocked
                                    ? Colors.green.shade800
                                    : const Color(0xFFD84315),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PaywallScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                isUnlocked
                                    ? "✓ Full Version Unlocked — View Status"
                                    : "View Unlock Price & Details (\$3.99)",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Section 1: Child Profile & Learning Progress
                _buildSectionHeader("Child Profile & Learning Progress"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7CC),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              FirebaseRewardsManager.unlockedEmojis.isNotEmpty
                                  ? FirebaseRewardsManager.unlockedEmojis.first
                                  : "🦁",
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  childName,
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF11153B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Stars Earned: ${FirebaseRewardsManager.starsEarned} 🌟",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            onPressed: () {
                              if (!hasProfile) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateProfileScreen(
                                      nextScreen: ProfileScreen(),
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              hasProfile ? "View Profile" : "Create Profile",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Detailed Real Activity Progress Summary
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildStatBadge("✏️ Traced", "${FirebaseRewardsManager.lettersTraced}"),
                          _buildStatBadge("🧩 Words", "${FirebaseRewardsManager.wordsBuilt}"),
                          _buildStatBadge("🔷 Shapes", "${FirebaseRewardsManager.shapesMatched}"),
                          _buildStatBadge("🔢 Numbers", "${FirebaseRewardsManager.numbersCounted}"),
                          _buildStatBadge("📖 Stories", "${FirebaseRewardsManager.storiesRead}"),
                          _buildStatBadge("🎨 Drawings", "${FirebaseRewardsManager.drawingsColored}"),
                        ],
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 24),

            // Section 2: Screen Time Controls
            _buildSectionHeader("Screen Time Limit"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daily Playtime Limit",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF11153B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedMinutes == 0
                              ? "Unlimited"
                              : "$_selectedMinutes Minutes",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [0, 15, 30, 45, 60].map((mins) {
                      final isSelected = _selectedMinutes == mins;
                      return ChoiceChip(
                        label: Text(mins == 0 ? "Unlimited" : "$mins min"),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6C63FF),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: GoogleFonts.nunito(
                          color: isSelected ? Colors.white : const Color(0xFF11153B),
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMinutes = mins;
                            });
                            ParentalTimeManager.saveSettings(mins);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  mins == 0
                                      ? "Screen time set to Unlimited"
                                      : "Screen time limit saved: $mins minutes",
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF6C63FF),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "When the limit expires, the app will show a friendly break screen with a sleep animation.",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Audio & Sounds
            _buildSectionHeader("Audio Preferences"),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      "Background Music",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    subtitle: Text(
                      "Play cheerful tunes during learning",
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey),
                    ),
                    value: _bgmEnabled,
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (val) {
                      setState(() {
                        _bgmEnabled = val;
                        MusicManager.isBgmEnabled = val;
                        if (val) {
                          MusicManager.resumeBgm();
                        } else {
                          MusicManager.stopBgm();
                        }
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      "Spoken Voiceovers",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    subtitle: Text(
                      "Audio guides for phonics, numbers & stories",
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey),
                    ),
                    value: _voiceoverEnabled,
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (val) {
                      setState(() {
                        _voiceoverEnabled = val;
                        MusicManager.isVoiceoverEnabled = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Return to Kids Mode Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF11153B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
              ),
              onPressed: () => Navigator.pop(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care_rounded, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Back to Little Gen Kids Mode",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    ),
  ),
);
}

  Widget _buildStatBadge(String title, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF11153B),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Colors.grey.shade800,
        letterSpacing: 0.3,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
