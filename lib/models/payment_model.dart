class PaymentModel {
  final String id;
  final String serviceId;
  final String? serviceTitle;
  final String clientId;
  final String? clientName;
  final String professionalId;
  final String? professionalName;
  final double amount;
  final String status;
  final String method;
  final String? transactionId;
  final String? pixQrCode;
  final String? pixCopyPaste;
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.serviceId,
    this.serviceTitle,
    required this.clientId,
    this.clientName,
    required this.professionalId,
    this.professionalName,
    required this.amount,
    required this.status,
    required this.method,
    this.transactionId,
    this.pixQrCode,
    this.pixCopyPaste,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? json['serviceId'] ?? '',
      serviceTitle: json['serviceTitle'],
      clientId: json['clientId']?.toString() ?? json['clientId'] ?? '',
      clientName: json['clientName'],
      professionalId: json['professionalId']?.toString() ?? json['professionalId'] ?? '',
      professionalName: json['professionalName'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'pending',
      method: json['method'] ?? 'PIX',
      transactionId: json['transactionId']?.toString(),
      pixQrCode: json['pixQrCode'],
      pixCopyPaste: json['pixCopyPaste'],
      paidAt: json['paidAt'] != null
          ? (json['paidAt'] is String
              ? DateTime.parse(json['paidAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['paidAt']))
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'amount': amount,
      'method': method,
      if (transactionId != null) 'transactionId': transactionId,
    };
  }
}


