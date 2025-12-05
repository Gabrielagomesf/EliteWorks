import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';

class ApiService {
  static const String tokenKey = 'auth_token';
  
  static String get baseUrl => ApiConfig.getBaseUrl();

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<Map<String, String>> getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erro desconhecido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar resposta: $e',
      };
    }
  }
}

