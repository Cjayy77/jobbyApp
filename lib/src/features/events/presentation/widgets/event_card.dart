import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String organizerName;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final List<String> categories;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final double? ticketPrice;

  const EventCard({
    super.key,
    required this.title,
    required this.organizerName,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    required this.categories,
    required this.onTap,
    required this.isSaved,
    required this.onSaveToggle,
    this.ticketPrice,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    String eventStatus;
    Color statusColor;
    final now = DateTime.now();

    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      eventStatus = 'Today';
      statusColor = Colors.green; // Green for today
    } else if (endDate.isBefore(now)) {
      eventStatus = 'Event Finished';
      statusColor = Colors.red; // Red for finished events
    } else {
      eventStatus = dateFormat.format(startDate);
      statusColor = Colors.grey; // Grey for upcoming events
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color:
                              isSaved ? Theme.of(context).primaryColor : null,
                        ),
                        onPressed: onSaveToggle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    organizerName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(location),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(startDate)),
                      if (!startDate.isAtSameMomentAs(endDate)) ...[
                        Text(' - '),
                        Text(dateFormat.format(endDate)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(timeFormat.format(startDate)),
                    ],
                  ),
                  if (ticketPrice != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat.currency(
                            symbol: 'XAF ',
                            decimalDigits: 0,
                          ).format(ticketPrice),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categories.map((category) {
                      return Chip(
                        label: Text(category),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
