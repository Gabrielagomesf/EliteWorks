class ProfessionalModel {
  final String id;
  final String userId;
  final List<String> categories;
  final String? bio;
  final double? rating;
  final int? totalReviews;
  final List<String>? portfolioImages;
  final Map<String, double>? servicePrices;
  final String? coverageArea;
  final bool isVerified;
  final Map<String, dynamic>? availability;
  final double? hourlyRate;
  final String? experience;
  final List<String>? certifications;

  ProfessionalModel({
    required this.id,
    required this.userId,
    required this.categories,
    this.bio,
    this.rating,
    this.totalReviews,
    this.portfolioImages,
    this.servicePrices,
    this.coverageArea,
    this.isVerified = false,
    this.availability,
    this.hourlyRate,
    this.experience,
    this.certifications,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['userId'] ?? '',
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      bio: json['bio'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'],
      portfolioImages: json['portfolioImages'] != null
          ? List<String>.from(json['portfolioImages'])
          : null,
      servicePrices: json['servicePrices'] != null
          ? Map<String, double>.from(
              (json['servicePrices'] as Map).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
      coverageArea: json['coverageArea'],
      isVerified: json['isVerified'] ?? false,
      availability: json['availability'] != null ? Map<String, dynamic>.from(json['availability']) : null,
      hourlyRate: json['hourlyRate'] != null ? (json['hourlyRate'] as num).toDouble() : null,
      experience: json['experience'],
      certifications: json['certifications'] != null ? List<String>.from(json['certifications']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categories': categories,
      if (bio != null) 'bio': bio,
      if (rating != null) 'rating': rating,
      if (totalReviews != null) 'totalReviews': totalReviews,
      if (portfolioImages != null) 'portfolioImages': portfolioImages,
      if (servicePrices != null) 'servicePrices': servicePrices,
      if (coverageArea != null) 'coverageArea': coverageArea,
      'isVerified': isVerified,
      if (availability != null) 'availability': availability,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
      if (experience != null) 'experience': experience,
      if (certifications != null) 'certifications': certifications,
    };
  }
}


