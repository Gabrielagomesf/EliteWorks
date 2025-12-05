class ServiceLocation {
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  ServiceLocation({
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceLocation();
    return ServiceLocation(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class ServiceModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String? professionalName;
  final String? clientName;
  final String? category;
  final String title;
  final String? description;
  final double? price;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final List<String> images;
  final ServiceLocation? location;

  ServiceModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    this.professionalName,
    this.clientName,
    this.category,
    required this.title,
    this.description,
    this.price,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
    this.images = const [],
    this.location,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      professionalId: json['professionalId']?.toString() ?? json['professionalId'] ?? '',
      clientId: json['clientId']?.toString() ?? json['clientId'] ?? '',
      professionalName: json['professionalName'],
      clientName: json['clientName'],
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
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      location: json['location'] != null ? ServiceLocation.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson({bool includeClientId = false}) {
    return {
      'professionalId': professionalId,
      if (includeClientId) 'clientId': clientId,
      if (category != null) 'category': category,
      'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (scheduledDate != null) 'scheduledDate': scheduledDate!.toIso8601String(),
      if (completedDate != null) 'completedDate': completedDate!.toIso8601String(),
      if (images.isNotEmpty) 'images': images,
      if (location != null) 'location': location!.toJson(),
    };
  }
}


