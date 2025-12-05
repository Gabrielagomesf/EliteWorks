import '../services/email_service.dart';
import 'api/api_service.dart';

class PasswordResetService {
  static String _generateResetToken() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (100000 + (random % 900000)).toString();
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await ApiService.post('/password-reset/request', {
        'email': email.trim().toLowerCase(),
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Código de recuperação enviado por email',
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erro ao solicitar recuperação de senha',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao solicitar recuperação de senha: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> validateResetToken({
    required String token,
    required String email,
  }) async {
    try {
      final response = await ApiService.post('/password-reset/validate', {
        'token': token,
        'email': email.trim().toLowerCase(),
      });

      if (response['valid'] == true) {
        return {
          'valid': true,
          'userId': response['userId'],
        };
      } else {
        return {
          'valid': false,
          'error': response['error'] ?? 'Token inválido',
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'error': 'Erro ao validar token: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post('/password-reset/reset', {
        'token': token,
        'email': email.trim().toLowerCase(),
        'newPassword': newPassword,
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Senha redefinida com sucesso',
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erro ao redefinir senha',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao redefinir senha: ${e.toString()}',
      };
    }
  }
}
