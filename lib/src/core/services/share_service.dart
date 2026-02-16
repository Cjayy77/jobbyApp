import 'package:share_plus/share_plus.dart';
import '../../features/events/models/event.dart';
import 'package:intl/intl.dart';

class ShareService {
  static Future<void> shareEvent(Event event) async {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final message = '''
Check out this event!

${event.title}
by ${event.organizerName}

📅 ${dateFormat.format(event.startDate)} at ${timeFormat.format(event.startDate)}
📍 ${event.location}

${event.description}

${event.ticketPrice != null ? '🎟 ${NumberFormat.currency(symbol: 'XAF ', decimalDigits: 0).format(event.ticketPrice)}' : 'Free Entry'}

Categories: ${event.categories.join(', ')}

Register now on our app!
''';

    await Share.share(message, subject: 'Check out: ${event.title}');
  }
}
