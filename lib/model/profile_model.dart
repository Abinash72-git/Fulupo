class ProfileModel {
  final bool success;
  final String message;
  final String? token;
  final String? userId;
  final String? name;
  final String? phone;
  final String? location;

  ProfileModel({
   required this.success,
    required this.message,
    this.token,
    this.userId,
    this.name,
    this.phone,
    this.location,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> json) {
    return ProfileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token']as String?,
      userId: json['user_id']as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
    );
  }
}