import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class FirebaseChatService {
  static final FirebaseChatService _instance = FirebaseChatService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseChatService() {
    return _instance;
  }

  FirebaseChatService._internal();

  // Get conversations stream for current user
  Stream<List<ChatConversation>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final participants = List<String>.from(doc['participants'] ?? []);
            final otherUserId =
                participants.firstWhere((id) => id != userId, orElse: () => '');

            return ChatConversation(
              id: doc.id,
              participantId: otherUserId,
              participantName: doc['participantName'] ?? 'Unknown',
              participantAvatar: doc['participantAvatar'] ?? '',
              lastMessage: doc['lastMessage'] ?? '',
              lastMessageTime:
                  (doc['lastMessageTime'] as Timestamp).toDate(),
              unreadCount: (doc['unreadBy'] ?? []).contains(userId) ? 1 : 0,
              isOnline: doc['isOnline'] ?? false,
            );
          }).toList();
        });
  }

  // Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage(
              id: doc.id,
              senderId: doc['senderId'] ?? '',
              senderName: doc['senderName'] ?? 'Unknown',
              content: doc['content'] ?? '',
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
              isRead: doc['isRead'] ?? false,
            );
          }).toList();
        });
  }

  // Send message
  Future<void> sendMessage({
    required String conversationId,
    required String userId,
    required String content,
    required DateTime timestamp,
  }) async {
    try {
      // Get sender name from current user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final senderName = userDoc['name'] ?? 'Unknown';

      // Add message to messages collection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': userId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp,
        'isRead': false,
      });

      // Update last message in conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': content,
        'lastMessageTime': timestamp,
        'lastSenderId': userId,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Create or get conversation
  Future<ChatConversation?> getOrCreateConversation({
    required List<String> participants,
    required List<String> participantNames,
  }) async {
    try {
      if (participants.isEmpty) return null;

      final userId1 = participants[0];

      // Query existing conversation
      final query = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in query.docs) {
        final docParticipants = List<String>.from(doc['participants'] ?? []);
        if (docParticipants.length == participants.length &&
            docParticipants.every((p) => participants.contains(p))) {
          return _conversationFromFirestore(doc);
        }
      }

      // Create new conversation if it doesn't exist
      final docRef = await _firestore.collection('conversations').add({
        'participants': participants,
        'participantName': participantNames.isNotEmpty ? participantNames[1] : 'User',
        'participantAvatar':
            participantNames.isNotEmpty ? participantNames[1].substring(0, 1).toUpperCase() : 'U',
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
        'lastSenderId': '',
        'unreadBy': [],
        'isOnline': false,
      });

      final newDoc = await docRef.get();
      return _conversationFromFirestore(newDoc);
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  ChatConversation _conversationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final currentUserId = participants.isNotEmpty ? participants[0] : '';
    final otherUserId = participants.length > 1 ? participants[1] : '';

    return ChatConversation(
      id: doc.id,
      participantId: otherUserId,
      participantName: data['participantName'] ?? 'Unknown',
      participantAvatar: data['participantAvatar'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: (data['unreadBy'] ?? []).contains(currentUserId) ? 1 : 0,
      isOnline: data['isOnline'] ?? false,
    );
  }

  // Mark conversation as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'unreadBy': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .where('unreadBy', arrayContains: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages first
      final messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete conversation
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }
}
