class GetprofileModel {
  final bool success;
  final String message;
  final String? token;
  final String? userId;
  final String? name;
  final String? phone;
  final String? location;

  GetprofileModel({
    required this.success,
    required this.message,
    this.token,
    this.userId,
    this.name,
    this.phone,
    this.location,
  });

  factory GetprofileModel.fromJson(Map<String, dynamic> json) {
    return GetprofileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] as String?,
      userId: json['user_id']?.toString(), // Convert userId to String
      name: json['name'] as String?,
      phone: json['phone']?.toString(), // Convert phone to String
      location: json['location'] as String?,
    );
  }
}