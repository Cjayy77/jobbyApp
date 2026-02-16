import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event.dart';

class EventSharingService {
  Future<void> shareEvent(Event event) async {
    final shareText = '''
${event.title}

📅 ${_formatDateTime(event.startDateTime)}
📍 ${event.location}

${event.description}

Organized by: ${event.organizerName}
''';

    await Share.share(shareText, subject: event.title);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} at ${dateTime.hour}:${dateTime.minute}';
  }
}

final eventSharingProvider = Provider<EventSharingService>((ref) {
  return EventSharingService();
});
