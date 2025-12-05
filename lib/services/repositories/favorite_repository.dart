import '../api/api_service.dart';

class FavoriteRepository {
  static Future<bool> addFavorite(String professionalId) async {
    final response = await ApiService.post(
      '/favorites',
      {'professionalId': professionalId},
      requiresAuth: true,
    );
    return response['success'] == true;
  }

  static Future<bool> removeFavorite(String professionalId) async {
    final response = await ApiService.delete(
      '/favorites/$professionalId',
      requiresAuth: true,
    );
    return response['success'] == true;
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await ApiService.get('/favorites', requiresAuth: true);
    if (response['success'] == true && response['favorites'] != null) {
      return List<Map<String, dynamic>>.from(response['favorites']);
    }
    return [];
  }

  static Future<bool> isFavorite(String professionalId) async {
    final response = await ApiService.get(
      '/favorites/$professionalId',
      requiresAuth: true,
    );
    if (response['success'] == true && response['isFavorite'] != null) {
      return response['isFavorite'] as bool;
    }
    return false;
  }
}


