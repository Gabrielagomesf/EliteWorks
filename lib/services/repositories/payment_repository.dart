import '../../models/payment_model.dart';
import '../api/api_service.dart';

class PaymentRepository {
  static Future<PaymentModel?> create({
    required String serviceId,
    required double amount,
    String method = 'PIX',
    String? cardToken,
    int? installments,
  }) async {
    final body = {
      'serviceId': serviceId,
      'amount': amount,
      'method': method,
    };

    if (cardToken != null) {
      body['cardData'] = {'token': cardToken, 'paymentMethodId': method == 'Cartão de Crédito' ? 'credit_card' : 'debit_card'};
    }
    if (installments != null) {
      body['installments'] = installments;
    }

    final response = await ApiService.post(
      '/payments',
      body,
      requiresAuth: true,
    );

    if (response['success'] == true && response['payment'] != null) {
      return PaymentModel.fromJson(response['payment']);
    }
    return null;
  }

  static Future<List<PaymentModel>> getByClientId({int limit = 50, int skip = 0, String? status}) async {
    final queryParams = <String>[];
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');

    final endpoint = '/payments/client?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint, requiresAuth: true);

    if (response['success'] == true && response['payments'] != null) {
      final payments = response['payments'] as List;
      return payments.map((p) => PaymentModel.fromJson(p)).toList();
    }
    return [];
  }

  static Future<List<PaymentModel>> getByProfessionalId({int limit = 50, int skip = 0, String? status}) async {
    final queryParams = <String>[];
    queryParams.add('limit=$limit');
    queryParams.add('skip=$skip');
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');

    final endpoint = '/payments/professional?${queryParams.join('&')}';
    final response = await ApiService.get(endpoint, requiresAuth: true);

    if (response['success'] == true && response['payments'] != null) {
      final payments = response['payments'] as List;
      return payments.map((p) => PaymentModel.fromJson(p)).toList();
    }
    return [];
  }

  static Future<List<PaymentModel>> getByServiceId(String serviceId) async {
    final response = await ApiService.get('/payments/service/$serviceId', requiresAuth: true);

    if (response['success'] == true && response['payments'] != null) {
      final payments = response['payments'] as List;
      return payments.map((p) => PaymentModel.fromJson(p)).toList();
    }
    return [];
  }

  static Future<PaymentModel?> getById(String id) async {
    final response = await ApiService.get('/payments/$id', requiresAuth: true);

    if (response['success'] == true && response['payment'] != null) {
      return PaymentModel.fromJson(response['payment']);
    }
    return null;
  }

  static Future<bool> updateStatus(String id, String status, {String? transactionId}) async {
    final updates = {'status': status};
    if (transactionId != null) updates['transactionId'] = transactionId;

    final response = await ApiService.put('/payments/$id/status', updates, requiresAuth: true);
    return response['success'] == true;
  }

  static Future<double> getTotalPaid() async {
    final response = await ApiService.get('/payments/client?status=completed', requiresAuth: true);
    if (response['success'] == true && response['totalPaid'] != null) {
      return (response['totalPaid'] as num).toDouble();
    }
    return 0.0;
  }
}

