// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fulupo/components/button.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/pages/bottom_sheet/product_category_page.dart';
// import 'package:fulupo/pages/delivery_map_pages.dart';
// import 'package:fulupo/pages/order_type_page.dart';
// import 'package:fulupo/pages/product_cart_widget.dart';
// import 'package:fulupo/pages/saved_address_list_bottomsheet.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/provider/user_provider.dart';
// import 'package:fulupo/route_genarator.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/util/exception.dart';
// import 'package:fulupo/widget/dilogue/dilogue.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({
//     super.key,
//   });

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   String mobile = '';
//   String name = '';
//   bool isAddress = false;
//   String token = '';
//   double TotalCurrentPrice = 0;
//   double TotalOldPrice = 0;
//   double totalSavings = 0;
//   double gstAmount = 0;
//   String _address = "Loading..."; // Default value
//   LatLng draggedLatLng = LatLng(0.0, 0.0);
//   String Delmobile = '';
//   String Delname = '';
//   bool isEditing = false;
//   String selectedAddress = '';
//   String updatedName = '';
//   String updatedMobile = '';
//   Timer? _debounce; // Timer to debounce API calls
//   String orderAddress = '';
// //  String _address = "Loading..."; // Default value
//   String flatHouseNo = '';
//   String landmark = '';
//   String updatedFlatHouseNo = '';
//   String updatedLandmark = '';
//   bool isLoading = true;
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController flatHouseNoController = TextEditingController();
//   final TextEditingController landmarkController =
//       TextEditingController(); // New controller

//   Map<String, Timer?> _debounceTimers = {};

//   GetProvider get getprovider => context.read<GetProvider>();
//   UserProvider get provider => context.read<UserProvider>();

//   // Product states for each item (like Carrot, Potato, etc.)
//   Map<String, int> itemCounts = {};

//   Map<String, bool> isFavorite = {};
//   Map<String, bool> isAdded = {};

//   void _onCountChanged(int newCount, item) {
//     // Cancel the previous timer if it exists
//     _debounce?.cancel();

//     // Set a new timer for 1 second
//     _debounce = Timer(const Duration(seconds: 1), () async {
//       // Trigger the API call here after the debounce delay
//       try {
//         await AppDialogue.openLoadingDialogAfterClose(context,
//             text: "Loading...", load: () async {
//           return await getprovider.updateCart(
//               categoryId: item.fruitCategoryId ?? '',
//               count: newCount,
//               token: token);
//         }, afterComplete: (resp) async {
//           if (resp.status) {
//             print("Success");
//             AppDialogue.toast(resp.data);
//           }
//         });
//       } catch (e) {
//         ExceptionHandler.showMessage(context, e);
//       }
//       await getprovider.fetchAddToCart(token);
//       await _fetchCartData();
//     });
//   }

//   getdata() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
//       name = prefs.getString(AppConstants.USERNAME) ?? '';
//       // Fetch using new keys
//       Delmobile = prefs.getString('SELECTED_MOBILE') ?? '';
//       Delname = prefs.getString('SELECTED_USER_NAME') ?? '';
//       selectedAddress = prefs.getString('SELECTED_ADDRESS_TYPE') ?? '';
//       flatHouseNo = prefs.getString('SELECTED_FLAT_HOUSE_NO') ??
//           ''; // Fetch flat/house no.
//       landmark = prefs.getString('SELECTED_LANDMARK') ?? ''; // Fetch landmark
//       nameController.text = Delname;
//       mobileController.text = Delmobile;
//       flatHouseNoController.text = flatHouseNo; // Set text for flat/house no.
//       landmarkController.text = landmark; // Set text for landmark
//       token = prefs.getString(AppConstants.token) ?? '';
//       orderAddress = prefs.getString(AppConstants.USERADDRESS) ?? '';
//       print(token);
//       log('Token: $token');

//       print(selectedAddress);
//       print(landmark);
//     });
//     print(mobile);
//     await getprovider.fetchOrderAddress(token);
//     await getprovider.getCart();

//     await _fetchDataRandom();

//     await _fetchCartData();

//     await recalculateTotalPrice();
//   }

//   Future<void> saveAddressToPrefs(String address) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('SELECTED__ADDRESS', address);
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
//       gstAmount = totalOldPrice * 0.03; // Calculate GST and store it
//     });
//   }

//   Future<void> _getLocationData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     try {
//       // Retrieve latitude and longitude as doubles
//       double? latitude = prefs.getDouble(AppConstants.USERLATITUTE);
//       double? longitude = prefs.getDouble(AppConstants.USERLONGITUTE);
//       String? address = prefs.getString(AppConstants.USERADDRESS);

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
//   }

//   Future<void> _fetchDataRandom() async {
//     final stopwatch = Stopwatch()..start(); // Start timer

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final cartData = await context.read<GetProvider>().fetchAddToCart(token);

//       final List<String> fruitIds = [];
//       for (var item in cartData) {
//         if (item.fruitsId != null && item.fruitsId!.isNotEmpty) {
//           fruitIds.add(item.fruitsId!);
//         }
//       }

//       print('Fruit IDs: $fruitIds');

//       if (fruitIds.isNotEmpty) {
//         await context.read<GetProvider>().fetchRandomProduct(fruitIds);
//       } else {
//         print('No valid fruit IDs found');
//       }
//     } catch (e) {
//       print('Error fetching cart data: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });

//       stopwatch.stop(); // Stop timer
//       print('Execution Time: ${stopwatch.elapsedMilliseconds} ms'); // Log time
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
//     await getprovider.fetchAddToCart(token);
//     await recalculateTotalPrice();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getdata();
//     _getLocationData();
//     recalculateTotalPrice();
//   }

//   @override
//   void dispose() {
//     // Dispose of the timer when the widget is disposed
//     _debounce?.cancel();
//     for (var timer in _debounceTimers.values) {
//       timer?.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;

//     final lastAddress = getprovider.getOrderAddress.isNotEmpty
//         ? getprovider.getOrderAddress.last
//         : null;

//     bool isExistingAddressEmpty = selectedAddress.isEmpty ||
//         flatHouseNo.isEmpty ||
//         orderAddress.isEmpty ||
//         landmark.isEmpty ||
//         Delname.isEmpty ||
//         Delmobile.isEmpty;

//     if (isExistingAddressEmpty && lastAddress != null) {
//       saveAddressToPrefs(lastAddress.addressLine ?? '');
//     }

//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       body: getprovider.getAddToCart.isEmpty
//           ? RefreshIndicator(
//               onRefresh: () async {
//                 await getprovider.fetchAddToCart(token);
//                 recalculateTotalPrice();
//                 _fetchDataRandom();
//               },
//               color: AppColor.fillColor,
//               child: Center(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: screenHeight * 0.12,
//                     ),
//                     Lottie.asset("assets/map_pin/emptycart.json",
//                         height: screenHeight * 0.3,
//                         width: screenWidth * 0.9,
//                         fit: BoxFit.cover),
//                     Text(
//                       'Your cart is empty',
//                       style: TextStyle(fontSize: 18),
//                       textScaleFactor: 1.0,
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.04,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         AppRouteName.apppage.push(context, args: 1);
//                       },
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                         decoration: BoxDecoration(
//                             color: AppColor.whiteColor,
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Text(
//                           'Go To Home',
//                           style: Styles.textStyleMedium(context,
//                               color: Colors.black),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await getprovider.fetchAddToCart(token);
//                 recalculateTotalPrice();
//               },
//               color: AppColor.fillColor,
//               child: Stack(
//                 children: [
//                   SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8.0, horizontal: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: screenHeight * 0.03,
//                           ),

//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               'Cart Page',
//                               style: Styles.textStyleMedium(context,
//                                   color: AppColor.whiteColor),
//                             ),
//                           ),
//                           SizedBox(
//                             height: screenHeight * 0.02,
//                           ),

//                           Text(
//                             'Selected Items',
//                             style: Styles.textStyleLarge(context,
//                                 color: AppColor.yellowColor),
//                             textScaleFactor: 1.0,
//                           ),
//                           SizedBox(
//                             height: screenHeight * 0.02,
//                           ),
//                           Consumer<GetProvider>(
//                             builder: (context, cartProvider, child) {
//                               if (cartProvider.getAddToCart.isEmpty) {
//                                 return Center(
//                                   child: Column(
//                                     children: [
//                                       // SizedBox(
//                                       //   height: screenHeight * 0.12,
//                                       // ),
//                                       Lottie.asset(
//                                           "assets/map_pin/emptycart.json",
//                                           height: screenHeight * 0.3,
//                                           width: screenWidth * 0.9,
//                                           fit: BoxFit.cover),
//                                       Text(
//                                         'Your cart is empty',
//                                         style: TextStyle(fontSize: 18),
//                                         textScaleFactor: 1.0,
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }

//                               return Container(
//                                 padding: EdgeInsets.symmetric(vertical: 7),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     // Delivery Time
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Row(
//                                         children: [
//                                           Icon(Icons.access_time,
//                                               color: Colors.green),
//                                           SizedBox(width: 10),
//                                           Text(
//                                             'Delivery in 13 mins',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Divider(
//                                       height: 1.1,
//                                     ),
//                                     // Cart Items
//                                     ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: NeverScrollableScrollPhysics(),
//                                       itemCount:
//                                           cartProvider.getAddToCart.length,
//                                       itemBuilder: (context, index) {
//                                         final item =
//                                             cartProvider.getAddToCart[index];
//                                         return _buildCartItem(
//                                           context,
//                                           item.fruitName ?? 'Unknown',
//                                           item.fruitsQuantity ?? '',
//                                           item.currentPrice?.toString() ?? '0',
//                                           item.oldPrice?.toString() ?? '',
//                                           item.fruitImage ?? '',
//                                           item.count ?? 1,
//                                           item.fruitSubname ?? '',
//                                           () async {
//                                             setState(() {
//                                               if (item.count != null &&
//                                                   item.count! > 0) {
//                                                 item.count = item.count! - 1;
//                                                 print(
//                                                     "Decremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
//                                                 log("Decremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
//                                                 recalculateTotalPrice();
//                                                 _onCountChanged(item.count ?? 0,
//                                                     item); // Trigger debounced API call
//                                               }
//                                             });

//                                             // cartProvider.decrementItem(item);
//                                           },
//                                           () async {
//                                             // cartProvider.incrementItem(item);
//                                             setState(() {
//                                               if (item.count != null) {
//                                                 item.count = item.count! + 1;
//                                                 print(
//                                                     "Incremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
//                                                 log("Incremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
//                                                 recalculateTotalPrice();
//                                                 _onCountChanged(item.count ?? 0,
//                                                     item); // Trigger debounced API call
//                                               }
//                                             });
//                                           },
//                                         );
//                                       },
//                                     ),

//                                     // Padding(
//                                     //   padding: const EdgeInsets.symmetric(
//                                     //       horizontal: 15, vertical: 10),
//                                     //   child: Row(
//                                     //     children: [
//                                     //       Text(
//                                     //         'Missed Something?',
//                                     //         style: Styles.textStyleMedium(
//                                     //             context,
//                                     //             color: AppColor.blackColor),
//                                     //       ),
//                                     //       Spacer(),
//                                     //       GestureDetector(
//                                     //         onTap: () async {
//                                     //           await AppRouteName.apppage
//                                     //               .push(context, args: 1);
//                                     //         },
//                                     //         child: Container(
//                                     //           padding: EdgeInsets.symmetric(
//                                     //               vertical: 5, horizontal: 5),
//                                     //           decoration: BoxDecoration(
//                                     //               color: AppColor.yellowColor,
//                                     //               borderRadius:
//                                     //                   BorderRadius.circular(
//                                     //                       10)),
//                                     //           child: Text(
//                                     //             '+ Add More Items',
//                                     //             style: Styles.textStyleSmall(
//                                     //                 context,
//                                     //                 color: AppColor.blackColor),
//                                     //           ),
//                                     //         ),
//                                     //       )
//                                     //     ],
//                                     //   ),
//                                     // )
//                                     // Row(
//                                     //   mainAxisAlignment:
//                                     //       MainAxisAlignment.center,
//                                     //   children: [
//                                     //     Icon(Icons.add,
//                                     //         color: const Color.fromARGB(
//                                     //             255, 117, 13, 13)),
//                                     //     SizedBox(width: 8),
//                                     //     Text('Add More Items',
//                                     //         style: TextStyle(
//                                     //             color: Colors.white)),
//                                     //   ],
//                                     // ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),

//                           SizedBox(
//                             height: screenHeight * 0.02,
//                           ),

//                           Text(
//                             'Payment Summary :',
//                             style: Styles.textStyleMedium(context,
//                                 color: AppColor.yellowColor),
//                             textScaleFactor: 1.0,
//                           ),
//                           SizedBox(
//                             height: screenHeight * 0.01,
//                           ),

//                           // Total Price Summary Section
//                           Container(
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 //Function to create rows with label and value
//                                 for (var item in [
//                                   {
//                                     'label': 'Total MRP Price:',
//                                     'value': TotalOldPrice.toStringAsFixed(2)
//                                   },
//                                   {
//                                     'label': 'Your Savings:',
//                                     'value': totalSavings.toStringAsFixed(2)
//                                   },
//                                   {
//                                     'label': 'Delivery Fees',
//                                     'value': '30.00',
//                                     'strikethrough': true
//                                   },
//                                   {
//                                     'label': 'GST Charges',
//                                     'value': gstAmount.toStringAsFixed(2)
//                                   },
//                                 ])
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.symmetric(vertical: 5),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           item['label'] as String,
//                                           style: Styles.textStyleMedium(context,
//                                               color: AppColor.fillColor),
//                                           textScaleFactor: 1.0,
//                                         ),
//                                         Text(
//                                           '₹${item['value']}',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColor.hintTextColor,
//                                             decoration:
//                                                 item['strikethrough'] == true
//                                                     ? TextDecoration.lineThrough
//                                                     : null,
//                                           ),
//                                           textScaleFactor: 1.0,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 SizedBox(height: 10),
//                                 Divider(),
//                                 SizedBox(height: 10),
//                                 // Total Pay Row
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Total Pay',
//                                       style: Styles.textStyleMedium(context,
//                                           color: AppColor.blackColor),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                     Text(
//                                       '₹${(TotalCurrentPrice + gstAmount).toStringAsFixed(2)}',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: AppColor.fillColor,
//                                       ),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(
//                             height: 20,
//                           ),
//                           Text(
//                             'Did You Forgot anthing?',
//                             style: Styles.textStyleMedium(context,
//                                 color: AppColor.yellowColor),
//                             textScaleFactor: 1.0,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           // GridView for additional products
//                           Consumer<GetProvider>(
//                             builder: (context, getprovider, child) {
//                               // Show the actual product list when data is available

//                               return SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: isLoading ||
//                                         getprovider.randomproduct.isEmpty
//                                     ? shimmerSlotBox()
//                                     : Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: List.generate(
//                                           getprovider.randomproduct.length,
//                                           (index) {
//                                             final product = getprovider
//                                                 .randomproduct[index];

//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 15),
//                                               child: ProductCard(
//                                                 image: product.Image!,
//                                                 name: product.Name!,
//                                                 subname: product.Subname!,
//                                                 price: product.currentPrice
//                                                         ?.toString() ??
//                                                     '0.00',
//                                                 oldPrice: product.oldPrice
//                                                         .toString() ??
//                                                     '0.00',
//                                                 weights: product.Quantity!,
//                                                 selectedWeight:
//                                                     product.Quantity!,
//                                                 isAdded: isAdded[product
//                                                         .subCategoryId] ??
//                                                     false,
//                                                 count: itemCounts[product
//                                                         .subCategoryId] ??
//                                                     0,
//                                                 isFavorite: isFavorite[product
//                                                         .subCategoryId] ??
//                                                     false,
//                                                 onChanged:
//                                                     (String? newValue) {},
//                                                 onIcrease: () {
//                                                   setState(() {
//                                                     itemCounts[product
//                                                             .subCategoryId!] =
//                                                         (itemCounts[product
//                                                                     .subCategoryId!] ??
//                                                                 0) +
//                                                             1;

//                                                     print(
//                                                         "Increased Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");
//                                                     log("Increased Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");

//                                                     recalculateTotalPrice();
//                                                   });

//                                                   // Trigger the debounced API call
//                                                   _debounceApiCall(
//                                                     product.subCategoryId ?? '',
//                                                     itemCounts[product
//                                                             .subCategoryId!] ??
//                                                         0,
//                                                     token,
//                                                   );
//                                                 },
//                                                 onAdd: () async {
//                                                   setState(() {
//                                                     if (!(isAdded[product
//                                                             .subCategoryId] ??
//                                                         false)) {
//                                                       isAdded[product
//                                                               .subCategoryId!] =
//                                                           true;
//                                                       itemCounts[product
//                                                           .subCategoryId!] = 1;
//                                                     } else {
//                                                       itemCounts[product
//                                                           .subCategoryId!] = 1;
//                                                     }

//                                                     print(
//                                                         "Added Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");
//                                                     log("Added Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");
//                                                   });
//                                                   try {
//                                                     await AppDialogue
//                                                         .openLoadingDialogAfterClose(
//                                                             context,
//                                                             text:
//                                                                 "Adding to cart...",
//                                                             load: () async {
//                                                       return await getprovider
//                                                           .addToCart(
//                                                         fruitId: product.Id!,
//                                                         categoryId: product
//                                                             .subCategoryId!,
//                                                         count: itemCounts[product
//                                                                 .subCategoryId] ??
//                                                             0,
//                                                         token: token,
//                                                       );
//                                                     }, afterComplete:
//                                                                 (resp) async {
//                                                       if (resp.status) {
//                                                         AppDialogue.toast(
//                                                             resp.data);
//                                                       }
//                                                     }
//                                                     );
//                                                   } on Exception catch (e) {
//                                                     ExceptionHandler
//                                                         .showMessage(
//                                                             context, e);
//                                                   }
//                                                   await getprovider
//                                                       .fetchAddToCart(token);
//                                                   await recalculateTotalPrice();
//                                                 },
//                                                 onRemove: () {
//                                                   setState(() {
//                                                     if ((itemCounts[product
//                                                                 .subCategoryId!] ??
//                                                             0) >
//                                                         0) {
//                                                       itemCounts[product
//                                                               .subCategoryId!] =
//                                                           (itemCounts[product
//                                                                       .subCategoryId!] ??
//                                                                   0) -
//                                                               1;

//                                                       print(
//                                                           "Decremented Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");
//                                                       log("Decremented Item: Name: ${product.Name}, ID: ${product.Id}, Count: ${itemCounts[product.subCategoryId!]}");

//                                                       recalculateTotalPrice();

//                                                       if (itemCounts[product
//                                                               .subCategoryId!] ==
//                                                           0) {
//                                                         isAdded[product
//                                                                 .subCategoryId!] =
//                                                             false;
//                                                       }
//                                                     }
//                                                   });

//                                                   // Trigger the debounced API call
//                                                   _debounceApiCall(
//                                                     product.subCategoryId ?? '',
//                                                     itemCounts[product
//                                                             .subCategoryId!] ??
//                                                         0,
//                                                     token,
//                                                   );
//                                                 },
//                                                 onFavoriteToggle: () async {
//                                                   setState(() {
//                                                     bool favoriteStatus =
//                                                         !(isFavorite[product
//                                                                 .subCategoryId] ??
//                                                             false);
//                                                     isFavorite[product
//                                                             .subCategoryId ??
//                                                         ''] = favoriteStatus;

//                                                     print(
//                                                         'Product ID: ${product.Id}, Name: ${product.Name}, Favorite: $favoriteStatus');
//                                                     log('Product ID: ${product.Id}, Name: ${product.Name}, Favorite: $favoriteStatus');
//                                                   });

//                                                   try {
//                                                     await AppDialogue
//                                                         .openLoadingDialogAfterClose(
//                                                       context,
//                                                       text:
//                                                           "Adding Wish List...",
//                                                       load: () async {
//                                                         return await provider
//                                                             .addWishList(
//                                                           categoryId: product
//                                                               .subCategoryId!,
//                                                           token: token,
//                                                           isCondtion:
//                                                               isFavorite[product
//                                                                       .subCategoryId] ??
//                                                                   false,
//                                                           productId:
//                                                               product.Id!,
//                                                         );
//                                                       },
//                                                       afterComplete:
//                                                           (resp) async {
//                                                         if (resp.status) {
//                                                           AppDialogue.toast(
//                                                               resp.data);
//                                                         }
//                                                       },
//                                                     );
//                                                   } on Exception catch (e) {
//                                                     ExceptionHandler
//                                                         .showMessage(
//                                                             context, e);
//                                                   }
//                                                 },
//                                                 onTap: () async {
//                                                   print('hello');
//                                                   final value =
//                                                       await showModalBottomSheet(
//                                                     context: context,
//                                                     isScrollControlled: true,
//                                                     backgroundColor:
//                                                         Colors.transparent,
//                                                     builder:
//                                                         (BuildContext context) {
//                                                       return ProductCategoryPage(
//                                                         categoryId: product
//                                                             .subCategoryId!,
//                                                       );
//                                                     },
//                                                   );
//                                                   if (value == 'Yes') {
//                                                     print(
//                                                         'ggggggggggggggggggggggg');
//                                                     await _fetchCartData();

//                                                     await recalculateTotalPrice();
//                                                   }
//                                                 },
//                                                 fruitsCount: product.count ?? 0,
//                                                 catgoryId: product.CategoryId!,
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                               );
//                             },
//                           ),

//                           const SizedBox(
//                             height: 20,
//                           ),

//                           getprovider.getOrderAddress.isEmpty
//                               ? SizedBox()
//                               : isExistingAddressEmpty
//                                   ? GestureDetector(
//                                       onTap: () async {
//                                         final val = await showModalBottomSheet(
//                                           context: context,
//                                           isScrollControlled: true,
//                                           shape: const RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.vertical(
//                                                 top: Radius.circular(20)),
//                                           ),
//                                           builder: (context) {
//                                             return const FractionallySizedBox(
//                                               heightFactor: 0.74,
//                                               child:
//                                                   SavedAddressListBottomsheet(
//                                                 page: 'Cart',
//                                               ),
//                                             );
//                                           },
//                                         );
//                                         if (val == "Yes") {
//                                           getdata();
//                                         }
//                                       },
//                                       child: Container(
//                                         padding:
//                                             EdgeInsets.symmetric(vertical: 25),
//                                         decoration: BoxDecoration(
//                                           color: AppColor.whiteColor,
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Icon(
//                                                     lastAddress?.addressType ==
//                                                             'Home'
//                                                         ? Icons.home
//                                                         : lastAddress
//                                                                     ?.addressType ==
//                                                                 'Work'
//                                                             ? Icons.work
//                                                             : lastAddress
//                                                                         ?.addressType ==
//                                                                     'Hotel'
//                                                                 ? Icons
//                                                                     .hotel_rounded
//                                                                 : Icons
//                                                                     .location_on, // Default icon
//                                                   ),
//                                                   const SizedBox(width: 25),
//                                                   Text(
//                                                     lastAddress != null
//                                                         ? 'Delivery at ${lastAddress.addressType}'
//                                                         : 'No Address Available',
//                                                     style:
//                                                         Styles.textStyleMedium(
//                                                             context,
//                                                             color: AppColor
//                                                                 .hintTextColor),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     softWrap: true,
//                                                     textAlign: TextAlign.start,
//                                                     textScaleFactor: 1.0,
//                                                   ),
//                                                   Spacer(),
//                                                   const Icon(
//                                                       Icons.arrow_forward_ios,
//                                                       size: 15),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 45),
//                                                 child: Text(
//                                                   lastAddress != null
//                                                       ? '${lastAddress.addressLine}, $orderAddress, ${lastAddress.addressType}'
//                                                       : 'No address is added',
//                                                   style: Styles.textStyleMedium(
//                                                       context,
//                                                       color: AppColor
//                                                           .hintTextColor),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                   textAlign: TextAlign.start,
//                                                   textScaleFactor: 1.0,
//                                                 ),
//                                               ),
//                                               Divider(),
//                                               const SizedBox(height: 5),
//                                               lastAddress == null ||
//                                                       lastAddress.name ==
//                                                           null ||
//                                                       lastAddress.mobile == null
//                                                   ? Row(
//                                                       children: [
//                                                         Icon(Icons.phone),
//                                                         const SizedBox(
//                                                             width: 20),
//                                                         Text(
//                                                           'No Contact Details Added',
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                       ],
//                                                     )
//                                                   : Row(
//                                                       children: [
//                                                         Icon(Icons.phone),
//                                                         const SizedBox(
//                                                             width: 25),
//                                                         Text(
//                                                           lastAddress
//                                                                   .name ??
//                                                               '',
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                         const SizedBox(
//                                                             width: 12),
//                                                         Text(
//                                                           lastAddress.mobile ??
//                                                               '',
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                         Spacer(),
//                                                         const Icon(
//                                                             Icons
//                                                                 .arrow_forward_ios,
//                                                             size: 15),
//                                                       ],
//                                                     )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   : GestureDetector(
//                                       onTap: () async {
//                                         final val = await showModalBottomSheet(
//                                           context: context,
//                                           isScrollControlled: true,
//                                           shape: const RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.vertical(
//                                                 top: Radius.circular(20)),
//                                           ),
//                                           builder: (context) {
//                                             return const FractionallySizedBox(
//                                               heightFactor: 0.74,
//                                               child:
//                                                   SavedAddressListBottomsheet(
//                                                 page: 'Cart',
//                                               ),
//                                             );
//                                           },
//                                         );
//                                         if (val == "Yes") {
//                                           getdata();
//                                         }
//                                       },
//                                       child: Container(
//                                         padding:
//                                             EdgeInsets.symmetric(vertical: 25),
//                                         decoration: BoxDecoration(
//                                             color: AppColor.whiteColor,
//                                             borderRadius:
//                                                 BorderRadius.circular(15)),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Icon(
//                                                     selectedAddress == 'Home'
//                                                         ? Icons.home
//                                                         : selectedAddress ==
//                                                                 'Work'
//                                                             ? Icons.work
//                                                             : selectedAddress ==
//                                                                     'Hotel'
//                                                                 ? Icons
//                                                                     .hotel_rounded
//                                                                 : Icons
//                                                                     .location_on, // Default icon if none match
//                                                   ),
//                                                   const SizedBox(
//                                                     width: 25,
//                                                   ),
//                                                   Text(
//                                                     'Delivery at $selectedAddress',
//                                                     style:
//                                                         Styles.textStyleMedium(
//                                                             context,
//                                                             color: AppColor
//                                                                 .hintTextColor),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     softWrap: true,
//                                                     textAlign: TextAlign.start,
//                                                     textScaleFactor: 1.0,
//                                                   ),
//                                                   Spacer(),
//                                                   const Icon(
//                                                     Icons.arrow_forward_ios,
//                                                     size: 15,
//                                                   ),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 45),
//                                                 child: Container(
//                                                   child: Text(
//                                                     orderAddress.isEmpty ||
//                                                             flatHouseNo.isEmpty
//                                                         ? 'No address is added'
//                                                         : '$flatHouseNo, $orderAddress, $landmark',
//                                                     style:
//                                                         Styles.textStyleMedium(
//                                                             context,
//                                                             color: AppColor
//                                                                 .hintTextColor),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     // softWrap: true,
//                                                     textAlign: TextAlign.start,
//                                                     textScaleFactor: 1.0,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Divider(),
//                                               const SizedBox(
//                                                 height: 5,
//                                               ),
//                                               Delmobile.isEmpty ||
//                                                       Delname.isEmpty
//                                                   ? Row(
//                                                       children: [
//                                                         Icon(Icons.phone),
//                                                         const SizedBox(
//                                                           width: 20,
//                                                         ),
//                                                         Text(
//                                                           ' No Contact Details is Added',
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                       ],
//                                                     )
//                                                   : Row(
//                                                       children: [
//                                                         Icon(Icons.phone),
//                                                         const SizedBox(
//                                                           width: 25,
//                                                         ),
//                                                         Text(
//                                                           '$Delname',
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 12,
//                                                         ),
//                                                         Text(
//                                                           Delmobile,
//                                                           style: Styles
//                                                               .textStyleMedium(
//                                                                   context,
//                                                                   color: AppColor
//                                                                       .hintTextColor),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           maxLines: 1,
//                                                           softWrap: true,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           textScaleFactor: 1.0,
//                                                         ),
//                                                         Spacer(),
//                                                         const Icon(
//                                                           Icons
//                                                               .arrow_forward_ios,
//                                                           size: 15,
//                                                         )
//                                                       ],
//                                                     )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),

//                           SizedBox(
//                             height: screenHeight * 0.13,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0, // Position it at the bottom
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 20, horizontal: 15),
//                       decoration: const BoxDecoration(
//                           color: AppColor.whiteColor,
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(15),
//                               topRight: Radius.circular(15))),
//                       child: getprovider.getOrderAddress.isEmpty
//                           ? Align(
//                               alignment: Alignment.center,
//                               child: SizedBox(
//                                 height: 30,
//                                 width: 30,
//                                 child:
//                                     CircularProgressIndicator(strokeWidth: 2),
//                               ),
//                             )
//                           : MyButton(
//                               text: getprovider.getOrderAddress.isEmpty
//                                   ? 'Add Address At Next Step'
//                                   : "Proceed to Pay",
//                               textcolor: AppColor.blackColor,
//                               textsize: 20,
//                               fontWeight: FontWeight.bold,
//                               letterspacing: 0.7,
//                               buttoncolor: AppColor.yellowColor,
//                               borderColor: AppColor.yellowColor,
//                               buttonheight: 55 * (screenHeight / 812),
//                               buttonwidth: screenWidth,
//                               radius: 40,
//                               onTap: () async {
//                                 FocusScope.of(context).unfocus();
//                                 try {
//                                   await AppDialogue.openLoadingDialogAfterClose(
//                                     context,
//                                     text: "Loading...",
//                                     load: () async {
//                                       // return await provider.sendOTP(mobile: mobile.text);
//                                     },
//                                     afterComplete: (resp) async {
//                                       //if (resp.status) {
//                                       if (
//                                           // isLoading == true
//                                           getprovider.getOrderAddress.isEmpty) {
//                                         print(
//                                             "no address is added ------------");
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     SelectAddressMap(
//                                                       targetPage: CartPage(),
//                                                       page: 'Cart',
//                                                     )));

//                                         //AppDialogue.toast(resp.data);
//                                       } else {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => OrderTypePage(
//                                               oldPrice: TotalOldPrice,
//                                               savings: totalSavings,
//                                               gstAmount: gstAmount,
//                                               totalWithGst:
//                                                   TotalCurrentPrice + gstAmount,
//                                             ),
//                                           ),
//                                         );
//                                         print(" address is added ------------");
//                                       }
//                                     },
//                                   );
//                                 } on Exception catch (e) {
//                                   ExceptionHandler.showMessage(context, e);
//                                 }
//                               }),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
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
//       await _fetchCartData();
//     });
//   }

//   Widget shimmerSlotBox() {
//     return Consumer<GetProvider>(
//       builder: (context, getprovider, child) {
//         // Show shimmer effect when data is loading
//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(getprovider.randomproduct.length, (index) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 15),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 120,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCartItem(
//     BuildContext context,
//     String title,
//     String weight,
//     String price,
//     String oldPrice,
//     String imageUrl,
//     int count,
//     String subTitle,
//     VoidCallback onDecrement,
//     VoidCallback onIncrement,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 13.0),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // Image
//               Container(
//                 height: 60,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                   image: DecorationImage(
//                     image: NetworkImage(imageUrl),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 15),
//               // Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: Styles.textStyleMedium(context,
//                           color: AppColor.fillColor),
//                       textScaleFactor: 1,
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       weight,
//                       style: Styles.textStyleSmall(context,
//                           color: AppColor.hintTextColor),
//                       textScaleFactor: 1,
//                     ),
//                   ],
//                 ),
//               ),
//               // Quantity Controls
//               Container(
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 193, 233, 170),
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.remove, color: Colors.red),
//                       onPressed: onDecrement,
//                     ),
//                     Text('$count'),
//                     IconButton(
//                       icon: Icon(Icons.add, color: Colors.green),
//                       onPressed: onIncrement,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 15),
//               // Price Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '${AppConstants.Rupees}$price',
//                     style: Styles.textStyleMedium(context,
//                         color: AppColor.fillColor),
//                   ),
//                   if (oldPrice.isNotEmpty)
//                     Text(
//                       '${AppConstants.Rupees}$oldPrice',
//                       style: Styles.textStyleSmall(context,
//                               color: AppColor.hintTextColor)
//                           .copyWith(
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 15,
//           )
//         ],
//       ),
//     );
//   }
// }







import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/cart/getCart_model.dart';
import 'package:fulupo/pages/bottom_sheet/product_category_page.dart';
import 'package:fulupo/pages/delivery_map_pages.dart';
import 'package:fulupo/pages/order_type_page.dart';
import 'package:fulupo/pages/product_cart_widget.dart';
import 'package:fulupo/pages/saved_address_list_bottomsheet.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String mobile = '';
  String name = '';
  bool isAddress = false;
  String token = '';
  double TotalCurrentPrice = 0;
  double TotalOldPrice = 0;
  double totalSavings = 0;
  double gstAmount = 0;
  String _address = "Loading..."; // Default value
  LatLng draggedLatLng = LatLng(0.0, 0.0);
  String Delmobile = '';
  String Delname = '';
  bool isEditing = false;
  String selectedAddress = '';
  String updatedName = '';
  String updatedMobile = '';
  Timer? _debounce; // Timer to debounce API calls
  String orderAddress = '';
  String flatHouseNo = '';
  String landmark = '';
  String updatedFlatHouseNo = '';
  String updatedLandmark = '';
  bool isLoading = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController flatHouseNoController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController(); // New controller

  Map<String, Timer?> _debounceTimers = {};
  List<GetcartModel> cartItems = []; // Updated to use GetcartModel

  GetProvider get getprovider => context.read<GetProvider>();
  UserProvider get provider => context.read<UserProvider>();

  // Product states for each item
  Map<String, int> itemCounts = {};
  Map<String, bool> isFavorite = {};
  Map<String, bool> isAdded = {};

  void _onQuantityChanged(int newQuantity, String productId) {
    // Cancel the previous timer if it exists
    _debounceTimers[productId]?.cancel();

    // Set a new timer for 1 second
    _debounceTimers[productId] = Timer(const Duration(seconds: 1), () async {
      // Trigger the API call here after the debounce delay
      // try {
      //   await AppDialogue.openLoadingDialogAfterClose(context,
          //  text: "Updating...", load: () async {
          // return await getprovider.updateCartQuantity(
          //     productId: productId,
          //     quantity: newQuantity,
          //     token: token);
      //  }, afterComplete: (resp) async {
          // if (resp.status) {
          //   AppDialogue.toast(resp.data);
          // }
       // }
      // );
      // } catch (e) {
      //   ExceptionHandler.showMessage(context, e);
      // }
      await fetchCartData();
      await recalculateTotalPrice();
    });
  }

  Future<void> fetchCartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the new getCart method to fetch cart data
      cartItems = await getprovider.getCart();
      
      // Clear current states
      itemCounts.clear();

      // Process the fetched data
      for (var item in cartItems) {
        itemCounts[item.productId] = item.quantity;
      }

      // Fetch additional data if needed
      await fetchRecommendedProducts();
    } catch (e) {
      log('Error fetching cart data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecommendedProducts() async {
    try {
      // Fetch recommended products based on cart items
      List<String> productIds = cartItems.map((item) => item.productId).toList();
      
      if (productIds.isNotEmpty) {
        await getprovider.fetchRandomProduct(productIds);
      }
    } catch (e) {
      log('Error fetching recommended products: $e');
    }
  }

  Future<void> getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
      name = prefs.getString(AppConstants.USERNAME) ?? '';
      // Fetch using new keys
      Delmobile = prefs.getString('SELECTED_MOBILE') ?? '';
      Delname = prefs.getString('SELECTED_USER_NAME') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS_TYPE') ?? '';
      flatHouseNo = prefs.getString('SELECTED_FLAT_HOUSE_NO') ?? '';
      landmark = prefs.getString('SELECTED_LANDMARK') ?? '';
      nameController.text = Delname;
      mobileController.text = Delmobile;
      flatHouseNoController.text = flatHouseNo;
      landmarkController.text = landmark;
      token = prefs.getString(AppConstants.token) ?? '';
      orderAddress = prefs.getString(AppConstants.USERADDRESS) ?? '';
      log('Token: $token');
    });
    
    await getprovider.fetchOrderAddress(token);
    await fetchCartData();
    await recalculateTotalPrice();
  }

  Future<void> saveAddressToPrefs(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('SELECTED__ADDRESS', address);
  }

  Future<void> recalculateTotalPrice() async {
    double totalCurrentPrice = 0;
    double totalOldPrice = 0;

    // Calculate prices based on cart items
    for (var item in cartItems) {
      totalCurrentPrice += item.mrpPrice * item.quantity;
      totalOldPrice += (item.discountPrice ?? item.mrpPrice) * item.quantity;
    }

    setState(() {
      TotalCurrentPrice = totalCurrentPrice;
      TotalOldPrice = totalOldPrice;
      totalSavings = totalOldPrice - totalCurrentPrice;
      gstAmount = totalCurrentPrice * 0.03; // Calculate GST (3%)
    });
  }

  Future<void> _getLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Retrieve latitude and longitude as doubles
      double? latitude = prefs.getDouble(AppConstants.USERLATITUTE);
      double? longitude = prefs.getDouble(AppConstants.USERLONGITUTE);
      String? address = prefs.getString(AppConstants.USERADDRESS);

      if (latitude != null && longitude != null && address != null) {
        // Update draggedLatLng with stored values
        draggedLatLng = LatLng(latitude, longitude);

        setState(() {
          _address = address; // Update the state with the retrieved address
        });
      } else {
        setState(() {
          _address = "No address found."; // Update with a default message
        });
      }
    } catch (e) {
      log('Error retrieving location data: $e');
      setState(() {
        _address = "Error retrieving address."; // Update with error message
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
    _getLocationData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }
    nameController.dispose();
    mobileController.dispose();
    flatHouseNoController.dispose();
    landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final lastAddress = getprovider.getOrderAddress.isNotEmpty
        ? getprovider.getOrderAddress.last
        : null;

    bool isExistingAddressEmpty = selectedAddress.isEmpty ||
        flatHouseNo.isEmpty ||
        orderAddress.isEmpty ||
        landmark.isEmpty ||
        Delname.isEmpty ||
        Delmobile.isEmpty;

    if (isExistingAddressEmpty && lastAddress != null) {
      saveAddressToPrefs(lastAddress.addressLine ?? '');
    }

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        elevation: 0,
        title: Text(
          'Cart Page',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: AppColor.yellowColor))
          : cartItems.isEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                await fetchCartData();
                await recalculateTotalPrice();
              },
              color: AppColor.fillColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/map_pin/emptycart.json",
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.9,
                      fit: BoxFit.cover
                    ),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textScaleFactor: 1.0,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    GestureDetector(
                      onTap: () {
                        AppRouteName.apppage.push(context, args: 1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColor.yellowColor,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          'Go To Home',
                          style: Styles.textStyleMedium(context, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await fetchCartData();
                await recalculateTotalPrice();
              },
              color: AppColor.fillColor,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          
                          Text(
                            'Selected Items',
                            style: Styles.textStyleLarge(context, color: AppColor.yellowColor),
                            textScaleFactor: 1.0,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Cart Items Container
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Delivery Time
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.green),
                                      SizedBox(width: 10),
                                      Text(
                                        'Delivery in 30 mins',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1.1),
                                
                                // Cart Items List
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    return _buildCartItem(
                                      context,
                                      item.productName,
                                      item.productCode,
                                      item.mrpPrice.toString(),
                                      item.discountPrice?.toString() ?? '',
                                      "${AppConstants.imageBaseUrl}/${item.storeLogo ?? ''}",
                                      item.quantity,
                                      item.storeName,
                                      () { // Decrement callback
                                        if (item.quantity > 1) {
                                          setState(() {
                                            cartItems[index] = GetcartModel(
                                              id: item.id,
                                              productId: item.productId,
                                              productName: item.productName,
                                              productCode: item.productCode,
                                              mrpPrice: item.mrpPrice,
                                              discountPrice: item.discountPrice,
                                              quantity: item.quantity - 1,
                                              storeName: item.storeName,
                                              storeId: item.storeId,
                                              storeLogo: item.storeLogo,
                                            );
                                            recalculateTotalPrice();
                                          });
                                          _onQuantityChanged(item.quantity - 1, item.productId);
                                        } else {
                                          // Show confirmation dialog for removing item
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Remove Item'),
                                              content: Text('Remove ${item.productName} from cart?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _onQuantityChanged(0, item.productId);
                                                  },
                                                  child: Text(
                                                    'Remove',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      () { // Increment callback
                                        setState(() {
                                          cartItems[index] = GetcartModel(
                                            id: item.id,
                                            productId: item.productId,
                                            productName: item.productName,
                                            productCode: item.productCode,
                                            mrpPrice: item.mrpPrice,
                                            discountPrice: item.discountPrice,
                                            quantity: item.quantity + 1,
                                            storeName: item.storeName,
                                            storeId: item.storeId,
                                            storeLogo: item.storeLogo,
                                          );
                                          recalculateTotalPrice();
                                        });
                                        _onQuantityChanged(item.quantity + 1, item.productId);
                                      },
                                    );
                                  },
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Missed Something?',
                                        style: Styles.textStyleMedium(context, color: AppColor.blackColor),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          await AppRouteName.apppage.push(context, args: 1);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: AppColor.yellowColor,
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Text(
                                            '+ Add More Items',
                                            style: Styles.textStyleSmall(context, color: AppColor.blackColor),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            'Payment Summary :',
                            style: Styles.textStyleMedium(context, color: AppColor.yellowColor),
                            textScaleFactor: 1.0,
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // Total Price Summary Section
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Function to create rows with label and value
                                for (var item in [
                                  {
                                    'label': 'Total MRP Price:',
                                    'value': TotalOldPrice.toStringAsFixed(2)
                                  },
                                  {
                                    'label': 'Your Savings:',
                                    'value': totalSavings.toStringAsFixed(2)
                                  },
                                  {
                                    'label': 'Delivery Fees',
                                    'value': '30.00',
                                    'strikethrough': true
                                  },
                                  {
                                    'label': 'GST Charges',
                                    'value': gstAmount.toStringAsFixed(2)
                                  },
                                ])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['label'] as String,
                                          style: Styles.textStyleMedium(context, color: AppColor.fillColor),
                                          textScaleFactor: 1.0,
                                        ),
                                        Text(
                                          '₹${item['value']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.hintTextColor,
                                            decoration: item['strikethrough'] == true
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          textScaleFactor: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 10),
                                Divider(),
                                SizedBox(height: 10),
                                // Total Pay Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Pay',
                                      style: Styles.textStyleMedium(context, color: AppColor.blackColor),
                                      textScaleFactor: 1.0,
                                    ),
                                    Text(
                                      '₹${(TotalCurrentPrice + gstAmount).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.fillColor,
                                      ),
                                      textScaleFactor: 1.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          
                          Text(
                            'You may also like',
                            style: Styles.textStyleMedium(context, color: AppColor.yellowColor),
                            textScaleFactor: 1.0,
                          ),
                          const SizedBox(height: 10),
                          
                          // Recommended Products
                          Consumer<GetProvider>(
                            builder: (context, getprovider, child) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: getprovider.randomproduct.isEmpty
                                    ? shimmerSlotBox()
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: List.generate(
                                          getprovider.randomproduct.length,
                                          (index) {
                                            final product = getprovider.randomproduct[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductCard(
                                                image: product.Image!,
                                                name: product.Name!,
                                                subname: product.Subname!,
                                                price: product.currentPrice?.toString() ?? '0.00',
                                                oldPrice: product.oldPrice.toString() ?? '0.00',
                                                weights: product.Quantity!,
                                                selectedWeight: product.Quantity!,
                                                isAdded: isAdded[product.subCategoryId] ?? false,
                                                count: itemCounts[product.subCategoryId] ?? 0,
                                                isFavorite: isFavorite[product.subCategoryId] ?? false,
                                                onChanged: (String? newValue) {},
                                                onIcrease: () {
                                                  // Handle increase
                                                },
                                                onAdd: () {
                                                  // Handle add
                                                },
                                                onRemove: () {
                                                  // Handle remove
                                                },
                                                onFavoriteToggle: () {
                                                  // Handle favorite toggle
                                                },
                                                onTap: () async {
                                                  // Handle tap
                                                },
                                                fruitsCount: product.count ?? 0,
                                                catgoryId: product.CategoryId!,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Address section
                          getprovider.getOrderAddress.isEmpty
                              ? SizedBox()
                              : isExistingAddressEmpty
                                  ? GestureDetector(
                                      onTap: () async {
                                        // Handle address selection
                                        final val = await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) {
                                            return const FractionallySizedBox(
                                              heightFactor: 0.74,
                                              child: SavedAddressListBottomsheet(page: 'Cart'),
                                            );
                                          },
                                        );
                                        if (val == "Yes") {
                                          getdata();
                                        }
                                      },
                                      child: _buildAddressCard(lastAddress, orderAddress),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        // Handle address selection
                                        final val = await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) {
                                            return const FractionallySizedBox(
                                              heightFactor: 0.74,
                                              child: SavedAddressListBottomsheet(page: 'Cart'),
                                            );
                                          },
                                        );
                                        if (val == "Yes") {
                                          getdata();
                                        }
                                      },
                                      child: _buildCustomAddressCard(selectedAddress, flatHouseNo, orderAddress, landmark, Delname, Delmobile),
                                    ),

                          SizedBox(height: screenHeight * 0.13),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Checkout Button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      decoration: const BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                        )
                      ),
                      child: getprovider.getOrderAddress.isEmpty
                          ? Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : MyButton(
                              text: getprovider.getOrderAddress.isEmpty
                                  ? 'Add Address At Next Step'
                                  : "Proceed to Pay",
                              textcolor: AppColor.blackColor,
                              textsize: 20,
                              fontWeight: FontWeight.bold,
                              letterspacing: 0.7,
                              buttoncolor: AppColor.yellowColor,
                              borderColor: AppColor.yellowColor,
                              buttonheight: 55 * (screenHeight / 812),
                              buttonwidth: screenWidth,
                              radius: 40,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                try {
                                  await AppDialogue.openLoadingDialogAfterClose(
                                    context,
                                    text: "Loading...",
                                    load: () async {
                                      // Any pre-processing if needed
                                      return Future.value(null);
                                    },
                                    afterComplete: (resp) async {
                                      if (getprovider.getOrderAddress.isEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SelectAddressMap(
                                              targetPage: CartPage(),
                                              page: 'Cart',
                                            )
                                          )
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderTypePage(
                                              oldPrice: TotalOldPrice,
                                              savings: totalSavings,
                                              gstAmount: gstAmount,
                                              totalWithGst: TotalCurrentPrice + gstAmount,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                } on Exception catch (e) {
                                  ExceptionHandler.showMessage(context, e);
                                }
                              }
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Custom address card when we have existing data
  Widget _buildCustomAddressCard(String addressType, String flatHouseNo, String orderAddress, String landmark, String name, String mobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  addressType == 'Home'
                      ? Icons.home
                      : addressType == 'Work'
                          ? Icons.work
                          : addressType == 'Hotel'
                              ? Icons.hotel_rounded
                              : Icons.location_on,
                ),
                const SizedBox(width: 25),
                Text(
                  'Delivery at $addressType',
                  style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  textScaleFactor: 1.0,
                ),
                Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 15),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Text(
                '$flatHouseNo, $orderAddress, $landmark',
                style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
                textScaleFactor: 1.0,
              ),
            ),
            Divider(),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.phone),
                const SizedBox(width: 25),
                Text(
                  name,
                  style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(width: 12),
                Text(
                  mobile,
                  style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  textScaleFactor: 1.0,
                ),
                Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 15)
              ],
            )
          ],
        ),
      ),
    );
  }

  // Address card for when we need to use lastAddress from getOrderAddress
  Widget _buildAddressCard(dynamic lastAddress, String orderAddress) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  lastAddress?.addressType == 'Home'
                      ? Icons.home
                      : lastAddress?.addressType == 'Work'
                          ? Icons.work
                          : lastAddress?.addressType == 'Hotel'
                              ? Icons.hotel_rounded
                              : Icons.location_on,
                ),
                const SizedBox(width: 25),
                Text(
                  lastAddress != null
                      ? 'Delivery at ${lastAddress.addressType}'
                      : 'No Address Available',
                  style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  textScaleFactor: 1.0,
                ),
                Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 15),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Text(
                lastAddress != null
                    ? '${lastAddress.addressLine}, $orderAddress, ${lastAddress.addressType}'
                    : 'No address is added',
                style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
                textScaleFactor: 1.0,
              ),
            ),
            Divider(),
            const SizedBox(height: 5),
            lastAddress == null || lastAddress.name == null || lastAddress.mobile == null
                ? Row(
                    children: [
                      Icon(Icons.phone),
                      const SizedBox(width: 20),
                      Text(
                        'No Contact Details Added',
                        style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        textScaleFactor: 1.0,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.phone),
                      const SizedBox(width: 25),
                      Text(
                        lastAddress.name ?? '',
                        style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        textScaleFactor: 1.0,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        lastAddress.mobile ?? '',
                        style: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        textScaleFactor: 1.0,
                      ),
                      Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 15),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    String title,
    String productCode,
    String price,
    String oldPrice,
    String imageUrl,
    int count,
    String storeName,
    VoidCallback onDecrement,
    VoidCallback onIncrement,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 15),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Styles.textStyleMedium(context, color: AppColor.fillColor),
                      textScaleFactor: 1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Code: $productCode",
                      style: Styles.textStyleSmall(context, color: AppColor.hintTextColor),
                      textScaleFactor: 1,
                    ),
                    SizedBox(height: 5),
                    Text(
                      storeName,
                      style: Styles.textStyleSmall(context, color: Colors.grey),
                      textScaleFactor: 1,
                    ),
                  ],
                ),
              ),
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 193, 233, 170),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: onDecrement,
                      iconSize: 18,
                      padding: EdgeInsets.all(2),
                      constraints: BoxConstraints(),
                    ),
                    Text('$count', 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: onIncrement,
                      iconSize: 18,
                      padding: EdgeInsets.all(2),
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              // Price Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppConstants.Rupees}$price',
                    style: Styles.textStyleMedium(context, color: AppColor.fillColor),
                  ),
                  if (oldPrice.isNotEmpty)
                    Text(
                      '${AppConstants.Rupees}$oldPrice',
                      style: Styles.textStyleSmall(context, color: AppColor.hintTextColor).copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(height: 1),
        ],
      ),
    );
  }

  Widget shimmerSlotBox() {
    return Row(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }),
    );
  }
}
