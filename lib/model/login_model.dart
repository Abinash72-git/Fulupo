// class LoginModel {
//   final bool success;
//   final String message;
//   final String? token;

//   LoginModel({
//     required this.success,
//     required this.message,
//     this.token,
//   });

//   factory LoginModel.fromMap(Map<String, dynamic> json) {
//     return LoginModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       token: json['token'],
//     );
//   }
// }


class LoginModel {
  final bool success;
  final String message;
  final String? token;
  final bool isExistingUser;
  final Map<String, dynamic>? data;

  LoginModel({
    required this.success,
    required this.message,
    this.token,
    this.isExistingUser = false,
    this.data,
  });

  factory LoginModel.fromMap(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      token: json['token'],
      isExistingUser: json['isExistingUser'] ?? false,
      data: json['data'] ?? {},
    );
  }

  String? get storeId => data?['storeId'];
  String? get userId => data?['_id']; // Add this getter for convenience
}
