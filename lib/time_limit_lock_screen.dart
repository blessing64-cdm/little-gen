import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'parental_time_manager.dart';
import 'home_menu_screen.dart';
import 'parent_gate_dialog.dart';

class TimeLimitLockScreen extends StatefulWidget {
  const TimeLimitLockScreen({super.key});

  @override
  State<TimeLimitLockScreen> createState() => _TimeLimitLockScreenState();
}

class _TimeLimitLockScreenState extends State<TimeLimitLockScreen> {
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startCountdown();
  }

  void _calculateRemainingTime() {
    if (ParentalTimeManager.lockUntil != null) {
      final diff = ParentalTimeManager.lockUntil!.difference(DateTime.now());
      if (diff.isNegative) {
        _remainingTime = Duration.zero;
      } else {
        _remainingTime = diff;
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateRemainingTime();
        if (_remainingTime == Duration.zero) {
          _countdownTimer?.cancel();
          _autoUnlock();
        }
      });
    });
  }

  void _autoUnlock() {
    ParentalTimeManager.resetLock();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeMenuScreen()),
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _verifyParentUnlock() {
    ParentGateDialog.show(
      context,
      onSuccess: () {
        ParentalTimeManager.resetLock();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeMenuScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F1FF), // Soft eye-friendly blue
      body: SafeArea(
        child: Stack(
          children: [
            // Settings Bypass Button in top right
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.settings, size: 30, color: Color(0xFF11153B)),
                onPressed: _verifyParentUnlock,
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sleeping/Winking Mascot Lottie
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(
                        'assets/lottie/mascot.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      "Time to Take a Break! 🕒",
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11153B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Great job learning today! Please rest your eyes for a bit and play again soon.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF11153B).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Countdown Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF11153B).withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2), width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Play Time Unlocks In",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_remainingTime),
                            style: GoogleFonts.nunito(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
