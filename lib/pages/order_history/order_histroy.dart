// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fulupo/model/order_history/getOrder_history.dart';
// import 'package:intl/intl.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/widget/dilogue/dilogue.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class OrderHistory extends StatefulWidget {
//   const OrderHistory({super.key});

//   @override
//   State<OrderHistory> createState() => _OrderHistoryState();
// }

// class _OrderHistoryState extends State<OrderHistory> {
//   bool isLoading = true;
//   List<GetOrderHistory>? orders;
//   GetProvider get getprovider => context.read<GetProvider>();

//   @override
//   void initState() {
//     super.initState();
//     _loadOrderHistory();
//   }

//   Future<void> _loadOrderHistory() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final result = await getprovider.getOrderHistory();

//       if (result.status) {
//         if (mounted) {
//           setState(() {
//             orders = result.data as List<GetOrderHistory>?;
//             isLoading = false;
//           });
//         }
//       } else {
//         log('Error getting order history: ${result.data}');
//         if (mounted) {
//           AppDialogue.toast("Failed to load order history");
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       log('Exception getting order history: $e');
//       if (mounted) {
//         AppDialogue.toast("An error occurred while loading orders");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       appBar: AppBar(
//         title: const Text("My Orders", textScaler: TextScaler.linear(1)),
//         backgroundColor: AppColor.fillColor,
//         foregroundColor: Colors.white,
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: AppColor.yellowColor),
//             )
//           : orders == null || orders!.isEmpty
//           ? _buildEmptyState()
//           : _buildOrdersList(),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_bag_outlined,
//             size: 80,
//             color: AppColor.yellowColor,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "No Orders Yet!",
//             style: Styles.textStyleMedium(
//               context,
//               color: AppColor.whiteColor,
//               // fontSize: 20,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Your order history will appear here",
//             style: Styles.textStyleSmall(context, color: Colors.grey[400]!),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Navigate to products or home page
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColor.yellowColor,
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               "Start Shopping",
//               textScaler: TextScaler.linear(1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrdersList() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColor.fillColor.withOpacity(0.05),
//             Colors.grey.withOpacity(0.1),
//           ],
//         ),
//       ),
//       child: RefreshIndicator(
//         onRefresh: _loadOrderHistory,
//         color: AppColor.yellowColor,
//         child: ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: orders!.length,
//           itemBuilder: (context, index) {
//             final order = orders![index];
//             // Add a colored divider between cards if not the last one
//             return Column(
//               children: [
//                 _buildOrderCard(order),
//                 if (index < orders!.length - 1)
//                   Container(
//                     height: 4,
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColor.fillColor.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(GetOrderHistory order) {
//     // Format date
//     final orderDate = order.createdAt != null
//         ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!)
//         : 'Unknown date';

//     // Get status color
//     Color getStatusColor() {
//       switch (order.orderStatus?.toLowerCase()) {
//         case 'placed':
//           return Colors.white;
//         case 'confirmed':
//           return Colors.green;
//         case 'shipped':
//           return Colors.orange;
//         case 'delivered':
//           return Colors.green.shade700;
//         case 'cancelled':
//           return Colors.red;
//         default:
//           return Colors.grey;
//       }
//     }

//     // Payment status color
//     Color getPaymentStatusColor() {
//       switch (order.paymentStatus?.toLowerCase()) {
//         case 'paid':
//           return Colors.green;
//         case 'pending':
//           return Colors.orange;
//         case 'failed':
//           return Colors.red;
//         default:
//           return Colors.grey;
//       }
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.white, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Order Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: BoxDecoration(
//               color: AppColor.fillColor,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Order #${order.id?.substring(order.id!.length - 8) ?? "Unknown"}",
//                       style: Styles.textStyleMedium(
//                         context,
//                         color: AppColor.yellowColor,
//                         // fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       orderDate,
//                       style: Styles.textStyleSmall(
//                         context,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: getStatusColor().withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: getStatusColor()),
//                   ),
//                   child: Text(
//                     order.orderStatus ?? 'Unknown',
//                     style: TextStyle(
//                       color: getStatusColor(),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                     textScaler: TextScaler.linear(1),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Order Items
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Items",
//                   style: Styles.textStyleMedium(
//                     context,
//                     color: Colors.black87,
//                     //  fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 05),

//                 // Items List
//                 ...List.generate(order.items?.length ?? 0, (index) {
//                   final item = order.items![index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             "${item.quantity ?? 0}x",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: AppColor.fillColor,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.name ?? "Unknown Product",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                               Text(
//                                 "₹${(item.price ?? 0).toStringAsFixed(2)} per unit",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           "₹${(item.total ?? 0).toStringAsFixed(2)}",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green[700],
//                           ),
//                           textScaler: TextScaler.linear(1),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),

//                 const Divider(thickness: 1),

//                 // Payment Details
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Payment Method",
//                       style: TextStyle(color: Colors.grey[700]),
//                       textScaler: TextScaler.linear(1),
//                     ),
//                     Text(
//                       order.paymentMode ?? "Unknown",
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                       textScaler: TextScaler.linear(1),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Payment Status",
//                       style: TextStyle(color: Colors.grey[700]),
//                       textScaler: TextScaler.linear(1),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: getPaymentStatusColor().withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         order.paymentStatus ?? "Unknown",
//                         style: TextStyle(
//                           color: getPaymentStatusColor(),
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                         textScaler: TextScaler.linear(1),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total Amount",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         fontSize: 15,
//                       ),
//                       textScaler: TextScaler.linear(1),
//                     ),
//                     Text(
//                       "₹${(order.totalAmount ?? 0).toStringAsFixed(2)}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green[700],
//                         fontSize: 16,
//                       ),
//                       textScaler: TextScaler.linear(1),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Address
//           // if (order.addressId != null)
//           //   Container(
//           //     padding: const EdgeInsets.all(10),
//           //     decoration: const BoxDecoration(
//           //       color: Colors.white,
//           //       border: Border(
//           //         top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
//           //       ),
//           //     ),
//           //     child: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: [
//           //         Text(
//           //           "Delivery Address",
//           //           style: Styles.textStyleMedium(
//           //             context,
//           //             color: Colors.black87,
//           //             //  fontSize: 15,
//           //           ),
//           //         ),
//           //         const SizedBox(height: 5),
//           //         Row(
//           //           children: [
//           //             Icon(
//           //               Icons.person_outline,
//           //               size: 18,
//           //               color: Colors.grey[600],
//           //             ),
//           //             const SizedBox(width: 8),
//           //             Text(
//           //               order.addressId?.name ?? "Unknown",
//           //               style: const TextStyle(fontSize: 14),
//           //               textScaler: TextScaler.linear(1),
//           //             ),
//           //           ],
//           //         ),
//           //         const SizedBox(height: 4),
//           //         Row(
//           //           children: [
//           //             Icon(
//           //               Icons.phone_outlined,
//           //               size: 18,
//           //               color: Colors.grey[600],
//           //             ),
//           //             const SizedBox(width: 8),
//           //             Text(
//           //               order.addressId?.mobile ?? "Unknown",
//           //               style: const TextStyle(fontSize: 14),
//           //               textScaler: TextScaler.linear(1),
//           //             ),
//           //           ],
//           //         ),
//           //         const SizedBox(height: 4),
//           //         Row(
//           //           crossAxisAlignment: CrossAxisAlignment.start,
//           //           children: [
//           //             Icon(
//           //               Icons.location_on_outlined,
//           //               size: 18,
//           //               color: Colors.grey[600],
//           //             ),
//           //             const SizedBox(width: 8),
//           //             Expanded(
//           //               child: Text(
//           //                 order.addressId?.addressLine ?? "Unknown address",
//           //                 style: const TextStyle(fontSize: 14),
//           //                 textScaler: TextScaler.linear(1),
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ],
//           //     ),
//           //   ),

//           // Action buttons
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       // Show order details
//                       _showOrderDetails(order);
//                     },
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColor.fillColor,
//                       side: BorderSide(color: AppColor.fillColor),
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 4,
//                         horizontal: 8,
//                       ),
//                       minimumSize: const Size(0, 32),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       "View Details",
//                       textScaler: TextScaler.linear(1),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Only show reorder button for delivered orders
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: order.orderStatus?.toLowerCase() == 'cancelled'
//                         ? null
//                         : () {
//                             // Handle support/help
//                             AppDialogue.toast("Support request submitted");
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.yellowColor,
//                       foregroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 4,
//                         horizontal: 8,
//                       ),
//                       minimumSize: const Size(0, 32),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       disabledBackgroundColor: Colors.grey.withOpacity(0.3),
//                     ),
//                     child: const Text(
//                       "Get Support",
//                       textScaler: TextScaler.linear(1),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showOrderDetails(GetOrderHistory order) {
//     // Format date
//     final orderDate = order.createdAt != null
//         ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!)
//         : 'Unknown date';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       builder: (context) {
//         return Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.85,
//           ),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Order Details",
//                     style: Styles.textStyleMedium(
//                       context,
//                       color: AppColor.fillColor,
//                       //  fontSize: 18,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ),
//               const Divider(),

//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Order Info
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             _detailRow(
//                               "Order ID",
//                               "#${order.id?.substring(order.id!.length - 8) ?? "Unknown"}",
//                             ),
//                             _detailRow("Date", orderDate),
//                             _detailRow(
//                               "Status",
//                               order.orderStatus ?? "Unknown",
//                             ),
//                             _detailRow(
//                               "Payment Method",
//                               order.paymentMode ?? "Unknown",
//                             ),
//                             _detailRow(
//                               "Payment Status",
//                               order.paymentStatus ?? "Unknown",
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Order Items
//                       Text(
//                         "Items",
//                         style: Styles.textStyleMedium(
//                           context,
//                           color: AppColor.fillColor,
//                           //  fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: order.items?.length ?? 0,
//                         itemBuilder: (context, index) {
//                           final item = order.items![index];
//                           return Card(
//                             elevation: 1,
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade200,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       "${item.quantity ?? 0}x",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: AppColor.fillColor,
//                                       ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           item.name ?? "Unknown Product",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 14,
//                                           ),
//                                           textScaler: TextScaler.linear(1),
//                                         ),
//                                         Text(
//                                           "₹${(item.price ?? 0).toStringAsFixed(2)} x ${item.quantity ?? 0}",
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey[600],
//                                           ),
//                                           textScaler: TextScaler.linear(1),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Text(
//                                     "₹${(item.total ?? 0).toStringAsFixed(2)}",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green[700],
//                                     ),
//                                     textScaler: TextScaler.linear(1),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),

//                       // Payment Details
//                       Text(
//                         "Payment Details",
//                         style: Styles.textStyleMedium(
//                           context,
//                           color: AppColor.fillColor,
//                           //  fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             _detailRow(
//                               "Items Total",
//                               "₹${order.totalAmount != null ? (order.totalAmount! - 40 - (order.totalAmount! * 0.05)).toStringAsFixed(2) : "0.00"}",
//                             ),
//                             _detailRow("Delivery Charge", "₹40.00"),
//                             _detailRow(
//                               "Tax",
//                               "₹${order.totalAmount != null ? (order.totalAmount! * 0.05).toStringAsFixed(2) : "0.00"}",
//                             ),
//                             const Divider(),
//                             _detailRow(
//                               "Total Amount",
//                               "₹${(order.totalAmount ?? 0).toStringAsFixed(2)}",
//                               titleStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               valueStyle: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[700],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Delivery Address
//                       Text(
//                         "Delivery Address",
//                         style: Styles.textStyleMedium(
//                           context,
//                           color: AppColor.fillColor,
//                           // fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Delivery Address",
//                               style: Styles.textStyleMedium(
//                                 context,
//                                 color: Colors.black87,
//                                 //  fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.person_outline,
//                                   size: 18,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   order.addressId?.name ?? "Unknown",
//                                   style: const TextStyle(fontSize: 14),
//                                   textScaler: TextScaler.linear(1),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.phone_outlined,
//                                   size: 18,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   order.addressId?.mobile ?? "Unknown",
//                                   style: const TextStyle(fontSize: 14),
//                                   textScaler: TextScaler.linear(1),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(
//                                   Icons.location_on_outlined,
//                                   size: 18,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     order.addressId?.addressLine ??
//                                         "Unknown address",
//                                     style: const TextStyle(fontSize: 14),
//                                     textScaler: TextScaler.linear(1),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Additional info for online payment
//                       if (order.paymentMode == "Razorpay") ...[
//                         const SizedBox(height: 20),
//                         Text(
//                           "Payment Information",
//                           style: Styles.textStyleMedium(
//                             context,
//                             color: AppColor.fillColor,
//                             // fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             children: [
//                               _detailRow(
//                                 "Razorpay Order ID",
//                                 order.razorpayOrderId ?? "N/A",
//                               ),
//                               if (order.razorpayPaymentId != null)
//                                 _detailRow(
//                                   "Payment ID",
//                                   order.razorpayPaymentId!,
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       //  const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),

//               // Bottom action button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Contact support
//                     Navigator.pop(context);
//                     AppDialogue.toast("Support request submitted");
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColor.fillColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Contact Support",
//                     textScaler: TextScaler.linear(1),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _detailRow(
//     String title,
//     String value, {
//     TextStyle? titleStyle,
//     TextStyle? valueStyle,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style:
//                 titleStyle ?? TextStyle(fontSize: 14, color: Colors.grey[700]),
//             textScaler: TextScaler.linear(1),
//           ),
//           Text(
//             value,
//             style:
//                 valueStyle ??
//                 const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
//             textScaler: TextScaler.linear(1),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/order_history/getOrder_history.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool isLoading = true;
  List<GetOrderHistory>? orders;
  GetProvider get getprovider => context.read<GetProvider>();
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  @override
  void dispose() {
    // Dispose all scroll controllers
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await getprovider.getOrderHistory();

      if (result.status) {
        if (mounted) {
          setState(() {
            orders = result.data as List<GetOrderHistory>?;
            isLoading = false;
          });
        }
      } else {
        log('Error getting order history: ${result.data}');
        if (mounted) {
          AppDialogue.toast("Failed to load order history");
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      log('Exception getting order history: $e');
      if (mounted) {
        AppDialogue.toast("An error occurred while loading orders");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: const Text("My Orders", textScaler: TextScaler.linear(1)),
        backgroundColor: AppColor.fillColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.yellowColor),
              )
            : orders == null || orders!.isEmpty
            ? _buildEmptyState()
            : _buildOrdersList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColor.yellowColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No Orders Yet!",
            style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Your order history will appear here",
            style: Styles.textStyleSmall(context, color: Colors.grey[400]!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.yellowColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Start Shopping",
              textScaler: TextScaler.linear(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.fillColor.withOpacity(0.05),
            Colors.grey.withOpacity(0.1),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadOrderHistory,
        color: AppColor.yellowColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders!.length,
          itemBuilder: (context, index) {
            final order = orders![index];
            return Column(
              children: [
                _buildOrderCard(order),
                if (index < orders!.length - 1)
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.fillColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(GetOrderHistory order) {
    final orderDate = order.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!)
        : 'Unknown date';

    Color getStatusColor() {
      final status = order.orderStatus?.toLowerCase() ?? '';
      switch (status) {
        case 'placed':
          return Colors.white;
        case 'confirmed':
          return Colors.green;
        case 'shipped':
          return Colors.orange;
        case 'delivered':
          return Colors.amber;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    Color getPaymentStatusColor() {
      switch (order.paymentStatus?.toLowerCase()) {
        case 'paid':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'failed':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.fillColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.id?.substring(order.id!.length - 8) ?? "Unknown"}",
                      style: Styles.textStyleMedium(
                        context,
                        color: AppColor.yellowColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderDate,
                      style: Styles.textStyleSmall(
                        context,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: getStatusColor()),
                  ),
                  child: Text(
                    order.orderStatus ?? 'Unknown',
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textScaler: const TextScaler.linear(1),
                  ),
                ),
              ],
            ),
          ),

          // Order Items
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items",
                      style: Styles.textStyleMedium(
                        context,
                        color: Colors.black87,
                      ),
                    ),
                    if ((order.items?.length ?? 0) > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.fillColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_vertical,
                              size: 12,
                              color: AppColor.fillColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Scroll",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.fillColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),

                // Scrollable Items List
                _buildScrollableItemsList(order),

                const Divider(thickness: 1),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Status",
                      style: TextStyle(color: Colors.grey[700]),
                      textScaler: const TextScaler.linear(1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getPaymentStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.paymentStatus ?? "Unknown",
                        style: TextStyle(
                          color: getPaymentStatusColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        textScaler: const TextScaler.linear(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                      textScaler: const TextScaler.linear(1),
                    ),
                    Text(
                      "₹${(order.totalAmount ?? 0).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                      textScaler: const TextScaler.linear(1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showOrderDetails(order);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.fillColor,
                      side: BorderSide(color: AppColor.fillColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "View Details",
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: order.orderStatus?.toLowerCase() == 'cancelled'
                        ? null
                        : () {
                            AppDialogue.toast("Support request submitted");
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: const Text(
                      "Get Support",
                      textScaler: const TextScaler.linear(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableItemsList(GetOrderHistory order) {
    final itemCount = order.items?.length ?? 0;
    final bool needsScroll = itemCount > 3;

    // Create a unique key for this order's scroll controller
    final scrollKey = 'order_${order.id}';
    if (!_scrollControllers.containsKey(scrollKey)) {
      _scrollControllers[scrollKey] = ScrollController();
    }

    return Container(
      height: needsScroll ? 140 : null,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: needsScroll
            ? Scrollbar(
                controller: _scrollControllers[scrollKey],
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(10),
                child: ListView.builder(
                  controller: _scrollControllers[scrollKey],
                  padding: const EdgeInsets.all(8.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final item = order.items![index];
                    return _buildItemRow(item, index == itemCount - 1);
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: List.generate(itemCount, (index) {
                    final item = order.items![index];
                    return _buildItemRow(item, index == itemCount - 1);
                  }),
                ),
              ),
      ),
    );
  }

  Widget _buildItemRow(dynamic item, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.fillColor.withOpacity(0.8),
                  AppColor.fillColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColor.fillColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              "${item.quantity ?? 0}x",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? "Unknown Product",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: const TextScaler.linear(1),
                ),
                Text(
                  "₹${(item.price ?? 0).toStringAsFixed(2)} per unit",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textScaler: const TextScaler.linear(1),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "₹${(item.total ?? 0).toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 14,
              ),
              textScaler: const TextScaler.linear(1),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(GetOrderHistory order) {
    final orderDate = order.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!)
        : 'Unknown date';

    final isDelivered = order.orderStatus?.toLowerCase() == 'delivered';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Details",
                    style: Styles.textStyleMedium(
                      context,
                      color: AppColor.fillColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _detailRow(
                              "Order ID",
                              "#${order.id?.substring(order.id!.length - 8) ?? "Unknown"}",
                            ),
                            _detailRow("Date", orderDate),
                            _detailRow(
                              "Status",
                              order.orderStatus ?? "Unknown",
                            ),
                            _detailRow(
                              "Payment Method",
                              order.paymentMode ?? "Unknown",
                            ),
                            _detailRow(
                              "Payment Status",
                              order.paymentStatus ?? "Unknown",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Items
                      Text(
                        "Items",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Scrollable Items Container for Details View
                      _buildDetailsScrollableItems(order),
                      const SizedBox(height: 20),

                      // Payment Details
                      Text(
                        "Payment Details",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _detailRow(
                              "Items Total",
                              "₹${order.totalAmount != null ? (order.totalAmount! - 40 - (order.totalAmount! * 0.05)).toStringAsFixed(2) : "0.00"}",
                            ),
                            _detailRow("Delivery Charge", "₹40.00"),
                            _detailRow(
                              "Tax",
                              "₹${order.totalAmount != null ? (order.totalAmount! * 0.05).toStringAsFixed(2) : "0.00"}",
                            ),
                            const Divider(),
                            _detailRow(
                              "Total Amount",
                              "₹${(order.totalAmount ?? 0).toStringAsFixed(2)}",
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Delivery Address
                      Text(
                        "Delivery Address",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.addressId?.name ?? "Unknown",
                                  style: const TextStyle(fontSize: 14),
                                  textScaler: const TextScaler.linear(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.addressId?.mobile ?? "Unknown",
                                  style: const TextStyle(fontSize: 14),
                                  textScaler: const TextScaler.linear(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.addressId?.addressLine ??
                                        "Unknown address",
                                    style: const TextStyle(fontSize: 14),
                                    textScaler: const TextScaler.linear(1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Additional info for online payment
                      if (order.paymentMode == "Razorpay") ...[
                        const SizedBox(height: 20),
                        Text(
                          "Payment Information",
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.fillColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _detailRow(
                                "Razorpay Order ID",
                                order.razorpayOrderId ?? "N/A",
                              ),
                              if (order.razorpayPaymentId != null)
                                _detailRow(
                                  "Payment ID",
                                  order.razorpayPaymentId!,
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        AppDialogue.toast("Support request submitted");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.fillColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Contact Support",
                        textScaler: TextScaler.linear(1),
                      ),
                    ),
                  ),

                  if (isDelivered) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.assignment_return_outlined),
                        label: const Text(
                          "Return Order",
                          textScaler: TextScaler.linear(1),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showReturnDialog(order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsScrollableItems(GetOrderHistory order) {
    final itemCount = order.items?.length ?? 0;
    final bool needsScroll = itemCount > 3;

    // Create a unique key for the details scroll controller
    final scrollKey = 'details_${order.id}';
    if (!_scrollControllers.containsKey(scrollKey)) {
      _scrollControllers[scrollKey] = ScrollController();
    }

    return Container(
      height: needsScroll ? 240 : null,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: needsScroll
            ? Scrollbar(
                controller: _scrollControllers[scrollKey],
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(10),
                child: ListView.builder(
                  controller: _scrollControllers[scrollKey],
                  physics: const BouncingScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final item = order.items![index];
                    return _buildDetailItemCard(item);
                  },
                ),
              )
            : Column(
                children: List.generate(itemCount, (index) {
                  final item = order.items![index];
                  return _buildDetailItemCard(item);
                }),
              ),
      ),
    );
  }

  Widget _buildDetailItemCard(dynamic item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.fillColor.withOpacity(0.8),
                    AppColor.fillColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "${item.quantity ?? 0}x",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textScaler: const TextScaler.linear(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? "Unknown Product",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textScaler: const TextScaler.linear(1),
                  ),
                  Text(
                    "₹${(item.price ?? 0).toStringAsFixed(2)} x ${item.quantity ?? 0}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    textScaler: const TextScaler.linear(1),
                  ),
                ],
              ),
            ),
            Text(
              "₹${(item.total ?? 0).toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textScaler: const TextScaler.linear(1),
            ),
          ],
        ),
      ),
    );
  }

  // void _showReturnDialog(GetOrderHistory order) {
  //   final formKey = GlobalKey<FormState>();

  //   String returnReason = '';
  //   String selectedProductId = '';
  //   int selectedQuantity = 1;
  //   List<File> selectedImages = [];

  //   // Simplified image picker methods without permission_handler
  //  Future<void> _pickImageFromGallery(StateSetter setDialogState) async {
  //   var status = await Permission.photos.request();
  //   if (!status.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Gallery permission denied")),
  //     );
  //     return;
  //   }

  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null && result.files.single.path != null) {
  //     setDialogState(() {
  //       selectedImages.add(File(result.files.single.path!));
  //     });
  //   }
  // }

  // Future<void> _takePicture(StateSetter setDialogState) async {
  //   var status = await Permission.camera.request();
  //   if (!status.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Camera permission denied")),
  //     );
  //     return;
  //   }

  //   final picker = ImagePicker();
  //   final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  //   if (photo != null) {
  //     setDialogState(() {
  //       selectedImages.add(File(photo.path));
  //     });
  //   }
  // }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => StatefulBuilder(
  //       builder: (context, setDialogState) => AlertDialog(
  //         title: const Text(
  //           "Return Order",
  //           style: TextStyle(
  //             color: AppColor.fillColor,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Form(
  //           key: formKey,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   "Select product to return:",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),

  //                 // Product Selection Dropdown
  //                 DropdownButtonFormField<String>(
  //                   decoration: InputDecoration(
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.grey.shade50,
  //                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                   ),
  //                   hint: const Text("Select Product"),
  //                   value: selectedProductId.isEmpty ? null : selectedProductId,
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please select a product';
  //                     }
  //                     return null;
  //                   },
  //                   items: order.items?.map((item) {
  //                     return DropdownMenuItem<String>(
  //                       value: item.productId ?? '',
  //                       child: Text(
  //                         item.name ?? "Unknown Product",
  //                         style: const TextStyle(fontSize: 14),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     );
  //                   }).toList() ?? [],
  //                   onChanged: (value) {
  //                     setDialogState(() {
  //                       selectedProductId = value ?? '';

  //                       // Reset quantity when product changes
  //                       selectedQuantity = 1;

  //                       // Find the selected item to get maximum quantity
  //                       if (value != null && value.isNotEmpty) {
  //                         final selectedItem = order.items?.firstWhere(
  //                           (item) => item.productId == value,
  //                          // orElse: () => null,
  //                         );
  //                         if (selectedItem != null) {
  //                           // Optionally limit max quantity to the ordered quantity
  //                           // maxQuantity = selectedItem.quantity ?? 1;
  //                         }
  //                       }
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // Quantity Selection
  //                 const Text(
  //                   "Quantity:",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     IconButton(
  //                       onPressed: () {
  //                         if (selectedQuantity > 1) {
  //                           setDialogState(() {
  //                             selectedQuantity--;
  //                           });
  //                         }
  //                       },
  //                       icon: const Icon(Icons.remove_circle_outline),
  //                       color: AppColor.fillColor,
  //                     ),
  //                     Text(
  //                       '$selectedQuantity',
  //                       style: const TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () {
  //                         setDialogState(() {
  //                           selectedQuantity++;
  //                         });
  //                       },
  //                       icon: const Icon(Icons.add_circle_outline),
  //                       color: AppColor.fillColor,
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // Reason for Return
  //                 const Text(
  //                   "Reason for return:",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 TextFormField(
  //                   maxLines: 3,
  //                   onChanged: (value) => returnReason = value,
  //                   validator: (value) {
  //                     if (value == null || value.trim().isEmpty) {
  //                       return 'Please provide a reason';
  //                     }
  //                     return null;
  //                   },
  //                   decoration: InputDecoration(
  //                     hintText: "Please state your reason for return...",
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(color: Colors.grey.shade300),
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.grey.shade50,
  //                     contentPadding: const EdgeInsets.all(12),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // Image Upload Section
  //                 const Text(
  //                   "Upload Images (Required):",
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),

  //                 // Display selected images
  //                 if (selectedImages.isNotEmpty)
  //                   Container(
  //                     height: 100,
  //                     margin: const EdgeInsets.only(bottom: 8),
  //                     child: ListView.builder(
  //                       scrollDirection: Axis.horizontal,
  //                       itemCount: selectedImages.length,
  //                       itemBuilder: (context, index) {
  //                         return Stack(
  //                           children: [
  //                             Container(
  //                               margin: const EdgeInsets.only(right: 8),
  //                               width: 100,
  //                               height: 100,
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(color: Colors.grey.shade300),
  //                                 image: DecorationImage(
  //                                   image: FileImage(selectedImages[index]),
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               ),
  //                             ),
  //                             Positioned(
  //                               top: -4,
  //                               right: 4,
  //                               child: GestureDetector(
  //                                 onTap: () {
  //                                   setDialogState(() {
  //                                     selectedImages.removeAt(index);
  //                                   });
  //                                 },
  //                                 child: Container(
  //                                   padding: const EdgeInsets.all(4),
  //                                   decoration: const BoxDecoration(
  //                                     color: Colors.red,
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: const Icon(
  //                                     Icons.close,
  //                                     color: Colors.white,
  //                                     size: 16,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //                   ),

  //                 // Add Image Buttons
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: OutlinedButton.icon(
  //                         onPressed: () => _pickImageFromGallery(setDialogState),
  //                         icon: const Icon(Icons.add_photo_alternate),
  //                         label: const Text("Gallery"),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColor.fillColor,
  //                           side: BorderSide(color: AppColor.fillColor),
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: OutlinedButton.icon(
  //                         onPressed: () => _takePicture(setDialogState),
  //                         icon: const Icon(Icons.camera_alt),
  //                         label: const Text("Camera"),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColor.fillColor,
  //                           side: BorderSide(color: AppColor.fillColor),
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),

  //                 // Image requirements note
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   "* Please upload clear images of the product showing the issue.",
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.grey[600],
  //                     fontStyle: FontStyle.italic,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             style: TextButton.styleFrom(
  //               foregroundColor: Colors.grey,
  //             ),
  //             child: const Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               // Validation
  //               if (formKey.currentState!.validate()) {
  //                 if (selectedImages.isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text("Please upload at least one image")),
  //                   );
  //                   return;
  //                 }

  //                 Navigator.pop(dialogContext);

  //                 // Submit replacement request
  //                 try {
  //                   await AppDialogue.openLoadingDialogAfterClose(
  //                     context, // Use the widget's context
  //                     text: "Submitting return request...",
  //                     load: () async {
  //                       return await getprovider.createReplacement(
  //                         orderId: order.id ?? '',
  //                         productId: selectedProductId,
  //                         reason: returnReason,
  //                         quantity: selectedQuantity.toString(),
  //                         images: selectedImages,
  //                       );
  //                     },
  //                     afterComplete: (resp) async {
  //                       if (resp.status && (resp.statusCode == 200 || resp.statusCode == 201)) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(content: Text("Return request submitted successfully!")),
  //                         );
  //                         // Refresh order history
  //                         await _loadOrderHistory();
  //                       } else {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(content: Text(resp.data?.toString() ?? "Failed to submit return request")),
  //                         );
  //                       }
  //                     },
  //                   );
  //                 } catch (e) {
  //                   log('Error submitting return: $e');
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text("An error occurred while submitting return: $e")),
  //                   );
  //                 }
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColor.fillColor,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text("Submit Return"),
  //           ),
  //         ],
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         backgroundColor: Colors.white,
  //         elevation: 4,
  //       ),
  //     ),
  //   );
  // }

  void _showReturnDialog(GetOrderHistory order) {
    final formKey = GlobalKey<FormState>();

    // Create a BuildContext variable to capture the context safely
    late BuildContext dialogBuildContext;

    String returnReason = '';
    String selectedProductId = '';
    int selectedQuantity = 1;
    List<File> selectedImages = [];

    // Simplified image picker methods without permission_handler
    Future<void> _pickImageFromGallery(StateSetter setDialogState) async {
      try {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          AppDialogue.toast("Gallery permission denied");
          return;
        }

        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.single.path != null) {
          setDialogState(() {
            selectedImages.add(File(result.files.single.path!));
          });
        }
      } catch (e) {
        log("Error picking image: $e");
        AppDialogue.toast("Failed to pick image");
      }
    }

    Future<void> _takePicture(StateSetter setDialogState) async {
      try {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          AppDialogue.toast("Camera permission denied");
          return;
        }

        final picker = ImagePicker();
        final XFile? photo = await picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          setDialogState(() {
            selectedImages.add(File(photo.path));
          });
        }
      } catch (e) {
        log("Error taking picture: $e");
        AppDialogue.toast("Failed to take picture");
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        dialogBuildContext = dialogContext; // Store the dialog context
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text(
              "Return Order",
              style: TextStyle(
                color: AppColor.fillColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select product to return:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Product Selection Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text("Select Product"),
                      value: selectedProductId.isEmpty
                          ? null
                          : selectedProductId,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                      items:
                          order.items?.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.productId ?? '',
                              child: Text(
                                item.name ?? "Unknown Product",
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList() ??
                          [],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedProductId = value ?? '';

                          // Reset quantity when product changes
                          selectedQuantity = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity Selection
                    const Text(
                      "Quantity:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (selectedQuantity > 1) {
                              setDialogState(() {
                                selectedQuantity--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColor.fillColor,
                        ),
                        Text(
                          '$selectedQuantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedQuantity++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColor.fillColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reason for Return
                    const Text(
                      "Reason for return:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      onChanged: (value) => returnReason = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a reason';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Please state your reason for return...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Upload Section
                    const Text(
                      "Upload Images (Required):",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Display selected images
                    if (selectedImages.isNotEmpty)
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    // Add Image Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _pickImageFromGallery(setDialogState),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text("Gallery"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.fillColor,
                              side: BorderSide(color: AppColor.fillColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _takePicture(setDialogState),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.fillColor,
                              side: BorderSide(color: AppColor.fillColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Image requirements note
                    const SizedBox(height: 8),
                    Text(
                      "* Please upload clear images of the product showing the issue.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validation
                  if (formKey.currentState!.validate()) {
                    if (selectedImages.isEmpty) {
                      // Use AppDialogue.toast instead of ScaffoldMessenger
                      AppDialogue.toast("Please upload at least one image");
                      return;
                    }

                    // Close dialog first
                    Navigator.pop(dialogContext);

                    // Submit replacement request
                    // Inside your ElevatedButton onPressed callback:

                    try {
                      final result =
                          await AppDialogue.openLoadingDialogAfterClose(
                            this.context,
                            text: "Submitting return request...",
                            load: () async {
                              return await getprovider.createReplacement(
                                orderId: order.id ?? '',
                                productId: selectedProductId,
                                reason: returnReason,
                                quantity: selectedQuantity.toString(),
                                images: selectedImages,
                              );
                            },
                            afterComplete:
                                null, // Don't provide a callback here
                          );

                      // Extract only the message from the response
                      String displayMessage =
                          "Return request submitted successfully";

                      if (result.status &&
                          (result.statusCode == 200 ||
                              result.statusCode == 201)) {
                        // Try to extract just the message field
                        if (result.data is Map &&
                            result.data['message'] != null) {
                          displayMessage = result.data['message'];
                        } else if (result.fullBody is Map &&
                            result.fullBody['message'] != null) {
                          displayMessage = result.fullBody['message'];
                        }

                        // Display only the message
                        AppDialogue.toast(displayMessage);

                        // Refresh order history
                        await _loadOrderHistory();
                      } else {
                        // For error case
                        String errorMessage = "Failed to submit return request";

                        // Try to extract error message
                        if (result.data is Map &&
                            result.data['message'] != null) {
                          errorMessage = result.data['message'];
                        } else if (result.data is String) {
                          errorMessage = result.data.toString();
                        }

                        AppDialogue.toast(errorMessage);
                      }
                    } catch (e) {
                      log('Error submitting return: $e');
                      AppDialogue.toast(
                        "An error occurred while submitting return",
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fillColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Submit Return"),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            elevation: 4,
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                titleStyle ?? TextStyle(fontSize: 14, color: Colors.grey[700]),
            textScaler: const TextScaler.linear(1),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            textScaler: const TextScaler.linear(1),
          ),
        ],
      ),
    );
  }
}
