class BaseModel {
  final bool success;
  final String message;

  BaseModel({
    required this.success,
    required this.message,
  });

  factory BaseModel.fromMap(Map<String, dynamic> json) {
    return BaseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}