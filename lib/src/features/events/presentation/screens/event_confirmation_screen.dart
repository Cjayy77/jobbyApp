import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../../../payment/models/payment.dart';
import '../../../payment/providers/payment_provider.dart';

class EventConfirmationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> eventData;

  const EventConfirmationScreen({
    super.key,
    required this.eventData,
  });

  @override
  ConsumerState<EventConfirmationScreen> createState() =>
      _EventConfirmationScreenState();
}

class _EventConfirmationScreenState
    extends ConsumerState<EventConfirmationScreen> {
  bool _isProcessingPayment = false;
  String _selectedPaymentMethod = 'mtn';
  final _phoneController = TextEditingController();
  Timer? _statusCheckTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      await ref.read(paymentProvider.notifier).initiatePayment(
            phoneNumber: _phoneController.text,
            amount: 500, // Event posting fee: 500 XAF
            method: _selectedPaymentMethod == 'mtn'
                ? PaymentMethod.mtn
                : PaymentMethod.orange,
          );

      _startPaymentStatusCheck();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _startPaymentStatusCheck() {
    const checkInterval = Duration(seconds: 5);
    _statusCheckTimer = Timer.periodic(checkInterval, (timer) async {
      final payment = ref.read(paymentProvider).value;
      if (payment != null) {
        await ref.read(paymentProvider.notifier).checkPaymentStatus(payment.id);

        if (payment.status == PaymentStatus.successful) {
          timer.cancel();
          _createEvent();
        } else if (payment.status == PaymentStatus.failed) {
          timer.cancel();
          if (mounted) {
            setState(() => _isProcessingPayment = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Payment failed. Please try again.')),
            );
          }
        }
      }
    });
  }

  Future<void> _createEvent() async {
    if (!mounted) return;

    try {
      final event = Event(
        id: '',
        title: widget.eventData['title'],
        description: widget.eventData['description'],
        organizerId: widget.eventData['organizerId'],
        organizerName: widget.eventData['organizerName'],
        location: widget.eventData['location'],
        startDateTime: widget.eventData['startDateTime'],
        endDateTime: widget.eventData['endDateTime'],
        maxAttendees: widget.eventData['maxAttendees'],
        attendees: const [],
        categories: List<String>.from(widget.eventData['categories']),
        imageUrl: widget.eventData['imageUrl'],
        ticketPrice: widget.eventData['ticketPrice'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(eventsProvider.notifier).createEvent(event);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview your event',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            EventCard(
              title: widget.eventData['title'],
              organizerName: widget.eventData['organizerName'],
              location: widget.eventData['location'],
              startDate: widget.eventData['startDateTime'],
              endDate: widget.eventData['endDateTime'],
              imageUrl: widget.eventData['imageUrl'],
              categories: List<String>.from(widget.eventData['categories']),
              onTap: () {}, // Disabled in preview
              isSaved: false,
              onSaveToggle: () {}, // Not needed in preview
              ticketPrice: widget.eventData['ticketPrice'],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Posting Fee',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '500 XAF',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your mobile money number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Methods:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Image.asset(
                        'assets/images/mtn_momo.png',
                        width: 40,
                        height: 40,
                      ),
                      title: const Text('MTN Mobile Money'),
                      trailing: Radio<String>(
                        value: 'mtn',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                      ),
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/images/orange_money.png',
                        width: 40,
                        height: 40,
                      ),
                      title: const Text('Orange Money'),
                      trailing: Radio<String>(
                        value: 'orange',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            payment.when(
              data: (data) => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isProcessingPayment ? null : _processPayment,
                  child: _isProcessingPayment
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Processing Payment...'),
                          ],
                        )
                      : const Text('Pay & Create Event'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isProcessingPayment)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Edit Event Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
