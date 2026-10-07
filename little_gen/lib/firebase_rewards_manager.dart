import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FirebaseRewardsManager {
  static final List<String> allEmojis = [
    "🦁", "🐱", "🐶", "🐼", "🦊", "🐸", "🐵", "🦄",
    "🌟", "🎈", "🚀", "🎨", "🎸", "⚽", "🚗", "🧸",
    "🍎", "🍓", "🍉", "🍕", "🍔", "🍦", "🍭", "🍩"
  ];

  // Default starting emojis (only 1 unlocked initially)
  static List<String> unlockedEmojis = ["🦁"];

  // Real stars earned tracked in profile
  static int starsEarned = 0;
  
  // Real activity metrics
  static int wordsBuilt = 0;
  static int lettersTraced = 0;
  static int shapesMatched = 0;
  static int numbersCounted = 0;
  static int storiesRead = 0;
  static int drawingsColored = 0;
  
  static bool isProfileCreated = false;
  static String childName = '';
  static String childAge = '';

  static final ValueNotifier<int> rewardsNotifier = ValueNotifier<int>(0);

  static List<String> get lockedEmojis {
    return allEmojis.where((e) => !unlockedEmojis.contains(e)).toList();
  }

  // Keys for SharedPreferences
  static const String _keyProfileCreated = 'rewards_profile_created';
  static const String _keyChildName = 'rewards_child_name';
  static const String _keyChildAge = 'rewards_child_age';
  static const String _keyUnlockedEmojis = 'rewards_unlocked_emojis';
  static const String _keyStarsEarned = 'rewards_stars_earned';
  static const String _keyLastRewardTime = 'rewards_last_reward_time';
  
  static const String _keyWordsBuilt = 'rewards_words_built';
  static const String _keyLettersTraced = 'rewards_letters_traced';
  static const String _keyShapesMatched = 'rewards_shapes_matched';
  static const String _keyNumbersCounted = 'rewards_numbers_counted';
  static const String _keyStoriesRead = 'rewards_stories_read';
  static const String _keyDrawingsColored = 'rewards_drawings_colored';

  // Load from local SharedPreferences
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isProfileCreated = prefs.getBool(_keyProfileCreated) ?? false;
      childName = prefs.getString(_keyChildName) ?? '';
      childAge = prefs.getString(_keyChildAge) ?? '';
      starsEarned = prefs.getInt(_keyStarsEarned) ?? 0;
      
      wordsBuilt = prefs.getInt(_keyWordsBuilt) ?? 0;
      lettersTraced = prefs.getInt(_keyLettersTraced) ?? 0;
      shapesMatched = prefs.getInt(_keyShapesMatched) ?? 0;
      numbersCounted = prefs.getInt(_keyNumbersCounted) ?? 0;
      storiesRead = prefs.getInt(_keyStoriesRead) ?? 0;
      drawingsColored = prefs.getInt(_keyDrawingsColored) ?? 0;
      
      final emojis = prefs.getStringList(_keyUnlockedEmojis);
      if (emojis != null && emojis.isNotEmpty) {
        unlockedEmojis = List<String>.from(emojis);
      } else {
        unlockedEmojis = ["🦁"];
      }
      
      rewardsNotifier.value++;
    } catch (e) {
      debugPrint("Local Rewards init error: $e");
    }
  }

  // Check if reward popup should be shown (approx 3 times a week)
  static Future<bool> shouldShowReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReward = prefs.getInt(_keyLastRewardTime);
      if (lastReward != null) {
        final DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(lastReward);
        final Duration diff = DateTime.now().difference(lastTime);
        if (diff.inDays >= 2) {
          return true;
        }
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("Error checking reward time: $e");
      return false;
    }
  }

  // Update last reward popup timestamp
  static Future<void> updateLastRewardTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastRewardTime, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("Error updating reward time: $e");
    }
  }

  // Unlock and save to local storage
  static Future<String?> unlockRandomEmoji() async {
    final locked = lockedEmojis;
    if (locked.isEmpty) return null;

    final random = Random();
    final newEmoji = locked[random.nextInt(locked.length)];
    unlockedEmojis.add(newEmoji);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyUnlockedEmojis, unlockedEmojis);
    } catch (e) {
      debugPrint("Local update error: $e");
    }
    
    rewardsNotifier.value++;
    debugPrint("Unlocked new emoji: $newEmoji");
    return newEmoji;
  }

  // Increment stars and save locally
  static Future<void> incrementStars() async {
    starsEarned++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyStarsEarned, starsEarned);
    } catch (e) {
      debugPrint("Local update stars error: $e");
    }
    rewardsNotifier.value++;
  }

  // Add multiple stars and save locally
  static Future<void> addStars(int count) async {
    starsEarned += count;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyStarsEarned, starsEarned);
    } catch (e) {
      debugPrint("Local update stars error: $e");
    }
    rewardsNotifier.value++;
  }

  // Spend stars and save locally
  static Future<bool> spendStars(int count) async {
    if (starsEarned < count) return false;
    starsEarned -= count;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyStarsEarned, starsEarned);
    } catch (e) {
      debugPrint("Local spend stars error: $e");
    }
    rewardsNotifier.value++;
    return true;
  }

  // Record Activity Helpers
  static Future<void> recordWordBuilt([int count = 1]) async {
    wordsBuilt += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWordsBuilt, wordsBuilt);
    rewardsNotifier.value++;
  }

  static Future<void> recordLetterTraced([int count = 1]) async {
    lettersTraced += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLettersTraced, lettersTraced);
    rewardsNotifier.value++;
  }

  static Future<void> recordShapeMatched([int count = 1]) async {
    shapesMatched += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShapesMatched, shapesMatched);
    rewardsNotifier.value++;
  }

  static Future<void> recordNumberCounted([int count = 1]) async {
    numbersCounted += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNumbersCounted, numbersCounted);
    rewardsNotifier.value++;
  }

  static Future<void> recordStoryRead([int count = 1]) async {
    storiesRead += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStoriesRead, storiesRead);
    rewardsNotifier.value++;
  }

  static Future<void> recordDrawingColored([int count = 1]) async {
    drawingsColored += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDrawingsColored, drawingsColored);
    rewardsNotifier.value++;
  }

  // Create Profile
  static Future<void> createProfile(String name, String age) async {
    isProfileCreated = true;
    childName = name;
    childAge = age;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyProfileCreated, true);
      await prefs.setString(_keyChildName, name);
      await prefs.setString(_keyChildAge, age);
      await prefs.setStringList(_keyUnlockedEmojis, unlockedEmojis);
      await prefs.setInt(_keyStarsEarned, starsEarned);
    } catch (e) {
      debugPrint("Error creating profile: $e");
    }
    rewardsNotifier.value++;
  }
}

