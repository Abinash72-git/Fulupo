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


// class LoginModel {
//   final bool success;
//   final String message;
//   final String? token;
//   final bool isExistingUser;
//   final Map<String, dynamic>? data;

//   LoginModel({
//     required this.success,
//     required this.message,
//     this.token,
//     this.isExistingUser = false,
//     this.data,
//   });

//   factory LoginModel.fromMap(Map<String, dynamic> json) => LoginModel(
//         success: json['success'] ?? false,
//         message: json['message'] ?? '',
//         token: json['token'],
//         isExistingUser: json['isExistingUser'] ?? false,
//         data: json['data'] ?? {},
//       );

//   String? get storeId => data?['storeId']?.toString();
//   String? get userId => data?['_id']?.toString();
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

  // ✅ Factory constructor to create from Map
  factory LoginModel.fromMap(Map<String, dynamic> json) => LoginModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        token: json['token'],
        isExistingUser: json['isExistingUser'] ?? false,
        data: json['data'] ?? {},
      );

  // ✅ Add this method to fix the error
  Map<String, dynamic> toMap() => {
        'success': success,
        'message': message,
        'token': token,
        'isExistingUser': isExistingUser,
        'data': data,
      };

  // ✅ Helper getters
  String? get storeId => data?['storeId']?.toString();
  String? get userId => data?['_id']?.toString();
}
