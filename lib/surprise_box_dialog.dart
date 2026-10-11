import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'firebase_rewards_manager.dart';

class SurpriseBoxDialog extends StatefulWidget {
  const SurpriseBoxDialog({super.key});

  @override
  State<SurpriseBoxDialog> createState() => _SurpriseBoxDialogState();
}

class _SurpriseBoxDialogState extends State<SurpriseBoxDialog> with TickerProviderStateMixin {
  int? _selectedIndex;
  late int _winningIndex;
  bool _isOpened = false;
  String? _wonEmoji;

  @override
  void initState() {
    super.initState();
    _winningIndex = Random().nextInt(3); // 0, 1, or 2
  }

  void _onBoxTapped(int index) async {
    if (_isOpened) return;

    setState(() {
      _selectedIndex = index;
      _isOpened = true;
    });
      
    if (index == _winningIndex) {
      final emoji = await FirebaseRewardsManager.unlockRandomEmoji();
      if (mounted) {
        setState(() {
          _wonEmoji = emoji;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF6C63FF), width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isOpened ? (_selectedIndex == _winningIndex ? "You Won!" : "Empty!") : "Pick a Box!",
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF11153B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isOpened 
                ? (_selectedIndex == _winningIndex ? "You found a new sticker!" : "Try again next time!") 
                : "One of these boxes contains a surprise sticker!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF11153B).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return _buildBox(index);
              }),
            ),
            
            const SizedBox(height: 30),
            
            if (_isOpened)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  "Awesome!",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    final isSelected = _selectedIndex == index;
    final isWinner = index == _winningIndex;

    return GestureDetector(
      onTap: () => _onBoxTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _isOpened 
            ? (isSelected ? (isWinner ? const Color(0xFFE2F6E1) : const Color(0xFFFFE5E5)) : Colors.grey.shade200)
            : const Color(0xFFD9F1FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isOpened ? [] : [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isOpened
              ? (isSelected
                  ? (isWinner
                      ? Text(_wonEmoji ?? "🎁", style: const TextStyle(fontSize: 32))
                      : const Text("💨", style: TextStyle(fontSize: 32)))
                  : const Text("🎁", style: TextStyle(fontSize: 32, color: Colors.grey)))
              : const Text("🎁", style: TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}
