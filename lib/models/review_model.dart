class ReviewModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String clientName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? serviceId;

  ReviewModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.serviceId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      professionalId: json['professionalId']?.toString() ?? json['professionalId'] ?? '',
      clientId: json['clientId']?.toString() ?? json['clientId'] ?? '',
      clientName: json['clientName'] ?? 'Cliente',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt']))
          : DateTime.now(),
      serviceId: json['serviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionalId': professionalId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}


