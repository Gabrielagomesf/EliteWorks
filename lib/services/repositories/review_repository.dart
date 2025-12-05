import '../../models/review_model.dart';
import '../api/api_service.dart';

class ReviewRepository {
  static Future<String?> create({
    required String professionalId,
    required double rating,
    String? comment,
    String? serviceId,
  }) async {
    final response = await ApiService.post(
      '/reviews',
      {
        'professionalId': professionalId,
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (serviceId != null) 'serviceId': serviceId,
      },
      requiresAuth: true,
    );
    
    if (response['success'] == true && response['review'] != null) {
      return response['review']['id'] as String?;
    }
    return null;
  }

  static Future<List<ReviewModel>> getByProfessionalId(String professionalId, {int limit = 50, int skip = 0}) async {
    final response = await ApiService.get('/reviews/professional/$professionalId?limit=$limit&skip=$skip');
    
    if (response['success'] == true && response['reviews'] != null) {
      final reviews = response['reviews'] as List;
      return reviews.map((r) => ReviewModel.fromJson(r)).toList();
    }
    return [];
  }

  static Future<ReviewModel?> getById(String id) async {
    final response = await ApiService.get('/reviews/$id');
    
    if (response['success'] == true && response['review'] != null) {
      return ReviewModel.fromJson(response['review']);
    }
    return null;
  }

  static Future<bool> update(String id, {double? rating, String? comment}) async {
    final updates = <String, dynamic>{};
    if (rating != null) updates['rating'] = rating;
    if (comment != null) updates['comment'] = comment;

    final response = await ApiService.put('/reviews/$id', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> delete(String id) async {
    final response = await ApiService.delete('/reviews/$id', requiresAuth: true);
    return response['success'] == true;
  }
}


