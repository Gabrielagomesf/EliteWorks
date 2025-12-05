import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiConfig {
  static String getBaseUrl() {
    try {
      final url = dotenv.env['API_BASE_URL'];
      if (url != null && url.isNotEmpty) {
        String cleanUrl = url.trim();
        cleanUrl = cleanUrl.endsWith('/') ? cleanUrl.substring(0, cleanUrl.length - 1) : cleanUrl;
        
        if (cleanUrl.contains('localhost')) {
          if (Platform.isAndroid) {
            cleanUrl = cleanUrl.replaceAll('localhost', '10.0.2.2');
          }
        }
        
        if (!cleanUrl.endsWith('/api')) {
          cleanUrl = '$cleanUrl/api';
        }
        
        if (kDebugMode) {
          print('API URL configurada do .env: $cleanUrl');
        }
        
        return cleanUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao ler API_BASE_URL do .env: $e');
      }
    }
    
    String baseUrl;
    
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      baseUrl = 'http://localhost:3000';
    } else {
      baseUrl = 'http://localhost:3000';
    }
    
    if (kDebugMode) {
      print('Usando URL padrão: $baseUrl/api');
    }
    
    return '$baseUrl/api';
  }
}

