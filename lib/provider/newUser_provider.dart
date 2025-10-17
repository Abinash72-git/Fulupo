// import 'package:flutter/material.dart';
// import 'package:fulupo/config/app_config.dart';
// import 'package:fulupo/enums/enum.dart';
// import 'package:fulupo/model/api_validation_model.dart';
// import 'package:fulupo/service/api_service.dart';
// import 'package:fulupo/service/device_info.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/exception.dart';
// import 'package:fulupo/util/global.dart';
// import 'package:fulupo/util/url_path.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer';

// class NewuserProvider extends ChangeNotifier {
//   bool isLoading = false;
//   bool isAuthorized = true;
//   bool isApiValidationError = false;
//   String token = '';

//   // BaseUrl
//   final String baseUrl = '${AppConfig.instance.baseUrl}';
//   //  final String baseUrl = 'https://fulupostore.tsitcloud.com/api/consumer/';

//   getdata() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token') ?? '';
//     print(token);
//     log('Token : $token');
//   }

//   Future<void> initialFetch() async {
//     AppGlobal.deviceInfo = await DeviceInfoServices.getDeviceInfo();
//   }

//   Future<APIResp> NewsendOTP({required String mobile}) async {
//     await getdata();
//     // final String? firebaseToken = await FirebaseMessaging.instance.getToken();
//     final apiService = APIService();
//     final resp = await apiService.post(
//       UrlPath.loginUrl.sendOTP,
//       data: {"mobile": mobile},
//       showNoInternet: false,
//       auth: false,
//       forceLogout: false,
//       console: true,
//       timeout: const Duration(seconds: 30),
//     );
//     print(resp.statusCode);
//     print("siki----------------------->");
//     print(resp.status);
//     print("viki------------------>");
//     if (resp.status) {
//       isApiValidationError = false;
//       return resp;
//     } else if (!resp.status && resp.data == "Validation Error") {
//       AppConstants.apiValidationModel = ApiValidationModel.fromJson(
//         resp.fullBody,
//       );
//       isApiValidationError = true;
//       notifyListeners();
//       return resp;
//     } else {
//       throw APIException(
//         type: APIErrorType.auth,
//         message:
//             resp.data?.toString() ?? "Invalid credential.please try again!",
//       );
//     }
//   }
// }
