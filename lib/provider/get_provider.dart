import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/api/api_intergration.dart';
import 'package:fulupo/config/app_config.dart';
import 'package:fulupo/enums/enum.dart';
import 'package:fulupo/model/api_validation_model.dart';
import 'package:fulupo/model/banner_model.dart';
import 'package:fulupo/model/cart/getCart_model.dart';
import 'package:fulupo/model/dailyBookingSlot_model.dart';
import 'package:fulupo/model/getAddToCart_model.dart';
import 'package:fulupo/model/getAllOrder_address_model.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/model/getAll_categeory/getAll_product_model/getAll_product.dart';
import 'package:fulupo/model/getAll_categeory/getAll_subproduct_model/getAll_subproduct.dart';
import 'package:fulupo/model/getWishlist_model.dart';
import 'package:fulupo/model/order_history/getOrder_history.dart';
import 'package:fulupo/model/random_product_model.dart';
import 'package:fulupo/model/replacement_history/getReplacement_model.dart';
import 'package:fulupo/model/subscription/getAll_subscription_model.dart';
import 'package:fulupo/model/subscription/getAll_weekly_model.dart';
import 'package:fulupo/model/subscription/getall_weekly_package_model.dart';
import 'package:fulupo/service/api_service.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/util/url_path.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetProvider extends ChangeNotifier {
  bool isApiValidationError = false;
  bool isLoading = false;

  Map<String, bool> _favorites = {};
  Map<String, bool> get favorites => _favorites;

  void setFavorite(String productId, bool value) {
    _favorites[productId] = value;
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favorites[productId] ?? false;
  }

  //Variables

  String token = '';
  List<GetaddtocartModel> _getAddToCart = [];
  List<GetAllOrderAddressModel> _getOrderAddress = [];
  List<RandomProductModel> _randomProduct = [];

  List<DailybookingslotModel> _dailySlot = [];
  List<GetwishlistModel> _wishList = [];

  List<BannerModel> _banner = [];
  List<GetAllCategoryModel> _catgeory = [];
  List<GetallProduct> _product = [];
  List<GetallSubproduct> _subproduct = [];
  List<GetOrderHistory> _orderHistory = [];
  List<GetallSubscriptionModel> _subscription = [];
  List<GetallWeeklyModel> _weeklySubscription = [];
  List<GetallWeeklyPackageModel> _weeklyPackage = [];
 List<ReplacementResponse> _replacementList = [];
 

  //Getter

  List<RandomProductModel> get randomproduct => _randomProduct;

  List<GetaddtocartModel> get getAddToCart => _getAddToCart;
  List<GetAllOrderAddressModel> get getOrderAddress => _getOrderAddress;
  List<DailybookingslotModel> get getDailySlot => _dailySlot;
  List<GetwishlistModel> get getWishList => _wishList;

  List<BannerModel> get banner => _banner;

  List<GetAllCategoryModel> get category => _catgeory;
  List<GetallProduct> get getproduct => _product;
  List<GetallSubproduct> get subproduct => _subproduct;
  List<GetOrderHistory> get orderHistory => _orderHistory;
  List<GetallSubscriptionModel> get subscription => _subscription;
  List<GetallWeeklyModel> get weeklySubscription => _weeklySubscription;
  List<GetallWeeklyPackageModel> get weeklyPackage => _weeklyPackage;
  List<ReplacementResponse> get replacementList => _replacementList;

  // BaseUrl
  final String baseUrl = '${AppConfig.instance.baseUrl}';

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    print(token);
    log('Token: $token');
  }

  //----------------------------GET ALL PRODUCTS---------------------------

  Future<APIResp> fetchCategories({required String storeCode}) async {
    print("→ enter fetchCategories");
    isLoading = true;
    isApiValidationError = false;
    notifyListeners();

    try {
      print("→ before prefs.getInstance");
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
      );
      print("→ after prefs.getInstance");

      final savedToken = prefs.getString(AppConstants.token) ?? '';
      token = savedToken;
      print("→ token len: ${token.length}");

      if (token.isEmpty) {
        isLoading = false;
        notifyListeners();
        return APIResp(
          status: false,
          statusCode: 401,
          data: {"message": "Missing token"},
          fullBody: null,
        );
      }

      print("→ before API post");
      final resp = await APIService.post(
        UrlPath.getUrl.getAllCatgeory,
        data: {"storeId": storeCode},
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));
      print("→ after API post | code: ${resp.statusCode}");

      if (resp.statusCode == 200 &&
          resp.data is Map &&
          resp.data["success"] == true) {
        final cats = (resp.data["categories"] as List?) ?? [];
        _catgeory = cats
            .map<GetAllCategoryModel>((e) => GetAllCategoryModel.fromJson(e))
            .toList();
        isLoading = false;
        notifyListeners();
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: resp.data,
          fullBody: resp.fullBody,
        );
      } else {
        isApiValidationError = true;
        isLoading = false;
        notifyListeners();
        return APIResp(
          status: false,
          statusCode: resp.statusCode,
          data: resp.data,
          fullBody: resp.fullBody,
        );
      }
    } on TimeoutException catch (_) {
      print("✖ timeout in fetchCategories (prefs or network)");
      isLoading = false;
      notifyListeners();
      return APIResp(
        status: false,
        statusCode: 408,
        data: {"message": "Timeout"},
        fullBody: null,
      );
    } catch (e, s) {
      print("✖ Exception in fetchCategories: $e\n$s");
      isLoading = false;
      notifyListeners();
      return APIResp(
        status: false,
        statusCode: 500,
        data: {"message": e.toString()},
        fullBody: null,
      );
    }
  }

  //get all category

  // Future<void> fetchCategory() async {
  //   final ApiIntegration api = ApiIntegration();

  //   try {
  //     await getdata();
  //     final String endpoint = UrlPath.getUrl.getAllCatgeory;
  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': token,
  //     };

  //     print('Request URL: $baseUrl$endpoint');
  //     log('Request URL: $baseUrl$endpoint');
  //     // Fetch data from API
  //     final List<GetallCategoryModel> fetchedCategory = await api
  //         .fetchData<GetallCategoryModel>(
  //           baseUrl: baseUrl,
  //           endpoint: endpoint,
  //           headers: headers,
  //           fromJson: (json) => GetallCategoryModel.fromJson(
  //             json,
  //           ), // Convert JSON to Fruit model
  //         );
  //     _catgeory = fetchedCategory;
  //     notifyListeners();
  //     print('All Category fetched successfully!');
  //     log('All Category fetched successfully!');
  //   } catch (error) {
  //     print('Error fetching fruits: $error');
  //     throw error;
  //   }
  // }

  // Future<APIResp> fetchCategories({required String storeCode}) async {
  //   print("--------------------- enter fetchCategories");
  //   isLoading = true;
  //   isApiValidationError = false;
  //   notifyListeners();

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedToken = prefs.getString(AppConstants.token);
  //     token = savedToken ?? '';
  //     print("Using token for fetchCategories: $token");

  //     if (token.isEmpty) {
  //       isLoading = false;
  //       notifyListeners();
  //       return APIResp(
  //         status: false,
  //         statusCode: 401,
  //         data: {"message": "Missing token"},
  //         fullBody: null,
  //       );
  //     }

  //     final resp = await APIService.post(
  //       UrlPath.getUrl.getAllCatgeory,
  //       data: {"storeId": storeCode},
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     print("Response Status Code: ${resp.statusCode}");
  //     print("Response Data------------------>");
  //     print("--------------------->  ${resp.data}");

  //     if (resp.statusCode == 200 &&
  //         resp.data is Map &&
  //         resp.data["success"] == true) {
  //       final List cats = (resp.data["categories"] as List?) ?? [];

  //       // Parse using your models
  //       final parsed = cats.map<GetAllCategoryModel>((e) {
  //         final m = GetAllCategoryModel.fromJson(e as Map<String, dynamic>);
  //         // Optional trim on categoryName
  //         return GetAllCategoryModel(
  //           id: m.id,
  //           categoryName: m.categoryName.trim(),
  //           products: m.products,
  //         );
  //       }).toList();

  //       _catgeory = parsed;
  //       isLoading = false;
  //       notifyListeners();

  //       return APIResp(
  //         status: true,
  //         statusCode: resp.statusCode,
  //         data: resp.data,
  //         fullBody: resp.fullBody,
  //       );
  //     } else {
  //       isApiValidationError = true;
  //       isLoading = false;
  //       notifyListeners();

  //       return APIResp(
  //         status: false,
  //         statusCode: resp.statusCode,
  //         data: resp.data,
  //         fullBody: resp.fullBody,
  //       );
  //     }
  //   } catch (e) {
  //     print("❌ Exception in fetchCategories: $e");
  //     isLoading = false;
  //     notifyListeners();

  //     return APIResp(
  //       status: false,
  //       statusCode: 500,
  //       data: {"message": e.toString()},
  //       fullBody: null,
  //     );
  //   }
  // }

  // Future<void> fetchCategory(String storeCode) async {
  //   final ApiIntegration api = ApiIntegration();

  //   try {
  //     await getdata();
  //     final String endpoint = UrlPath.getUrl.getAllCatgeory;
  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': token,
  //     };

  //     print('Request URL: $baseUrl$endpoint');
  //     log('Request URL: $baseUrl$endpoint');

  //     // ✅ Fetch data with fromJson
  //     final List<GetAllCategoryModel> fetchedCategory = await api
  //         .fetchData<GetAllCategoryModel>(
  //           baseUrl: baseUrl,
  //           endpoint: endpoint,
  //           headers: headers,
  //           body: {"storeId": storeCode},
  //           fromJson: (json) => GetAllCategoryModel.fromJson(json),
  //         );

  //     _catgeory = fetchedCategory;
  //     notifyListeners();

  //     print('✅ All categories fetched successfully!');
  //     log('✅ All categories fetched successfully!');
  //   } catch (error) {
  //     print('❌ Error fetching categories: $error');
  //     throw error;
  //   }
  // }

  Future<APIResp> getProducts() async {
    print("--------------------- enter getProducts");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    print("Using token for getProducts: $token");

    try {
      final resp = await APIService.post(
        UrlPath.getUrl.getAllCatgeory, // ✅ point to correct endpoint
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        data: null,
      );

      print("Response Status Code: ${resp.statusCode}");
      print("Response Data------------------>");
      print(resp.data);

      if (resp.statusCode == 200 && resp.fullBody['data'] != null) {
        List<dynamic> productJsonList = resp.fullBody['data'];
        List<GetAllCategoryModel> products = productJsonList
            .map((e) => GetAllCategoryModel.fromJson(e))
            .toList();

        /// ✅ store products in provider for UI use
        _catgeory = products;
        notifyListeners();

        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: products,
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error fetching products.",
        );
      }
    } catch (e) {
      print("❌ Exception in getProducts: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: null,
        fullBody: null,
      );
    }
  }
  // get all product

  Future<void> fetchProduct(String productid) async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint = '${UrlPath.getUrl.getAllProduct}/${productid}';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      // Fetch data from API
      final List<GetallProduct> fetchedProduct = await api
          .fetchData<GetallProduct>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) =>
                GetallProduct.fromJson(json), // Convert JSON to Fruit model
          );
      _product = fetchedProduct;
      notifyListeners();
      print('All Product fetched successfully!');
      log('All Product fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      throw error;
    }
  }
  // get all sub product

  Future<void> fetchSubProduct(String subproductid) async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint =
          '${UrlPath.getUrl.getAllSubProduct}/${subproductid}';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      // Fetch data from API
      final List<GetallSubproduct> fetchedSubProduct = await api
          .fetchData<GetallSubproduct>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) =>
                GetallSubproduct.fromJson(json), // Convert JSON to Fruit model
          );
      _subproduct = fetchedSubProduct;
      notifyListeners();
      print('All Sub Product fetched successfully!');
      log('All Sub Product fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      throw error;
    }
  }

  //Random getting all product

  Future<void> fetchRandomProduct(List<String> itemIds) async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint = UrlPath.getUrl.getrandomproduct;
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      final Map<String, dynamic> body = {
        'item_ids': itemIds, // Sending item_ids array as Strings
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      print('Request Body: $body');

      final List<RandomProductModel> fetchedRandomProduct = await api
          .fetchData<RandomProductModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            body: body, // Passing body with item_ids
            fromJson: (json) => RandomProductModel.fromJson(json),
          );

      _randomProduct = fetchedRandomProduct;
      notifyListeners();
      print('Random Products fetched successfully!');
      log('Random Products fetched successfully!');
    } catch (error) {
      print('Error fetching random products: $error');
      throw error;
    }
  }

  //--------------------CART FUNCTION----------------------------------------------
  // Function to add to cart
  Future<APIResp> addToCart({
    required String fruitId,
    required String categoryId,
    required int count,
    required String token,
  }) async {
    // final String? firebaseToken = await FirebaseMessaging.instance.getToken();
    final apiService = APIService();
    final resp = await APIService.post(
      UrlPath.getUrl.addToCart,
      data: {
        "item_id": fruitId,
        "category_id": categoryId,
        "count": count,
        "token": token,
      },
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

  //fetching cart item particular user
  Future<List<GetaddtocartModel>> fetchAddToCart(String token) async {
    final ApiIntegration api = ApiIntegration();
    try {
      final String endpoint = '${UrlPath.getUrl.getCart}/$token';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      // Fetch the cart data
      final List<GetaddtocartModel> fetchedData = await api
          .fetchData<GetaddtocartModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => GetaddtocartModel.fromJson(json),
          );

      // Update the local state
      _getAddToCart = fetchedData;
      notifyListeners();

      print('Cart data fetched successfully!');
      log('Cart data fetched successfully!');

      // Return the fetched data
      return fetchedData;
    } catch (error) {
      print('Error fetching cart data: $error');
      throw error;
    }
  }

  // update the cart item
  Future<APIResp> updateCart({
    required String categoryId,
    required int count,
    required String token,
  }) async {
    // final String? firebaseToken = await FirebaseMessaging.instance.getToken();
    final apiService = APIService();
    final resp = await APIService.post(
      UrlPath.getUrl.updateCart,
      data: {"count_change": count, "category_id": categoryId, "token": token},
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

// Future<APIResp> addAddress({
//   required String name,
//   required String phone,
//   required String token,
//   required String address,
//   required String addressType,
//   required String addAddressName,
// }) async {
//   final resp = await APIService.post(
//     UrlPath.getUrl.addAddress,
//     data: {
//       "name": name,
//       "mobile": phone,
//       "addressLine": address,
//       "addressType": addressType,
//       "addressName": addAddressName,
//     },
//     showNoInternet: false,
//     auth: true,
//     forceLogout: false,
//     console: true,
//     timeout: const Duration(seconds: 30),
//     headers: {},
//   );

//   print(resp.statusCode);
//   print("siki----------------------->");
//   print(resp.status);
//   print("viki------------------>");

//   if (resp.status) {
//     isApiValidationError = false;

//     // ✅ Extract address ID and save it locally
//     try {
//       final data = resp.fullBody;
//       if (data != null && data is Map && data['addresses'] != null) {
//         // Get the latest (most recent) address from list
//         final List addresses = data['addresses'];
//         if (addresses.isNotEmpty) {
//           final latestAddress = addresses.last;
//           final addressId = latestAddress['_id'];

//           // ✅ Save in SharedPreferences
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(AppConstants.ADDRESS_ID, addressId);

//           print("✅ Address ID saved locally: $addressId");
//         }
//       }
//     } catch (e) {
//       print("⚠️ Error saving address ID: $e");
//     }

//     return resp;
//   } else if (!resp.status && resp.data == "Validation Error") {
//     AppConstants.apiValidationModel = ApiValidationModel.fromJson(resp.fullBody);
//     isApiValidationError = true;
//     notifyListeners();
//     return resp;
//   } else {
//     throw APIException(
//       type: APIErrorType.auth,
//       message: resp.data?.toString() ?? "Invalid credential. Please try again!",
//     );
//   }
// }

Future<APIResp> addAddress({
  required String name,
  required String phone,
  required String token,
  required String address,
  required String addressType,
  required String addAddressName,
}) async {
  final resp = await APIService.post(
    UrlPath.postUrl.addAddress,
    data: {
      "name": name,
      "mobile": phone,
      "addressLine": address,
      "addressType": addressType,
      "addressName": addAddressName,
    },
    showNoInternet: false,
    auth: true,
    forceLogout: false,
    console: true,
    timeout: const Duration(seconds: 30),
    headers: {},
  );

  print(resp.statusCode);
  print("siki----------------------->");
  print(resp.status);
  print("viki------------------>");

  // ✅ Treat message containing "success" as success even if resp.status is false
  final bool isMessageSuccess = (resp.fullBody['message']?.toString().toLowerCase().contains('success') ?? false);

  if (resp.status || isMessageSuccess) {
    isApiValidationError = false;

    // ✅ Extract address ID and save it locally
    try {
      final data = resp.fullBody;
      if (data != null && data is Map && data['address'] != null) {
        final addressId = data['address']['_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.ADDRESS_ID, addressId);

        print("✅ Address ID saved locally: $addressId");
      }
    } catch (e) {
      print("⚠️ Error saving address ID: $e");
    }

    return resp;
  } else if (!resp.status && resp.data == "Validation Error") {
    AppConstants.apiValidationModel = ApiValidationModel.fromJson(resp.fullBody);
    isApiValidationError = true;
    notifyListeners();
    return resp;
  } else {
    throw APIException(
      type: APIErrorType.auth,
      message: resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }
}


//new
  Future<void> fetchOrderAddress(String token) async {
    try {
      final String endpoint = UrlPath.getUrl.getAddress;

      final response = await APIService.get(
        endpoint,
        headers: {
          'Authorization': 'Bearer $token', // ✅ Correct way to send token
        },
      );

      print("✅ API Success: ${response.fullBody}");

      final data = response.fullBody;
      if (data != null && data['addresses'] != null) {
        final List list = data['addresses'];

        // ✅ Parse and assign to provider variable
        _getOrderAddress = list
            .map((e) => GetAllOrderAddressModel.fromJson(e))
            .toList();

        // ✅ Notify UI listeners after data update
        notifyListeners();
      } else {
        _getOrderAddress = [];
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error fetching addresses: $e");
      _getOrderAddress = [];
      notifyListeners();
      rethrow;
    }
  }
// // new for delete a address
// Future<APIResp> deleteOrderAddress({
//   required String addressId,
//   required String token,
// }) async {
//   try {
//     final String endpoint = "${UrlPath.deleteUrl.deleteAddress}/$addressId";

//     final response = await APIService.delete(
//       endpoint,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     log("🗑️ Delete Response: ${response.fullBody}");

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       // Success
//       await fetchOrderAddress(token); // Refresh list after delete
//       notifyListeners();
//       return APIResp(status: true, data: "Address deleted successfully");
//     } else {
//       return APIResp(
//         status: false,
//         data: "Failed to delete address (${response.statusCode})",
//       );
//     }
//   } catch (e) {
//     log("❌ Error deleting address: $e");
//     return APIResp(status: false, data: "Error deleting address");
//   }
// }


  //Get all Order Address-------------------------------------
  // Future<void> fetchOrderAddress(String token) async {
  //   final ApiIntegration api = ApiIntegration();
  //   try {
  //     final String endpoint = '${UrlPath.getUrl.getAddress}/$token';
  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': token,
  //     };
  //     final String requestUrl = '$baseUrl$endpoint';
  //     print('Request URL: $requestUrl');
  //     log('Request URL: $requestUrl');
  //     // Fetch fruit categories using the fetchData method
  //     final List<GetAllOrderAddressModel> fetchedOrderAddress = await api
  //         .fetchData<GetAllOrderAddressModel>(
  //           baseUrl: baseUrl,
  //           endpoint: endpoint,
  //           headers: headers,
  //           fromJson: (json) => GetAllOrderAddressModel.fromJson(json),
  //         );
  //     // Update the local state and notify listeners
  //     _getOrderAddress = fetchedOrderAddress;
  //     notifyListeners();
  //     print('Order Address fetched successfully!');
  //   } catch (error) {
  //     print('Error fetching fruits: $error');
  //     log('Error fetching fruits: $error');
  //     throw error;
  //   }
  // }

  //fetch DailyBooking Slot

  Future<void> fetchDailyBookingSlot() async {
    final ApiIntegration api = ApiIntegration();
    await getdata();
    try {
      final String endpoint = '${UrlPath.getUrl.getDailySlot}';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      final String requestUrl = '$baseUrl$endpoint';

      print('Request URL: $requestUrl');
      log('Request URL: $requestUrl');

      // Fetch daily slots
      final List<DailybookingslotModel> fetchedDailySlot = await api
          .fetchData<DailybookingslotModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => DailybookingslotModel.fromJson(json),
          );

      _dailySlot = fetchedDailySlot;
      notifyListeners();

      print('Daily Booking Slot fetched successfully!');
      log('Daily Booking Slot fetched successfully!');
    } catch (error) {
      print('Error fetching slots: $error');
      log('Error fetching slots: $error');
      throw error;
    }
  }

  //pre booking slot
  Future<void> fetchPreBookingSlot() async {
    final ApiIntegration api = ApiIntegration();
    await getdata();
    try {
      final String endpoint = '${UrlPath.getUrl.getPreSlot}';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      final String requestUrl = '$baseUrl$endpoint';

      print('Request URL: $requestUrl');
      log('Request URL: $requestUrl');

      // Fetch daily slots
      final List<DailybookingslotModel> fetchedPreBookingSlot = await api
          .fetchData<DailybookingslotModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => DailybookingslotModel.fromJson(json),
          );

      _dailySlot = fetchedPreBookingSlot;
      notifyListeners();

      print('Pre Booking Slot fetched successfully!');
      log('Pre Booking Slot fetched successfully!');
    } catch (error) {
      print('Error fetching slots: $error');
      log('Error fetching slots: $error');
      throw error;
    }
  }

  //get WishList
  // Future<List<GetwishlistModel>> fetchWishList(String token) async {
  //   final ApiIntegration api = ApiIntegration();
  //   try {
  //     final String endpoint = '${UrlPath.getUrl.getWishList}/$token';
  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': token,
  //     };

  //     // Fetch the cart data
  //     final List<GetwishlistModel> fetchedWishList = await api
  //         .fetchData<GetwishlistModel>(
  //           baseUrl: baseUrl,
  //           endpoint: endpoint,
  //           headers: headers,
  //           fromJson: (json) => GetwishlistModel.fromJson(json),
  //         );

  //     // Update the local state
  //     _wishList = fetchedWishList;
  //     notifyListeners();

  //     print('WishList fetched successfully!');
  //     log('WishListfetched successfully!');

  //     // Return the fetched data
  //     return fetchedWishList;
  //   } catch (error) {
  //     print('Error fetching cart data: $error');
  //     throw error;
  //   }
  // }
  // get banner image

  Future<void> fetchBanner() async {
    final ApiIntegration api = ApiIntegration();
    await getdata();
    try {
      final String endpoint = '${UrlPath.getUrl.getBanner}';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      final String requestUrl = '$baseUrl$endpoint';

      print('Request URL: $requestUrl');
      log('Request URL: $requestUrl');

      // Fetch daily slots
      final List<BannerModel> fetchedBanner = await api.fetchData<BannerModel>(
        baseUrl: baseUrl,
        endpoint: endpoint,
        headers: headers,
        fromJson: (json) => BannerModel.fromJson(json),
      );

      _banner = fetchedBanner;
      notifyListeners();

      print('Banner fetched successfully!');
      log('Banner fetched successfully!');
    } catch (error) {
      print('Error fetching Banner: $error');
      log('Error fetching Banner: $error');
      throw error;
    }
  }
  // adding to order history

  Future<APIResp> addBooking({
    required String token,
    required List<Map<String, dynamic>> items,
    required DateTime bookingDate, // Keep as DateTime
    required String slotSchedule,
    required String startTime,
    required String endTime,
    required double oldPrice,
    required double savings,
    required double gst,
    required double deliveryFees,
    required double totalPay,
    required String order_Address,
  }) async {
    final apiService = APIService();

    final resp = await APIService.post(
      UrlPath.getUrl.addBookingOrder,
      data: {
        "token": token,
        "items": items
            .map(
              (item) => {
                "sub_category_id": item["sub_category_id"],
                "count": item["count"],
              },
            )
            .toList(),
        "booking_date": bookingDate.toIso8601String().split(
          "T",
        )[0], // Convert to YYYY-MM-DD
        "slot_schedule": slotSchedule,
        "start_time": startTime,
        "end_time": endTime,
        "old_price": oldPrice,
        "savings": savings,
        "gst": gst,
        "delivery_fees": deliveryFees,
        "total_pay": totalPay,
        "order_address": order_Address,
      },
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );

    print("Status Code: ${resp.statusCode}");
    print("Response Status: ${resp.status}");

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
            resp.data?.toString() ??
            "Invalid booking details. Please try again!",
      );
    }
  }
  // get order history

  Future<void> fetchOrderHistory(String token) async {
    final ApiIntegration api = ApiIntegration();
    await getdata();
    try {
      final String endpoint = '${UrlPath.getUrl.getOrderHistory}/$token';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      final String requestUrl = '$baseUrl$endpoint';

      print('Request URL: $requestUrl');
      log('Request URL: $requestUrl');

      // Fetch order history with corrected API response handling
      final List<GetOrderHistory> fetchedOrderHistory = await api
          .fetchData<GetOrderHistory>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => GetOrderHistory.fromJson(json),
          );

      _orderHistory = fetchedOrderHistory;
      notifyListeners();

      print('Order History fetched successfully!');
      log('Order History fetched successfully!');
    } catch (error) {
      print('Error fetching Order History: $error');
      log('Error fetching Order History: $error');
    }
  }

  // get all subscription
  Future<void> fetchSubscription() async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint = UrlPath.getUrl.getAllSubscription;
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      // Fetch data from API
      final List<GetallSubscriptionModel> fetchedSubscription = await api
          .fetchData<GetallSubscriptionModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => GetallSubscriptionModel.fromJson(
              json,
            ), // Convert JSON to Fruit model
          );
      _subscription = fetchedSubscription;
      notifyListeners();
      print('All Subscription fetched successfully!');
      log('All Subscription fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      throw error;
    }
  }

  // get all weeekly subscription
  Future<void> fetchWeeklySubscription() async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint = UrlPath.getUrl.getAllWeeklySubscription;
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      // Fetch data from API
      final List<GetallWeeklyModel> fetchedWeeklySubscription = await api
          .fetchData<GetallWeeklyModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) =>
                GetallWeeklyModel.fromJson(json), // Convert JSON to Fruit model
          );
      _weeklySubscription = fetchedWeeklySubscription;
      notifyListeners();
      print('All Weekly Subscription fetched successfully!');
      log('All Weekly Subscription fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      throw error;
    }
  }

  //get weekly package types
  Future<void> fetchWeeklyPackageType(String weekId) async {
    final ApiIntegration api = ApiIntegration();

    try {
      final String endpoint = '${UrlPath.getUrl.getAllWeeklyPackage}/$weekId';
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      print('Request URL: $baseUrl$endpoint');
      log('Request URL: $baseUrl$endpoint');
      // Fetch data from API
      final List<GetallWeeklyPackageModel> fetchedWeeklyPackageType = await api
          .fetchData<GetallWeeklyPackageModel>(
            baseUrl: baseUrl,
            endpoint: endpoint,
            headers: headers,
            fromJson: (json) => GetallWeeklyPackageModel.fromJson(
              json,
            ), // Convert JSON to Fruit model
          );
      _weeklyPackage = fetchedWeeklyPackageType;
      notifyListeners();
      print('All Weekly Package Type fetched successfully!');
      log('All Weekly Package Type fetched successfully!');
    } catch (error) {
      print('Error fetching fruits: $error');
      throw error;
    }
  }

  // weekly subscription booking
  Future<APIResp> addWeeklyBooking({
    required String token,
    required String weeklyPackageId,
    required String packageType,
    required String date1,
    required String date2,
    required String date3,
    String? date4,
    String? date5,
    String? date6,
    String? date7,
    required double price,
    required double gst,
    required double discount,
    required double totalPay,
    required List<Map<String, dynamic>> items,
    required List<String> selectedDates,
  }) async {
    final apiService = APIService();

    final resp = await APIService.post(
      UrlPath.getUrl.bookingWeekSubscription,
      data: {
        "token": token,
        "weekly_id": weeklyPackageId,
        "package_type": packageType,
        "date1": date1,
        "date2": date2,
        "date3": date3,
        "date4": date4,
        "date5": date5,
        "date6": date6,
        "date7": date7,
        "price": price,
        "gst": gst,
        "discount": discount,
        "total_pay": totalPay,
        "items": _prepareItemsForRequest(items, selectedDates),
      },
      showNoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
      headers: {},
    );

    print("Status Code: ${resp.statusCode}");
    print("Response Status: ${resp.status}");

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
            resp.data?.toString() ??
            "Invalid booking details. Please try again!",
      );
    }
  }

  // Function to adjust the 'items' structure
  List<Map<String, dynamic>> _prepareItemsForRequest(
    List<Map<String, dynamic>> items,
    List<String> selectedDates,
  ) {
    List<Map<String, dynamic>> formattedItems = [];

    for (var i = 0; i < items.length; i++) {
      var item = items[i];

      // Ensure there is an entry for each day in the selectedDates
      Map<String, dynamic> itemEntry = {'fruit': item['fruit']};

      for (var j = 0; j < selectedDates.length; j++) {
        // Add fruit with correct day key
        itemEntry['day${j + 1}'] = item['dates'].length > j
            ? item['dates'][j]
            : ''; // Ensure we don't exceed the length of the dates array
      }

      formattedItems.add(itemEntry);
    }

    print("Formatted Items: ${jsonEncode(formattedItems)}");
    return formattedItems;
  }

  // ------------------------------------------------------------------------------------------------------------------------------------

  // Whishlist (add,remove,get)

  Future<APIResp> addWishList({
    required String customerId,
    required String storeId,
    required String productId,
  }) async {
    log("--------------------- enter addWishList");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    log("Using token for addWishList: $token");

    try {
      final data = {
        "customerId": customerId,
        "storeId": storeId,
        "productId": productId,
      };

      log('Adding to wishlist: $data');

      final resp = await APIService.post(
        UrlPath.postUrl.addWishList,
        data: jsonEncode(data),
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Response Data------------------>");
      log("${resp.data}");

      // Check for success based on status code and message
      if (resp.statusCode == 200) {
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: resp.fullBody['message'] ?? "Added to wishlist",
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error adding to wishlist.",
        );
      }
    } catch (e) {
      log("❌ Exception in addWishList: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: "Failed to add to wishlist: $e",
        fullBody: null,
      );
    }
  }

  Future<APIResp> removeWishList({
    required String customerId,
    required String storeId,
    required String productId,
  }) async {
    log("--------------------- enter removeWishList");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    log("Using token for removeWishList: $token");

    try {
      final data = {
        "customerId": customerId,
        "storeId": storeId,
        "productId": productId,
      };

      log('Removing from wishlist: $data');

      final resp = await APIService.post(
        UrlPath.postUrl.removeWishList, // Update this with your actual endpoint
        data: jsonEncode(data),
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Response Data------------------>");
      log("${resp.data}");

      // Check for success
      if (resp.statusCode == 200) {
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: "Removed from wishlist",
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error removing from wishlist.",
        );
      }
    } catch (e) {
      log("❌ Exception in removeWishList: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: "Failed to remove from wishlist: $e",
        fullBody: null,
      );
    }
  }

  // Future<List<ProductModel>> getWishlistProducts(String customerId) async {
  //   log("--------------------- enter getWishlistProducts");

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString(AppConstants.token);
  //   String? storeId = prefs.getString(AppConstants.StoreCode);

  //   log("Using token for getWishlistProducts: $token");

  //   if (customerId.isEmpty || storeId == null || storeId.isEmpty) {
  //     return [];
  //   }

  //   try {
  //     final data = {
  //       "customerId": customerId,
  //       "storeId": storeId,

  //     };

  //     final resp = await APIService.post(
  //       UrlPath.getUrl.getWishlist,
  //       data: data,
  //       console: true,
  //       auth: true,
  //       showNoInternet: false,
  //       forceLogout: false,
  //       timeout: const Duration(seconds: 30),

  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     );

  //     log("Response Status Code: ${resp.statusCode}");

  //     if (resp.statusCode == 200 && resp.fullBody['data'] != null) {
  //       final wishlistData = resp.fullBody['data'] as List<dynamic>;

  //       List<ProductModel> products = [];

  //       // Extract product details from wishlist items
  //       for (var item in wishlistData) {
  //         // Assuming each wishlist item has a productDetails field
  //         // Adjust according to your API response structure
  //         if (item['productDetails'] != null) {
  //           final productData = item['productDetails'];
  //           products.add(ProductModel.fromJson(productData));
  //         }
  //       }

  //       return products;
  //     } else {
  //       log("No wishlist data found or error in response");
  //       return [];
  //     }
  //   } catch (e) {
  //     log("❌ Exception in getWishlistProducts: $e");
  //     return [];
  //   }
  // }

  Future<List<ProductModel>> getWishlistProducts(String customerId) async {
    log("--------------------- enter getWishlistProducts");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    String? storeId = prefs.getString(AppConstants.StoreCode);

    log("Using token for getWishlistProducts: $token");

    if (customerId.isEmpty || storeId == null || storeId.isEmpty) {
      return [];
    }

    try {
      // First, get the list of wishlist items
      final resp = await APIService.post(
        UrlPath.getUrl.getWishlist,
        params: {},
        data: jsonEncode({"customerId": customerId, "storeId": storeId}),
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");

      if (resp.statusCode == 200 && resp.fullBody['data'] != null) {
        final List<dynamic> wishlistData = resp.fullBody['data'];
        List<String> productIds = [];

        // Extract product IDs from the wishlist
        for (var item in wishlistData) {
          if (item['productId'] != null) {
            // Check if productId is a string or an object
            if (item['productId'] is Map) {
              String? id = item['productId']['_id'];
              if (id != null) {
                productIds.add(id);
              }
            } else if (item['productId'] is String) {
              productIds.add(item['productId']);
            }
          }
        }

        log("Extracted product IDs: $productIds");

        if (productIds.isEmpty) {
          return [];
        }

        // Find products in the categories we already have
        List<ProductModel> products = [];

        // Iterate through all categories and find matching products
        for (var cat in category) {
          // Use 'category' getter instead of '_category'
          for (var product in cat.products) {
            if (productIds.contains(product.id)) {
              products.add(product);
            }
          }
        }

        log("Found ${products.length} products from categories");
        return products;
      }

      log("No wishlist data found or error in response");
      return [];
    } catch (e) {
      log("❌ Exception in getWishlistProducts: $e");
      return [];
    }
  }

  Future<APIResp> addCart({
    required int quantity,
    required String storeId,
    required String productId,
  }) async {
    log("--------------------- enter addToCart");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    log("Using token for addToCart: $token");

    try {
      final data = {
        "quantity": quantity,
        "storeId": storeId,
        "productId": productId,
      };

      log('Adding to Cart: $data');

      final resp = await APIService.post(
        UrlPath.postUrl.addToCart,
        data: jsonEncode(data),
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Response Data------------------>");
      log("${resp.data}");

      // Check for success based on status code and message
      if (resp.statusCode == 200) {
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: resp.fullBody['message'] ?? "Added to Cart",
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error adding to Cart.",
        );
      }
    } catch (e) {
      log("❌ Exception in addCart: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: "Failed to add to Cart: $e",
        fullBody: null,
      );
    }
  }

  Future<List<GetcartModel>> getCart() async {
    log("--------------------- enter getCart");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);

    if (token == null || token.isEmpty) {
      log("Token missing — cannot fetch cart");
      return [];
    }

    try {
      final resp = await APIService.get(
        UrlPath.getUrl.getCart, // should point to your cart endpoint
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Full Cart Response: ${resp.fullBody}");

      // ✅ The root JSON itself contains the cart data
      if (resp.statusCode == 200 && resp.fullBody['items'] != null) {
        final List<dynamic> items = resp.fullBody['items'];

        List<GetcartModel> cartList = items
            .map((item) => GetcartModel.fromJson(item))
            .toList();

        log("✅ Cart loaded with ${cartList.length} items");
        return cartList;
      }

      log("No cart items found or invalid response");
      return [];
    } catch (e, st) {
      log("❌ Exception in getCart: $e\n$st");
      return [];
    }
  }

  Future<APIResp> UpdateCart({
    required int quantity,
    required String storeId,
    required String productId,
  }) async {
    log("--------------------- enter UpdateCart");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    log("Using token for UpdateCart: $token");

    try {
      final data = {
        "quantity": quantity,
        "storeId": storeId,
        "productId": productId,
      };

      log('Update from Cart: $data');

      final resp = await APIService.post(
        UrlPath.postUrl.updateCart,
        data: jsonEncode(data),
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Response Data------------------>");
      log("${resp.data}");

      // Check for success
      if (resp.statusCode == 200) {
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: "Update from Cart",
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error Update from Cart.",
        );
      }
    } catch (e) {
      log("❌ Exception in UpdateCart: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: "Failed to Update from Cart: $e",
        fullBody: null,
      );
    }
  }

  Future<APIResp> RemoveCart({

    required String storeId,
    required String productId,
  }) async {
    log("--------------------- enter RemoveCart");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.token);
    log("Using token for RemoveCart: $token");

    try {
      final data = {
    
        "storeId": storeId,
        "productId": productId,
      };

      log('Update from Cart: $data');

      final resp = await APIService.post(
        UrlPath.postUrl.removeCart,
        data: jsonEncode(data),
        params: {},
        console: true,
        auth: true,
        showNoInternet: false,
        forceLogout: false,
        timeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log("Response Status Code: ${resp.statusCode}");
      log("Response Data------------------>");
      log("${resp.data}");

      // Check for success
      if (resp.statusCode == 200) {
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: "Remove from Cart",
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.auth,
          message: resp.data?.toString() ?? "Error Remove from Cart.",
        );
      }
    } catch (e) {
      log("❌ Exception in RemoveCart: $e");
      return APIResp(
        status: false,
        statusCode: 500,
        data: "Failed to Remove from Cart: $e",
        fullBody: null,
      );
    }
  }

//Orders
Future<APIResp> createOrder({
  required String storeId,
  required String addressId,
  required List<Map<String, dynamic>> items,
  required double totalAmount,
  required String paymentMode,
}) async {
  log("--------------------- enter createOrder");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(AppConstants.token);
  log("Using token for createOrder: $token");

  try {
    final data = {
      "storeId": storeId,
      "addressId": addressId,
      "items": items,
      "totalAmount": totalAmount,
      "paymentMode": paymentMode,
    };
    
    log('Create Order data: $data');
    
    final resp = await APIService.post(
      UrlPath.postUrl.createOrder,
      data: jsonEncode(data),
      params: {},
      console: true,
      auth: true,
      showNoInternet: false,
      forceLogout: false,
      timeout: const Duration(seconds: 30),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    log("Response Status Code: ${resp.statusCode}");
    log("Response Data------------------>");
    log("${resp.data}");
    
    // Check for success based on status code AND presence of order object
    if (resp.statusCode == 200) {
      // Check if response contains 'order' object (indicates success)
      if (resp.fullBody != null && resp.fullBody['order'] != null) {
        String message = resp.fullBody['message'] ?? "Order created successfully";
        log("✅ Order creation successful: $message");
        
        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: message,
          fullBody: resp.fullBody,
        );
      } else {
        // 200 but no order object means something went wrong
        String errorMessage = resp.fullBody?['message'] ?? "Error creating order.";
        log("❌ Order creation failed: $errorMessage");
        
        return APIResp(
          status: false,
          statusCode: resp.statusCode ?? 500,
          data: errorMessage,
          fullBody: resp.fullBody,
        );
      }
    } else {
      // Non-200 status code
      String errorMessage = "Error creating order.";
      
      if (resp.data is Map) {
        final dataMap = resp.data as Map<String, dynamic>;
        errorMessage = dataMap['message'] ?? dataMap['error'] ?? errorMessage;
      } else if (resp.data is String) {
        errorMessage = resp.data;
      }
      
      log("❌ Order creation failed: $errorMessage");
      
      return APIResp(
        status: false,
        statusCode: resp.statusCode ?? 500,
        data: errorMessage,
        fullBody: resp.fullBody,
      );
    }
  } on APIException catch (e) {
    log("❌ APIException in createOrder: ${e.message}");
    return APIResp(
      status: false,
      statusCode: 500,
      data: e.message ?? "Failed to create order",
      fullBody: null,
    );
  } catch (e) {
    log("❌ Exception in createOrder: $e");
    return APIResp(
      status: false,
      statusCode: 500,
      data: "Failed to create order: ${e.toString()}",
      fullBody: null,
    );
  }
}

Future<APIResp> verifyPayment({
  required String razorpayOrderId,
  required String razorpayPaymentId,
  required String razorpaySignature,
  String? orderId,
}) async {
  log("--------------------- enter verifyPayment");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(AppConstants.token);

  try {
    final data = {
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
      // Add orderId only if provided and not empty
      if (orderId != null && orderId.isNotEmpty) "orderId": orderId,
    };
    
    log('Verify Payment data: $data');
    
    final resp = await APIService.post(
      UrlPath.postUrl.verifyOrder,
      data: jsonEncode(data),
      params: {},
      console: true,
      auth: true,
      showNoInternet: false,
      forceLogout: false,
      timeout: const Duration(seconds: 30),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    log("Verify Payment Response: ${resp.statusCode}");
    log("${resp.data}");
    
    // For 200 status code, we need to check the response content
    if (resp.statusCode == 200) {
      // Check if response contains success indicators
      if (resp.fullBody != null) {
        final dynamic fullBody = resp.fullBody;
        
        // Check for success message in the response
        if (fullBody is Map) {
          final message = fullBody['message'];
          if (message != null && message.toString().toLowerCase().contains("success")) {
            // Success case
            return APIResp(
              status: true,
              statusCode: resp.statusCode,
              data: message,
              fullBody: fullBody,
            );
          }
        }
      }
    }
    
    // If we reach here, either it's not a 200 response or success indicators weren't found
    String errorMessage = "Payment verification failed";
    if (resp.fullBody is Map && resp.fullBody['message'] != null) {
      errorMessage = resp.fullBody['message'];
    }
    
    return APIResp(
      status: false,
      statusCode: resp.statusCode ?? 500,
      data: errorMessage,
      fullBody: resp.fullBody,
    );
  } catch (e) {
    log("❌ Exception in verifyPayment: $e");
    return APIResp(
      status: false,
      statusCode: 500,
      data: "Failed to verify payment: ${e.toString()}",
      fullBody: null,
    );
  }

}


Future<APIResp> getOrderHistory() async {
  print("--------------------- enter orderHistory");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(AppConstants.token);
  print("Using token for orderHistory: $token");

  try {
    final resp = await APIService.get(
      UrlPath.getUrl.getOrderHistory,
      params: {},
      console: true,
      auth: true,
      showNoInternet: false,
      forceLogout: false,
      timeout: const Duration(seconds: 30),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      data: null,
    );

    print("Response Status Code: ${resp.statusCode}");
    print("Response Data------------------>");
    print(resp.data);

    if (resp.statusCode == 200) {
      if (resp.fullBody != null) {
        // Get count from the response
        
        // Get orders array from the response
        List<dynamic> ordersJsonList = resp.fullBody['orders'] ?? [];
        List<GetOrderHistory> orderHistory = ordersJsonList
            .map((e) => GetOrderHistory.fromJson(e))
            .toList();

        /// Store orders in provider for UI use
        _orderHistory = orderHistory;
        notifyListeners();

        return APIResp(
          status: true,
          statusCode: resp.statusCode,
          data: orderHistory,
          fullBody: resp.fullBody,
        );
      } else {
        throw APIException(
          type: APIErrorType.internalServerError,
          message: "Empty response received",
        );
      }
    } else {
      throw APIException(
        type: APIErrorType.auth,
        message: resp.data?.toString() ?? "Error fetching orderHistory.",
      );
    }
  } catch (e) {
    print("❌ Exception in orderHistory: $e");
    return APIResp(
      status: false,
      statusCode: 500,
      data: null,
      fullBody: null,
    );
  }
}

// Replacement

Future<APIResp> createReplacement({
  required String orderId,
  required String productId,
  required String reason,
  required String quantity,
  required List<File> images,
}) async {
  log("--------------------- enter createReplacement");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(AppConstants.token);
  log("Using token for createReplacement: $token");

  try {
    FormData formData = FormData();
    
    formData.fields.addAll([
      MapEntry('orderId', orderId),
      MapEntry('productId', productId),
      MapEntry('reason', reason),
      MapEntry('quantity', quantity),
    ]);
    

    for (int i = 0; i < images.length; i++) {
      File image = images[i];
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${i}_${image.path.split('/').last}';
      

      MultipartFile multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      );
      

      formData.files.add(MapEntry('images', multipartFile));
    }
    

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    

    final resp = await APIService.post(
      UrlPath.postUrl.createReplacement,
      data: formData,
      console: true,
      auth: true,
      showNoInternet: true,
      forceLogout: false,
      timeout: const Duration(seconds: 60),
      headers: headers,
    );

    log("Response Status Code: ${resp.statusCode}");
    log("Response Data: ${resp.data}");

    return resp;
  } catch (e) {
    log("❌ Exception in createReplacement: $e");
    return APIResp(
      status: false,
      statusCode: 500,
      data: "Failed to submit replacement request: $e",
      fullBody: null,
    );
  }
}
//get

Future<void> fetchReplacementList({
  required String token,
  required String customerId,
}) async {
  final ApiIntegration api = ApiIntegration();
  await getdata();

  isLoading = true;
  notifyListeners();

  try {
    // ✅ Construct the complete API URL
    final String endpoint = '${UrlPath.getUrl.getReplacement}/$customerId';

    // ✅ Call the API using your APIService
    final APIResp resp = await APIService.get(
      endpoint,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Handle the API response
    if (resp.status && resp.data != null) {
      // The data is a Map, not a List
      final Map<String, dynamic> responseData = resp.data as Map<String, dynamic>;
      
      // Create a single ReplacementResponse from the map
      final ReplacementResponse replacementResponse = ReplacementResponse.fromJson(responseData);
      
      // Store in a list with a single item
      _replacementList = [replacementResponse];
      
      isApiValidationError = false;
      print('✅ Replacement list fetched successfully!');
      log('✅ Replacement list fetched successfully!');
    } else {
      print('⚠️ Failed to fetch replacement list: ${resp.data}');
      isApiValidationError = true;
    }
  } catch (error) {
    print('❌ Error fetching replacement list: $error');
    log('❌ Error fetching replacement list: $error');
    isApiValidationError = true;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}



}


