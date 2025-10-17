// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';

// class CartBottomSheet extends StatefulWidget {
//   final ProductModel product;
//   final int quantity;
//   final Function(int) onQuantityChanged;
//   final VoidCallback onViewCart;
  
//   const CartBottomSheet({
//     Key? key,
//     required this.product,
//     required this.quantity,
//     required this.onQuantityChanged,
//     required this.onViewCart,
//   }) : super(key: key);

//   @override
//   State<CartBottomSheet> createState() => _CartBottomSheetState();
// }

// class _CartBottomSheetState extends State<CartBottomSheet> {
//   late Timer _autoHideTimer;
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Auto-hide the sheet after 4 seconds unless user interacts with it
//     _autoHideTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//     });
//   }
  
//   @override
//   void dispose() {
//     _autoHideTimer.cancel();
//     super.dispose();
//   }
  
//   void _cancelAutoHide() {
//     _autoHideTimer.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double totalPrice = widget.product.mrpPrice * widget.quantity;
    
//     return GestureDetector(
//       onTap: _cancelAutoHide, // Cancel auto-hide when user taps the sheet
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Success message
//             Row(
//               children: [
//                 const Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Item added to cart!',
//                   style: Styles.textStyleMedium(context, color: Colors.green),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
            
//             const Divider(),
            
//             // Product details
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Product image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: "${AppConstants.imageBaseUrl}/${widget.product.productImage}",
//                     width: 60,
//                     height: 60,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                           ),
//                         ),
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.error),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(width: 12),
                
//                 // Product name and price
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.product.name,
//                         style: Styles.textStyleMedium(context),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "₹${widget.product.mrpPrice}",
//                         style: Styles.textStyleMedium(
//                           context, 
//                           color: AppColor.fillColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Quantity controls
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Row(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           _cancelAutoHide();
//                           if (widget.quantity > 1) {
//                             widget.onQuantityChanged(widget.quantity - 1);
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           child: const Icon(Icons.remove, size: 16),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: Text(
//                           "${widget.quantity}",
//                           style: Styles.textStyleMedium(context),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           _cancelAutoHide();
//                           widget.onQuantityChanged(widget.quantity + 1);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           child: const Icon(Icons.add, size: 16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Order summary
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Price (${widget.quantity} item${widget.quantity > 1 ? 's' : ''})',
//                         style: Styles.textStyleSmall(context),
//                       ),
//                       Text(
//                         "₹$totalPrice",
//                         style: Styles.textStyleMedium(context),
//                       ),
//                     ],
//                   ),
//                   if (widget.product.discountPrice != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'You save:',
//                             style: Styles.textStyleSmall(context, color: Colors.green),
//                           ),
//                           Text(
//                             "₹${(widget.product.mrpPrice - (widget.product.discountPrice ?? 0)) * widget.quantity}",
//                             style: Styles.textStyleSmall(context, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: AppColor.fillColor),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     onPressed: () {
//                       _cancelAutoHide();
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       'Continue Shopping',
//                       style: Styles.textStyleSmall(
//                         context, 
//                         color: AppColor.fillColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.fillColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     onPressed: () {
//                       _cancelAutoHide();
//                       Navigator.pop(context);
//                       widget.onViewCart();
//                     },
//                     child: Text('View Cart',style: Styles.textStyleSmall(
//                         context, 
//                         color: AppColor.whiteColor,),
//                   ),)
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
