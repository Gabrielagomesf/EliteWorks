import '../../models/ad_model.dart';
import '../api/api_service.dart';

class AdRepository {
  static Future<String?> create({
    String? professionalId,
    required String title,
    required String category,
    String? description,
    double price = 0.0,
    List<String>? images,
    DateTime? expiresAt,
    Map<String, dynamic>? details,
  }) async {
    final body = {
      'title': title,
      'category': category,
      if (description != null) 'description': description,
      'price': price,
      if (images != null) 'images': images,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      if (details != null) 'details': details,
    };
    
    if (professionalId != null) {
      body['professionalId'] = professionalId;
    }

    final response = await ApiService.post(
      '/ads',
      body,
      requiresAuth: true,
    );
    
    if (response['success'] == true && response['ad'] != null) {
      return response['ad']['id'] as String?;
    }
    return null;
  }

  static Future<List<AdModel>> getByProfessionalId(String professionalId, {int limit = 50, int skip = 0, bool? isActive}) async {
    final queryParams = <String>[];
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');
    if (isActive != null) queryParams.add('isActive=$isActive');

    final endpoint = '/ads/professional/$professionalId?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint);
    
    if (response['success'] == true && response['ads'] != null) {
      final ads = response['ads'] as List;
      return ads.map((a) => AdModel.fromJson(a)).toList();
    }
    return [];
  }

  static Future<List<AdModel>> getActiveAds({int limit = 50, int skip = 0, String? category, String? professionalId}) async {
    final queryParams = <String>[];
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');
    if (category != null) queryParams.add('category=$category');
    if (professionalId != null) queryParams.add('professionalId=$professionalId');

    final endpoint = '/ads/active?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint);
    
    if (response['success'] == true && response['ads'] != null) {
      final ads = response['ads'] as List;
      return ads.map((a) => AdModel.fromJson(a)).toList();
    }
    return [];
  }

  static Future<AdModel?> getById(String id) async {
    final response = await ApiService.get('/ads/$id');
    
    if (response['success'] == true && response['ad'] != null) {
      return AdModel.fromJson(response['ad']);
    }
    return null;
  }

  static Future<bool> update(String id, Map<String, dynamic> updates) async {
    final response = await ApiService.put('/ads/$id', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> delete(String id) async {
    final response = await ApiService.delete('/ads/$id', requiresAuth: true);
    return response['success'] == true;
  }
}


