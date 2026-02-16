import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/events/models/event.dart';

class ShareHelper {
  static Future<void> shareEvent(Event event, String appLink) async {
    final shareText = '''
🎉 ${event.title}
by ${event.organizerName}

📅 When: ${_formatDateTime(event.startDate)}
📍 Where: ${event.location}

${event.description}

Register now: $appLink
''';

    await Share.share(shareText,
        subject: 'Check out this event: ${event.title}');
  }

  static Future<void> launchMap(String location) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
