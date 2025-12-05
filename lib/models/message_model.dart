class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final String? serviceId;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    this.serviceId,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Usuário',
      receiverId: json['receiverId']?.toString() ?? json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? 'Usuário',
      message: json['message'] ?? '',
      serviceId: json['serviceId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'message': message,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }
}


