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

class WishlistCartBottomSheet extends StatefulWidget {
  final ProductModel latestProduct;
  final int totalItems;
  final double totalPrice;
  final VoidCallback onViewCart;
  final List<String> recentProductImages;
  final List<ProductModel> cartItems;
  final Map<String, int> qtyByProductKey;
  final Function(ProductModel, int) onQuantityChanged;

  const WishlistCartBottomSheet({
    Key? key,
    required this.latestProduct,
    required this.totalItems,
    required this.totalPrice,
    required this.onViewCart,
    required this.recentProductImages,
    required this.cartItems,
    required this.qtyByProductKey,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<WishlistCartBottomSheet> createState() =>
      _WishlistCartBottomSheetState();
}

class _WishlistCartBottomSheetState extends State<WishlistCartBottomSheet> {
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
                : null,
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

  Widget _buildCollapsedView() {
    return Row(
      children: [
        // Stack of product images
        SizedBox(
          width: 80,
          height: 50,
          child: Stack(children: _buildProductImageStack()),
        ),

        const SizedBox(width: 5),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.fillColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.fillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.totalItems}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.totalItems == 1 ? 'item' : 'items',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '₹${widget.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.fillColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

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
          child: const Text('View Cart', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with wishlist context
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Items from Wishlist',
                style: Styles.textStyleLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColor.fillColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cart items list
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final qty = widget.qtyByProductKey[_productKey(item)] ?? 0;

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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: Styles.textStyleMedium(context)
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.fillColor,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Wishlist indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 12,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Wishlist',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

                        // Quantity control
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text('Remove from Cart'),
                                          ],
                                        ),
                                        content: Text(
                                          'Remove ${item.name} from cart?\n\nNote: This item will remain in your wishlist.',
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

          // Cart Summary with wishlist context
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.pink.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Wishlist Items Summary',
                      style: Styles.textStyleSmall(context).copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Proceed to Cart Button
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Proceed to Cart',
                  style: Styles.textStyleMedium(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductImageStack() {
    List<Widget> imageWidgets = [];

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

    if (validImages.isEmpty) return imageWidgets;

    final displayCount = validImages.length > 3 ? 3 : validImages.length;

    for (int i = displayCount - 1; i >= 0; i--) {
      final leftOffset = i * 22.0;

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
              child: Stack(
                children: [
                  CachedNetworkImage(
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
                      child: const Icon(
                        Icons.error,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Small heart indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(Icons.favorite, size: 8, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
              gradient: LinearGradient(
                colors: [AppColor.fillColor, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
