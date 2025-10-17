// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/model/product_base_model.dart';
// import 'package:fulupo/pages/bottom_sheet/product_category_page.dart';
// import 'package:fulupo/pages/gridview/gridview_page.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/provider/user_provider.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/util/exception.dart';
// import 'package:fulupo/widget/dilogue/dilogue.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// class WishlistPage extends StatefulWidget {
//   const WishlistPage({super.key});

//   @override
//   State<WishlistPage> createState() => _WishlistPageState();
// }

// class _WishlistPageState extends State<WishlistPage> {
//   String token = '';
//   double TotalCurrentPrice = 0;
//   double TotalOldPrice = 0;
//   double totalSavings = 0;
//   Map<String, int> itemCounts = {};
//   Map<String, Timer?> _debounceTimers = {};
//   Map<String, bool> isFavorite = {};
//   Map<String, bool> isAdded = {};
//   GetProvider get getprovider => context.read<GetProvider>();
//   UserProvider get provider => context.read<UserProvider>();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _getLocationData();
//   }

//   Future<void> _getLocationData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     try {
//       // Retrieve latitude and longitude as doubles

//       token = prefs.getString('token') ?? '';
//       print(token);
//       log('Token: $token');
//     } catch (e) {
//       print('Error retrieving location data: $e');
//       setState(() {});
//     }
//     await _fetchCartData();
//     await getprovider.fetchWishList(token);
//     await _fetchWishlistData();
//   }

//   void _debounceApiCall(String categoryId, int count, String token) {
//     // Cancel any existing timer for the categoryId
//     if (_debounceTimers[categoryId] != null) {
//       _debounceTimers[categoryId]?.cancel();
//     }

//     // Start a new timer
//     _debounceTimers[categoryId] = Timer(const Duration(seconds: 1), () async {
//       try {
//         await AppDialogue.openLoadingDialogAfterClose(context,
//             text: "Updating...", load: () async {
//           return await getprovider.updateCart(
//             categoryId: categoryId,
//             count: count,
//             token: token,
//           );
//         }, afterComplete: (resp) async {
//           if (resp.status) {
//             AppDialogue.toast(resp.data);
//           }
//         });
//       } catch (e) {
//         ExceptionHandler.showMessage(context, e);
//       }

//       // Fetch updated cart data
//       await getprovider.fetchAddToCart(token);
//       await recalculateTotalPrice();
//     });
//   }

//   Future<void> _fetchWishlistData() async {
//     try {
//       // Fetch wishlist data
//       final wishlistData =
//           await context.read<GetProvider>().fetchWishList(token);

//       // Clear current wishlist state
//       isFavorite.clear();

//       // Process the fetched data
//       for (var item in wishlistData) {
//         final categoryId = item.CategoryId;

//         if (categoryId != null) {
//           isFavorite[categoryId] = true; // Mark as favorite if in wishlist
//         }
//       }

//       // Handle categories that are no longer in the wishlist
//       for (final categoryId in isFavorite.keys) {
//         if (!wishlistData.any((item) => item.CategoryId == categoryId)) {
//           isFavorite[categoryId] = false; // Set to false if not in the wishlist
//         }
//       }
//     } catch (e) {
//       print('Error fetching wishlist data: $e');
//     }
//   }

//   Future<void> _fetchCartData() async {
//     try {
//       // Fetch cart data
//       final cartData = await context.read<GetProvider>().fetchAddToCart(token);

//       // Clear current states
//       itemCounts.clear();
//       isAdded.clear();

//       // Process the fetched data
//       for (var item in cartData) {
//         final categoryId = item.fruitCategoryId;
//         final count = item.count;

//         if (categoryId != null) {
//           // Update item counts and isAdded status
//           itemCounts[categoryId] = count ?? 0;
//           isAdded[categoryId] =
//               (count ?? 0) > 0; // Set isAdded to true if count > 0
//         }
//       }

//       // Handle categories that are no longer in the cart
//       for (final categoryId in isAdded.keys) {
//         if (!cartData.any((item) => item.fruitCategoryId == categoryId)) {
//           isAdded[categoryId] = false; // Mark as false if not in the cart data
//         }
//       }
//     } catch (e) {
//       print('Error fetching cart data: $e');
//     }

//     // Fetch additional data
//   }

//   @override
//   void dispose() {
//     // Dispose the ScrollController to free up resources

//     super.dispose(); // Always call the superclass dispose() method
//     // Cancel all timers when the widget is disposed
//     for (var timer in _debounceTimers.values) {
//       timer?.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       appBar: AppBar(
//         title: Text(
//           'Wish List',
//           style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
//           textScaleFactor: 1,
//         ),
//         backgroundColor: AppColor.fillColor,
//         leading: IconButton(
//           icon:
//               Icon(Icons.arrow_back, color: AppColor.whiteColor), // Back arrow
//           onPressed: () {
//             Navigator.pop(context); // Go back to the previous screen
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(children: [
//           const SizedBox(
//             height: 20,
//           ),
//           Consumer<GetProvider>(
//             builder: (context, wishlistprovider, child) {
//               if (wishlistprovider.getWishList.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Lottie.asset("assets/map_pin/empty-wishList.json",
//                           height: screenHeight * 0.3,
//                           width: screenWidth * 0.9,
//                           fit: BoxFit.cover),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       const Text(
//                         'Your WishList is empty',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                         textScaleFactor: 1.0,
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return ProductGridView(
//                 products: wishlistprovider.getWishList.map((getWishList) {
//                   return Product(
//                     id: getWishList.Id,
//                     categoryId: getWishList.CategoryId,
//                     name: getWishList.Name,
//                     subname: getWishList.Subname,
//                     image: getWishList.Image,
//                     weights: getWishList.Quantity,
//                     currentPrice: getWishList.currentPrice,
//                     oldPrice: getWishList.oldPrice,
//                   );
//                 }).toList(),
//                 onProductTap: (product) async {
//                   print('hello');
//                   final value = await showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     builder: (BuildContext context) {
//                       return ProductCategoryPage(
//                         categoryId: product.categoryId!,
//                         // categoryType: ProductCategoryType.dairyProducts,
//                       );
//                     },
//                   );
//                   if (value == 'Yes') {
//                     print('ggggggggggggggggggggggg');
//                     _getLocationData();
//                   }
//                 },
//                 onAdd: (product) async {
//                   setState(() {
//                     if (!(isAdded[product.categoryId] ?? false)) {
//                       isAdded[product.categoryId!] = true;
//                       itemCounts[product.categoryId!] = 1;
//                     } else {
//                       itemCounts[product.categoryId!] = 1;
//                     }

//                     print(
//                         "Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");
//                     log("Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");
//                   });
//                   try {
//                     await AppDialogue.openLoadingDialogAfterClose(context,
//                         text: "Adding to cart...", load: () async {
//                       return await wishlistprovider.addToCart(
//                         fruitId: product.id!,
//                         categoryId: product.categoryId!,
//                         count: itemCounts[product.categoryId] ?? 0,
//                         token: token,
//                       );
//                     }, afterComplete: (resp) async {
//                       if (resp.status) {
//                         AppDialogue.toast(resp.data);
//                       }
//                     });
//                   } on Exception catch (e) {
//                     ExceptionHandler.showMessage(context, e);
//                   }
//                   //await dairyProvider.fetchAddToCart(token);
//                   // await recalculateTotalPrice();
//                 },
//                 onRemove: (product) async {
//                   setState(() {
//                     if ((itemCounts[product.categoryId!] ?? 0) > 0) {
//                       itemCounts[product.categoryId!] =
//                           (itemCounts[product.categoryId!] ?? 0) - 1;

//                       print(
//                           "Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");
//                       log("Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");

//                       recalculateTotalPrice();

//                       if (itemCounts[product.categoryId!] == 0) {
//                         isAdded[product.categoryId!] = false;
//                       }
//                     }
//                   });

//                   // Trigger the debounced API call
//                   _debounceApiCall(
//                     product.categoryId ?? '',
//                     itemCounts[product.categoryId!] ?? 0,
//                     token,
//                   );
//                 },
//                 onIncrease: (product) async {
//                   setState(() {
//                     itemCounts[product.categoryId!] =
//                         (itemCounts[product.categoryId!] ?? 0) + 1;

//                     print(
//                         "Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");
//                     log("Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}");

//                     recalculateTotalPrice();
//                   });

//                   // Trigger the debounced API call
//                   _debounceApiCall(
//                     product.categoryId ?? '',
//                     itemCounts[product.categoryId!] ?? 0,
//                     token,
//                   );
//                 },
//                 onFavoriteToggle: (product) async {
//                   setState(() {
//                     bool favoriteStatus =
//                         !(isFavorite[product.categoryId] ?? false);
//                     isFavorite[product.categoryId ?? ''] = favoriteStatus;

//                     print(
//                         'Product ID: ${product.id}, Name: ${product.name}, Favorite: $favoriteStatus');
//                     log('Product ID: ${product.id}, Name: ${product.name}, Favorite: $favoriteStatus');
//                   });
//                   try {
//                     await AppDialogue.openLoadingDialogAfterClose(
//                       context,
//                       text: "Adding Wish List...",
//                       load: () async {
//                         return await provider.addWishList(
//                           categoryId: product.categoryId!,
//                           token: token,
//                           isCondtion: isFavorite[product.categoryId] ?? false,
//                           productId: product.id!,
//                         );
//                       },
//                       afterComplete: (resp) async {
//                         if (resp.status) {
//                           AppDialogue.toast(resp.data);
//                         }
//                       },
//                     );
//                   } on Exception catch (e) {
//                     ExceptionHandler.showMessage(context, e);
//                   }
//                   await getprovider.fetchWishList(token);
//                 },
//                 isAdded: isAdded,
//                 itemCounts: itemCounts,
//                 isFavorite: isFavorite,
//                 recalculateTotalPrice: recalculateTotalPrice,
//                 fetchCart: () async {
//                   // await _fetchCartData();
//                 },
//               );
//             },
//           ),
//         ]),
//       ),
//     );
//   }

//   Future<void> recalculateTotalPrice() async {
//     double totalCurrentPrice = 0;
//     double totalOldPrice = 0;

//     // Simulating any potential asynchronous call if needed in the future
//     await Future.delayed(Duration.zero);

//     getprovider.getAddToCart.forEach((item) {
//       totalCurrentPrice += (item.currentPrice ?? 0.0) * (item.count ?? 0);
//       totalOldPrice += (item.oldPrice ?? 0.0) * (item.count ?? 0);
//     });

//     setState(() {
//       TotalCurrentPrice = totalCurrentPrice;
//       TotalOldPrice = totalOldPrice;
//       totalSavings = totalOldPrice - totalCurrentPrice;
//       // gstAmount = totalOldPrice * 0.03; // Calculate GST and store it
//     });
//   }

//   Widget shimmerSlotBox() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.green[300]!,
//       child: Container(
//         height: 250,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   height: 50,
//                   width: 50,
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(10)),
//                 )
//               ],
//             ),
//             Container(
//               height: 15,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool isLoading = true;
  List<ProductModel> wishlistProducts = [];
  
  @override
  void initState() {
    super.initState();
    _loadWishlistProducts();
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
      
      // Get wishlist products from provider
      final products = await context.read<GetProvider>().getWishlistProducts(customerId);
      
      setState(() {
        wishlistProducts = products;
        isLoading = false;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to remove item from wishlist')),
      );
      return;
    }
    
    // Call remove API
    final response = await context.read<GetProvider>().removeWishList(
      customerId: customerId,
      storeId: storeId,
      productId: productId,
    );
    
    if (response.status) {
      // Remove the product from local list
      setState(() {
        wishlistProducts.removeWhere((product) => product.id == productId);
      });
      
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Removed from wishlist')),
      // );
      AppDialogue.toast("Removed from wishlist");
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to remove from wishlist')),
      // );
      AppDialogue.toast("Failed to remove from wishlist");
    }
  } catch (e) {
    log('Error removing from wishlist: $e');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('An error occurred')),
    // );
    AppDialogue.toast("An error occurred");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(true), // ✅ Return true
      ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? _buildLoadingView()
              : wishlistProducts.isEmpty
                  ? _buildEmptyWishlist()
                  : _buildWishlistGrid(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColor.fillColor),
          const SizedBox(height: 16),
          Text(
            'Loading wishlist...',
            style: Styles.textStyleMedium(context, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: Styles.textStyleLarge(context, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your wishlist to see them here',
            style: Styles.textStyleMedium(context, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fillColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: wishlistProducts.length,
      itemBuilder: (context, index) {
        final product = wishlistProducts[index];
        return _buildWishlistItem(product);
      },
    );
  }

  Widget _buildWishlistItem(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: "${AppConstants.imageBaseUrl}/${product.productImage}",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
              
              // Product Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "₹${product.mrpPrice}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.fillColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.discountPrice != null && 
                            product.discountPrice != product.mrpPrice)
                          Text(
                            "₹${product.discountPrice}",
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.fillColor,
                        minimumSize: const Size(double.infinity, 36),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // Add to cart functionality
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeFromWishlist(product.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
