import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_validator.dart';
import '../models/user_model.dart';
import 'api/api_service.dart';
import 'repositories/professional_repository.dart';
import 'repositories/user_repository.dart';

class AuthService {
  static const String _userEmailKey = 'userEmail';
  static const String _userTypeKey = 'userType';
  static const String _userNameKey = 'userName';
  static const String _userIdKey = 'userId';

  static Future<void> initialize() async {
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final validationError = AuthValidator.validateRegistration(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
      );

      if (validationError != null) {
        return {'success': false, 'error': validationError};
      }

      if (!AuthValidator.isEmailFormatValid(email)) {
        return {'success': false, 'error': 'Formato de email inválido'};
      }

      if (!AuthValidator.isPasswordStrong(password)) {
        return {
          'success': false,
          'error': 'Senha deve ter pelo menos 8 caracteres, incluindo maiúsculas, minúsculas, números e caracteres especiais'
        };
      }

      final response = await ApiService.post('/auth/register', {
        'email': email.trim().toLowerCase(),
        'password': password,
        'name': name.trim(),
        'phone': phone.trim(),
        'userType': userType,
      });

      if (response['success'] == true) {
        final userData = response['user'] as Map<String, dynamic>;
        final token = response['token'] as String;

        await ApiService.saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userEmailKey, userData['email'] as String);
        await prefs.setString(_userTypeKey, userData['userType'] as String);
        await prefs.setString(_userNameKey, userData['name'] as String);
        await prefs.setString(_userIdKey, userData['id'] as String);

        return {
          'success': true,
          'user': userData,
          'professional': response['professional'],
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erro ao registrar usuário',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao registrar: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'error': 'Email e senha são obrigatórios'};
      }

      final response = await ApiService.post('/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      if (response['success'] == true) {
        final userData = response['user'] as Map<String, dynamic>;
        final token = response['token'] as String;

        await ApiService.saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userEmailKey, userData['email'] as String);
        await prefs.setString(_userTypeKey, userData['userType'] as String);
        await prefs.setString(_userNameKey, userData['name'] as String);
        await prefs.setString(_userIdKey, userData['id'] as String);

        return {
          'success': true,
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Email ou senha inválidos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao fazer login: ${e.toString()}',
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    await ApiService.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);
    final token = await ApiService.getToken();
    return email != null && token != null;
  }

  static Future<UserModel?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/users/profile', requiresAuth: true);
      if (response['success'] == true && response['user'] != null) {
        return UserModel.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>?> getCurrentUserBasic() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);
    final userType = prefs.getString(_userTypeKey);
    final userName = prefs.getString(_userNameKey);
    final userId = prefs.getString(_userIdKey);

    if (email != null && userType != null && userName != null && userId != null) {
      return {
        'email': email,
        'userType': userType,
        'name': userName,
        'id': userId,
      };
    }

    return null;
  }

  static Future<Map<String, dynamic>> deleteAccount(String userId, String userType) async {
    try {
      final success = await UserRepository.delete(userId);
      
      if (success) {
        if (userType == 'profissional') {
          await ProfessionalRepository.deleteByUserId(userId);
        }
        
        await logout();
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Erro ao deletar conta'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro ao deletar conta: ${e.toString()}'};
    }
  }
}
