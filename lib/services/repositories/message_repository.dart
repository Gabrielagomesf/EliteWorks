import '../../models/message_model.dart';
import '../api/api_service.dart';

class MessageRepository {
  static Future<MessageModel?> sendMessage({
    required String receiverId,
    required String message,
    String? serviceId,
  }) async {
    final response = await ApiService.post(
      '/messages',
      {
        'receiverId': receiverId,
        'message': message,
        if (serviceId != null) 'serviceId': serviceId,
      },
      requiresAuth: true,
    );

    if (response['success'] == true && response['message'] != null) {
      return MessageModel.fromJson(response['message']);
    }
    return null;
  }

  static Future<List<MessageModel>> getConversation(String otherUserId, {int limit = 50, int skip = 0}) async {
    final response = await ApiService.get(
      '/messages/conversation/$otherUserId?limit=$limit&skip=$skip',
      requiresAuth: true,
    );

    if (response['success'] == true && response['messages'] != null) {
      final messages = response['messages'] as List;
      return messages.map((m) => MessageModel.fromJson(m)).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await ApiService.get('/messages/conversations', requiresAuth: true);

    if (response['success'] == true && response['conversations'] != null) {
      return List<Map<String, dynamic>>.from(response['conversations']);
    }
    return [];
  }

  static Future<bool> markAsRead(List<String> messageIds) async {
    final response = await ApiService.put(
      '/messages/read',
      {'messageIds': messageIds},
      requiresAuth: true,
    );
    return response['success'] == true;
  }

  static Future<bool> markConversationAsRead(String otherUserId) async {
    final response = await ApiService.put(
      '/messages/conversation/$otherUserId/read',
      {},
      requiresAuth: true,
    );
    return response['success'] == true;
  }

  static Future<int> getUnreadCount() async {
    final response = await ApiService.get('/messages/unread-count', requiresAuth: true);
    if (response['success'] == true && response['unreadCount'] != null) {
      return response['unreadCount'] as int;
    }
    return 0;
  }

  static Future<bool> deleteMessage(String id) async {
    final response = await ApiService.delete('/messages/$id', requiresAuth: true);
    return response['success'] == true;
  }
}


