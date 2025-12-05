class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType;
  final DateTime createdAt;
  final String? profileImage;
  final Map<String, dynamic>? additionalInfo;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.profileImage,
    this.additionalInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? 'cliente',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      profileImage: json['profileImage'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
      if (profileImage != null) 'profileImage': profileImage,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };
  }

  bool get isProfessional => userType == 'profissional';
  bool get isClient => userType == 'cliente';
}



