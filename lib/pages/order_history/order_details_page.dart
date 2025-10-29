// import 'dart:developer';


// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/model/order_history/getOrder_history.dart';
// import 'package:fulupo/pages/order_history/full_orderDetails_page.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OrderDetailsPage extends StatefulWidget {
//   const OrderDetailsPage({super.key});

//   @override
//   State<OrderDetailsPage> createState() => _OrderDetailsPageState();
// }

// class _OrderDetailsPageState extends State<OrderDetailsPage> {
//   String token = '';
//   bool isLoading = false;
//   bool isToday(DateTime date) {
//     DateTime now = DateTime.now();
//     return now.year == date.year &&
//         now.month == date.month &&
//         now.day == date.day;
//   }

//   GetProvider get getprovider => context.read<GetProvider>();

//   Future<void> _getData() async {
//     setState(() {
//       isLoading = true; // Set loading state to true when the function starts
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       token = prefs.getString('token') ?? '';

//       print('Token: $token');
//       await getprovider.fetchOrderHistory(token);
//     } catch (e) {
//       print("Error fetching order history: $e");
//     } finally {
//       setState(() {
//         isLoading =
//             false; // Set loading state to false once the data is fetched or if an error occurs
//       });
//     }

//     // DateTime now = DateTime.now();
//     // DateTime givenDate =
//     //     DateTime(2025, 3, 5); // Change this to test different dates

//     // isToday = now.year == givenDate.year &&
//     //     now.month == givenDate.month &&
//     //     now.day == givenDate.day;

//     // print(isToday ? "Yes" : "No");
//     // log(isToday ? "Yes" : "No");
//   }

//   String _formatTime(String? time) {
//     if (time == null || time.isEmpty) return ''; // Handle null or empty cases

//     try {
//       final parsedTime =
//           DateFormat("HH:mm:ss").parse(time); // Parse 24-hour time
//       return DateFormat("hh:mm a")
//           .format(parsedTime); // Convert to 12-hour format
//     } catch (e) {
//       return time; // Return original if parsing fails
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       appBar: AppBar(
//         title: Text(
//           'Placed Order',
//           style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
//         ),
//         backgroundColor: AppColor.fillColor,
//       ),
//       body: Consumer<GetProvider>(
//         builder: (context, provider, child) {
//           if (isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // Group orders by orderId
//           Map<String, List<GetOrderHistory>> groupedOrders = {};
//           // for (var order in provider.orderHistory) {
//           //   groupedOrders.putIfAbsent(order.orderId!, () => []).add(order);
//           // }

//           return ListView.builder(
//             itemCount: groupedOrders.length,
//             itemBuilder: (context, index) {
//               String orderId = groupedOrders.keys.elementAt(index);
//               List<GetOrderHistory> orders = groupedOrders[orderId]!;

//               // Get first product details from this order group
//               GetOrderHistory firstProduct = orders.first;

//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           FullOrderDetailsPage(orderId: orderId),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black12, blurRadius: 4),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // ListTile(
//                         //   leading: const Icon(
//                         //     Icons.check_circle,
//                         //     color: AppColor.fillColor,
//                         //   ),
//                         //   title: isToday(
//                         //           firstProduct.bookingDate ?? DateTime.now())
//                         //       ? Text(
//                         //           "Your Daily Order!",
//                         //           style: Styles.textStyleMedium(context,
//                         //               color: AppColor.fillColor),
//                         //         )
//                         //       : Text(
//                         //           "Your Pre Order!",
//                         //           style: Styles.textStyleMedium(context,
//                         //               color: AppColor.fillColor),
//                         //         ),
//                         // ),
//                         Divider(color: Colors.grey.shade300),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 8),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment
//                                 .spaceBetween, // ✅ Prevents overflow
//                             children: [
//                               // Product Image
//                               // ClipRRect(
//                               //   borderRadius: BorderRadius.circular(8),
//                               //   child: Image.network(
//                               //     firstProduct.image ?? '',
//                               //     height: 60,
//                               //     width: 60,
//                               //     fit: BoxFit.cover,
//                               //     errorBuilder: (context, error, stackTrace) =>
//                               //         const Icon(Icons.image_not_supported,
//                               //             size: 50),
//                               //   ),
//                               // ),
//                               const SizedBox(width: 12),

//                               // Order details
//                               // Expanded(
//                               //   // ✅ Prevents overflow
//                               //   child: Column(
//                               //     crossAxisAlignment: CrossAxisAlignment.start,
//                               //     children: [
//                               //       Text(
//                               //         "Order Placed at ${DateFormat('dd MMM yy').format(firstProduct.bookingDate!.toLocal())}",
//                               //         style: Styles.textStyleMedium(context),
//                               //         overflow: TextOverflow.ellipsis,
//                               //       ),
//                               //       const SizedBox(height: 4),
//                               //       Text(
//                               //         " At ${_formatTime(firstProduct.startTime)} - ${_formatTime(firstProduct.endTime)}",
//                               //         style: Styles.textStyleSmall(context,
//                               //             color: AppColor.hintTextColor),
//                               //         overflow: TextOverflow.ellipsis,
//                               //       ),
//                               //       Row(
//                               //         children: [
//                               //           Text(
//                               //             "${firstProduct.productName} - ${firstProduct.productQuantity}",
//                               //             style: Styles.textStyleSmall(context,
//                               //                 color: AppColor.hintTextColor),
//                               //             overflow: TextOverflow
//                               //                 .ellipsis, // ✅ Prevents wrapping issues
//                               //           ),
//                               //           Spacer(),
//                               //           Text(
//                               //             "₹ ${firstProduct.totalPay?.toStringAsFixed(2) ?? '0.00'}",
//                               //             style: Styles.textStyleMedium(
//                               //               context,
//                               //               color: AppColor.fillColor,
//                               //             ),
//                               //           ),
//                               //         ],
//                               //       ),
//                               //     ],
//                               //   ),
//                               // ),

//                               // Price
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
