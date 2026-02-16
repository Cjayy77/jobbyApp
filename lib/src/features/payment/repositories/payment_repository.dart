import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> savePayment(Payment payment) async {
    try {
      await _firestore
          .collection('payments')
          .doc(payment.id)
          .set(payment.toJson());
    } catch (e) {
      throw Exception('Failed to save payment: $e');
    }
  }

  Future<Payment?> getPayment(String id) async {
    try {
      final doc = await _firestore.collection('payments').doc(id).get();
      if (doc.exists) {
        return Payment.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  Stream<List<Payment>> getPaymentsByUser(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromJson(doc.data()))
            .toList());
  }
}