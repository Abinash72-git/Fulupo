// // lib/widgets/product_card.dart

// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:provider/provider.dart';

// import 'package:shimmer/shimmer.dart';

// class ProductCard extends StatelessWidget {
//   final String image;
//   final String name;
//   final String subname;
//   final String price;
//   final String oldPrice;
//   final String weights;
//   final int fruitsCount;

//   final String selectedWeight;
//   final Function(String?) onChanged;
//   final bool isAdded;
//   final Function() onAdd;
//   final Function() onRemove;
//   final int count;
//   final Function() onFavoriteToggle;
//   final bool isFavorite;
//   final Function() onTap;
//   final Function() onIcrease;
//   final String catgoryId;

//   const ProductCard({
//     Key? key,
//     required this.image,
//     required this.name,
//     required this.subname,
//     required this.price,
//     required this.oldPrice,
//     required this.weights,
//     required this.selectedWeight,
//     required this.onChanged,
//     required this.isAdded,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onIcrease,
//     required this.count,
//     required this.onFavoriteToggle,
//     required this.isFavorite,
//     required this.onTap,
//     required this.fruitsCount,
//     required this.catgoryId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     // Ensure the selectedWeight is in the weights list
//     String finalSelectedWeight = weights.contains(selectedWeight)
//         ? selectedWeight
//         : weights;
//     GetProvider getprovider = context.read<GetProvider>();

//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               height: screenHeight * 0.29,
//               width: screenWidth * 0.43,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 60),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       name.isNotEmpty
//                           ? FittedBox(
//                               fit: BoxFit.scaleDown,
//                               child: Text(
//                                 name,
//                                 style: Styles.textStyleMedium(
//                                   context,
//                                   color: AppColor.fillColor,
//                                 ),
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                             )
//                           : Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: 20,
//                                 width: 100,
//                                 color: Colors.white,
//                               ),
//                             ),
//                       // subname.isNotEmpty
//                       //     ? Text(
//                       //         subname,
//                       //         style: Styles.textStyleExtraSmall(
//                       //           context,
//                       //           color: AppColor.hintTextColor,
//                       //         ),
//                       //         textScaler: TextScaler.linear(1),
//                       //       )
//                       //     : Shimmer.fromColors(
//                       //         baseColor: Colors.grey[300]!,
//                       //         highlightColor: Colors.grey[100]!,
//                       //         child: Container(
//                       //           height: 15,
//                       //           width: 80,
//                       //           color: Colors.white,
//                       //         ),
//                       //       ),
//                       SizedBox(height: 8),
//                       // Display weight selection
//                       Container(
//                         height: 35,
//                         width: screenWidth * 0.25,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColor.hintTextColor),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 7),
//                           child: Row(
//                             children: [
//                               fruitsCount > 1
//                                   ? Text(
//                                       finalSelectedWeight ?? "Select",
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.hintTextColor,
//                                       ),
//                                     )
//                                   : Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 15,
//                                       ),
//                                       child: Text(
//                                         finalSelectedWeight ?? "Select",
//                                         style: Styles.textStyleMedium(
//                                           context,
//                                           color: AppColor.hintTextColor,
//                                         ),
//                                       ),
//                                     ),
//                               Spacer(),
//                               fruitsCount > 1
//                                   ? GestureDetector(
//                                       onTap: () async {
//                                         onTap();
//                                       },
//                                       child: Container(
//                                         height: 20,
//                                         width: 20,
//                                         decoration: BoxDecoration(
//                                           color: AppColor.fillColor,
//                                           borderRadius: BorderRadius.circular(
//                                             5,
//                                           ),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(
//                                             Icons.keyboard_arrow_down_outlined,
//                                             color: Colors.white,
//                                             size: 20,
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   : Container(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       // Display prices
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: price.isNotEmpty
//                                 ? FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       '₹ $price',
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.blackColor,
//                                       ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   )
//                                 : Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[100]!,
//                                     child: Container(
//                                       height: 20,
//                                       width: 60,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                           Expanded(
//                             child: oldPrice.isNotEmpty
//                                 ? FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       '₹ $oldPrice',
//                                       style:
//                                           Styles.textStyleSmall(
//                                             context,
//                                             color: AppColor.hintTextColor,
//                                           ).copyWith(
//                                             decoration:
//                                                 TextDecoration.lineThrough,
//                                           ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   )
//                                 : Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[100]!,
//                                     child: Container(
//                                       height: 20,
//                                       width: 60,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       // Add/Remove functionality
//                       GestureDetector(
//                         onTap: () {
//                           onAdd();
//                         },
//                         child: Container(
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: AppColor.fillColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: isAdded
//                               ? Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: IconButton(
//                                         icon: Icon(
//                                           Icons.remove,
//                                           color: AppColor.whiteColor,
//                                         ),
//                                         onPressed: onRemove,
//                                         iconSize: 16,
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: FittedBox(
//                                         fit: BoxFit.scaleDown,
//                                         child: Text(
//                                           '$count',
//                                           style: Styles.textStyleMedium(
//                                             context,
//                                             color: AppColor.yellowColor,
//                                           ),
//                                           textScaler: TextScaler.linear(1),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                         right: 8.0,
//                                       ),
//                                       child: IconButton(
//                                         icon: Icon(
//                                           Icons.add,
//                                           color: AppColor.whiteColor,
//                                         ),
//                                         onPressed: onIcrease,
//                                         iconSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Center(
//                                   child: FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       'ADD',
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.whiteColor,
//                                       ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 10,
//               left: 15,
//               child: Stack(
//                 children: [
//                   Container(
//                     height: 65,
//                     width: MediaQuery.of(context).size.width * 0.35,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   Positioned(
//                     top: 5,
//                     right: 5,
//                     child: GestureDetector(
//                       onTap: onFavoriteToggle,
//                       child: Container(
//                         height: 20,
//                         width: 20,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.favorite,
//                           color: isFavorite ? Colors.red : Colors.grey,
//                           size: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 25,
//               left: 18,
//               child: Container(
//                 height: 60,
//                 width: MediaQuery.of(context).size.width * 0.3,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color:
//                       Colors.grey[300], // Background color for the placeholder
//                 ),
//                 child: image.isNotEmpty
//                     ? Image.network(
//                         image,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) {
//                             return child;
//                           } else {
//                             return Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: 60,
//                                 width: MediaQuery.of(context).size.width * 0.3,
//                                 color: Colors.white,
//                               ),
//                             );
//                           }
//                         },
//                         errorBuilder: (context, error, stackTrace) {
//                           // If the image fails to load, show a blank placeholder
//                           return Container(
//                             color: Colors
//                                 .grey[300], // Grey background for placeholder
//                             child: Icon(
//                               Icons
//                                   .image_not_supported, // Default Flutter "image not supported" icon
//                               color: Colors.grey[600],
//                               size: 30,
//                             ),
//                           );
//                         },
//                       )
//                     : Container(
//                         color: Colors.grey[300], // Placeholder background color
//                         child: Icon(
//                           Icons.image, // Placeholder image icon
//                           color: Colors.grey[600],
//                           size: 30,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// lib/widgets/product_card.dart
//--------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:provider/provider.dart';

// import 'package:shimmer/shimmer.dart';

// class ProductCard extends StatelessWidget {
//   final String image;
//   final String name;
//   final String subname;
//   final String price;
//   final String oldPrice;
//   final String weights;
//   final int fruitsCount;

//   final String selectedWeight;
//   final Function(String?) onChanged;
//   final bool isAdded;
//   final Function() onAdd;
//   final Function() onRemove;
//   final int count;
//   final Function() onFavoriteToggle;
//   final bool isFavorite;
//   final Function() onTap;
//   final Function() onIcrease;
//   final String catgoryId;

//   const ProductCard({
//     Key? key,
//     required this.image,
//     required this.name,
//     required this.subname,
//     required this.price,
//     required this.oldPrice,
//     required this.weights,
//     required this.selectedWeight,
//     required this.onChanged,
//     required this.isAdded,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onIcrease,
//     required this.count,
//     required this.onFavoriteToggle,
//     required this.isFavorite,
//     required this.onTap,
//     required this.fruitsCount,
//     required this.catgoryId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double imageHeight = 80; // change here
//     final double imageWidth = screenWidth * 0.35;
//     // Ensure the selectedWeight is in the weights list
//     String finalSelectedWeight = weights.contains(selectedWeight)
//         ? selectedWeight
//         : weights;
//     GetProvider getprovider = context.read<GetProvider>();

//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               height: screenHeight * 0.26,
//               width: screenWidth * 0.4,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 75),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       name.isNotEmpty
//                           ? FittedBox(
//                               fit: BoxFit.scaleDown,
//                               child: Text(
//                                 name,
//                                 style: Styles.textStyleMedium(
//                                   context,
//                                   color: AppColor.fillColor,
//                                 ),
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                             )
//                           : Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: 20,
//                                 width: 100,
//                                 color: Colors.white,
//                               ),
//                             ),
//                       //  SizedBox(height: 8),
//                       // Display weight selection
//                       Container(
//                         height: 30,
//                         width: screenWidth * 0.25,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColor.hintTextColor),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 7),
//                           child: Row(
//                             children: [
//                               fruitsCount > 1
//                                   ? Text(
//                                       finalSelectedWeight ?? "Select",
//                                       style: Styles.textStyleSmall(
//                                         context,
//                                         color: AppColor.hintTextColor,
//                                       ),
//                                     )
//                                   : Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 15,
//                                       ),
//                                       child: Text(
//                                         finalSelectedWeight ?? "Select",
//                                         style: Styles.textStyleMedium(
//                                           context,
//                                           color: AppColor.hintTextColor,
//                                         ),
//                                       ),
//                                     ),
//                               Spacer(),
//                               fruitsCount > 1
//                                   ? GestureDetector(
//                                       onTap: () async {
//                                         onTap();
//                                       },
//                                       child: Container(
//                                         height: 20,
//                                         width: 20,
//                                         decoration: BoxDecoration(
//                                           color: AppColor.fillColor,
//                                           borderRadius: BorderRadius.circular(
//                                             5,
//                                           ),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(
//                                             Icons.keyboard_arrow_down_outlined,
//                                             color: Colors.white,
//                                             size: 20,
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   : Container(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       //  SizedBox(height: 5),
//                       // Display prices
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: price.isNotEmpty
//                                 ? FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       '₹ $price',
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.blackColor,
//                                       ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   )
//                                 : Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[100]!,
//                                     child: Container(
//                                       height: 20,
//                                       width: 60,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                           Expanded(
//                             child: oldPrice.isNotEmpty
//                                 ? FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       '₹ $oldPrice',
//                                       style:
//                                           Styles.textStyleSmall(
//                                             context,
//                                             color: AppColor.hintTextColor,
//                                           ).copyWith(
//                                             decoration:
//                                                 TextDecoration.lineThrough,
//                                           ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   )
//                                 : Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[100]!,
//                                     child: Container(
//                                       height: 20,
//                                       width: 60,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       // Add/Remove functionality
//                       GestureDetector(
//                         onTap: () {
//                           onAdd();
//                         },
//                         child: Container(
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: AppColor.fillColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: isAdded
//                               ? Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: IconButton(
//                                         icon: Icon(
//                                           Icons.remove,
//                                           color: AppColor.whiteColor,
//                                         ),
//                                         onPressed: onRemove,
//                                         iconSize: 16,
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: FittedBox(
//                                         fit: BoxFit.scaleDown,
//                                         child: Text(
//                                           '$count',
//                                           style: Styles.textStyleMedium(
//                                             context,
//                                             color: AppColor.yellowColor,
//                                           ),
//                                           textScaler: TextScaler.linear(1),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                         right: 8.0,
//                                       ),
//                                       child: IconButton(
//                                         icon: Icon(
//                                           Icons.add,
//                                           color: AppColor.whiteColor,
//                                         ),
//                                         onPressed: onIcrease,
//                                         iconSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Center(
//                                   child: FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       'ADD',
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.whiteColor,
//                                       ),
//                                       textScaler: TextScaler.linear(1),
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // Image container with proper grey background
//             Positioned(
//               top: 8,
//               left:
//                   (screenWidth * 0.3 - imageWidth) / 2, // to center inside card
//               child: Container(
//                 height: imageHeight,
//                 width: imageWidth,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: image.isNotEmpty
//                       ? Image.network(
//                           image,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) {
//                               return child;
//                             } else {
//                               return Shimmer.fromColors(
//                                 baseColor: Colors.grey[300]!,
//                                 highlightColor: Colors.grey[100]!,
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   color: Colors.white,
//                                 ),
//                               );
//                             }
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: double.infinity,
//                               height: double.infinity,
//                               color: Colors.grey[300],
//                               child: Icon(
//                                 Icons.image_not_supported,
//                                 color: Colors.grey[600],
//                                 size: 30,
//                               ),
//                             );
//                           },
//                         )
//                       : Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           color: Colors.grey[300],
//                           child: Icon(
//                             Icons.image,
//                             color: Colors.grey[600],
//                             size: 30,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//             // Favorite button positioned properly
//             Positioned(
//               top: 15,
//               right: 15,
//               child: GestureDetector(
//                 onTap: onFavoriteToggle,
//                 child: Container(
//                   height: 28,
//                   width: 28,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 3,
//                         offset: Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.favorite,
//                     color: isFavorite ? Colors.red : Colors.grey[400],
//                     size: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';

// class ProductCard extends StatelessWidget {
//   final String image;
//   final String name;
//   final String subname;
//   final String price;
//   final String oldPrice;
//   final String weights;
//   final int fruitsCount;

//   final String selectedWeight;
//   final Function(String?) onChanged;
//   final bool isAdded;
//   final Function() onAdd;
//   final Function() onRemove;
//   final int count;
//   final Function() onFavoriteToggle;
//   final bool isFavorite;
//   final Function() onTap;
//   final Function() onIcrease;
//   final String catgoryId;

//   const ProductCard({
//     Key? key,
//     required this.image,
//     required this.name,
//     required this.subname,
//     required this.price,
//     required this.oldPrice,
//     required this.weights,
//     required this.selectedWeight,
//     required this.onChanged,
//     required this.isAdded,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onIcrease,
//     required this.count,
//     required this.onFavoriteToggle,
//     required this.isFavorite,
//     required this.onTap,
//     required this.fruitsCount,
//     required this.catgoryId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Adjusted dimensions for 3-column layout
//     final double cardWidth =
//         (screenWidth - 60) / 3; // Account for padding and spacing
//     final double imageHeight = 70;
//     final double imageWidth = cardWidth * 0.8;

//     // Ensure the selectedWeight is in the weights list
//     String finalSelectedWeight = weights.contains(selectedWeight)
//         ? selectedWeight
//         : weights;
//     GetProvider getprovider = context.read<GetProvider>();

//     return Stack(
//       children: [
//         Container(
//           width: cardWidth,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Space for image
//                 SizedBox(height: imageHeight + 2),

//                 // Product name
//                 name.isNotEmpty
//                     ? Text(
//                         name,
//                         style: Styles.textStyleSmall(
//                           context,
//                           color: AppColor.fillColor,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         textScaler: TextScaler.linear(1),
//                       )
//                     : Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Container(
//                           height: 15,
//                           width: 60,
//                           color: Colors.white,
//                         ),
//                       ),

//                 SizedBox(height: 2),

//                 // Weight selection container
//                 Container(
//                   height: 25,
//                   width: cardWidth * 0.9,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: AppColor.hintTextColor,
//                       width: 0.5,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             finalSelectedWeight ?? "Select",
//                             style: Styles.textStyleExtraSmall(
//                               context,
//                               color: AppColor.hintTextColor,
//                             ),
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (fruitsCount > 1)
//                           GestureDetector(
//                             onTap: () async {
//                               onTap();
//                             },
//                             child: Container(
//                               height: 15,
//                               width: 15,
//                               decoration: BoxDecoration(
//                                 color: AppColor.fillColor,
//                                 borderRadius: BorderRadius.circular(3),
//                               ),
//                               child: const Center(
//                                 child: Icon(
//                                   Icons.keyboard_arrow_down_outlined,
//                                   color: Colors.white,
//                                   size: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 2),

//                 // Price row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: price.isNotEmpty
//                           ? Text(
//                               '₹$price',
//                               style: Styles.textStyleSmall(
//                                 context,
//                                 color: AppColor.blackColor,
//                               ),
//                               textAlign: TextAlign.left,
//                               overflow: TextOverflow.ellipsis,
//                               textScaler: TextScaler.linear(1),
//                             )
//                           : Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: 12,
//                                 width: 30,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                     SizedBox(width: 2),
//                     Expanded(
//                       child: oldPrice.isNotEmpty
//                           ? Text(
//                               '₹$oldPrice',
//                               style:
//                                   Styles.textStyleExtraSmall(
//                                     context,
//                                     color: AppColor.hintTextColor,
//                                   ).copyWith(
//                                     decoration: TextDecoration.lineThrough,
//                                   ),
//                               textAlign: TextAlign.right,
//                               overflow: TextOverflow.ellipsis,
//                               textScaler: TextScaler.linear(1),
//                             )
//                           : Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 height: 12,
//                                 width: 25,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 4),

//                 // Add/Remove button
//                 GestureDetector(
//                   onTap: () {
//                     onAdd();
//                   },
//                   child: Container(
//                     height: 28,
//                     width: cardWidth * 0.9,
//                     decoration: BoxDecoration(
//                       color: AppColor.fillColor,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: isAdded
//                         ? Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               GestureDetector(
//                                 onTap: onRemove,
//                                 child: Container(
//                                   width: 28,
//                                   height: 28,
//                                   child: Icon(
//                                     Icons.remove,
//                                     color: AppColor.whiteColor,
//                                     size: 14,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Center(
//                                   child: Text(
//                                     '$count',
//                                     style: Styles.textStyleSmall(
//                                       context,
//                                       color: AppColor.yellowColor,
//                                     ),
//                                     textScaler: TextScaler.linear(1),
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: onIcrease,
//                                 child: Container(
//                                   width: 28,
//                                   height: 28,
//                                   child: Icon(
//                                     Icons.add,
//                                     color: AppColor.whiteColor,
//                                     size: 14,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Center(
//                             child: Text(
//                               'ADD',
//                               style: Styles.textStyleSmall(
//                                 context,
//                                 color: AppColor.whiteColor,
//                               ),
//                               textScaler: TextScaler.linear(1),
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Product image positioned at the top
//         Positioned(
//           top: 5,
//           left: (cardWidth - imageWidth) / 2, // Center the image
//           child: Container(
//             height: imageHeight,
//             width: imageWidth,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 3,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: image.isNotEmpty
//                   ? Image.network(
//                       image,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) {
//                           return child;
//                         } else {
//                           return Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(
//                               width: double.infinity,
//                               height: double.infinity,
//                               color: Colors.white,
//                             ),
//                           );
//                         }
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: double.infinity,
//                           height: double.infinity,
//                           color: Colors.grey[300],
//                           child: Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey[600],
//                             size: 24,
//                           ),
//                         );
//                       },
//                     )
//                   : Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       color: Colors.grey[300],
//                       child: Icon(
//                         Icons.image,
//                         color: Colors.grey[600],
//                         size: 24,
//                       ),
//                     ),
//             ),
//           ),
//         ),

//         // Favorite button
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: onFavoriteToggle,
//             child: Container(
//               height: 24,
//               width: 24,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.favorite,
//                 color: isFavorite ? Colors.red : Colors.grey[400],
//                 size: 14,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String subname;
  final String price;
  final String oldPrice;
  final String weights;
  final int fruitsCount;

  final String selectedWeight;
  final Function(String?) onChanged;
  final bool isAdded;
  final Function() onAdd;
  final Function() onRemove;
  final int count;
  final Function() onFavoriteToggle;
  final bool isFavorite;
  final Function() onTap;
  final Function() onIcrease;
  final String catgoryId;

  const ProductCard({
    Key? key,
    required this.image,
    required this.name,
    required this.subname,
    required this.price,
    required this.oldPrice,
    required this.weights,
    required this.selectedWeight,
    required this.onChanged,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
    required this.onIcrease,
    required this.count,
    required this.onFavoriteToggle,
    required this.isFavorite,
    required this.onTap,
    required this.fruitsCount,
    required this.catgoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjusted dimensions for 3-column layout
    final double cardWidth =
        (screenWidth - 55) / 3; // Account for padding and spacing
    final double imageHeight = 70;
    final double imageWidth = cardWidth * 0.9;

    // Ensure the selectedWeight is in the weights list
    String finalSelectedWeight = weights.contains(selectedWeight)
        ? selectedWeight
        : weights;
    GetProvider getprovider = context.read<GetProvider>();

    return Stack(
      children: [
        Container(
          height: 160, // Fixed height for compact card
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Space for image
                //  SizedBox(height: 55),

                // Product name
                name.isNotEmpty
                    ? Text(
                        _capitalizeWords(name),
                        style: Styles.textStyleSmall(
                          context,
                          color: AppColor.fillColor, // ✅ Flexible color
                          fontWeight: FontWeight.w900, // ✅ Flexible font weight
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1),
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 15,
                          width: 60,
                          color: Colors.white,
                        ),
                      ),

                //  SizedBox(height: 4),

                // Weight selection container
                // Container(
                //   height: 25,
                //   width: cardWidth * 0.9,
                //   decoration: BoxDecoration(
                //     border: Border.all(
                //       color: AppColor.hintTextColor,
                //       width: 0.5,
                //     ),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 4),
                //     child: Row(
                //       children: [
                //         Expanded(
                //           child: Text(
                //             finalSelectedWeight ?? "Select",
                //             style: Styles.textStyleExtraSmall(
                //               context,
                //               color: AppColor.hintTextColor,
                //             ),
                //             textAlign: TextAlign.center,
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //         ),
                //         if (fruitsCount > 1)
                //           GestureDetector(
                //             onTap: () async {
                //               onTap();
                //             },
                //             child: Container(
                //               height: 15,
                //               width: 15,
                //               decoration: BoxDecoration(
                //                 color: AppColor.fillColor,
                //                 borderRadius: BorderRadius.circular(3),
                //               ),
                //               child: const Center(
                //                 child: Icon(
                //                   Icons.keyboard_arrow_down_outlined,
                //                   color: Colors.white,
                //                   size: 12,
                //                 ),
                //               ),
                //             ),
                //           ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 4),

                // Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: price.isNotEmpty
                          ? Text(
                              '₹$price',
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.blackColor,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.linear(1),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 12,
                                width: 30,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: oldPrice.isNotEmpty
                          ? Text(
                              '₹$oldPrice',
                              style:
                                  Styles.textStyleExtraSmall(
                                    context,
                                    color: AppColor.hintTextColor,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.linear(1),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 12,
                                width: 25,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                // Add/Remove button
                GestureDetector(
                  onTap: () {
                    onAdd();
                  },
                  child: Container(
                    height: 28,
                    width: cardWidth * 0.9,
                    decoration: BoxDecoration(
                      color: AppColor.fillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isAdded
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: onRemove,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  child: Icon(
                                    Icons.remove,
                                    color: AppColor.whiteColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$count',
                                    style: Styles.textStyleSmall(
                                      context,
                                      color: AppColor.yellowColor,
                                    ),
                                    textScaler: TextScaler.linear(1),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: onIcrease,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  child: Icon(
                                    Icons.add,
                                    color: AppColor.whiteColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              'ADD',
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.whiteColor,
                              ),
                              textScaler: TextScaler.linear(1),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Product image positioned at the top
        Positioned(
          top: 5,
          left: (cardWidth - imageWidth) / 2, // Center the image
          child: Container(
            height: imageHeight,
            width: imageWidth,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ),
            ),
          ),
        ),

        // Favorite button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                color: isFavorite ? Colors.red : Colors.grey[400],
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
