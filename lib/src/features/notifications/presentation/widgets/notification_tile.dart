import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.jobApplication:
        return Icons.work_outline;
      case NotificationType.newJob:
        return Icons.business_center;
      case NotificationType.chat:
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications;
    }
  }

  void _handleTap(BuildContext context) {
    onTap(); // Mark as read

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.jobApplication:
      case NotificationType.newJob:
        if (notification.jobId != null) {
          Navigator.pushNamed(
            context,
            '/job-details',
            arguments: notification.jobId,
          );
        }
        break;
      case NotificationType.chat:
        Navigator.pushNamed(context, '/chat');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown notification type.')),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? Colors.grey[200]
            : Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          _getIcon(),
          color: notification.isRead
              ? Colors.grey[600]
              : Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            timeago.format(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _handleTap(context),
      isThreeLine: true,
    );
  }
}
