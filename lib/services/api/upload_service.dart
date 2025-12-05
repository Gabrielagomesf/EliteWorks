import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../api/api_service.dart';
import '../../config/api_config.dart';

class UploadService {
  static MediaType? _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      default:
        return null;
    }
  }
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Usuário não autenticado',
        };
      }

      final baseUrl = ApiConfig.getBaseUrl();
      final uri = Uri.parse('$baseUrl/upload/profile');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final contentType = _getContentType(fileExtension);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': true,
            'imageUrl': data['imageUrl'],
            'filename': data['filename'],
            'publicId': data['publicId'],
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erro ao processar resposta do servidor: ${e.toString()}',
          };
        }
      } else {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'error': data['error'] ?? 'Erro ao fazer upload da imagem',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erro ao fazer upload. Status: ${response.statusCode}. Resposta: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
          };
        }
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

      final baseUrl = ApiConfig.getBaseUrl();
      final uri = Uri.parse('$baseUrl/upload/multiple');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type;

      for (var file in imageFiles) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        final contentType = _getContentType(fileExtension);
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            contentType: contentType,
          ),
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

