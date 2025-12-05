import '../../models/user_model.dart';
import '../api/api_service.dart';

class UserRepository {
  static Future<UserModel?> findByEmail(String email) async {
    final response = await ApiService.get('/users/email/$email');
    if (response['success'] == true && response['user'] != null) {
      return UserModel.fromJson(response['user']);
    }
    return null;
  }

  static Future<UserModel?> findById(String id) async {
    final response = await ApiService.get('/users/$id', requiresAuth: true);
    if (response['success'] == true && response['user'] != null) {
      return UserModel.fromJson(response['user']);
    }
    return null;
  }

  static Future<String?> create(UserModel user, {String? password}) async {
    final userData = user.toJson();
    if (password != null) {
      userData['password'] = password;
    }
    
    final response = await ApiService.post('/auth/register', userData);
    if (response['success'] == true && response['user'] != null) {
      return response['user']['id'] as String?;
    }
    return null;
  }

  static Future<bool> update(String id, Map<String, dynamic> updates) async {
    final response = await ApiService.put('/users/profile', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> delete(String id) async {
    final response = await ApiService.delete('/users/account', requiresAuth: true);
    return response['success'] == true;
  }
}

