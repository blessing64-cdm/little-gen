import 'package:flutter/material.dart';

class AdManager {
  // Completely disable ads as requested for Amazon Fire Tablet build
  static const bool adsEnabled = false;

  // Initialize (no-op)
  static Future<void> initialize() async {
    debugPrint("Ads are disabled for Amazon release.");
  }

  // Preload (no-op)
  static void preloadInterstitial() {}

  // Show Interstitial (no-op)
  static void showInterstitial(BuildContext context) {}
}

