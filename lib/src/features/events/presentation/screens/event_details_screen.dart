import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../auth/providers/auth_provider.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isLoading = false;

  Future<void> _registerForEvent() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(eventsProvider.notifier).registerForEvent(widget.event.id);
      await NotificationService().scheduleEventReminder(
        widget.event.id,
        widget.event.title,
        widget.event.startDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered for event!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(eventsProvider.notifier).deleteEvent(widget.event.id);
      await NotificationService().cancelEventReminder(
        widget.event.id,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting event: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final isOrganizer = currentUser?.uid == widget.event.organizerId;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (isOrganizer) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(
                context,
                '/event-edit',
                arguments: widget.event,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteEvent,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ShareService.shareEvent(widget.event),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.event.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.event.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${widget.event.organizerName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(dateFormat.format(widget.event.startDate)),
                    subtitle: Text(timeFormat.format(widget.event.startDate)),
                  ),
                  if (widget.event.startDate != widget.event.endDate)
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                          'Until ${dateFormat.format(widget.event.endDate)}'),
                      subtitle: Text(timeFormat.format(widget.event.endDate)),
                    ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(widget.event.location),
                  ),
                  if (widget.event.ticketPrice != null)
                    ListTile(
                      leading: const Icon(Icons.payments),
                      title: Text(
                        NumberFormat.currency(
                          symbol: 'XAF ',
                          decimalDigits: 0,
                        ).format(widget.event.ticketPrice),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.event.description),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: widget.event.categories.map((category) {
                      return Chip(label: Text(category));
                    }).toList(),
                  ),
                  if (widget.event.maxAttendees > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Attendees: ${widget.event.attendees.length}/${widget.event.maxAttendees}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    LinearProgressIndicator(
                      value: widget.event.attendees.length /
                          widget.event.maxAttendees,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isOrganizer
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isLoading ? null : _registerForEvent,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.event.ticketPrice != null
                              ? 'Register - XAF ${NumberFormat('#,###').format(widget.event.ticketPrice)}'
                              : 'Register for Free',
                        ),
                ),
              ),
            )
          : null,
    );
  }
}
