import '../api/api_service.dart';

class NotificationRepository {
  static Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    int skip = 0,
    bool? isRead,
    String? type,
  }) async {
    final queryParams = <String>[];
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');
    if (isRead != null) queryParams.add('isRead=$isRead');
    if (type != null && type.isNotEmpty) queryParams.add('type=$type');

    final endpoint = '/notifications?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint, requiresAuth: true);
    
    if (response['success'] == true && response['notifications'] != null) {
      return List<Map<String, dynamic>>.from(response['notifications']);
    }
    return [];
  }

  static Future<int> getUnreadCount() async {
    final response = await ApiService.get('/notifications/unread-count', requiresAuth: true);
    if (response['success'] == true && response['unreadCount'] != null) {
      return response['unreadCount'] as int;
    }
    return 0;
  }

  static Future<bool> markAsRead(String id) async {
    final response = await ApiService.put('/notifications/$id/read', {}, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> markAllAsRead() async {
    final response = await ApiService.put('/notifications/read-all', {}, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> delete(String id) async {
    final response = await ApiService.delete('/notifications/$id', requiresAuth: true);
    return response['success'] == true;
  }
}


