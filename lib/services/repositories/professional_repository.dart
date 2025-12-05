import '../../models/professional_model.dart';
import '../api/api_service.dart';

class ProfessionalRepository {
  static Future<String?> create(ProfessionalModel professional) async {
    final response = await ApiService.post('/professionals', professional.toJson());
    if (response['success'] == true && response['professional'] != null) {
      return response['professional']['id'] as String?;
    }
    return null;
  }

  static Future<ProfessionalModel?> findByUserId(String userId) async {
    final response = await ApiService.get('/professionals/user/$userId');
    if (response['success'] == true && response['professional'] != null) {
      return ProfessionalModel.fromJson(response['professional']);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> findByIdWithUser(String id) async {
    final response = await ApiService.get('/professionals/$id');
    if (response['success'] == true) {
      return {
        'professional': response['professional'],
        'user': response['user'],
      };
    }
    return null;
  }

  static Future<ProfessionalModel?> findById(String id) async {
    final response = await ApiService.get('/professionals/$id');
    if (response['success'] == true && response['professional'] != null) {
      final professionalData = response['professional'] as Map<String, dynamic>;
      // Se houver userId no user, usar o ID do user
      if (response['user'] != null) {
        professionalData['userId'] = response['user']['id'];
      }
      return ProfessionalModel.fromJson(professionalData);
    }
    return null;
  }

  static Future<bool> update(String id, Map<String, dynamic> updates) async {
    final response = await ApiService.put('/professionals/$id', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> deleteByUserId(String userId) async {
    final response = await ApiService.delete('/professionals/user/$userId', requiresAuth: true);
    return response['success'] == true;
  }

  static Future<List<ProfessionalModel>> getFeatured({int limit = 10}) async {
    final response = await ApiService.get('/professionals/featured?limit=$limit');
    if (response['success'] == true && response['results'] != null) {
      final results = response['results'] as List;
      return results.map((p) => ProfessionalModel.fromJson(p['professional'])).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFeaturedWithUserInfo({int limit = 10}) async {
    final response = await ApiService.get('/professionals/featured?limit=$limit');
    if (response['success'] == true && response['results'] != null) {
      return List<Map<String, dynamic>>.from(response['results']);
    }
    return [];
  }

  static Future<List<ProfessionalModel>> search({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
    int limit = 20,
    int skip = 0,
  }) async {
    final queryParams = <String>[];
    if (query != null) queryParams.add('query=$query');
    if (category != null) queryParams.add('category=$category');
    if (minRating != null) queryParams.add('minRating=$minRating');
    if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
    if (location != null) queryParams.add('location=$location');
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');

    final endpoint = '/professionals/search?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint);
    
    if (response['success'] == true && response['results'] != null) {
      final results = response['results'] as List;
      return results.map((p) => ProfessionalModel.fromJson(p['professional'])).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> searchWithUserInfo({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
    int limit = 20,
    int skip = 0,
  }) async {
    final queryParams = <String>[];
    if (query != null) queryParams.add('query=$query');
    if (category != null) queryParams.add('category=$category');
    if (minRating != null) queryParams.add('minRating=$minRating');
    if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
    if (location != null) queryParams.add('location=$location');
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');

    final endpoint = '/professionals/search?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint);
    
    if (response['success'] == true && response['results'] != null) {
      return List<Map<String, dynamic>>.from(response['results']);
    }
    return [];
  }

  static Future<int> count({
    String? query,
    String? category,
    double? minRating,
    double? maxPrice,
    String? location,
  }) async {
    final queryParams = <String>[];
    if (query != null) queryParams.add('query=$query');
    if (category != null) queryParams.add('category=$category');
    if (minRating != null) queryParams.add('minRating=$minRating');
    if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
    if (location != null) queryParams.add('location=$location');

    final endpoint = '/professionals/count?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint);
    
    if (response['success'] == true && response['total'] != null) {
      return response['total'] as int;
    }
    return 0;
  }
}

