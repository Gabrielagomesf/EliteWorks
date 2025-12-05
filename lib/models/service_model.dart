class ServiceModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String? professionalName;
  final String? category;
  final String title;
  final String? description;
  final double? price;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;

  ServiceModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    this.professionalName,
    this.category,
    required this.title,
    this.description,
    this.price,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      professionalId: json['professionalId']?.toString() ?? json['professionalId'] ?? '',
      clientId: json['clientId']?.toString() ?? json['clientId'] ?? '',
      professionalName: json['professionalName'],
      category: json['category'],
      title: json['title'] ?? '',
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt']))
          : DateTime.now(),
      scheduledDate: json['scheduledDate'] != null
          ? (json['scheduledDate'] is String
              ? DateTime.parse(json['scheduledDate'])
              : DateTime.fromMillisecondsSinceEpoch(json['scheduledDate']))
          : null,
      completedDate: json['completedDate'] != null
          ? (json['completedDate'] is String
              ? DateTime.parse(json['completedDate'])
              : DateTime.fromMillisecondsSinceEpoch(json['completedDate']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionalId': professionalId,
      'clientId': clientId,
      if (category != null) 'category': category,
      'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (scheduledDate != null) 'scheduledDate': scheduledDate!.toIso8601String(),
      if (completedDate != null) 'completedDate': completedDate!.toIso8601String(),
    };
  }
}


