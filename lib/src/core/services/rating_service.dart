import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingService {
  static const String _launchCountKey = 'app_launch_count';
  static const String _lastRatingPromptKey = 'last_rating_prompt';
  static const String _hasRatedKey = 'has_rated_app';

  Future<bool> shouldShowRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Don't show if user has already rated
    if (prefs.getBool(_hasRatedKey) ?? false) {
      return false;
    }

    // Get launch count
    final launchCount = prefs.getInt(_launchCountKey) ?? 0;
    await prefs.setInt(_launchCountKey, launchCount + 1);

    // Get last prompt date
    final lastPrompt = prefs.getInt(_lastRatingPromptKey);
    final lastPromptDate = lastPrompt != null
        ? DateTime.fromMillisecondsSinceEpoch(lastPrompt)
        : null;

    // Show rating prompt if:
    // 1. App has been launched at least 5 times, and
    // 2. Last prompt was more than 30 days ago or never shown
    if (launchCount >= 5 &&
        (lastPromptDate == null ||
            DateTime.now().difference(lastPromptDate).inDays >= 30)) {
      await prefs.setInt(
          _lastRatingPromptKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    }

    return false;
  }

  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  Future<void> showRatingDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enjoying Jobby?'),
        content: const Text(
            'If you find Jobby helpful, please take a moment to rate it on the store. Your feedback helps us improve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );

    if (result == true) {
      final storeUrl = Theme.of(context).platform == TargetPlatform.iOS
          ? 'https://apps.apple.com/app/id[YOUR_APP_ID]' // Replace with actual App Store ID
          : 'https://play.google.com/store/apps/details?id=cm.jobby.app'; // Replace with actual Package name

      if (await canLaunchUrl(Uri.parse(storeUrl))) {
        await launchUrl(Uri.parse(storeUrl));
        await markAsRated();
      }
    }
  }
}
