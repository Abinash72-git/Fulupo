// import 'dart:developer';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:fulupo/model/cart/getCart_model.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Cartpage extends StatefulWidget {
//   const Cartpage({super.key});

//   @override
//   State<Cartpage> createState() => _CartpageState();
// }

// class _CartpageState extends State<Cartpage> {
//   late Future<List<GetcartModel>> _cartFuture;
//   String? userAddress;
//   GetProvider get getprovider => context.read<GetProvider>();

//   @override
//   void initState() {
//     super.initState();
//     _cartFuture = getprovider.getCart();
//     _getLocation();
//   }

//   Future<void> _getLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userAddress =
//           prefs.getString(AppConstants.USERADDRESS) ?? "No address saved";
//     });
//     log('$userAddress');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       appBar: AppBar(
//         title: const Text("Cart"),
//         backgroundColor: AppColor.fillColor,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // 🔹 Address Bar at the Top
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: const BoxDecoration(color: AppColor.fillColor),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(
//                   Icons.location_on,
//                   color: Colors.redAccent,
//                   size: 22,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 40),
//                         child: Text(
//                           "Delivery to Your selected location",
//                           style: Styles.textStyleMedium(
//                             context,
//                             color: AppColor.yellowColor,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         userAddress ?? "Loading address...",
//                         style: Styles.textStyleSmall(
//                           context,
//                           color: AppColor.whiteColor,
//                         ),
//                         maxLines: 1, // 🔹 Only one line
//                         overflow: TextOverflow.ellipsis, // 🔹 Truncate if long
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               width: double.infinity,

//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Add new address coming soon"),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: AppColor.fillColor,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Icon(
//                         Icons.add,
//                         size: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       "Add Address",
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // 🔹 Cart Items (FutureBuilder)
//           Expanded(
//             child: FutureBuilder<List<GetcartModel>>(
//               future: _cartFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }
//                 final cartItems = snapshot.data ?? [];
//                 if (cartItems.isEmpty) {
//                   return const Center(child: Text("Your cart is empty"));
//                 }

//                 double total = 0;
//                 for (var item in cartItems) {
//                   total += (item.mrpPrice * item.quantity);
//                 }

//                 return Column(
//                   children: [
//                     Expanded(
//                       child: GridView.builder(
//                         padding: const EdgeInsets.all(10),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisExtent: 180,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                             ),
//                         itemCount: cartItems.length,
//                         itemBuilder: (context, index) {
//                           final item = cartItems[index];
//                           return Card(
//                             elevation: 3,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 85,
//                                     child: CachedNetworkImage(
//                                       imageUrl:
//                                           "${AppConstants.imageBaseUrl}/${item.storeLogo ?? ''}",
//                                       fit: BoxFit.contain,
//                                       placeholder: (context, url) => Container(
//                                         color: Colors.grey[100],
//                                         child: const Center(
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                           ),
//                                         ),
//                                       ),
//                                       errorWidget: (context, url, error) =>
//                                           Container(
//                                             color: Colors.grey[100],
//                                             child: const Icon(
//                                               Icons.image_not_supported,
//                                               color: Colors.grey,
//                                               size: 30,
//                                             ),
//                                           ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),

//                                   // Product Name
//                                   FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       item.productName,
//                                       style: Styles.textStyleSmall(
//                                         context,
//                                         color: AppColor.fillColor,
//                                       ),
//                                       textScaler: const TextScaler.linear(1),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),

//                                   // Product Price
//                                   Text(
//                                     "₹${item.mrpPrice.toStringAsFixed(2)}",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green[700],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),

//                                   // Counter
//                                   Container(
//                                     height: 26,
//                                     decoration: BoxDecoration(
//                                       color: AppColor.fillColor,
//                                       border: Border.all(
//                                         color: AppColor.fillColor,
//                                         width: 1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//                                             if (item.quantity > 1) {
//                                               setState(() {});
//                                             }
//                                           },
//                                           child: const Icon(
//                                             Icons.remove,
//                                             size: 14,
//                                             color: AppColor.whiteColor,
//                                           ),
//                                         ),
//                                         Text(
//                                           "${item.quantity}",
//                                           style: Styles.textStyleMedium(
//                                             context,
//                                             color: AppColor.yellowColor,
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                             setState(() {});
//                                           },
//                                           child: const Icon(
//                                             Icons.add,
//                                             size: 14,
//                                             color: AppColor.whiteColor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                     // Bottom total bar
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 5,
//                             offset: const Offset(0, -2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Total: ₹${total.toStringAsFixed(2)}",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColor.fillColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 25,
//                                 vertical: 10,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Checkout coming soon"),
//                                 ),
//                               );
//                             },
//                             child: const Text("Checkout"),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
