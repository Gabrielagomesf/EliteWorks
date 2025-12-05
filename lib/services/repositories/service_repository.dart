import '../../models/service_model.dart';
import '../api/api_service.dart';

class ServiceRepository {
  static Future<String?> create(ServiceModel service) async {
    final response = await ApiService.post('/services', service.toJson(), requiresAuth: true);
    if (response['success'] == true && response['service'] != null) {
      return response['service']['id'] as String?;
    }
    return null;
  }

  static Future<ServiceModel?> findById(String id) async {
    final response = await ApiService.get('/services/$id', requiresAuth: true);
    if (response['success'] == true && response['service'] != null) {
      return ServiceModel.fromJson(response['service']);
    }
    return null;
  }

  static Future<List<ServiceModel>> findByClientId(String clientId) async {
    final response = await ApiService.get('/services/client/$clientId', requiresAuth: true);
    if (response['success'] == true && response['services'] != null) {
      final services = response['services'] as List;
      return services.map((s) => ServiceModel.fromJson(s)).toList();
    }
    return [];
  }

  static Future<List<ServiceModel>> findByProfessionalId(String professionalId) async {
    final response = await ApiService.get('/services/professional/$professionalId', requiresAuth: true);
    if (response['success'] == true && response['services'] != null) {
      final services = response['services'] as List;
      return services.map((s) => ServiceModel.fromJson(s)).toList();
    }
    return [];
  }

  static Future<bool> update(String id, Map<String, dynamic> updates) async {
    final response = await ApiService.put('/services/$id', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<bool> delete(String id) async {
    final response = await ApiService.delete('/services/$id', requiresAuth: true);
    return response['success'] == true;
  }
}


