
// import 'dart:developer';
// import 'package:dio/dio.dart';


// class ApiIntegration {
//   Future<List<Model>> fetchData<Model>({
//     required String baseUrl,
//     required String endpoint,
//     required Map<String, String> headers,
//     required Model Function(Map<String, dynamic>) fromJson,
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       final String fullUrl = '$baseUrl$endpoint';
//       print('Request URL: $fullUrl');
//       log('Request URL: $fullUrl');

//       Dio dio = Dio(
//         BaseOptions(
//           baseUrl: baseUrl,
//           headers: headers,
//           connectTimeout: Duration(seconds: 10),
//           receiveTimeout: Duration(seconds: 10),
//           contentType: Headers.jsonContentType,
//           responseType: ResponseType.json,
//         ),
//       );

//       final response = await dio.post(
//         endpoint,
//         data: body, // Dio automatically encodes it to JSON
//       );

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.data}');
//       log('Response Status: ${response.statusCode}');
//       log('Response Body: ${response.data}');

//       if (response.statusCode == 200) {
//         final jsonResponse = response.data;

//         if (jsonResponse.containsKey('data')) {
//           if (jsonResponse['data'] is List) {
//             final List<dynamic> data = jsonResponse['data'];
//             return data
//                 .map((item) => fromJson(item as Map<String, dynamic>))
//                 .toList();
//           } else {
//             throw Exception('Expected "data" to be a list, but it is not.');
//           }
//         } else if (jsonResponse.containsKey('message')) {
//           print('Message: ${jsonResponse['message']}');
//           return []; // Handle empty or message-only response
//         } else {
//           print('Unexpected response structure: $jsonResponse');
//           throw Exception('Unexpected response structure.');
//         }
//       } else {
//         throw Exception('Failed to fetch data: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error in API integration: $error');
//       throw error;
//     }
//   }

//   // for only for order history
//   Future<List<Model>> fetchsData<Model>({
//     required String baseUrl,
//     required String endpoint,
//     required Map<String, String> headers,
//     required Model Function(Map<String, dynamic>) fromJson,
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       final String fullUrl = '$baseUrl$endpoint';
//       print('Request URL: $fullUrl');
//       log('Request URL: $fullUrl');

//       Dio dio = Dio(
//         BaseOptions(
//           baseUrl: baseUrl,
//           headers: headers,
//           connectTimeout: Duration(seconds: 10),
//           receiveTimeout: Duration(seconds: 10),
//           contentType: Headers.jsonContentType,
//           responseType: ResponseType.json,
//         ),
//       );

//       final response = await dio.post(
//         endpoint,
//         data: body, // Dio automatically encodes Map to JSON
//       );

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.data}');
//       log('Response Status: ${response.statusCode}');
//       log('Response Body: ${response.data}');

//       if (response.statusCode == 200) {
//         final jsonResponse = response.data;

//         if (jsonResponse.containsKey('data') &&
//             jsonResponse['data'] is Map<String, dynamic>) {
//           // ✅ Extract the correct list inside 'data'
//           if (jsonResponse['data'].containsKey('order_history') &&
//               jsonResponse['data']['order_history'] is List) {
//             final List<dynamic> data = jsonResponse['data']['order_history'];
//             return data
//                 .map((item) => fromJson(item as Map<String, dynamic>))
//                 .toList();
//           } else {
//             throw Exception(
//               'Expected "order_history" to be a list, but it is not.',
//             );
//           }
//         } else if (jsonResponse.containsKey('message')) {
//           print('Message: ${jsonResponse['message']}');
//           return []; // Handle gracefully
//         } else {
//           print('Unexpected response structure: $jsonResponse');
//           throw Exception('Unexpected response structure.');
//         }
//       } else {
//         throw Exception('Failed to fetch data: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error in API integration: $error');
//       throw error;
//     }
//   }

//   // //Get Add to cart
//   //  Future<List<Model>> fetchDatas<Model>({
//   //   required String baseUrl,
//   //   required String endpoint,
//   //   required Map<String, String> headers,
//   //   required Model Function(Map<String, dynamic>) fromJson,
//   // }) async {
//   //   try {
//   //     final String fullUrl = '$baseUrl$endpoint';
//   //     print('Request URL: $fullUrl');

//   //     final response = await http.post(
//   //       Uri.parse(fullUrl),
//   //       headers: headers,
//   //     );

//   //     print('Response Status: ${response.statusCode}');
//   //     print('Response Body: ${response.body}');

//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//   //       if (jsonResponse.containsKey('cart_items') &&
//   //           jsonResponse['cart_items'] is List) {
//   //         final List<dynamic> data = jsonResponse['cart_items'];
//   //         return data
//   //             .map((item) => fromJson(item as Map<String, dynamic>))
//   //             .toList();
//   //       } else {
//   //         throw Exception('Unexpected response structure: Missing "cart_items".');
//   //       }
//   //     } else {
//   //       throw Exception('Failed to fetch data: ${response.statusCode}');
//   //     }
//   //   } catch (error) {
//   //     print('Error in API integration: $error');
//   //     throw error;
//   //   }
//   // }
// }



import 'dart:developer';
import 'package:dio/dio.dart';

class ApiIntegration {
  final Dio dio;

  ApiIntegration({String? baseUrl, Map<String, String>? headers})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
            headers: headers ?? {},
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        );

  Future<List<Model>> fetchData<Model>({
    required String baseUrl, 
    required String endpoint,
    required Model Function(Map<String, dynamic>) fromJson,
    String method = "POST", // Can be GET, POST, PUT, DELETE
    Map<String, dynamic>? body,
    String? listKey, required Map<String, String> headers, // <-- NEW: For nested lists like "order_history"
  }) async {
    try {
      log("🔹 Request: $method $endpoint");
      log("🔹 Body: ${body ?? {}}");

      late Response response;

      // Dynamically choose HTTP method
      switch (method.toUpperCase()) {
        case "GET":
          response = await dio.get(endpoint, queryParameters: body);
          break;
        case "PUT":
          response = await dio.put(endpoint, data: body);
          break;
        case "DELETE":
          response = await dio.delete(endpoint, data: body);
          break;
        default:
          response = await dio.post(endpoint, data: body);
      }

      log("✅ Status: ${response.statusCode}");
      log("✅ Response: ${response.data}");

      // Check if response is successful
      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        // ✅ Handle nested list responses dynamically
        if (listKey != null &&
            jsonResponse.containsKey('data') &&
            jsonResponse['data'][listKey] is List) {
          final List<dynamic> data = jsonResponse['data'][listKey];
          return data.map((item) => fromJson(item)).toList();
        }

        // ✅ Default case when `data` is a direct list
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => fromJson(item)).toList();
        }

        // ✅ If only message is returned
        if (jsonResponse.containsKey('message')) {
          log("⚠️ Message: ${jsonResponse['message']}");
          return [];
        }

        throw Exception("Unexpected response structure: $jsonResponse");
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      log("❌ Dio Error: ${e.message}");
      if (e.response != null) {
        throw Exception("API Error: ${e.response?.data}");
      }
      throw Exception("Network Error: ${e.message}");
    } catch (e) {
      log("❌ Unknown Error: $e");
      throw Exception("Unexpected Error: $e");
    }
  }
}
