import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fulupo/api/api_intergration.dart';
import 'package:fulupo/config/app_config.dart';
import 'package:fulupo/enums/enum.dart';
import 'package:fulupo/model/api_validation_model.dart';
import 'package:fulupo/model/getProfile_model.dart';
import 'package:fulupo/model/login_model.dart';
import 'package:fulupo/model/profile_model.dart';
import 'package:fulupo/service/api_service.dart';
import 'package:fulupo/service/device_info.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/util/global.dart';
import 'package:fulupo/util/url_path.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isAuthorized = true;
  bool isApiValidationError = false;
  String token = '';
  List<GetprofileModel> _profile = [];
  List<GetprofileModel> get profile => _profile;
  Map<String, dynamic> loginResponse = {};
  // BaseUrl
  final String baseUrl = '${AppConfig.instance.baseUrl}';

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    print(token);
    log('Token: $token');
  }

  Future<void> initialFetch() async {
    AppGlobal.deviceInfo = await DeviceInfoServices.getDeviceInfo();
  }

  // Future<APIResp> sendOTP({required String mobile}) async {
  //   await getdata();
  //   // final String? firebaseToken = await FirebaseMessaging.instance.getToken();
  //   final apiService = APIService();
  //   final resp = await apiService.post(
  //     UrlPath.loginUrl.sendOTP,
  //     data: {"mobile": mobile},
  //     showNoInternet: false,
  //     auth: false,
  //     forceLogout: false,
  //     console: true,
  //     timeout: const Duration(seconds: 30),
  //   );
  //   print(resp.statusCode);
  //   print("siki----------------------->");
  //   print(resp.status);
  //   print("viki------------------>");
  //   if (resp.status) {
  //     isApiValidationError = false;
  //     return resp;
  //   } else if (!resp.status && resp.data == "Validation Error") {
  //     AppConstants.apiValidationModel = ApiValidationModel.fromJson(
  //       resp.fullBody,
  //     );
  //     isApiValidationError = true;
  //     notifyListeners();
  //     return resp;
  //   } else {
  //     throw APIException(
  //       type: APIErrorType.auth,
  //       message:
  //           resp.data?.toString() ?? "Invalid credential.please try again!",
  //     );
  //   }
  // }

  // Future<APIResp> sendOTP({required String mobile}) async {
  //   await getdata();
  //   final apiService = APIService();

  //   final resp = await apiService.post(
  //     UrlPath.loginUrl.sendOTP,
  //     data: {"mobile": mobile},
  //     showNoInternet: false,
  //     auth: false,
  //     forceLogout: false,
  //     console: true,
  //     timeout: const Duration(seconds: 30),
  //   );

  //   print("Status Code: ${resp.statusCode}");
  //   print("API Status: ${resp.status}");
  //   print("API Data: ${resp.data}");

  //   // ✅ If OTP sent successfully, handle it separately
  //   if (resp.status) {
  //     isApiValidationError = false;
  //     return resp;
  //   } else if (resp.data == "Validation Error") {
  //     AppConstants.apiValidationModel = ApiValidationModel.fromJson(
  //       resp.fullBody,
  //     );
  //     isApiValidationError = true;
  //     notifyListeners();
  //     return resp;
  //   } else {
  //     throw APIException(
  //       type: APIErrorType.auth,
  //       message:
  //           resp.data?.toString() ?? "Invalid credential. Please try again!",
  //     );
  //   }
  // }
  Future<APIResp> sendOTP({required String mobile}) async {
  await getdata();
  
  final resp = await APIService.post(
    UrlPath.loginUrl.sendOTP,
    data: {"mobile": mobile},
    showNoInternet: false,
    auth: false,
    forceLogout: false,
    console: true,
    timeout: const Duration(seconds: 30),
    headers: {},
  );

  print("Status Code: ${resp.statusCode}");
  print("API Status: ${resp.status}");
  print("API Data: ${resp.data}");

  if (resp.statusCode == 200) {
    // Store the full response
    loginResponse = resp.fullBody;
    
    isApiValidationError = false;
    notifyListeners();
    
    return resp;
  } else if (resp.data == "Validation Error") {
    AppConstants.apiValidationModel = ApiValidationModel.fromJson(
      resp.fullBody,
    );
    isApiValidationError = true;
    notifyListeners();
    return resp;
  } else {
    throw APIException(
      type: APIErrorType.auth,
      message:
          resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }
}

  // Future<APIResp> verifyOtpAndLogin({
  //   required String mobile,
  //   required String otp,
  // }) async {
  //   final apiService = APIService();
  //   final resp = await apiService.post(
  //     UrlPath.loginUrl.otpVerify,
  //     data: {"mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''), "otp": otp},
  //     showNoInternet: false,
  //     auth: false,
  //     forceLogout: false,
  //     console: true,
  //     timeout: const Duration(seconds: 30),
  //   );

  //   print(resp.statusCode);
  //   print(resp.status);

  //   if (resp.status) {
  //     // Parse the response into LoginModel
  //     LoginModel data = LoginModel.fromMap(resp.fullBody);

  //     // If the token exists, save it locally and return
  //     if (data.token != null && data.token!.isNotEmpty) {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString(AppConstants.token, data.token!);
  //     }

  //     return resp; // Return the API response
  //   } else if (!resp.status && resp.data == "Validation Error") {
  //     AppConstants.apiValidationModel = ApiValidationModel.fromJson(
  //       resp.fullBody,
  //     );
  //     isApiValidationError = true;
  //     notifyListeners();
  //     return resp;
  //   } else {
  //     throw APIException(
  //       type: APIErrorType.toast,
  //       message:
  //           resp.data?.toString() ?? "Invalid credential. Please try again!",
  //     );
  //   }
  // }

  // Future<APIResp> verifyOtpAndLogin({
  //   required String mobile,
  //   required String otp,
  // }) async {
  //   final apiService = APIService();
  //   final resp = await apiService.post(
  //     UrlPath.loginUrl.otpVerify,
  //     data: {"mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''), "otp": otp},
  //     showNoInternet: false,
  //     auth: false,
  //     forceLogout: false,
  //     console: true,
  //     timeout: const Duration(seconds: 30),
  //   );

  //   print(resp.statusCode);
  //   print(resp.status);

  //   // Check if the API call was successful (HTTP 200)
  //   if (resp.statusCode == 200) {
  //     // Parse the response into LoginModel
  //     LoginModel data = LoginModel.fromMap(resp.fullBody);

  //     // If the token exists, save it locally and return
  //     if (data.token != null && data.token!.isNotEmpty) {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString(AppConstants.token, data.token!);
  //     }

  //     // Return successful response
  //     return APIResp(
  //       status: true, // Force status to true for successful HTTP 200
  //       statusCode: resp.statusCode,
  //       data: resp.data,
  //       fullBody: resp.fullBody,
  //     );
  //   } else if (resp.statusCode == 400 && resp.data == "Validation Error") {
  //     AppConstants.apiValidationModel = ApiValidationModel.fromJson(
  //       resp.fullBody,
  //     );
  //     isApiValidationError = true;
  //     notifyListeners();
  //     return resp;
  //   } else {
  //     throw APIException(
  //       type: APIErrorType.toast,
  //       message:
  //           resp.data?.toString() ?? "Invalid credential. Please try again!",
  //     );
  //   }
  // }

  // Future<APIResp> verifyOtpAndLogin({
  //   required String mobile,
  //   required String otp,
   
  // }) async {
  //   final resp = await APIService.post(
  //     UrlPath.loginUrl.otpVerify,
  //     data: {"mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''), "otp": otp},
  //     showNoInternet: false,
  //     auth: false,
  //     forceLogout: false,
  //     console: true,
  //     timeout: const Duration(seconds: 30),
  //     headers: {},
  //   );

  //   print(resp.statusCode);
  //   print(resp.status);

  //   if (resp.statusCode == 200) {
  //     // Parse token and save locally
  //     LoginModel data = LoginModel.fromMap(resp.fullBody);

  //     if (data.token != null && data.token!.isNotEmpty) {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString(AppConstants.token, data.token!);

  //       // ✅ Save storeId (store code)
  //       final storeId = data.data?['storeId'] ?? '';
  //       if (storeId.isNotEmpty) {
  //         await prefs.setString(AppConstants.StoreCode, storeId);
  //         print("✅ Saved StoreCode: $storeId");
  //       }
  //     }

  //     return APIResp(
  //       status: true,
  //       statusCode: resp.statusCode,
  //       data: resp.data,
  //       fullBody: resp.fullBody,
  //     );
  //   } else if (resp.statusCode == 400 && resp.data == "Validation Error") {
  //     AppConstants.apiValidationModel = ApiValidationModel.fromJson(
  //       resp.fullBody,
  //     );
  //     isApiValidationError = true;
  //     notifyListeners();
  //     return resp;
  //   } else {
  //     throw APIException(
  //       type: APIErrorType.toast,
  //       message:
  //           resp.data?.toString() ?? "Invalid credential. Please try again!",
  //     );
  //   }
  // }

Future<APIResp> verifyLogin({
  required String mobile,
  required String otp,
  String? email,
  String? name,
  String? storeId,
}) async {
  final resp = await APIService.post(
    UrlPath.loginUrl.otpVerify,
    data: {
      "mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''),
      "otp": otp,
      "name": name,
      "email": email,
      "storeId":storeId,
    },
    showNoInternet: false,
    auth: false,
    forceLogout: false,
    console: true,
    timeout: const Duration(seconds: 30),
    headers: {},
  );

  print(resp.statusCode);
  print(resp.status);

  // Check if the API call was successful (HTTP 200)
  if (resp.statusCode == 200) {
    // Parse the response into LoginModel
    LoginModel data = LoginModel.fromMap(resp.fullBody);

    // If the token exists, save it locally and return
    if (data.token != null && data.token!.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.token, data.token!);
      
      // Save storeId (store code)
      final storeId = data.storeId ?? '';
      if (storeId.isNotEmpty) {
        await prefs.setString(AppConstants.StoreCode, storeId);
        print("✅ Saved StoreCode: $storeId");
      }
      
      // Fix: Use data.id directly instead of data.data?['id']
      final userId = data.userId ?? '';
      if (userId.isNotEmpty) {
        await prefs.setString(AppConstants.USER_ID, userId);
        print("✅ Saved User ID: $userId");  // Fix: Correct print statement
      } else {
        print("⚠️ User ID is empty in the response");
      }
    }
  }
  
 return resp;
}

  Future<APIResp> createProfile({
    required String userName,
    required String location,
    required String phone,
  }) async {
    // Prepare form data
    final formData = dio.FormData.fromMap({
      "name": userName,
      "location": location,
      "phone": phone,
    });

    final apiService = APIService();
    final resp = await APIService.post(
      '${UrlPath.loginUrl.createProfile}',
      data: formData,
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );

    print(resp.statusCode);
    print(resp.status);

    if (resp.status) {
      ProfileModel profile = ProfileModel.fromMap(resp.fullBody);

      // Save token locally
      if (profile.token != null && profile.token!.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.token, profile.token!);
      }

      return resp;
    } else {
      throw APIException(
        type: APIErrorType.toast,
        message: resp.data?.toString() ?? "Failed to create profile!",
      );
    }
  }

  //udpade user
  Future<APIResp> editProfile({
    required String userName,
    required String phone,
    required String token,
  }) async {
    // Prepare form data
    final formData = dio.FormData.fromMap({"name": userName, "phone": phone});

    final apiService = APIService();
    final resp = await APIService.post(
      '${UrlPath.loginUrl.updateProfile}/$token',
      data: formData,
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );

    print(resp.statusCode);
    print(resp.status);

    if (resp.status) {
      ProfileModel profile = ProfileModel.fromMap(resp.fullBody);

      // Save token locally
      if (profile.token != null && profile.token!.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.token, profile.token!);
      }

      return resp;
    } else {
      throw APIException(
        type: APIErrorType.toast,
        message: resp.data?.toString() ?? "Failed to create profile!",
      );
    }
  }

  //get user
  Future<void> fetchUser(String token) async {
    final ApiIntegration api = ApiIntegration();
    try {
      final String endpoint = '${UrlPath.getUrl.getUser}/$token';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      final String requestUrl = '$baseUrl$endpoint';
      print('Request URL: $requestUrl');
      log('Request URL: $requestUrl');

      // Fetch fruit categories using the fetchData method
      final List<GetprofileModel> getUser = await api
          .fetchData<GetprofileModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => GetprofileModel.fromJson(json),
          );

      // Update the local state and notify listeners
      _profile = getUser;
      notifyListeners();

      print('User fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      log('Error fetching fruits: $error');
      throw error;
    }
  }

  // Delete order Address
  Future<APIResp> deleteOrderAddress({
    required String addressId,
    required String token,
  }) async {
    // Prepare form data
    final formData = dio.FormData.fromMap({
      "address_id": addressId,
      "token": token,
    });
    final apiService = APIService();
    final resp = await APIService.post(
      UrlPath.loginUrl.deleteOrderAddress,
      data: formData,
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );
    print(resp.statusCode);
    print("siki----------------------->");
    print(resp.status);
    print("viki------------------>");
    if (resp.status) {
      isApiValidationError = false;
      return resp;
    } else if (!resp.status && resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    } else {
      throw APIException(
        type: APIErrorType.auth,
        message:
            resp.data?.toString() ?? "Invalid credential.please try again!",
      );
    }
  }

  // adding and removing wishlist
  Future<APIResp> addWishList({
    required String categoryId,
    required String token,
    required bool isCondtion,
    required String productId,
  }) async {
    // Prepare form data
    final formData = dio.FormData.fromMap({
      "category_id": categoryId,
      "token": token,
      "condition": isCondtion,
      "product_id": productId,
    });
    final apiService = APIService();
    final resp = await APIService.post(
      UrlPath.loginUrl.addWishlist,
      data: formData,
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );
    print(resp.statusCode);
    print("siki----------------------->");
    print(resp.status);
    print("viki------------------>");
    if (resp.status) {
      isApiValidationError = false;
      return resp;
    } else if (!resp.status && resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    } else {
      throw APIException(
        type: APIErrorType.auth,
        message:
            resp.data?.toString() ?? "Invalid credential.please try again!",
      );
    }
  }
}
