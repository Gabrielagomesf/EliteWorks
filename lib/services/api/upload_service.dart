import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_service.dart';
import '../../config/api_config.dart';

class UploadService {
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Usuário não autenticado',
        };
      }

      final baseUrl = ApiConfig.getBaseUrl().replaceAll('/api', '');
      final uri = Uri.parse('$baseUrl/upload/profile');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'imageUrl': data['imageUrl'],
          'filename': data['filename'],
        };
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao fazer upload da imagem',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao fazer upload: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadMultipleImages(
    List<File> imageFiles, {
    String type = 'portfolio',
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Usuário não autenticado',
        };
      }

      final baseUrl = ApiConfig.getBaseUrl().replaceAll('/api', '');
      final uri = Uri.parse('$baseUrl/upload/multiple');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type;

      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'imageUrls': List<String>.from(data['imageUrls'] ?? []),
          'count': data['count'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao fazer upload das imagens',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao fazer upload: ${e.toString()}',
      };
    }
  }
}

