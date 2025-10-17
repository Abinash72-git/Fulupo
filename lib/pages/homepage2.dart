import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/model/product_base_model.dart';
import 'package:fulupo/pages/bottom_sheet/product_category_page.dart';
import 'package:fulupo/pages/bottom_sheet/simplecartbottom_sheet.dart';
import 'package:fulupo/pages/bottom_sheet_page.dart';
import 'package:fulupo/pages/custom_drawar.dart';
import 'package:fulupo/pages/gridview/gridview_page.dart';
import 'package:fulupo/pages/homepageWidgets.dart/productcard.dart';
import 'package:fulupo/pages/profile_page.dart';
import 'package:fulupo/pages/saved_address_list_bottomsheet.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/service/api_service.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  String _address = "Loading...";

  LatLng draggedLatLng = LatLng(0.0, 0.0);
  int myCurrentIndex = 0;
  String token = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  GetProvider get getprovider => context.read<GetProvider>();
  UserProvider get provider => context.read<UserProvider>();

  bool isItemAdded = false;
  double TotalCurrentPrice = 0;
  double TotalOldPrice = 0;
  double totalSavings = 0;

  Map<String, String> selectedWeights = {};
  Map<String, int> itemCounts = {};

  Map<String, bool> isFavorite = {};
  Map<String, bool> isAdded = {};
  Map<String, Timer?> _debounceTimers = {};
  String selectedAddress = '';
  int selectedCategoryIndex = 0;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  String selectedAddressName = '';
  // A stable per-product quantity map kept at page level
  final Map<String, int> _qtyByProductKey = {};
  String _productKey(ProductModel p) => '${p.name}|${p.productImage}';

  // Track cart items
  List<ProductModel> _cartItems = [];
  List<String> _recentProductImages = []; // For product image stack
  double _cartTotalPrice = 0.0;

  PersistentBottomSheetController? _persistentBottomSheetController;
  bool _isBottomSheetOpen = false;
  // Add a product to cart
  void _addToCart(ProductModel product, int quantity) {
  setState(() {
    // Check if product already exists in cart
    bool productExists = false;

    // Update quantity if product exists
    for (var i = 0; i < _cartItems.length; i++) {
      if (_cartItems[i].id == product.id) {
        _cartItems[i] = product;
        productExists = true;
        break;
      }
    }

    // Add product if it doesn't exist
    if (!productExists) {
      _cartItems.add(product);
    }

    // CRITICAL FIX: Rebuild recent images properly
    _recentProductImages.clear();
    for (var item in _cartItems) {
      final keyStr = _productKey(item);
      final qty = _qtyByProductKey[keyStr] ?? 0;
      
      // Only add images for items with quantity > 0
      if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
        _recentProductImages.add(item.productImage);
        if (_recentProductImages.length >= 3) break;
      }
    }

    // Recalculate cart total
    _updateCartTotal();
  });

  // Show the cart bottom sheet if it's not already showing
  if (!_isBottomSheetOpen) {
    _showSimpleCartBottomSheet(product);
  } else {
    _updateCartBottomSheet();
  }
}

  void _updateCartTotal() {
  double total = 0.0;
  int itemCount = 0;

  // CRITICAL FIX: Clean up _cartItems to only include items with qty > 0
  _cartItems.removeWhere((item) {
    final keyStr = _productKey(item);
    final qty = _qtyByProductKey[keyStr] ?? 0;
    return qty <= 0;
  });

  // Calculate total from _qtyByProductKey
  for (var entry in _qtyByProductKey.entries) {
    ProductModel? product;
    for (var category in visibleCategories) {
      for (var p in category.products) {
        if (_productKey(p) == entry.key) {
          product = p;
          break;
        }
      }
      if (product != null) break;
    }

    if (product != null) {
      total += product.mrpPrice * entry.value;
      itemCount += entry.value;
    }
  }

  setState(() {
    _cartTotalPrice = total;
  });

  // CRITICAL FIX: Rebuild recent images after cleanup
  _recentProductImages.clear();
  for (var item in _cartItems) {
    final qty = _qtyByProductKey[_productKey(item)] ?? 0;
    if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
      _recentProductImages.add(item.productImage);
      if (_recentProductImages.length >= 3) break;
    }
  }

  // Check if we need to show, update, or close the bottom sheet
  if (itemCount > 0) {
    if (!_isBottomSheetOpen) {
      ProductModel? firstProduct;
      for (var category in visibleCategories) {
        for (var p in category.products) {
          final qty = _qtyByProductKey[_productKey(p)] ?? 0;
          if (qty > 0) {
            firstProduct = p;
            break;
          }
        }
        if (firstProduct != null) break;
      }

      if (firstProduct != null) {
        _showSimpleCartBottomSheet(firstProduct);
      }
    } else {
      _updateCartBottomSheet();
    }
  } else if (_isBottomSheetOpen) {
    _persistentBottomSheetController?.close();
  }
}
  // Show the simplified cart bottom sheet
 void _showSimpleCartBottomSheet(ProductModel latestProduct) {
  // Calculate total items in cart
  int totalItems = 0;
  for (var qty in _qtyByProductKey.values) {
    totalItems += qty;
  }

  // No need to show if there are no items
  if (totalItems == 0) {
    // If bottom sheet is open, close it
    if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
      _persistentBottomSheetController!.close();
      _persistentBottomSheetController = null;
      _isBottomSheetOpen = false;
    }
    return;
  }

  // CRITICAL FIX: Rebuild _recentProductImages from actual cart items
  _recentProductImages.clear();
  for (var item in _cartItems) {
    final keyStr = _productKey(item);
    final qty = _qtyByProductKey[keyStr] ?? 0;
    
    // Only add images for items that still have quantity > 0
    if (qty > 0 && !_recentProductImages.contains(item.productImage)) {
      _recentProductImages.add(item.productImage);
      
      // Limit to 3 images
      if (_recentProductImages.length >= 3) break;
    }
  }

  // If bottom sheet is already open, just update it
  if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
    _persistentBottomSheetController!.setState!(() {
      // This will trigger a rebuild of the bottom sheet with new data
    });
    return;
  }

  // Otherwise, show a new persistent bottom sheet
  _persistentBottomSheetController = _scaffoldKey.currentState?.showBottomSheet(
    (BuildContext context) {
      return SimpleCartBottomSheet(
        latestProduct: latestProduct,
        totalItems: totalItems,
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
              
              // Remove from cart items
              _cartItems.removeWhere((item) => _productKey(item) == keyStr);
              
              // CRITICAL FIX: Rebuild recent images from remaining cart items
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
            
            // Update cart total
            _updateCartTotal();
            
            // If cart is now empty, close the sheet
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

  // Listen to bottom sheet close event
  _persistentBottomSheetController!.closed.then((value) {
    _isBottomSheetOpen = false;
    _persistentBottomSheetController = null;
    setState(() {});
  });
}



  void _updateCartBottomSheet() {
    if (_isBottomSheetOpen && _persistentBottomSheetController != null) {
      _persistentBottomSheetController!.setState!(() {
        // This forces the bottom sheet to rebuild with new data
      });
    }
  }

  // Show a more detailed cart view
  void _showFullCartBottomSheet() {
    // Implement your full cart view here
    // This is just a placeholder
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
                        imageUrl:
                            "${AppConstants.imageBaseUrl}/${item.productImage}",
                        width: 50,
                        height: 50,
                      ),
                      title: Text(item.name),
                      subtitle: Text('₹${item.mrpPrice}'),
                      trailing: Text(
                        'Qty: ${_qtyByProductKey[_productKey(item)] ?? 0}',
                      ),
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
                onPressed: () {
                  Navigator.pop(context);
                  // Proceed to checkout
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

  @override
  void initState() {
    super.initState();
    _getLocationData();
    _loadWishlistData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });

    //  getprovider.fetchBanner();
    fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    for (var t in _debounceTimers.values) {
      t?.cancel();
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page
    print('Returned to HomePage, refreshing wishlist...');
    _loadWishlistData();
  }

  Future<void> _loadWishlistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString(AppConstants.USER_ID) ?? '';

      if (customerId.isEmpty) {
        log('User ID is empty, skipping wishlist loading');
        setState(() {
          isFavorite.clear();
        });
        return;
      }

      log('Loading wishlist for user: $customerId');

      // Fetch wishlist products from provider
      final wishlistProducts = await getprovider.getWishlistProducts(
        customerId,
      );

      // Clear and rebuild the isFavorite map based on fetched data
      setState(() {
        isFavorite.clear();
        for (var product in wishlistProducts) {
          isFavorite[product.id] = true;
        }
      });

      log('Wishlist data loaded: ${isFavorite.length} items');
    } catch (e) {
      log('Error loading wishlist data: $e');
      // On error, clear favorites to be safe
      setState(() {
        isFavorite.clear();
      });
    }
  }

  Future<void> _getLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      double? latitude = prefs.getDouble(AppConstants.USERLATITUTE);
      double? longitude = prefs.getDouble(AppConstants.USERLONGITUTE);

      // Get all address components
      String? address = prefs.getString(AppConstants.USERADDRESS);
      String? flatHouseNo = prefs.getString('SELECTED_FLAT_HOUSE_NO') ?? '';

      token = prefs.getString('token') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS_TYPE') ?? '';
      selectedAddressName = prefs.getString('SELECTED_ADDRESS_NAME') ?? '';

      // Format the address to include flat/house number
      if (flatHouseNo.isNotEmpty && address != null) {
        address = "$flatHouseNo, $address";
      }

      log('Token: $token');
      log('Selected Address Type: $selectedAddress');
      log('Selected Address Name: $selectedAddressName');
      log('Full Address: $address');

      if (latitude != null && longitude != null && address != null) {
        draggedLatLng = LatLng(latitude, longitude);
        setState(() {
          _address = address!;
        });
      } else {
        setState(() {
          _address = "No address found.";
        });
      }
    } catch (e) {
      log('Error retrieving location data: $e');
      setState(() {
        _address = "Error retrieving address.";
      });
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString(AppConstants.USER_ID) ?? '';
      final storeId = prefs.getString(AppConstants.StoreCode) ?? '';

      if (customerId.isEmpty || storeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add items to wishlist'),
          ),
        );
        return;
      }

      // Log current state
      log(
        'Before toggle - Favorite state for $productId: ${isFavorite[productId]}',
      );

      // Store previous state
      final previousState = isFavorite[productId] ?? false;

      // Important: Update state immediately for responsive UI
      setState(() {
        isFavorite[productId] = !previousState;
      });

      log(
        'After toggle - Favorite state for $productId: ${isFavorite[productId]}',
      );

      if (!previousState) {
        // If it was not favorite before
        // Add to wishlist
        final resp = await getprovider.addWishList(
          customerId: customerId,
          storeId: storeId,
          productId: productId,
        );

        log(
          'Add wishlist API response status: ${resp.status}, statusCode: ${resp.statusCode}',
        );

        if (!resp.status || resp.statusCode != 200) {
          // API failed, revert UI state
          if (mounted) {
            setState(() {
              isFavorite[productId] = previousState;
            });

            AppDialogue.toast("Failed to add to wishlist");
          }
        } else {
          // API succeeded, ensure the state is updated
          if (mounted) {
            setState(() {
              isFavorite[productId] = true;
            });

            AppDialogue.toast(resp.data.toString());
          }
        }
      } else {
        // If it was favorite before
        // Call remove from wishlist API
        final resp = await getprovider.removeWishList(
          customerId: customerId,
          storeId: storeId,
          productId: productId,
        );

        if (!resp.status || resp.statusCode != 200) {
          // API failed, revert UI state
          if (mounted) {
            setState(() {
              isFavorite[productId] = previousState;
            });

            AppDialogue.toast("Failed to remove from wishlist");
          }
        } else {
          // API succeeded, ensure the state is updated
          if (mounted) {
            setState(() {
              isFavorite[productId] = false;
            });

            AppDialogue.toast("Removed from wishlist");
          }
        }
      }
    } catch (e) {
      log('Error in _toggleFavorite: $e');
    }
  }

  Future<void> recalculateTotalPrice() async {
    double totalCurrentPrice = 0;
    double totalOldPrice = 0;

    await Future.delayed(Duration.zero);

    getprovider.getAddToCart.forEach((item) {
      totalCurrentPrice += (item.currentPrice ?? 0.0) * (item.count ?? 0);
      totalOldPrice += (item.oldPrice ?? 0.0) * (item.count ?? 0);
    });

    setState(() {
      TotalCurrentPrice = totalCurrentPrice;
      TotalOldPrice = totalOldPrice;
      totalSavings = totalOldPrice - totalCurrentPrice;
    });
  }

  Future<void> storeLocationData(
    double latitude,
    double longitude,
    String address,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.USERLATITUTE, latitude.toString());
    await prefs.setString(AppConstants.USERLONGITUTE, longitude.toString());
    await prefs.setString(AppConstants.USERADDRESS, address);
  }

 @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    key: _scaffoldKey,
    drawer: CustomDrawer(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
    ),
    onDrawerChanged: (isOpened) async {
      if (!isOpened) {
        log("Drawer is closed");
        await recalculateTotalPrice();
        await _loadWishlistData();
      }
    },
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await _getLocationData();
        },
        color: AppColor.fillColor,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            // Add padding to the bottom to account for the bottom sheet
            padding: EdgeInsets.only(
              bottom: _isBottomSheetOpen ? 80.0 : 16.0, // Add padding when bottom sheet is open
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(),

                  SizedBox(height: 20),

                  // Search Bar
                  _buildSearchBar(), 
                  SizedBox(height: 20),
                  if (getprovider.banner.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        height: screenHeight * 0.16,
                        autoPlayInterval: const Duration(seconds: 5),
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        aspectRatio: 200,
                        onPageChanged: (index, reason) {
                          setState(() {
                            myCurrentIndex = index;
                          });
                        },
                      ),
                      items: getprovider.banner.map((banner) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: banner.Image ?? '',
                            width: screenWidth * 0.9,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    // 🔸 Default banner when API returns nothing
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/vegitable.jpg', // ✅ your default asset
                        height: screenHeight * 0.14,
                        width: screenWidth * 0.9,
                        fit: BoxFit.cover,
                      ),
                    ),

                  SizedBox(height: 20),

                  // 🔼 Carousel Dots
                  Center(
                    child: AnimatedSmoothIndicator(
                      activeIndex: myCurrentIndex,
                      count: getprovider.banner.isNotEmpty
                          ? getprovider.banner.length
                          : 1,
                      effect: const JumpingDotEffect(
                        dotHeight: 5,
                        dotWidth: 5,
                        spacing: 5,
                        dotColor: Color.fromARGB(255, 172, 171, 171),
                        activeDotColor: AppColor.whiteColor,
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Shop by Category',
                      style: Styles.textStyleLarge(
                        context,
                        color: AppColor.yellowColor,
                      ),
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                  // Category Slider
                  _buildCategorySliderAlternative(context),

                  SizedBox(height: 20),
                  // Product Grid
                  _buildProductGrid(),
                  
                  // Add extra space at the bottom when bottom sheet is open
                  if (_isBottomSheetOpen)
                    SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(Icons.menu, color: AppColor.whiteColor, size: 30),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getAddressIcon(), color: Colors.red),
                    SizedBox(width: 10),
                    Flexible(
                      child: GestureDetector(
                        onTap: () async {
                          final val = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SavedAddressListBottomsheet(
                                    page: 'Home',
                                  ),
                            ),
                          );
                          if (val == "Yes") {
                            _getLocationData();
                          }
                        },
                        child: Text(
                          // ✅ Show custom name if available, otherwise show type
                          selectedAddressName.isEmpty
                              ? (selectedAddress.isEmpty
                                    ? "Select Address"
                                    : selectedAddress)
                              : selectedAddressName,
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.yellowColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 35,
                      color: Colors.black,
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    _address, // This now contains the complete formatted address
                    style: Styles.textStyleSmall(
                      context,
                      color: AppColor.whiteColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Allow 2 lines for better display
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: Icon(
              Icons.person_2_rounded,
              color: AppColor.whiteColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAddressIcon() {
    if (selectedAddress.isEmpty || selectedAddress == 'Home') {
      return Icons.home;
    } else if (selectedAddress == 'Work') {
      return Icons.work;
    } else if (selectedAddress == 'Others') {
      return Icons.hotel_rounded;
    } else {
      return Icons.location_on;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search by product or category...",
            hintStyle: Styles.textStyleMedium(
              context,
              color: AppColor.hintTextColor,
            ),
            prefixIcon: Icon(Icons.search, color: AppColor.hintTextColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    final trimmedQuery = query.toLowerCase().trim();

    // Step 1: Check for category name match
    int categoryIndex = visibleCategories.indexWhere(
      (cat) => cat.categoryName.toLowerCase().trim().startsWith(trimmedQuery),
    );

    // ✅ CASE 1: Direct Category Match
    if (categoryIndex != -1) {
      setState(() {
        selectedCategoryIndex = categoryIndex;
        _searchQuery =
            ''; // ✅ Clear search query to show full category products
      });

      _categoryScrollController.animateTo(
        categoryIndex * 96.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // ✅ CASE 2: Search for product inside categories
    for (int i = 0; i < visibleCategories.length; i++) {
      final productIndex = visibleCategories[i].products.indexWhere(
        (prod) => prod.name.toLowerCase().contains(trimmedQuery),
      );
      if (productIndex != -1) {
        setState(() {
          selectedCategoryIndex = i;
          _searchQuery = trimmedQuery;
        });

        _categoryScrollController.animateTo(
          i * 96.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        Future.delayed(Duration(milliseconds: 300), () {
          _productScrollController.animateTo(
            productIndex * 240.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });

        return;
      }
    }

    // ✅ CASE 3: Nothing found
    setState(() {
      _searchQuery = trimmedQuery;
    });
  }

  Widget _buildProductGrid() {
    List<ProductModel> matchedProducts = [];

    // If search query is not empty, find matching products
    if (_searchQuery.isNotEmpty) {
      for (var category in visibleCategories) {
        matchedProducts.addAll(
          category.products.where(
            (product) => product.name.toLowerCase().contains(_searchQuery),
          ),
        );
      }
    } else {
      // Default: show products from selected category
      matchedProducts = visibleCategories.isNotEmpty
          ? visibleCategories[selectedCategoryIndex].products
          : [];
    }

    if (matchedProducts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            "No matching products found.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matchedProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final product = matchedProducts[index];
        final keyStr = _productKey(product);
        final qty = _qtyByProductKey[keyStr] ?? 0;

        // Get favorite status from map using product ID
        final bool isFav = isFavorite[product.id] ?? false;

        return ProductnewCard(
          key: Key('${product.id}_${isFav ? 'fav' : 'nofav'}'),
          product: product,
          quantity: qty,
          isFavorite: isFav,
          onFavoriteToggle: (pid) {
            log('Toggling favorite for: $pid');
            _toggleFavorite(pid);
          },
          onQuantityChanged: (newQty) {
            final previousQty = _qtyByProductKey[keyStr] ?? 0;

            setState(() {
              if (newQty <= 0) {
                _qtyByProductKey.remove(keyStr);

                // Also remove from cart items if quantity becomes zero
                _cartItems.removeWhere((item) => _productKey(item) == keyStr);

                // Remove from recent images if this was the last one
                if (_cartItems.isEmpty) {
                  _recentProductImages.clear();
                }

                // Update cart totals and maybe close sheet if empty
                _updateCartTotal();
              } else {
                _qtyByProductKey[keyStr] = newQty;

                // Only show cart bottom sheet when adding a new product
                if (previousQty == 0) {
                  _addToCart(product, newQty);
                } else {
                  // For increments, update but don't create new sheet
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

                  // Update recent product images
                  if (previousQty < newQty) {
                    _recentProductImages.remove(product.productImage);
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
          },

          onViewCart: () {
            // This callback should handle viewing the cart, not showing a bottom sheet
            _showFullCartBottomSheet(); // Show the full cart view
          },
        );
        
      },
    );
  }

  void _showCartBottomSheet() {
    // Implement your existing cart bottom sheet or navigation to cart page
    // This is just a placeholder
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          children: [
            Text('Your Cart', style: Styles.textStyleLarge(context)),
            // Add your cart items list here
            Expanded(
              child: Center(
                child: Text(
                  'Cart items will be displayed here',
                  style: Styles.textStyleMedium(context),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.fillColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  List<GetAllCategoryModel> allCategories = [];
  List<GetAllCategoryModel> visibleCategories = [];
  int currentIndex = 2;
  bool isLoading = true;

  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final storeCode = prefs.getString(AppConstants.StoreCode) ?? '';
    final userId = prefs.getString(AppConstants.USER_ID) ?? '';
    log('Store Code: $storeCode');
    log('User Id : $userId ');

    if (storeCode.isEmpty) {
      if (!mounted) return;
      setState(() {
        allCategories = [];
        visibleCategories = [];
        isLoading = false;
      });
      log('Store code missing. Skipping category fetch.');
      return;
    }

    try {
      await getprovider.fetchCategories(storeCode: storeCode);
      if (!mounted) return;

      final cats = List<GetAllCategoryModel>.from(getprovider.category ?? []);
      setState(() {
        allCategories = cats;
        visibleCategories = cats.length >= 10
            ? cats.take(10).toList()
            : List.from(cats);
        isLoading = false;
      });

      _handleIndexChange();
    } catch (e, st) {
      log("Error fetching categories: $e\n$st");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleIndexChange() async {
    if (visibleCategories.length < 3) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
        currentIndex = 2;
      });
    }

    final current = visibleCategories[currentIndex];
    log(
      "Current Index: $currentIndex, Category: ${current.categoryName}. ${current.id}",
    );

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildCategorySliderAlternative(BuildContext context) {
    if (visibleCategories.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColor.fillColor),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: visibleCategories.length,
        separatorBuilder: (_, __) => SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = visibleCategories[index];
          final isSelected = index == selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColor.fillColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 65,
                      width: 65,
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl:
                            "${AppConstants.imageBaseUrl}/${category.categoryimage}",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.category,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),
                  Expanded(
                    child: Center(
                      child: Text(
                        category.categoryName.trim(),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? Colors.black87 : Colors.white,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
