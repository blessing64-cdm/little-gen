import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'time_limit_lock_screen.dart';

class ParentalTimeManager {
  static int screenTimeLimitMinutes = 0; // 0 means disabled
  static DateTime? sessionStart;
  static DateTime? lockUntil;
  static bool isLocked = false;
  static Timer? _periodicTimer;

  static DocumentReference get _docRef {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_device';
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // Load parent limit settings and lock state from Firestore
  static Future<void> initialize() async {
    try {
      final snapshot = await _docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('screenTimeLimit')) {
          screenTimeLimitMinutes = data['screenTimeLimit'] as int? ?? 0;
        }
        if (data.containsKey('lockUntil')) {
          final timestamp = data['lockUntil'] as Timestamp?;
          lockUntil = timestamp?.toDate();
          if (lockUntil != null && DateTime.now().isBefore(lockUntil!)) {
            isLocked = true;
          }
        }
      }
    } catch (e) {
      debugPrint("ParentalTimeManager initialization error: $e");
    }
  }

  // Set time limit in Firestore
  static void saveSettings(int limitMinutes) {
    screenTimeLimitMinutes = limitMinutes;
    // Reset session start when setting is changed
    sessionStart = DateTime.now();

    // Fire and forget Firebase update
    _docRef.update({
      'screenTimeLimit': limitMinutes
    }).catchError((e) {
      _docRef.set({
        'screenTimeLimit': limitMinutes
      }, SetOptions(merge: true));
    });
  }

  // Start checking elapsed play time
  static void startMonitoring(BuildContext context) {
    _periodicTimer?.cancel();
    sessionStart ??= DateTime.now();

    // Check every 5 seconds for lighter CPU usage
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkTimeLimit(context);
    });
  }

  static void stopMonitoring() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  static void _checkTimeLimit(BuildContext context) {
    if (isLocked) return;

    // Check if cooldown lock is active (e.g. they re-opened the app)
    if (lockUntil != null && DateTime.now().isBefore(lockUntil!)) {
      _lockAppImmediately(context);
      return;
    }

    if (screenTimeLimitMinutes <= 0) return;

    final elapsed = DateTime.now().difference(sessionStart!).inMinutes;
    if (elapsed >= screenTimeLimitMinutes) {
      _lockAppImmediately(context);
    }
  }

  // Lock the app and update Firestore status
  static void _lockAppImmediately(BuildContext context) {
    isLocked = true;
    
    // Set 30-minute cooldown timer
    lockUntil = DateTime.now().add(const Duration(minutes: 30));
    
    // Fire and forget Firebase update
    _docRef.update({
      'lockUntil': Timestamp.fromDate(lockUntil!)
    }).catchError((e) {
      _docRef.set({
        'lockUntil': Timestamp.fromDate(lockUntil!)
      }, SetOptions(merge: true));
    });

    // Direct redirection to the lock screen, wiping previous history
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TimeLimitLockScreen()),
        (route) => false, // Clears everything from screen
      );
    }
  }

  // Bypass or unlock lock state
  static void resetLock() {
    isLocked = false;
    lockUntil = null;
    sessionStart = DateTime.now();
    
    // Fire and forget Firebase update
    _docRef.update({
      'lockUntil': FieldValue.delete()
    }).catchError((e) {
      debugPrint("Failed to delete lockUntil: $e");
    });
  }
}
