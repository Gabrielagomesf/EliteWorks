class AdModel {
  final String id;
  final String professionalId;
  final String title;
  final String description;
  final String category;
  final double price;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? details;

  AdModel({
    required this.id,
    required this.professionalId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.images,
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
    this.details,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      professionalId: json['professionalId']?.toString() ?? json['professionalId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt']))
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] is String
              ? DateTime.parse(json['expiresAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['expiresAt']))
          : null,
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionalId': professionalId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (details != null) 'details': details,
    };
  }
}


