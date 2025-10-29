import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/pages/bottom_sheet/simplecartbottom_sheet.dart'; // Import your bottom sheet
import 'package:fulupo/pages/whilist/wishlistbottomsheet.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> with TickerProviderStateMixin {
  bool isLoading = true;
  List<ProductModel> wishlistProducts = [];
  
  // ✅ ADD CART FUNCTIONALITY - Same as HomePage2
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, int> _qtyByProductKey = {};
  List<ProductModel> _cartItems = [];
  List<String> _recentProductImages = [];
  double _cartTotalPrice = 0.0;
  int _totalCartItems = 0;
  PersistentBottomSheetController? _persistentBottomSheetController;
  bool _isBottomSheetOpen = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  GetProvider get getprovider => context.read<GetProvider>();
  
  String _productKey(ProductModel p) => '${p.name}|${p.productImage}';
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadWishlistProducts();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ CART FUNCTIONALITY - Same as HomePage2
  void _addToCart(ProductModel product, int quantity) {
    setState(() {
      bool productExists = false;

      for (var i = 0; i < _cartItems.length; i++) {
        if (_cartItems[i].id == product.id) {
          _cartItems[i] = product;
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        _cartItems.add(product);
      }

      _recentProductImages.clear();
      for (var item in _cartItems) {
        final keyStr = _productKey(item);
        final qty = _qtyByProductKey[keyStr] ?? 0;

        if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
          _recentProductImages.add(item.productImage);
          if (_recentProductImages.length >= 3) break;
        }
      }

      _updateCartTotal();
    });

    if (!_isBottomSheetOpen) {
      _showWishlistCartBottomSheet(product);
    } else {
      _updateCartBottomSheet();
    }
  }

  void _updateCartTotal() {
    double total = 0.0;
    int itemCount = 0;

    _cartItems.removeWhere((item) {
      final keyStr = _productKey(item);
      final qty = _qtyByProductKey[keyStr] ?? 0;
      return qty <= 0;
    });

    for (var entry in _qtyByProductKey.entries) {
      ProductModel? product;
      for (var p in wishlistProducts) {
        if (_productKey(p) == entry.key) {
          product = p;
          break;
        }
      }

      if (product != null) {
        total += product.mrpPrice * entry.value;
        itemCount += entry.value;
      }
    }

    setState(() {
      _cartTotalPrice = total;
      _totalCartItems = itemCount;
    });

    _recentProductImages.clear();
    for (var item in _cartItems) {
      final qty = _qtyByProductKey[_productKey(item)] ?? 0;
      if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
        _recentProductImages.add(item.productImage);
        if (_recentProductImages.length >= 3) break;
      }
    }

    if (itemCount > 0) {
      if (!_isBottomSheetOpen) {
        ProductModel? firstProduct;
        for (var p in wishlistProducts) {
          final qty = _qtyByProductKey[_productKey(p)] ?? 0;
          if (qty > 0) {
            firstProduct = p;
            break;
          }
        }

        if (firstProduct != null) {
          _showWishlistCartBottomSheet(firstProduct);
        }
      } else {
        _updateCartBottomSheet();
      }
    } else if (_isBottomSheetOpen) {
      _persistentBottomSheetController?.close();
    }
  }

void _showWishlistCartBottomSheet(ProductModel latestProduct) {
  if (_totalCartItems == 0) {
    if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
      _persistentBottomSheetController!.close();
      _persistentBottomSheetController = null;
      _isBottomSheetOpen = false;
    }
    return;
  }

  _recentProductImages.clear();
  for (var item in _cartItems) {
    final keyStr = _productKey(item);
    final qty = _qtyByProductKey[keyStr] ?? 0;

    if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
      _recentProductImages.add(item.productImage);
      if (_recentProductImages.length >= 3) break;
    }
  }

  if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
    _persistentBottomSheetController!.setState!(() {});
    return;
  }

  _persistentBottomSheetController = _scaffoldKey.currentState?.showBottomSheet(
    (BuildContext context) {
      return WishlistCartBottomSheet( // Use the new bottom sheet
        latestProduct: latestProduct,
        totalItems: _totalCartItems,
        totalPrice: _cartTotalPrice,
        recentProductImages: _recentProductImages,
        cartItems: _cartItems,
        qtyByProductKey: _qtyByProductKey,
        onViewCart: () {
          _showFullCartBottomSheet();
        },
        onQuantityChanged: (product, newQuantity) {
          final keyStr = _productKey(product);

          setState(() {
            if (newQuantity <= 0) {
              _qtyByProductKey.remove(keyStr);
              _cartItems.removeWhere((item) => _productKey(item) == keyStr);

              _recentProductImages.clear();
              for (var item in _cartItems) {
                final qty = _qtyByProductKey[_productKey(item)] ?? 0;
                if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
                  _recentProductImages.add(item.productImage);
                  if (_recentProductImages.length >= 3) break;
                }
              }
            } else {
              _qtyByProductKey[keyStr] = newQuantity;
            }

            _updateCartTotal();

            if (_qtyByProductKey.isEmpty) {
              _persistentBottomSheetController?.close();
            }
          });
        },
      );
    },
    backgroundColor: Colors.transparent,
    elevation: 0,
  );

  _isBottomSheetOpen = true;
  setState(() {});

  _persistentBottomSheetController!.closed.then((value) {
    _isBottomSheetOpen = false;
    _persistentBottomSheetController = null;
    setState(() {});
  });
}

  void _updateCartBottomSheet() {
    if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
      _persistentBottomSheetController!.setState!(() {});
    }
  }

  void _showFullCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Your Cart', style: Styles.textStyleLarge(context)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: "${AppConstants.imageBaseUrl}/${item.productImage}",
                        width: 50,
                        height: 50,
                      ),
                      title: Text(item.name),
                      subtitle: Text('₹${item.mrpPrice}'),
                      trailing: Text('Qty: ${_qtyByProductKey[_productKey(item)] ?? 0}'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fillColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final storeId = prefs.getString(AppConstants.StoreCode) ?? '';

                  if (storeId.isEmpty) {
                    AppDialogue.toast("Store ID missing");
                    return;
                  }

                  bool success = false;

                  for (final item in _cartItems) {
                    final qty = _qtyByProductKey[_productKey(item)] ?? 0;
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
                    Navigator.pop(context);
                    AppRouteName.apppage.push(context, args: 0);
                  }
                },
                child: Text(
                  'Checkout ₹$_cartTotalPrice',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ QUANTITY UPDATE FUNCTION
  void _updateQuantity(String productId, int newQuantity) {
    // Find the product
    ProductModel? product;
    for (var p in wishlistProducts) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) return;

    final keyStr = _productKey(product);
    final previousQty = _qtyByProductKey[keyStr] ?? 0;

    setState(() {
      if (newQuantity <= 0) {
        _qtyByProductKey.remove(keyStr);
        _cartItems.removeWhere((item) => _productKey(item) == keyStr);
        _updateCartTotal();
      } else {
        _qtyByProductKey[keyStr] = newQuantity;

        if (previousQty == 0) {
          _addToCart(product!, newQuantity);
        } else {
          bool productExists = false;
          for (var i = 0; i < _cartItems.length; i++) {
            if (_cartItems[i].id == product!.id) {
              _cartItems[i] = product;
              productExists = true;
              break;
            }
          }

          if (!productExists) {
            _cartItems.add(product!);
          }

          if (previousQty < newQuantity) {
            _recentProductImages.remove(product!.productImage);
            _recentProductImages.insert(0, product.productImage);
            if (_recentProductImages.length > 3) {
              _recentProductImages = _recentProductImages.sublist(0, 3);
            }
          }

          _updateCartTotal();
          _updateCartBottomSheet();
        }
      }
    });
  }

  Future<void> _loadWishlistProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString(AppConstants.USER_ID) ?? '';
      
      if (customerId.isEmpty) {
        log('User ID is empty, cannot load wishlist');
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      final products = await context.read<GetProvider>().getWishlistProducts(customerId);
      
      setState(() {
        wishlistProducts = products;
        isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      log('Error loading wishlist products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString(AppConstants.USER_ID) ?? '';
      final storeId = prefs.getString(AppConstants.StoreCode) ?? '';
      
      if (customerId.isEmpty || storeId.isEmpty) {
        AppDialogue.toast('Unable to remove item from wishlist');
        return;
      }
      
      final response = await context.read<GetProvider>().removeWishList(
        customerId: customerId,
        storeId: storeId,
        productId: productId,
      );
      
      if (response.status) {
        setState(() {
          wishlistProducts.removeWhere((product) => product.id == productId);
        });
        
        AppDialogue.toast("Removed from wishlist");
      } else {
        AppDialogue.toast("Failed to remove from wishlist");
      }
    } catch (e) {
      log('Error removing from wishlist: $e');
      AppDialogue.toast("An error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ✅ ADD SCAFFOLD KEY
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'My Wishlist',
              style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
              textScaler: const TextScaler.linear(1),
            ),
            if (wishlistProducts.isNotEmpty)
              Text(
                '${wishlistProducts.length} items',
                style: Styles.textStyleSmall(context, color: Colors.white70)
                    .copyWith(fontSize: 12),
                textScaler: const TextScaler.linear(1),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (wishlistProducts.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.yellowColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${wishlistProducts.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
            ? _buildLoadingView()
            : wishlistProducts.isEmpty
                ? _buildEmptyWishlist()
                : _buildWishlistGrid(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColor.yellowColor,
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/map_pin/empty-wishList.json",
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.9,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Wishlist is empty',
              style: Styles.textStyleMedium(
                context,
                color: AppColor.whiteColor,
              ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to your wishlist to see them here',
              style: Styles.textStyleSmall(context, color: Colors.white70),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.yellowColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Start Shopping',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        color: AppColor.yellowColor,
        backgroundColor: Colors.white,
        onRefresh: _loadWishlistProducts,
        child: Container(
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
          // ✅ ADD BOTTOM PADDING FOR CART BOTTOM SHEET
          child: Padding(
            padding: EdgeInsets.only(
              bottom: _isBottomSheetOpen ? 80.0 : 16.0,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
              ),
              itemCount: wishlistProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistProducts[index];
                final keyStr = _productKey(product);
                final qty = _qtyByProductKey[keyStr] ?? 0;
                
                return WishlistProductCard(
                  product: product,
                  quantity: qty, // ✅ USE CART QUANTITY
                  onQuantityChanged: (newQuantity) => _updateQuantity(product.id, newQuantity),
                  onRemoveFromWishlist: () => _removeFromWishlist(product.id),
                  onViewCart: () {
                    AppRouteName.apppage.push(context, args: 0);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Keep your existing WishlistProductCard class unchanged
class WishlistProductCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemoveFromWishlist;
  final VoidCallback onViewCart;

  const WishlistProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemoveFromWishlist,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
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
            // Product Image with Remove from Wishlist Icon
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Product Image
                  CachedNetworkImage(
                    imageUrl: "${AppConstants.imageBaseUrl}/${product.productImage}",
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
                  
                  // Remove from Wishlist Icon
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onRemoveFromWishlist,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  // Discount Badge if applicable
                  if (product.discountPrice != null && 
                      product.discountPrice != product.mrpPrice)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${((1 - (product.discountPrice! / product.mrpPrice)) * 100).toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Product Name
            Text(
              product.name,
              style: Styles.textStyleSmall(
                context,
                color: AppColor.fillColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1),
            ),

            const SizedBox(height: 2),

            // Product Price & Discount Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "₹${product.mrpPrice}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                if (product.discountPrice != null &&
                    product.discountPrice != product.mrpPrice) ...[
                  const SizedBox(width: 6),
                  Text(
                    "₹${product.discountPrice}",
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            // Add / Counter Button
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
                        onQuantityChanged(1);
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
                        // Minus Button
                        GestureDetector(
                          onTap: () {
                            onQuantityChanged(quantity - 1);
                          },
                          child: const Icon(
                            Icons.remove,
                            size: 14,
                            color: AppColor.whiteColor,
                          ),
                        ),

                        // Quantity Text
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

                        // Plus Button
                        GestureDetector(
                          onTap: () {
                            onQuantityChanged(quantity + 1);
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
