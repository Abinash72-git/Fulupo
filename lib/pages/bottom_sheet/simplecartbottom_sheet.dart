import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleCartBottomSheet extends StatefulWidget {
  final ProductModel latestProduct;
  final int totalItems;
  final double totalPrice;
  final VoidCallback onViewCart;
  final List<String> recentProductImages;
  final List<ProductModel> cartItems;
  final Map<String, int> qtyByProductKey;
  final Function(ProductModel, int) onQuantityChanged; // Add this callback

  const SimpleCartBottomSheet({
    Key? key,
    required this.latestProduct,
    required this.totalItems,
    required this.totalPrice,
    required this.onViewCart,
    required this.recentProductImages,
    required this.cartItems,
    required this.qtyByProductKey,
    required this.onQuantityChanged, // Add this parameter
  }) : super(key: key);

  @override
  State<SimpleCartBottomSheet> createState() => _SimpleCartBottomSheetState();
}

class _SimpleCartBottomSheetState extends State<SimpleCartBottomSheet> {
  bool _isExpanded = false;
  GetProvider get getprovider => context.read<GetProvider>();

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _productKey(ProductModel p) => '${p.name}|${p.productImage}';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Main bottom sheet container
        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -5) {
              setState(() {
                _isExpanded = true;
              });
            } else if (details.primaryDelta! > 5 && _isExpanded) {
              setState(() {
                _isExpanded = false;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded
                ? MediaQuery.of(context).size.height * 0.7
                : null, // Auto height for collapsed state
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: _isExpanded ? 16 : 12,
              bottom: _isExpanded ? 16 : 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: _isExpanded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (_isExpanded)
                  _buildExpandedView()
                else
                  _buildCollapsedView(),
              ],
            ),
          ),
        ),

        // Arrow positioned above the sheet
        Positioned(
          top: -15,
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: AppColor.fillColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Separated the collapsed view to a dedicated method
  Widget _buildCollapsedView() {
    return Row(
      children: [
        // Stack of product images
        SizedBox(
          width: 80, // Updated from 60 to 90
          height: 50, // Updated from 35 to 50
          child: Stack(children: _buildProductImageStack()),
        ),

        const SizedBox(width: 5),

        // Item count and total price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.totalItems} ${widget.totalItems == 1 ? 'item' : 'items'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${widget.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fillColor,
                ),
              ),
            ],
          ),
        ),

        // View cart button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.fillColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {},
          child: const Text('View Cart', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // Separated the expanded view to a dedicated method
  Widget _buildExpandedView() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Check your Items',
            style: Styles.textStyleLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Cart items list
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final qty = widget.qtyByProductKey[_productKey(item)] ?? 0;

                // Skip items with zero quantity
                if (qty <= 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl:
                                "${AppConstants.imageBaseUrl}/${item.productImage}",
                            width: 70,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              width: 70,
                              height: 70,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              width: 70,
                              height: 70,
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Styles.textStyleMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.fillColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Product Code: ${item.productCode}',
                                style: Styles.textStyleSmall(context).copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '₹${(item.mrpPrice * qty).toStringAsFixed(2)}',
                                    style: Styles.textStyleMedium(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (item.discountPrice != null &&
                                      item.discountPrice! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        '₹${(item.discountPrice! * qty).toStringAsFixed(2)}',
                                        style: Styles.textStyleSmall(context)
                                            .copyWith(
                                              color: Colors.grey[500],
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Quantity control - NEW COMPONENT
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.fillColor.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Minus button
                              InkWell(
                                onTap: () {
                                  if (qty > 1) {
                                    widget.onQuantityChanged(item, qty - 1);
                                  } else if (qty == 1) {
                                    // Show confirmation dialog for removing item
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Remove Item'),
                                        content: Text(
                                          'Remove ${item.name} from cart?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              widget.onQuantityChanged(item, 0);
                                            },
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: qty > 1
                                        ? AppColor.fillColor
                                        : Colors.red[400],
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                    ),
                                  ),
                                  child: Icon(
                                    qty > 1
                                        ? Icons.remove
                                        : Icons.delete_outline,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),

                              // Quantity display
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 5,
                                ),
                                color: Colors.white,
                                child: Text(
                                  qty.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.fillColor,
                                  ),
                                  textScaler: TextScaler.linear(1),
                                ),
                              ),

                              // Plus button
                              InkWell(
                                onTap: () {
                                  widget.onQuantityChanged(item, qty + 1);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColor.fillColor,
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(8),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Cart Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Items',
                      style: Styles.textStyleSmall(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      '${widget.totalItems}',
                      style: Styles.textStyleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: Styles.textStyleSmall(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${widget.totalPrice.toStringAsFixed(2)}',
                      style: Styles.textStyleLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColor.fillColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // View Full Cart Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fillColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),

            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final storeId = prefs.getString(AppConstants.StoreCode) ?? '';

              if (storeId.isEmpty) {
                AppDialogue.toast("Store ID missing");
                return;
              }

              bool success = false;

              for (final item in widget.cartItems) {
                final qty = widget.qtyByProductKey[_productKey(item)] ?? 0;
                if (qty > 0) {
                  final resp = await getprovider.addCart(
                    storeId: storeId,
                    productId: item.id,
                    quantity: qty,
                  );

                  if (resp.status && resp.statusCode == 200) {
                    AppDialogue.toast(resp.data.toString());
                    success = true;
                  } else {
                    AppDialogue.toast("Failed: ${resp.data}");
                  }
                }
              }

              if (success && mounted) {
                AppRouteName.apppage.push(context, args: 0);
              }
            },

            child: Text(
              'View Full Cart',
              style: Styles.textStyleMedium(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductImageStack() {
    List<Widget> imageWidgets = [];

    // Filter to show only images for products that still exist in cart (qty > 0)
    final validImages = <String>[];
    for (String imgPath in widget.recentProductImages) {
      for (var item in widget.cartItems) {
        if (item.productImage == imgPath) {
          final qty = widget.qtyByProductKey[_productKey(item)] ?? 0;
          if (qty > 0) {
            validImages.add(imgPath);
            break;
          }
        }
      }
    }

    // If nothing valid, return empty
    if (validImages.isEmpty) return imageWidgets;

    // Limit maximum 3 visible
    final displayCount = validImages.length > 3 ? 3 : validImages.length;

    // Reverse order so latest product appears on top/front
    for (int i = displayCount - 1; i >= 0; i--) {
      final leftOffset = i * 22.0; // overlap spacing

      imageWidgets.add(
        Positioned(
          left: leftOffset,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: "${AppConstants.imageBaseUrl}/${validImages[i]}",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, size: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Optional "+N" overlay if more than 3 items
    if (validImages.length > 3) {
      imageWidgets.insert(
        0,
        Positioned(
          left: displayCount * 22.0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.fillColor,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                "+${validImages.length - 3}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return imageWidgets;
  }
}
