class WorkModel {
  final String id;
  final String professionalId;
  final String title;
  final String description;
  final List<String> images;
  final String category;
  final DateTime completedAt;
  final double? price;
  final String? clientName;

  WorkModel({
    required this.id,
    required this.professionalId,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    required this.completedAt,
    this.price,
    this.clientName,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['_id'].toString(),
      professionalId: json['professionalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      category: json['category'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      clientName: json['clientName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionalId': professionalId,
      'title': title,
      'description': description,
      'images': images,
      'category': category,
      'completedAt': completedAt.toIso8601String(),
      if (price != null) 'price': price,
      if (clientName != null) 'clientName': clientName,
    };
  }
}



