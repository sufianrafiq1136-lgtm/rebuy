import '../models/chat_model.dart';

class MockChatService {
  static final MockChatService _instance = MockChatService._internal();

  late List<ChatConversation> _conversations;
  late Map<String, List<ChatMessage>> _messages;

  factory MockChatService() {
    return _instance;
  }

  MockChatService._internal() {
    _initializeData();
  }

  void _initializeData() {
    _conversations = [
      ChatConversation(
        id: 'conv1',
        participantId: 'user1',
        participantName: 'Ali Hassan',
        participantAvatar: 'A',
        lastMessage: 'Is the iPhone 13 still available?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 2,
        isOnline: true,
      ),
      ChatConversation(
        id: 'conv2',
        participantId: 'user2',
        participantName: 'Sara Khan',
        participantAvatar: 'S',
        lastMessage: 'Can you do \$80 for the Nike Air Max?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        unreadCount: 1,
        isOnline: true,
      ),
      ChatConversation(
        id: 'conv3',
        participantId: 'user3',
        participantName: 'Usman Malik',
        participantAvatar: 'U',
        lastMessage: 'Thanks! I\'ll pick it up tomorrow.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
        isOnline: false,
      ),
      ChatConversation(
        id: 'conv4',
        participantId: 'user4',
        participantName: 'Fatima Noor',
        participantAvatar: 'F',
        lastMessage: 'Is the desk solid wood?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isOnline: false,
      ),
      ChatConversation(
        id: 'conv5',
        participantId: 'user5',
        participantName: 'Ahmed Raza',
        participantAvatar: 'R',
        lastMessage: 'Deal! Sending payment now.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: true,
      ),
      ChatConversation(
        id: 'conv6',
        participantId: 'user6',
        participantName: 'Zainab Shah',
        participantAvatar: 'Z',
        lastMessage: 'Do you ship to Lahore?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 3,
        isOnline: false,
      ),
    ];

    _messages = {
      'conv1': [
        ChatMessage(
          id: 'm1',
          senderId: 'user1',
          senderName: 'Ali Hassan',
          content: 'Hi, is this available?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isRead: true,
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'me',
          senderName: 'You',
          content: 'Yes, it is! Do you want to see more photos?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          isRead: true,
        ),
        ChatMessage(
          id: 'm3',
          senderId: 'user1',
          senderName: 'Ali Hassan',
          content: 'Is the iPhone 13 still available?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isRead: false,
        ),
      ],
      'conv2': [
        ChatMessage(
          id: 'm4',
          senderId: 'user2',
          senderName: 'Sara Khan',
          content: 'Can you do \$80 for the Nike Air Max?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: false,
        ),
      ],
    };
  }

  Future<List<ChatConversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _conversations;
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _messages[conversationId] ?? [];
  }

  Future<void> sendMessage(String conversationId, String content) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'You',
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
    );

    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }
    _messages[conversationId]!.add(message);

    // Update conversation
    final convIndex =
        _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
      );
    }
  }

  Future<void> markAsRead(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final convIndex =
        _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      _conversations[convIndex] =
          _conversations[convIndex].copyWith(unreadCount: 0);
    }
  }

  int get unreadCount =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);
}
