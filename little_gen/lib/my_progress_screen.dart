import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'firebase_rewards_manager.dart';

class MyProgressScreen extends StatelessWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Progress", style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF11153B),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: FirebaseRewardsManager.rewardsNotifier,
        builder: (context, _, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard("🌟 Total Stars", "${FirebaseRewardsManager.starsEarned}", Colors.amber.shade700),
                const SizedBox(height: 14),
                _buildStatCard("✏️ Letters Traced", "${FirebaseRewardsManager.lettersTraced}", Colors.purple),
                const SizedBox(height: 14),
                _buildStatCard("🧩 Words Built", "${FirebaseRewardsManager.wordsBuilt}", Colors.orange),
                const SizedBox(height: 14),
                _buildStatCard("🔷 Shapes Matched", "${FirebaseRewardsManager.shapesMatched}", Colors.blue),
                const SizedBox(height: 14),
                _buildStatCard("🔢 Numbers Counted", "${FirebaseRewardsManager.numbersCounted}", Colors.green),
                const SizedBox(height: 14),
                _buildStatCard("📖 Stories Read", "${FirebaseRewardsManager.storiesRead}", Colors.teal),
                const SizedBox(height: 14),
                _buildStatCard("🎨 Drawings Colored", "${FirebaseRewardsManager.drawingsColored}", Colors.pink),
                const SizedBox(height: 30),
                Center(
                  child: Lottie.asset(
                    'assets/lottie/mascot.json',
                    width: 180,
                    height: 180,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF11153B)),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
