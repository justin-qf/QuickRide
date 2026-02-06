import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickride/core/models/chat_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<ChatMessage>> streamMessages(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(50) // 🔥 REQUIRED
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String rideId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final chatId = _uuid.v4();
    final chatMessage = ChatMessage(
      id: chatId,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('rides')
        .doc(rideId)
        .collection('chats')
        .doc(chatId)
        .set(chatMessage.toJson());
  }
}
