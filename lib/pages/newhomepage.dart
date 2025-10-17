// import 'dart:async';
// import 'dart:developer';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
// import 'package:fulupo/model/product_base_model.dart';
// import 'package:fulupo/pages/bottom_sheet/product_category_page.dart';
// import 'package:fulupo/pages/bottom_sheet_page.dart';
// import 'package:fulupo/pages/custom_drawar.dart';
// import 'package:fulupo/pages/gridview/gridview_page.dart';
// import 'package:fulupo/pages/profile_page.dart';
// import 'package:fulupo/pages/saved_address_list_bottomsheet.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/provider/user_provider.dart';
// import 'package:fulupo/route_genarator.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/util/constant_image.dart';
// import 'package:fulupo/util/exception.dart';
// import 'package:fulupo/widget/dilogue/dilogue.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String _address = "Loading...";

//   LatLng draggedLatLng = LatLng(0.0, 0.0);
//   int myCurrentIndex = 0;
//   String token = '';
//   // Add a key to control the Scaffold
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   //  String storeCode = '';

//   // List<GetfruitsCategoryModel> selectProduct = [];
//   // GetProvider

//   GetProvider get getprovider => context.read<GetProvider>();
//   UserProvider get provider => context.read<UserProvider>();

//   bool isItemAdded = false;
//   double TotalCurrentPrice = 0;
//   double TotalOldPrice = 0;
//   double totalSavings = 0;

//   Map<String, String> selectedWeights = {};
//   Map<String, int> itemCounts = {};

//   Map<String, bool> isFavorite = {};
//   Map<String, bool> isAdded = {};
//   // Map<String, int> productCount = {};
//   Map<String, Timer?> _debounceTimers = {};
//   String selectedAddress = '';

//   @override
//   void initState() {
//     super.initState();
//     _getLocationData();

//     // Listen for scroll events

//     _scrollController.addListener(() {
//       if (_scrollController.offset > 100 && !_isScrolled) {
//         setState(() {
//           _isScrolled = true; // Show the arrow button when scrolled
//         });
//       } else if (_scrollController.offset <= 100 && _isScrolled) {
//         setState(() {
//           _isScrolled =
//               false; // Hide the arrow button when scrolled back to the top
//         });
//       }
//     });

//     // getprovider.fetchBanner();
//     fetchCategories();
//     getData();

//     // _fetchCartData();
//   }

//   Future<void> getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String storeCode = prefs.getString(AppConstants.StoreCode) ?? '';
//     print('🔹 Store Code: $storeCode');

//     log('Store Code: $storeCode');

//     // await getprovider.fetchCategories(storeCode: storeCode);
//   }

//   @override
//   void dispose() {
//     // Dispose the ScrollController to free up resources
//     _scrollController.dispose();

//     super.dispose(); // Always call the superclass dispose() method
//     // Cancel all timers when the widget is disposed
//     for (var timer in _debounceTimers.values) {
//       timer?.cancel();
//     }
//     super.dispose();
//   }

//   Future<void> _getLocationData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     try {
//       // Retrieve latitude and longitude as doubles
//       double? latitude = prefs.getDouble(AppConstants.USERLATITUTE);
//       double? longitude = prefs.getDouble(AppConstants.USERLONGITUTE);
//       String? address = prefs.getString(AppConstants.USERADDRESS);
//       token = prefs.getString('token') ?? '';
//       selectedAddress = prefs.getString('SELECTED_ADDRESS_TYPE') ?? '';
//       print(token);
//       log('Token: $token');

//       if (latitude != null && longitude != null && address != null) {
//         // Update draggedLatLng with stored values
//         draggedLatLng = LatLng(latitude, longitude);

//         setState(() {
//           _address = address; // Update the state with the retrieved address
//         });
//       } else {
//         setState(() {
//           _address = "No address found."; // Update with a default message
//         });
//       }
//     } catch (e) {
//       print('Error retrieving location data: $e');
//       setState(() {
//         _address = "Error retrieving address."; // Update with error message
//       });
//     }
//     // await _fetchCartData();
//     // await _fetchWishlistData();
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
//     await getprovider.fetchAddToCart(token);
//     await recalculateTotalPrice();

//     //------------------------
//     // await getprovider.fetchVegetable();
//     // await getprovider.fetchDairy();
//   }

//   Future<void> _fetchWishlistData() async {
//     try {
//       // Fetch wishlist data
//       final wishlistData = await context.read<GetProvider>().fetchWishList(
//         token,
//       );

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

//   void _debounceApiCall(String categoryId, int count, String token) {
//     // Cancel any existing timer for the categoryId
//     if (_debounceTimers[categoryId] != null) {
//       _debounceTimers[categoryId]?.cancel();
//     }

//     // Start a new timer
//     _debounceTimers[categoryId] = Timer(const Duration(seconds: 1), () async {
//       try {
//         await AppDialogue.openLoadingDialogAfterClose(
//           context,
//           text: "Updating...",
//           load: () async {
//             return await getprovider.updateCart(
//               categoryId: categoryId,
//               count: count,
//               token: token,
//             );
//           },
//           afterComplete: (resp) async {
//             if (resp.status) {
//               AppDialogue.toast(resp.data);
//             }
//           },
//         );
//       } catch (e) {
//         ExceptionHandler.showMessage(context, e);
//       }

//       // Fetch updated cart data
//       await getprovider.fetchAddToCart(token);
//       await recalculateTotalPrice();
//     });
//   }

//   Future<void> storeLocationData(
//     double latitude,
//     double longitude,
//     String address,
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Store latitude and longitude as strings
//     await prefs.setString(AppConstants.USERLATITUTE, latitude.toString());
//     await prefs.setString(AppConstants.USERLONGITUTE, longitude.toString());
//     await prefs.setString(AppConstants.USERADDRESS, address);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       key: _scaffoldKey, // Set the key to the Scaffold
//       //  backgroundColor: AppColor.fillColor,
//       drawer: CustomDrawer(
//         screenHeight: screenHeight,
//         screenWidth: screenWidth,
//       ),
//       onDrawerChanged: (isOpened) async {
//         if (!isOpened) {
//           print("Drawer is closed-------------------");

//           await _fetchCartData();
//           await _fetchWishlistData();
//           await recalculateTotalPrice();
//         }
//       },
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/bg.jpg"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await _getLocationData();
//           },
//           color: AppColor.fillColor,
//           child: Stack(
//             children: [
//               SafeArea(
//                 child: Stack(
//                   children: [
//                     SingleChildScrollView(
//                       controller: _scrollController, // Attach controller
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 10,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       _scaffoldKey.currentState
//                                           ?.openDrawer(); // Open the drawer
//                                     },
//                                     child: const Icon(
//                                       Icons.menu,
//                                       color: AppColor.whiteColor,
//                                       size: 30,
//                                     ),
//                                   ),
//                                   SizedBox(width: 20),
//                                   SizedBox(width: 8),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             (selectedAddress.isEmpty ||
//                                                     selectedAddress == 'Home')
//                                                 ? Icons.home
//                                                 : selectedAddress == 'Work'
//                                                 ? Icons.work
//                                                 : selectedAddress == 'Hotel'
//                                                 ? Icons.hotel_rounded
//                                                 : Icons
//                                                       .location_on, // Default icon if none match
//                                             color: Colors.red,
//                                           ),
//                                           SizedBox(width: 10),
//                                           GestureDetector(
//                                             onTap: () async {
//                                               final val = await Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const SavedAddressListBottomsheet(
//                                                         page: 'Home',
//                                                       ),
//                                                 ),
//                                               );

//                                               if (val == "Yes") {
//                                                 print(
//                                                   '99999999999999999999999',
//                                                 );
//                                                 _getLocationData();
//                                               }
//                                               // _getLocationData();
//                                             },
//                                             child: Text(
//                                               selectedAddress,
//                                               style: Styles.textStyleMedium(
//                                                 context,
//                                                 color: AppColor.yellowColor,
//                                               ),
//                                               textScaleFactor: 1,
//                                             ),
//                                           ),
//                                           SizedBox(width: 5),
//                                           GestureDetector(
//                                             onTap: () async {
//                                               final val = await Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const SavedAddressListBottomsheet(
//                                                         page: 'Home',
//                                                       ),
//                                                 ),
//                                               );

//                                               if (val == "Yes") {
//                                                 print(
//                                                   '99999999999999999999999',
//                                                 );
//                                                 _getLocationData();
//                                               }
//                                             },
//                                             child: const Icon(
//                                               Icons.keyboard_arrow_down,
//                                               size: 35,
//                                               color: Color.fromARGB(
//                                                 255,
//                                                 36,
//                                                 35,
//                                                 35,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(
//                                         width: screenWidth * 0.6,
//                                         child: Text(
//                                           _address,
//                                           style: Styles.textStyleSmall(context),
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                           textScaleFactor: 1,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Spacer(),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => ProfilePage(),
//                                         ),
//                                       );
//                                     },
//                                     child: Icon(
//                                       Icons.person_2_rounded,
//                                       color: AppColor.whiteColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.02),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 15),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.3),
//                                     spreadRadius: 2,
//                                     blurRadius: 5,
//                                     offset: Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: SizedBox(
//                                 height: 40,
//                                 child: TextField(
//                                   controller: _searchController,
//                                   decoration: InputDecoration(
//                                     hintText: "Search...",
//                                     hintStyle: Styles.textStyleMedium(
//                                       context,
//                                       color: AppColor.hintTextColor,
//                                     ),
//                                     prefixIcon: Icon(
//                                       Icons.search,
//                                       color: AppColor.hintTextColor,
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: const BorderSide(
//                                         color: Colors.white,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: const BorderSide(
//                                         color: Colors.white,
//                                         width: 2,
//                                       ),
//                                     ),
//                                   ),
//                                   onChanged: (query) {
//                                     setState(() {
//                                       _searchQuery = query.toLowerCase();
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),

//                             SizedBox(height: screenHeight * 0.03),
//                             CarouselSlider(
//                               options: CarouselOptions(
//                                 autoPlay: false,
//                                 height: screenHeight * 0.12,
//                                 autoPlayInterval: const Duration(seconds: 5),
//                                 viewportFraction: 1,
//                                 enlargeCenterPage: true,
//                                 aspectRatio: 200,
//                                 onPageChanged: (index, reason) {
//                                   setState(() {
//                                     myCurrentIndex = index;
//                                   });
//                                 },
//                               ),
//                               items: getprovider.banner.map((banner) {
//                                 // if (getprovider.banner.isEmpty) {
//                                 //   shimmerSlotBox();
//                                 // }
//                                 return ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: CachedNetworkImage(
//                                     imageUrl: banner.Image!,
//                                     width: screenWidth * 0.9,
//                                     fit: BoxFit.cover,
//                                     placeholder: (context, url) => const Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                     errorWidget: (context, url, error) =>
//                                         const Icon(
//                                           Icons.error,
//                                           color: Colors.red,
//                                           size: 50,
//                                         ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             Center(
//                               child: AnimatedSmoothIndicator(
//                                 activeIndex: myCurrentIndex,
//                                 count: (getprovider.banner.isNotEmpty)
//                                     ? getprovider.banner.length
//                                     : 1,
//                                 effect: const JumpingDotEffect(
//                                   dotHeight: 5,
//                                   dotWidth: 5,
//                                   spacing: 5,
//                                   dotColor: Color.fromARGB(255, 172, 171, 171),
//                                   activeDotColor: AppColor.whiteColor,
//                                   paintStyle: PaintingStyle.fill,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.02),

//                             // Replace this section in your main build method (around line 570):
//                             Center(
//                               child: Text(
//                                 'Shop By Category',
//                                 style: Styles.textStyleLarge(
//                                   context,
//                                   color: AppColor.yellowColor,
//                                 ),
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.02),

//                             // Show loading state or category list
//                             if (isLoading)
//                               Container(
//                                 height: 100,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.33),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: const Center(
//                                   child: CircularProgressIndicator(
//                                     color: AppColor.yellowColor,
//                                   ),
//                                 ),
//                               )
//                             else
//                               buildCategoryList(),

//                             SizedBox(height: screenHeight * 0.02),

//                             Center(
//                               child: Text(
//                                 'Shop By Category',
//                                 style: Styles.textStyleLarge(
//                                   context,
//                                   color: AppColor.yellowColor,
//                                 ),
//                                 textScaler: TextScaler.linear(1),
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.02),

//                             // Show loading state
//                             visibleCategories.length < 3
//                                 ? const Center(
//                                     child: CircularProgressIndicator(),
//                                   ) // Prevent crash
//                                 : buildCategoryList(),

//                             SizedBox(height: screenHeight * 0.02),
//                             Center(
//                               child: Text(
//                                 'Upto 50% Off',
//                                 style: Styles.textStyleLarge(
//                                   context,
//                                   color: AppColor.yellowColor,
//                                 ),
//                                 textScaleFactor: 1.0,
//                               ),
//                             ),

//                             SizedBox(height: screenHeight * 0.03),
//                             Consumer<GetProvider>(
//                               builder: (context, allproductprovider, child) {
//                                 if (isLoading) {
//                                   return Center(
//                                     child:
//                                         CircularProgressIndicator(), // Show loader
//                                   );
//                                 }

//                                 // 🔥 Filter products based on search query
//                                 List<Product>
//                                 filteredProducts = allproductprovider.getproduct
//                                     .where(
//                                       (getproduct) =>
//                                           getproduct.name
//                                               ?.toLowerCase()
//                                               .contains(_searchQuery) ??
//                                           false,
//                                     )
//                                     .map((getproduct) {
//                                       return Product(
//                                         id: getproduct.id,
//                                         categoryId: getproduct.subcategoryid,
//                                         name: getproduct.name,
//                                         subname: getproduct.subname,
//                                         image: getproduct.image,
//                                         weights: getproduct.quantity,
//                                         currentPrice: getproduct.currentPrice,
//                                         oldPrice: getproduct.oldPrice,
//                                         count: getproduct.count,
//                                       );
//                                     })
//                                     .toList();

//                                 if (filteredProducts.isEmpty) {
//                                   return Center(
//                                     child: Lottie.asset(
//                                       "assets/map_pin/search_empty.json",
//                                       height: screenHeight * 0.2,
//                                       width: screenWidth * 0.9,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   );
//                                 }

//                                 return ProductGridView(
//                                   products:
//                                       filteredProducts, // ✅ Pass only matching products
//                                   onProductTap: (product) async {
//                                     print('hello');
//                                     final value = await showModalBottomSheet(
//                                       context: context,
//                                       isScrollControlled: true,
//                                       backgroundColor: Colors.transparent,
//                                       builder: (BuildContext context) {
//                                         return ProductCategoryPage(
//                                           categoryId: product.categoryId!,
//                                         );
//                                       },
//                                     );
//                                     if (value == 'Yes') {
//                                       print('ggggggggggggggggggggggg');
//                                       _getLocationData();
//                                     }
//                                   },
//                                   onAdd: (product) async {
//                                     setState(() {
//                                       if (!(isAdded[product.categoryId] ??
//                                           false)) {
//                                         isAdded[product.categoryId!] = true;
//                                         itemCounts[product.categoryId!] = 1;
//                                       } else {
//                                         itemCounts[product.categoryId!] = 1;
//                                       }
//                                       print(
//                                         "Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                       );
//                                       log(
//                                         "Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                       );
//                                     });

//                                     try {
//                                       await AppDialogue.openLoadingDialogAfterClose(
//                                         context,
//                                         text: "Adding to cart...",
//                                         load: () async {
//                                           return await allproductprovider
//                                               .addToCart(
//                                                 fruitId: product.id!,
//                                                 categoryId: product.categoryId!,
//                                                 count:
//                                                     itemCounts[product
//                                                         .categoryId] ??
//                                                     0,
//                                                 token: token,
//                                               );
//                                         },
//                                         afterComplete: (resp) async {
//                                           if (resp.status) {
//                                             AppDialogue.toast(resp.data);
//                                           }
//                                         },
//                                       );
//                                     } on Exception catch (e) {
//                                       ExceptionHandler.showMessage(context, e);
//                                     }

//                                     await allproductprovider.fetchAddToCart(
//                                       token,
//                                     );
//                                     await recalculateTotalPrice();
//                                   },
//                                   onRemove: (product) async {
//                                     setState(() {
//                                       if ((itemCounts[product.categoryId!] ??
//                                               0) >
//                                           0) {
//                                         itemCounts[product.categoryId!] =
//                                             (itemCounts[product.categoryId!] ??
//                                                 0) -
//                                             1;

//                                         print(
//                                           "Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                         );
//                                         log(
//                                           "Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                         );

//                                         recalculateTotalPrice();

//                                         if (itemCounts[product.categoryId!] ==
//                                             0) {
//                                           isAdded[product.categoryId!] = false;
//                                         }
//                                       }
//                                     });

//                                     _debounceApiCall(
//                                       product.categoryId ?? '',
//                                       itemCounts[product.categoryId!] ?? 0,
//                                       token,
//                                     );
//                                   },
//                                   onIncrease: (product) async {
//                                     setState(() {
//                                       itemCounts[product.categoryId!] =
//                                           (itemCounts[product.categoryId!] ??
//                                               0) +
//                                           1;

//                                       print(
//                                         "Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                       );
//                                       log(
//                                         "Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.categoryId!]}",
//                                       );

//                                       recalculateTotalPrice();
//                                     });

//                                     _debounceApiCall(
//                                       product.categoryId ?? '',
//                                       itemCounts[product.categoryId!] ?? 0,
//                                       token,
//                                     );
//                                   },
//                                   onFavoriteToggle: (product) async {
//                                     setState(() {
//                                       bool favoriteStatus =
//                                           !(isFavorite[product.categoryId] ??
//                                               false);
//                                       isFavorite[product.categoryId ?? ''] =
//                                           favoriteStatus;

//                                       print(
//                                         'Product ID: ${product.id}, Name: ${product.name}, Favorite: $favoriteStatus',
//                                       );
//                                       log(
//                                         'Product ID: ${product.id}, Name: ${product.name}, Favorite: $favoriteStatus',
//                                       );
//                                     });

//                                     try {
//                                       await AppDialogue.openLoadingDialogAfterClose(
//                                         context,
//                                         text: "Adding Wish List...",
//                                         load: () async {
//                                           return await provider.addWishList(
//                                             categoryId: product.categoryId!,
//                                             token: token,
//                                             isCondtion:
//                                                 isFavorite[product
//                                                     .categoryId] ??
//                                                 false,
//                                             productId: product.id!,
//                                           );
//                                         },
//                                         afterComplete: (resp) async {
//                                           if (resp.status) {
//                                             AppDialogue.toast(resp.data);
//                                           }
//                                         },
//                                       );
//                                     } on Exception catch (e) {
//                                       ExceptionHandler.showMessage(context, e);
//                                     }
//                                   },
//                                   isAdded: isAdded,
//                                   itemCounts: itemCounts,
//                                   isFavorite: isFavorite,
//                                   recalculateTotalPrice: recalculateTotalPrice,
//                                   fetchCart: () async {
//                                     await _fetchCartData();
//                                   },
//                                 );
//                               },
//                             ),
//                             // ===== Upto 50% Off =====
//                             SizedBox(height: screenHeight * 0.02),
//                             Center(
//                               child: Text(
//                                 'Upto 50% Off',
//                                 style: Styles.textStyleLarge(
//                                   context,
//                                   color: AppColor.yellowColor,
//                                 ),
//                                 textScaleFactor: 1.0,
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.03),

//                             if (visibleCategories.isNotEmpty &&
//                                 visibleCategories.length > 2)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Category name header
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0,
//                                     ),
//                                     child: Text(
//                                       visibleCategories[2]
//                                           .categoryName, // Middle selected category
//                                       style: Styles.textStyleLarge(
//                                         context,
//                                         color: AppColor.whiteColor,
//                                       ),
//                                       textScaleFactor: 1,
//                                     ),
//                                   ),

//                                   SizedBox(height: screenHeight * 0.015),

//                                   // Products grid
//                                   Consumer<GetProvider>(
//                                     builder: (context, provider, child) {
//                                       final selectedCategory =
//                                           visibleCategories[2];
//                                       final categoryProducts =
//                                           selectedCategory.products;

//                                       // Filter products based on search query
//                                       final filteredProducts = categoryProducts
//                                           .where((product) {
//                                             return product.name
//                                                 .toLowerCase()
//                                                 .contains(_searchQuery);
//                                           })
//                                           .toList();

//                                       if (filteredProducts.isEmpty) {
//                                         return Container(
//                                           height: screenHeight * 0.15,
//                                           child: Center(
//                                             child: _searchQuery.isNotEmpty
//                                                 ? Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Icon(
//                                                         Icons.search_off,
//                                                         size: 40,
//                                                         color: AppColor
//                                                             .whiteColor
//                                                             .withOpacity(0.7),
//                                                       ),
//                                                       SizedBox(height: 8),
//                                                       Text(
//                                                         'No products found',
//                                                         style:
//                                                             Styles.textStyleMedium(
//                                                               context,
//                                                               color: AppColor
//                                                                   .whiteColor
//                                                                   .withOpacity(
//                                                                     0.7,
//                                                                   ),
//                                                             ),
//                                                       ),
//                                                     ],
//                                                   )
//                                                 : Text(
//                                                     'No products available',
//                                                     style:
//                                                         Styles.textStyleMedium(
//                                                           context,
//                                                           color: AppColor
//                                                               .whiteColor
//                                                               .withOpacity(0.7),
//                                                         ),
//                                                   ),
//                                           ),
//                                         );
//                                       }

//                                       return GridView.builder(
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 8,
//                                         ),
//                                         itemCount: filteredProducts.length,
//                                         gridDelegate:
//                                             const SliverGridDelegateWithFixedCrossAxisCount(
//                                               crossAxisCount: 2,
//                                               childAspectRatio: 0.78,
//                                               crossAxisSpacing: 10,
//                                               mainAxisSpacing: 10,
//                                             ),
//                                         itemBuilder: (context, index) {
//                                           final product =
//                                               filteredProducts[index];

//                                           // Build image URL
//                                           final imageUrl =
//                                               product.productImage.startsWith(
//                                                 'http',
//                                               )
//                                               ? product.productImage
//                                               : 'https://fulupostore.tsitcloud.com/${product.productImage}';

//                                           // Calculate discount percentage
//                                           final discountPercent =
//                                               product.discountPrice != null
//                                               ? ((product.mrpPrice -
//                                                         product
//                                                             .discountPrice!) /
//                                                     product.mrpPrice *
//                                                     100)
//                                               : 0.0;

//                                           return InkWell(
//                                             onTap: () async {
//                                               final value =
//                                                   await showModalBottomSheet(
//                                                     context: context,
//                                                     isScrollControlled: true,
//                                                     backgroundColor:
//                                                         Colors.transparent,
//                                                     builder: (context) =>
//                                                         ProductCategoryPage(
//                                                           categoryId:
//                                                               product.id,
//                                                         ),
//                                                   );
//                                               if (value == 'Yes') {
//                                                 await _getLocationData();
//                                               }
//                                             },
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.black
//                                                         .withOpacity(0.1),
//                                                     blurRadius: 6,
//                                                     offset: const Offset(0, 2),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   // Product image with discount badge
//                                                   Expanded(
//                                                     flex: 3,
//                                                     child: Stack(
//                                                       children: [
//                                                         ClipRRect(
//                                                           borderRadius:
//                                                               const BorderRadius.vertical(
//                                                                 top:
//                                                                     Radius.circular(
//                                                                       12,
//                                                                     ),
//                                                               ),
//                                                           child: CachedNetworkImage(
//                                                             imageUrl: imageUrl,
//                                                             width:
//                                                                 double.infinity,
//                                                             fit: BoxFit.cover,
//                                                             placeholder:
//                                                                 (
//                                                                   context,
//                                                                   url,
//                                                                 ) => Container(
//                                                                   color: Colors
//                                                                       .grey[200],
//                                                                   child: const Center(
//                                                                     child: CircularProgressIndicator(
//                                                                       strokeWidth:
//                                                                           2,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                             errorWidget:
//                                                                 (
//                                                                   context,
//                                                                   url,
//                                                                   error,
//                                                                 ) => Container(
//                                                                   color: Colors
//                                                                       .grey[200],
//                                                                   child: const Icon(
//                                                                     Icons
//                                                                         .broken_image,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     size: 40,
//                                                                   ),
//                                                                 ),
//                                                           ),
//                                                         ),

//                                                         // Discount badge
//                                                         if (discountPercent > 0)
//                                                           Positioned(
//                                                             top: 8,
//                                                             left: 8,
//                                                             child: Container(
//                                                               padding:
//                                                                   const EdgeInsets.symmetric(
//                                                                     horizontal:
//                                                                         6,
//                                                                     vertical: 3,
//                                                                   ),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                     color: Colors
//                                                                         .red,
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                           4,
//                                                                         ),
//                                                                   ),
//                                                               child: Text(
//                                                                 '${discountPercent.toStringAsFixed(0)}% OFF',
//                                                                 style:
//                                                                     Styles.textStyleSmall(
//                                                                       context,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ).copyWith(
//                                                                       fontSize:
//                                                                           10,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                           ),

//                                                         // Stock status
//                                                         if (product
//                                                                 .showAvlQty <=
//                                                             0)
//                                                           Positioned(
//                                                             bottom: 8,
//                                                             right: 8,
//                                                             child: Container(
//                                                               padding:
//                                                                   const EdgeInsets.symmetric(
//                                                                     horizontal:
//                                                                         6,
//                                                                     vertical: 3,
//                                                                   ),
//                                                               decoration: BoxDecoration(
//                                                                 color: Colors
//                                                                     .red
//                                                                     .withOpacity(
//                                                                       0.9,
//                                                                     ),
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       4,
//                                                                     ),
//                                                               ),
//                                                               child: Text(
//                                                                 'Out of Stock',
//                                                                 style:
//                                                                     Styles.textStyleSmall(
//                                                                       context,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ).copyWith(
//                                                                       fontSize:
//                                                                           10,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                       ],
//                                                     ),
//                                                   ),

//                                                   // Product details
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                             8.0,
//                                                           ),
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           // Product name
//                                                           Text(
//                                                             product.name,
//                                                             maxLines: 2,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             style:
//                                                                 Styles.textStyleMedium(
//                                                                   context,
//                                                                   color: Colors
//                                                                       .black87,
//                                                                 ).copyWith(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600,
//                                                                 ),
//                                                           ),

//                                                           const Spacer(),

//                                                           // Price row
//                                                           Row(
//                                                             children: [
//                                                               // Current price
//                                                               Text(
//                                                                 '₹${(product.discountPrice ?? product.mrpPrice).toStringAsFixed(0)}',
//                                                                 style:
//                                                                     Styles.textStyleMedium(
//                                                                       context,
//                                                                       color: AppColor
//                                                                           .fillColor,
//                                                                     ).copyWith(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                     ),
//                                                               ),

//                                                               const SizedBox(
//                                                                 width: 6,
//                                                               ),

//                                                               // Original price (if discounted)
//                                                               if (product.discountPrice !=
//                                                                       null &&
//                                                                   product.discountPrice! <
//                                                                       product
//                                                                           .mrpPrice)
//                                                                 Text(
//                                                                   '₹${product.mrpPrice.toStringAsFixed(0)}',
//                                                                   style:
//                                                                       Styles.textStyleSmall(
//                                                                         context,
//                                                                         color: AppColor
//                                                                             .pinkColor,
//                                                                       ).copyWith(
//                                                                         decoration:
//                                                                             TextDecoration.lineThrough,
//                                                                       ),
//                                                                 ),

//                                                               const Spacer(),

//                                                               // Add to cart button or stock info
//                                                               product.showAvlQty >
//                                                                       0
//                                                                   ? GestureDetector(
//                                                                       onTap: () {
//                                                                         // Add your add to cart logic here
//                                                                         print(
//                                                                           'Add to cart: ${product.name}',
//                                                                         );
//                                                                       },
//                                                                       child: Container(
//                                                                         padding:
//                                                                             const EdgeInsets.all(
//                                                                               6,
//                                                                             ),
//                                                                         decoration: BoxDecoration(
//                                                                           color:
//                                                                               AppColor.fillColor,
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(
//                                                                                 6,
//                                                                               ),
//                                                                         ),
//                                                                         child: const Icon(
//                                                                           Icons
//                                                                               .add,
//                                                                           color:
//                                                                               Colors.white,
//                                                                           size:
//                                                                               16,
//                                                                         ),
//                                                                       ),
//                                                                     )
//                                                                   : Text(
//                                                                       'N/A',
//                                                                       style:
//                                                                           Styles.textStyleSmall(
//                                                                             context,
//                                                                             color:
//                                                                                 Colors.red,
//                                                                           ).copyWith(
//                                                                             fontWeight:
//                                                                                 FontWeight.w500,
//                                                                           ),
//                                                                     ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),

//                             if (TotalCurrentPrice != 0)
//                               SizedBox(height: screenHeight * 0.13),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (_isScrolled) // Show the arrow button only if scrolled
//                       Positioned(
//                         bottom: 130,
//                         right: 10,
//                         child: GestureDetector(
//                           onTap: () {
//                             // Scroll to the top when the arrow button is tapped
//                             _scrollController.animateTo(
//                               0, // Scroll to the top
//                               duration: Duration(milliseconds: 500),
//                               curve: Curves.easeInOut,
//                             );
//                           },
//                           child: Container(
//                             height: 40,
//                             width: 40,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.black.withOpacity(0.4),
//                             ),
//                             child: const Icon(
//                               Icons.arrow_upward,
//                               color: AppColor.yellowColor,
//                               size: 25,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               // Conditionally show the floating bottom container if any item is added
//               if (TotalCurrentPrice != 0)
//                 Positioned(
//                   bottom: 10,
//                   left: 0,
//                   right: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.topCenter,
//                             child: GestureDetector(
//                               onTap: () async {
//                                 // Show BottomSheet with the updated list of products
//                                 final value = await showModalBottomSheet(
//                                   context: context,
//                                   isScrollControlled: true,
//                                   builder: (BuildContext context) {
//                                     return BottomSheetWidget();
//                                   },
//                                 );
//                                 if (value == 'Yes') {
//                                   print('ggggggggggggggggggggggg');
//                                   await _getLocationData();
//                                 }
//                               },
//                               child: Container(
//                                 height: 30,
//                                 width: 30,
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       blurRadius: 8,
//                                       color: Colors.grey,
//                                       offset: Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_drop_up_outlined,
//                                   color: AppColor.fillColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               // Image Container
//                               Container(
//                                 height: 60,
//                                 width: 60,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                   image: const DecorationImage(
//                                     image: AssetImage(
//                                       ConstantImageKey.vegitable,
//                                     ), // Your image logic here
//                                     fit: BoxFit.cover,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.5),
//                                       spreadRadius: 2,
//                                       blurRadius: 5,
//                                       offset: Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 20),
//                               // Column with Item Info
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Display the number of items and total price
//                                   FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       '${getprovider.getAddToCart.length} Item${getprovider.getAddToCart.length > 1 ? 's' : ''} | ₹${TotalCurrentPrice.toStringAsFixed(2)}',
//                                       style: Styles.textStyleMedium(
//                                         context,
//                                         color: AppColor.blackColor,
//                                       ),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                   ),
//                                   // Display the saved amount
//                                   FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       'You Saved ₹${totalSavings.toStringAsFixed(2)}',
//                                       style: Styles.textStyleSmall(
//                                         context,
//                                         color: AppColor.fillColor,
//                                       ),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Spacer(),
//                               // Cart Button
//                               GestureDetector(
//                                 onTap: () {
//                                   AppRouteName.apppage.push(context, args: 0);
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 10,
//                                     horizontal: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: AppColor.fillColor,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       'Go to Cart',
//                                       style: Styles.textStyleSmall(
//                                         context,
//                                         color: AppColor.whiteColor,
//                                       ),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               Container(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // List<GetallCategoryModel> allCategories = [];
//   // List<GetallCategoryModel> visibleCategories = [];
//   List<GetAllCategoryModel> allCategories = [];
//   List<GetAllCategoryModel> visibleCategories = [];
//   int currentIndex = 2; // Middle index
//   bool isLoading = true; // Track API loading state // Middle index
//   Future<void> fetchCategories() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String storeCode = prefs.getString(AppConstants.StoreCode) ?? '';
//     print('🔹 Store Code: $storeCode');

//     try {
//       await getprovider.fetchCategories(storeCode: storeCode);

//       if (mounted) {
//         setState(() {
//           // Filter out categories with empty products arrays
//           allCategories = getprovider.category
//               .where((category) => category.products.isNotEmpty)
//               .toList();

//           if (allCategories.isNotEmpty) {
//             visibleCategories = allCategories.length >= 5
//                 ? allCategories.take(5).toList()
//                 : List.from(allCategories);
//           } else {
//             // Handle case where no categories have products
//             visibleCategories = [];
//           }

//           isLoading = false; // API call completed
//         });
//       }
//     } catch (e) {
//       print("Error fetching categories: $e");
//       if (mounted) {
//         setState(() {
//           isLoading = false; // API call failed
//         });
//       }
//     }

//     // Only call _handleIndexChange if we have categories with products
//     if (visibleCategories.isNotEmpty) {
//       _handleIndexChange();
//     }
//   }
//   // Future<void> fetchCategories() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String storeCode = prefs.getString(AppConstants.StoreCode) ?? '';
//   //   print('🔹 Store Code: $storeCode');
//   //   try {
//   //     await getprovider.fetchCategories(storeCode: storeCode);
//   //     if (mounted) {
//   //       setState(() {
//   //         allCategories = List.from(getprovider.category);

//   //         if (allCategories.isNotEmpty) {
//   //           visibleCategories = allCategories.length >= 5
//   //               ? allCategories.take(5).toList()
//   //               : List.from(allCategories);
//   //         }

//   //         isLoading = false; // API call completed
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error fetching categories: $e");
//   //     if (mounted) {
//   //       setState(() {
//   //         isLoading = false; // API call failed
//   //       });
//   //     }
//   //   }
//   //   _handleIndexChange();
//   // }

//   void scrollRight() {
//     if (allCategories.length < 5) return;

//     setState(() {
//       if (allCategories.length == 5) {
//         // Rotate cyclically for exactly 5 items
//         // GetallCategoryModel first = visibleCategories.removeAt(0);
//         GetAllCategoryModel first = visibleCategories.removeAt(0);
//         visibleCategories.add(first);
//       } else {
//         // Normal scrolling for more than 5 items
//         // GetallCategoryModel first = visibleCategories.removeAt(0);
//         GetAllCategoryModel first = visibleCategories.removeAt(0);
//         int nextIndex =
//             (allCategories.indexOf(visibleCategories.last) + 1) %
//             allCategories.length;
//         visibleCategories.add(allCategories[nextIndex]);
//       }
//     });

//     _handleIndexChange();
//   }

//   void scrollLeft() {
//     if (allCategories.length < 5) return;

//     setState(() {
//       if (allCategories.length == 5) {
//         // Rotate cyclically for exactly 5 items
//         GetAllCategoryModel last = visibleCategories.removeLast();
//         visibleCategories.insert(0, last);
//       } else {
//         // Normal scrolling for more than 5 items
//         GetAllCategoryModel last = visibleCategories.removeLast();
//         int prevIndex =
//             (allCategories.indexOf(visibleCategories.first) -
//                 1 +
//                 allCategories.length) %
//             allCategories.length;
//         visibleCategories.insert(0, allCategories[prevIndex]);
//       }
//     });

//     _handleIndexChange();
//   }

//   // Handle the API call based on the current index
//   Future<void> _handleIndexChange() async {
//     if (visibleCategories.length < 3) return; // Prevent RangeError

//     setState(() {
//       isLoading = true; // Start loading indicator before API call
//     });

//     currentIndex = 2;
//     String currentCategory = visibleCategories[currentIndex].categoryName!;
//     String currentCategoryId = visibleCategories[currentIndex].id!;

//     print(
//       "Current Index: $currentIndex, Category: $currentCategory.  $currentCategoryId",
//     );
//     log(
//       "Current Index: $currentIndex, Category: $currentCategory.  $currentCategoryId",
//     );

//     try {
//       await getprovider.fetchProduct(currentCategoryId);
//     } catch (e) {
//       print("Error fetching product: $e");
//       log("Error fetching product: $e");
//     } finally {
//       setState(() {
//         isLoading = false; // Stop loading indicator after API call
//       });
//     }
//   }

//   // Container for normal image display
//   Widget buildImageContainer(GetAllCategoryModel category) {
//     final String imageUrl = category.categoryimage ?? '';

//     return Container(
//       height: 50,
//       width: 50,
//       decoration: BoxDecoration(
//         color: AppColor.fillColor,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: imageUrl.isNotEmpty
//             ? Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   // ✅ Fallback if image fails to load
//                   return const Icon(
//                     Icons.image_not_supported_outlined,
//                     size: 30,
//                     color: Colors.grey,
//                   );
//                 },
//               )
//             : const Icon(
//                 Icons.image_outlined, // ✅ Fallback if URL is empty
//                 size: 30,
//                 color: Colors.grey,
//               ),
//       ),
//     );
//   }

//   Widget buildCategoryList() {
//     // Handle case where no categories have products
//     if (visibleCategories.isEmpty) {
//       return Container(
//         height: 100,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.33),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Center(
//           child: Text(
//             'No categories with products available',
//             style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     return GestureDetector(
//       onHorizontalDragEnd: (details) {
//         if (details.primaryVelocity! < 0) {
//           scrollRight();
//         } else if (details.primaryVelocity! > 0) {
//           scrollLeft();
//         }
//       },
//       child: Container(
//         height: 100,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.33),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List.generate(visibleCategories.length, (index) {
//             return GestureDetector(
//               onTap: () => selectIndex(index),
//               child: index == 2
//                   ? buildAnimatedContainer(visibleCategories[index])
//                   : buildImageContainer(visibleCategories[index]),
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   // Widget buildCategoryList() {
//   //   return GestureDetector(
//   //     onHorizontalDragEnd: (details) {
//   //       if (details.primaryVelocity! < 0) {
//   //         scrollRight();
//   //       } else if (details.primaryVelocity! > 0) {
//   //         scrollLeft();
//   //       }
//   //     },
//   //     child: Container(
//   //       height: 100,
//   //       width: double.infinity,
//   //       decoration: BoxDecoration(
//   //         color: Colors.black.withOpacity(0.33),
//   //         borderRadius: BorderRadius.circular(20),
//   //       ),
//   //       child: Row(
//   //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //         children: List.generate(visibleCategories.length, (index) {
//   //           return GestureDetector(
//   //             onTap: () => selectIndex(index),
//   //             child: index == 2
//   //                 ? buildAnimatedContainer(visibleCategories[index])
//   //                 : buildImageContainer(visibleCategories[index]),
//   //           );
//   //         }),
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Container for the animated middle image

//   Widget buildAnimatedContainer(GetAllCategoryModel category) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
//       width: 70,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 2,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 50,
//             width: 50,
//             // decoration: BoxDecoration(
//             //   borderRadius: BorderRadius.circular(10),
//             //   image: DecorationImage(
//             //     image: NetworkImage(category.image!),
//             //     fit: BoxFit.cover,
//             //   ),
//             // ),
//           ),
//           SizedBox(height: 8),
//           Expanded(
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 category.categoryName!,
//                 style: Styles.textStyleSmall(
//                   context,
//                   color: AppColor.fillColor,
//                 ).copyWith(fontWeight: FontWeight.bold),
//                 textScaleFactor: 1.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void selectIndex(int index) {
//     if (index == 2 || visibleCategories.isEmpty) return;

//     setState(() {
//       GetAllCategoryModel temp = visibleCategories[index];
//       visibleCategories[index] = visibleCategories[2];
//       visibleCategories[2] = temp;
//     });

//     _handleIndexChange();
//   }

//   Widget shimmerSlotBox() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[300]!,
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
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ],
//             ),
//             Container(
//               height: 15,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Select an image directly by its index
// }
