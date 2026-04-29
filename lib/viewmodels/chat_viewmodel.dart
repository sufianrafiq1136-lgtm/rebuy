import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../services/firebase_chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseChatService _chatService = FirebaseChatService();

  List<ChatConversation> _conversations = [];
  Map<String, List<ChatMessage>> _messages = {};
  bool _isLoading = false;
  String? _error;
  String? _selectedConversationId;
  String? _userId;

  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get currentMessages =>
      _selectedConversationId != null
          ? _messages[_selectedConversationId] ?? []
          : [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void listenToConversations() {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chatService.getConversationsStream(_userId!).listen(
        (conversations) {
          _conversations = conversations;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Failed to load conversations: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to listen to conversations: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectConversation(String conversationId) {
    _selectedConversationId = conversationId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Listen to messages for this conversation
      _chatService.getMessagesStream(conversationId).listen(
        (messages) {
          _messages[conversationId] = messages;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Failed to load messages: $error';
          _isLoading = false;
          notifyListeners();
        },
      );

      // Mark conversation as read
      _markAsRead(conversationId);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to select conversation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _markAsRead(String conversationId) async {
    if (_userId == null) return;

    try {
      await _chatService.markAsRead(conversationId, _userId!);

      // Update conversation unread count
      final index =
          _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] =
            _conversations[index].copyWith(unreadCount: 0);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark as read: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_selectedConversationId == null || _userId == null) return;

    try {
      await _chatService.sendMessage(
        conversationId: _selectedConversationId!,
        userId: _userId!,
        content: content,
        timestamp: DateTime.now(),
      );

      // Messages will be updated via the stream listener
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> startConversation({
    required String recipientId,
    required String recipientName,
  }) async {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      final conversation = await _chatService.getOrCreateConversation(
        participants: [_userId!, recipientId],
        participantNames: ['You', recipientName],
      );

      if (conversation != null) {
        selectConversation(conversation.id);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start conversation: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _chatService.deleteConversation(conversationId);
      _conversations.removeWhere((c) => c.id == conversationId);
      if (_selectedConversationId == conversationId) {
        _selectedConversationId = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation: ${e.toString()}';
      notifyListeners();
    }
  }
}
