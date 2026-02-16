import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../repositories/payment_repository.dart';
import '../services/payment_service.dart';

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, AsyncValue<Payment?>>((ref) {
  return PaymentNotifier(
    PaymentService(),
    PaymentRepository(),
  );
});

class PaymentNotifier extends StateNotifier<AsyncValue<Payment?>> {
  final PaymentService _paymentService;
  final PaymentRepository _paymentRepository;

  PaymentNotifier(this._paymentService, this._paymentRepository)
      : super(const AsyncValue.data(null));

  Future<void> initiatePayment({
    required String phoneNumber,
    required double amount,
    required PaymentMethod method,
  }) async {
    state = const AsyncValue.loading();

    try {
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        amount: amount,
        currency: 'XAF',
        method: method,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
      );

      // Save initial payment record
      await _paymentRepository.savePayment(payment);

      // Initiate payment with provider
      final transactionId = method == PaymentMethod.mtn
          ? await _paymentService.initiateMTNPayment(
              phoneNumber: phoneNumber,
              amount: amount,
              currency: 'XAF',
              reference: payment.id,
            )
          : await _paymentService.initiateOrangePayment(
              phoneNumber: phoneNumber,
              amount: amount,
              currency: 'XAF',
              reference: payment.id,
              description: 'Payment for job posting',
            );

      // Update payment with transaction ID
      final updatedPayment = payment.copyWith(transactionId: transactionId);
      await _paymentRepository.savePayment(updatedPayment);

      state = AsyncValue.data(updatedPayment);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> checkPaymentStatus(String paymentId) async {
    try {
      final payment = await _paymentRepository.getPayment(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      if (payment.method == PaymentMethod.mtn &&
          payment.transactionId != null) {
        final status =
            await _paymentService.checkMTNPaymentStatus(payment.transactionId!);
        final paymentStatus = PaymentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == status['status'],
          orElse: () => PaymentStatus.failed,
        );
        final updatedPayment = payment.copyWith(status: paymentStatus);
        await _paymentRepository.savePayment(updatedPayment);
        state = AsyncValue.data(updatedPayment);
      }
      // For Orange Money, status updates come through webhooks
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
