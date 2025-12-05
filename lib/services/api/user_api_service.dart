import '../api/api_service.dart';

class UserApiService {
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/users/profile', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    return await ApiService.put('/users/profile', updates, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await ApiService.put(
      '/users/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      requiresAuth: true,
    );
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    return await ApiService.delete('/users/account', requiresAuth: true);
  }
}

