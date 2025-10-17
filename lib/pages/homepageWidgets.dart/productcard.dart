import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/pages/bottom_sheet/cartbottom_sheet.dart';

import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:shimmer/shimmer.dart';

class ProductnewCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final Function(int) onQuantityChanged;
  final bool isFavorite;
  final Function(String productId) onFavoriteToggle;
  final VoidCallback onViewCart; // Add this new callback

  const ProductnewCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onViewCart, // Add this new parameter
  });

  // void _showCartBottomSheet(BuildContext context, int newQuantity) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (BuildContext context) {
  //       return CartBottomSheet(
  //         product: product,
  //         quantity: newQuantity,
  //         onQuantityChanged: onQuantityChanged,
  //         onViewCart: onViewCart,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Debug log to track favorite status
    log('ProductCard: ${product.id}, isFavorite: $isFavorite');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // 🔹 Product Image with Favorite Icon Overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Product Image
                  CachedNetworkImage(
                    imageUrl:
                        "${AppConstants.imageBaseUrl}/${product.productImage}",
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                  
                  // Favorite Icon - Positioned in top-right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        log('Favorite icon tapped for product: ${product.id}');
                        onFavoriteToggle(product.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // 🔹 Product Name with Shimmer
            product.name.isNotEmpty
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      product.name,
                      style: Styles.textStyleSmall(
                        context,
                        color: AppColor.fillColor,
                      ),
                      textScaler: const TextScaler.linear(1),
                    ),
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 14,
                      width: 80,
                      color: Colors.white,
                    ),
                  ),

            const SizedBox(height: 2),

            // 🔹 Product Price & Discount Price in a Single Row with Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 MRP Price or Shimmer
                product.mrpPrice != null &&
                        product.mrpPrice.toString().isNotEmpty
                    ? Text(
                        "₹${product.mrpPrice}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 12,
                          width: 40,
                          color: Colors.white,
                        ),
                      ),

                const SizedBox(width: 6),

                // 🔹 Discount Price or Shimmer
                product.discountPrice != null &&
                        product.discountPrice.toString().isNotEmpty &&
                        product.discountPrice.toString() !=
                            product.mrpPrice.toString()
                    ? Text(
                        "₹${product.discountPrice}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 10,
                          width: 35,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),

            const SizedBox(height: 4),

            // 🔹 Add / Counter Button
            quantity == 0
                ? SizedBox(
                    width: 75,
                    height: 26,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColor.fillColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        // Update quantity
                        onQuantityChanged(1);
                        
                        // Show bottom sheet
                        // _showCartBottomSheet(context, 1);
                      },
                      child: const Text(
                        "ADD",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 75,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColor.fillColor,
                      border: Border.all(color: AppColor.fillColor, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔹 Minus Button
                        GestureDetector(
                          onTap: () {
                            // Update quantity
                            onQuantityChanged(quantity - 1);
                            
                            // Only show bottom sheet if quantity becomes 0
                            if (quantity == 1) {
                              // Don't show bottom sheet for removal
                            }
                          },
                          child: const Icon(
                            Icons.remove,
                            size: 14,
                            color: AppColor.whiteColor,
                          ),
                        ),

                        // 🔹 Quantity Text
                        Flexible(
                          child: Text(
                            "$quantity",
                            textAlign: TextAlign.center,
                            style: Styles.textStyleMedium(
                              context,
                              color: AppColor.yellowColor,
                            ),
                            textScaler: const TextScaler.linear(1),
                          ),
                        ),

                        // 🔹 Plus Button
                        GestureDetector(
                          onTap: () {
                            // Get new quantity
                            int newQuantity = quantity + 1;
                            
                            // Update quantity
                            onQuantityChanged(newQuantity);
                            
                            // Show bottom sheet for increment
                          //  _showCartBottomSheet(context, newQuantity);
                          },
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
        
      ),
    );
  }
}
