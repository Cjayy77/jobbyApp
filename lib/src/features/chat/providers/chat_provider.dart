import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../../../core/providers/firebase_providers.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatNotifier(ref);
});

final chatMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('messages')
      .where('chatId', isEqualTo: chatId)
      .orderBy('sentAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
});

class ChatNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final Ref _ref;
  StreamSubscription<List<Chat>>? _subscription;

  ChatNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final currentUser = _ref.read(firebaseAuthProvider).currentUser;
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      _subscription?.cancel();
      _subscription = FirebaseFirestore.instance
          .collection('chats')
          .where(Filter.or(
            Filter('jobSeekerId', isEqualTo: currentUser.uid),
            Filter('employerId', isEqualTo: currentUser.uid),
          ))
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList())
          .listen(
            (chats) => state = AsyncValue.data(chats),
            onError: (error) =>
                state = AsyncValue.error(error, StackTrace.current),
          );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final currentUser = _ref.read(firebaseAuthProvider).currentUser;
      if (currentUser == null) throw 'User not authenticated';

      final message = Message(
        id: '',
        senderId: currentUser.uid,
        receiverId: '', // Provide a valid receiverId
        content: content,
        timestamp: DateTime.now(), // Use timestamp instead of sentAt
        chatId: chatId,
      );

      // Create message
      await FirebaseFirestore.instance
          .collection('messages')
          .add(message.toFirestore());

      // Update chat's lastMessageAt
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .update({'lastMessageAt': Timestamp.fromDate(message.timestamp)});
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
