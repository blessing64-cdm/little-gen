import 'package:flutter/foundation.dart';
import 'dart:math';

class RewardsManager {
  // All possible emojis that can be unlocked
  static final List<String> allEmojis = [
    "🦁", "🐱", "🐶", "🐼", "🦊", "🐸", "🐵", "🦄",
    "🌟", "🎈", "🚀", "🎨", "🎸", "⚽", "🚗", "🧸",
    "🍎", "🍓", "🍉", "🍕", "🍔", "🍦", "🍭", "🍩"
  ];

  // Emojis that the user starts with
  static List<String> unlockedEmojis = ["🦁"];

  // Helper to get locked emojis
  static List<String> get lockedEmojis {
    return allEmojis.where((e) => !unlockedEmojis.contains(e)).toList();
  }

  // ValueNotifier to trigger rebuilds when an emoji is unlocked
  static final ValueNotifier<int> rewardsNotifier = ValueNotifier<int>(0);

  // Randomly unlock a new emoji. Returns the emoji if successful, or null if all are unlocked.
  static String? unlockRandomEmoji() {
    final locked = lockedEmojis;
    if (locked.isEmpty) return null;

    final random = Random();
    final newEmoji = locked[random.nextInt(locked.length)];
    unlockedEmojis.add(newEmoji);
    
    // Notify listeners
    rewardsNotifier.value++;
    
    debugPrint("Unlocked new emoji: $newEmoji");
    return newEmoji;
  }
}
