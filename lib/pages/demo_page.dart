// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class LocationDisplayPage extends StatefulWidget {
// //   @override
// //   _LocationDisplayPageState createState() => _LocationDisplayPageState();
// // }

// // class _LocationDisplayPageState extends State<LocationDisplayPage> {
// //   String? savedLatitude;
// //   String? savedLongitude;
// //   String? savedAddress;

// //   // Flag to check if data is loading
// //   bool isLoading = true;

// //   // Function to retrieve saved location data as strings
// //   Future<void> getLocationData() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();

// //     // Retrieve latitude and longitude as double
// //     double? latitude = prefs.getDouble('latitude');
// //     double? longitude = prefs.getDouble('longitude');

// //     // Retrieve address as string
// //     String? address = prefs.getString('address');

// //     // Handle potential null values
// //     setState(() {
// //       savedLatitude = latitude?.toString() ?? 'Not Available';
// //       savedLongitude = longitude?.toString() ?? 'Not Available';
// //       savedAddress = address ?? 'Not Available';
// //     });

// //     print('Latitude: $savedLatitude');
// //     print('Longitude: $savedLongitude');
// //     print('Address: $savedAddress');
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Fetch location data when the page initializes
// //     getLocationData();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Saved Location Data'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child:
// //             // Show loading indicator
// //             Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Latitude: ${savedLatitude ?? 'Not Available'}',
// //               style: const TextStyle(fontSize: 18),
// //             ),
// //             SizedBox(height: 10),
// //             Text(
// //               'Longitude: ${savedLongitude ?? 'Not Available'}',
// //               style: const TextStyle(fontSize: 18),
// //             ),
// //             SizedBox(height: 10),
// //             Text(
// //               'Address: ${savedAddress ?? 'Not Available'}',
// //               style: const TextStyle(fontSize: 18),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';

// // class ScrollWithArrowButtonPage extends StatefulWidget {
// //   @override
// //   _ScrollWithArrowButtonPageState createState() =>
// //       _ScrollWithArrowButtonPageState();
// // }

// // class _ScrollWithArrowButtonPageState extends State<ScrollWithArrowButtonPage> {
// //   ScrollController _scrollController = ScrollController();
// //   bool _isButtonVisible = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Listen to the scroll position changes
// //     _scrollController.addListener(() {
// //       if (_scrollController.offset > MediaQuery.of(context).size.height) {
// //         if (!_isButtonVisible) {
// //           setState(() {
// //             _isButtonVisible = true; // Show the button
// //           });
// //         }
// //       } else {
// //         if (_isButtonVisible) {
// //           setState(() {
// //             _isButtonVisible = false; // Hide the button when scrolling back up
// //           });
// //         }
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Scroll and Arrow Button Example')),
// //       body: Stack(
// //         children: [
// //           // Your content in a SingleChildScrollView
// //           SingleChildScrollView(
// //             controller: _scrollController,
// //             child: Column(
// //               children: List.generate(30, (index) {
// //                 return Container(
// //                   height: 150,
// //                   margin: EdgeInsets.all(10),
// //                   color: index % 2 == 0 ? Colors.blue : Colors.orange,
// //                   child: Center(
// //                     child: Text(
// //                       'Item $index',
// //                       style: TextStyle(color: Colors.white),
// //                     ),
// //                   ),
// //                 );
// //               }),
// //             ),
// //           ),

// //           // Conditional arrow button that appears only when scrolled down
// //           if (_isButtonVisible)
// //             Positioned(
// //               bottom: 20,
// //               right: 20,
// //               child: FloatingActionButton(
// //                 onPressed: () {
// //                   // Scroll the content back to the top when clicked
// //                   _scrollController.animateTo(
// //                     0, // Scroll to top
// //                     duration: Duration(milliseconds: 300),
// //                     curve: Curves.easeInOut,
// //                   );
// //                 },
// //                 child: Icon(Icons.arrow_upward),
// //                 backgroundColor: Colors.blue,
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart'; // Import the intl package

// // class DemoPage extends StatefulWidget {
// //   const DemoPage({super.key});

// //   @override
// //   State<DemoPage> createState() => _DemoPageState();
// // }

// // class _DemoPageState extends State<DemoPage> {
// //   // List of time slots for morning, afternoon, and evening
// //   final List<Map<String, String>> morningSlots = [
// //     {"start": "7:00 AM", "end": "8:00 AM"},
// //     {"start": "8:00 AM", "end": "10:00 AM"},
// //     {"start": "10:00 AM", "end": "11:00 AM"},
// //   ];

// //   final List<Map<String, String>> afternoonSlots = [
// //     {"start": "12:00 PM", "end": "1:00 PM"},
// //     {"start": "1:00 PM", "end": "3:00 PM"},
// //     {"start": "3:00 PM", "end": "4:00 PM"},
// //   ];

// //   final List<Map<String, String>> eveningSlots = [
// //     {"start": "5:00 PM", "end": "6:00 PM"},
// //     {"start": "6:00 PM", "end": "7:00 PM"},
// //     {"start": "7:00 PM", "end": "8:00 PM"}, // This slot
// //   ];

// //   // Get the current time
// //   DateTime currentTime = DateTime.now();

// //   // Function to convert string time to DateTime for comparison
// //   DateTime convertToDateTime(String timeStr) {
// //     final format = DateFormat("h:mm a"); // Format matching "7:00 AM"
// //     DateTime dateTime = format.parse(timeStr);
// //     return DateTime(currentTime.year, currentTime.month, currentTime.day,
// //         dateTime.hour, dateTime.minute);
// //   }

// //   // Function to determine if a time slot is past, present, or future
// //   Color getSlotColor(DateTime slotStart, DateTime slotEnd) {
// //     if (currentTime.isAfter(slotEnd)) {
// //       return Colors.grey; // Past slot
// //     } else {
// //       return Colors.green; // Both present and future slots are green
// //     }
// //   }

// //   // Function to handle slot click and print the time (only for present/future slots)
// //   void onSlotClick(String startTime, String endTime) {
// //     print("Selected Time Slot: $startTime to $endTime");
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Time Slot Example")),
// //       body: ListView(
// //         padding: const EdgeInsets.all(8),
// //         children: [
// //           // Morning Slots
// //           _buildTimeSlotSection("Morning Slots", morningSlots),
// //           // Afternoon Slots
// //           _buildTimeSlotSection("Afternoon Slots", afternoonSlots),
// //           // Evening Slots
// //           _buildTimeSlotSection("Evening Slots", eveningSlots),
// //         ],
// //       ),
// //     );
// //   }

// //   // Helper function to create each time slot section (Morning, Afternoon, Evening)
// //   Widget _buildTimeSlotSection(String title, List<Map<String, String>> slots) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 10),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             title,
// //             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //           ),
// //           SizedBox(height: 10),
// //           // List of time slots
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: List.generate(slots.length, (index) {
// //               String startTime = slots[index]['start']!;
// //               String endTime = slots[index]['end']!;

// //               // Convert start and end times to DateTime objects for comparison
// //               DateTime slotStart = convertToDateTime(startTime);
// //               DateTime slotEnd = convertToDateTime(endTime);

// //               // Get the color based on the current time and slot time
// //               Color slotColor = getSlotColor(slotStart, slotEnd);

// //               // Only allow tap for present and future slots (not past slots)
// //               return GestureDetector(
// //                 onTap: (currentTime.isAfter(slotEnd))
// //                     ? null // Disable tap if it's past
// //                     : () {
// //                         // Call onSlotClick when the slot is clicked (present/future)
// //                         onSlotClick(startTime, endTime);
// //                       },
// //                 child: Container(
// //                   width: 90,
// //                   height: 60,
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     color: slotColor,
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: Colors.black),
// //                   ),
// //                   child: Text(
// //                     '$startTime\n-$endTime',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       color:
// //                           Colors.white, // White text for present/future slots
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             }),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // import 'package:farms/provider/user_provider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class FruitsPage extends StatefulWidget {
// //   @override
// //   _FruitsPageState createState() => _FruitsPageState();
// // }

// // class _FruitsPageState extends State<FruitsPage> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Fetch fruits data as soon as the widget is initialized
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final provider = Provider.of<UserProvider>(context, listen: false);
// //       provider.getFruits();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Fruits List"),
// //       ),
// //       body: Consumer<UserProvider>(
// //         builder: (context, provider, child) {
// //           // Show a loading indicator if the provider is loading
// //           if (provider.isLoading) {
// //             return Center(child: CircularProgressIndicator());
// //           }

// //           // Show a message if there are no fruits available
// //           if (provider.fruitsList.isEmpty) {
// //             return Center(child: Text("No fruits available"));
// //           }

// //           // Display the list of fruits in a ListView
// //           return ListView.builder(
// //             itemCount: provider.fruitsList.length,
// //             itemBuilder: (context, index) {
// //               final fruit = provider.fruitsList[index];
// //               return ListTile(
// //                 leading: Image.network(
// //                   fruit.fruitImage,
// //                   errorBuilder: (context, error, stackTrace) =>
// //                       Icon(Icons.image_not_supported),
// //                 ),
// //                 title: Text(fruit.fruitName),
// //                 subtitle:
// //                     Text("${fruit.fruitSubname} - ₹${fruit.currentPrice}"),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// // import 'dart:convert';
// // import 'package:farms/model/fruits_model.dart';
// // import 'package:http/http.dart' as http;

// // class ApiService {
// //   final String baseUrl =
// //       'https://tabsquareinfotech.com/App/Abinesh_be_work/tsit_farms/public/api/farmsGetFruits';

// //   Future<List<Fruit>> fetchFruits() async {
// //     try {
// //       final response = await http.post(Uri.parse(baseUrl));

// //       if (response.statusCode == 200) {
// //         List<dynamic> data = json.decode(response.body);
// //         return data.map((item) => Fruit.fromJson(item)).toList();
// //       } else {
// //         throw Exception('Failed to load fruits');
// //       }
// //     } catch (e) {
// //       throw Exception('Failed to load fruits: $e');
// //     }
// //   }
// // }

// // import 'dart:developer';

// // import 'package:farms/customs/styles.dart';
// // import 'package:farms/provider/get_provider.dart';
// // import 'package:farms/util/color_constant.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:shimmer/shimmer.dart';

// // class DemoPage extends StatefulWidget {
// //   const DemoPage({super.key});

// //   @override
// //   State<DemoPage> createState() => _DemoPageState();
// // }

// // class _DemoPageState extends State<DemoPage> {
// //   String token = '';
// //   double TotalCurrentPrice = 0;
// //   double TotalOldPrice = 0;
// //   GetProvider get getprovider => context.read<GetProvider>();

// //   getdata() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       token = prefs.getString('token') ?? '';
// //       print(token);
// //       log('Token: $token');
// //     });

// //     await getprovider.fetchAddToCart(token);
// //     // Call the method to update the totals after fetching data
// //     recalculateTotalPrice();
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     getdata();
// //   }

// //   // Method to recalculate total current and old prices
// //   void recalculateTotalPrice() {
// //     double totalCurrentPrice = 0;
// //     double totalOldPrice = 0;

// //     getprovider.getAddToCart.forEach((item) {
// //       totalCurrentPrice += (item.currentPrice ?? 0.0) * (item.count ?? 0);
// //       totalOldPrice += (item.oldPrice ?? 0.0) * (item.count ?? 0);
// //     });

// //     setState(() {
// //       TotalCurrentPrice = totalCurrentPrice;
// //       TotalOldPrice = totalOldPrice;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         body: SingleChildScrollView(
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 15),
// //         child: Column(
// //           children: [
// //             Consumer<GetProvider>(
// //               builder: (context, cartProvider, child) {
// //                 if (cartProvider.getAddToCart.isEmpty) {
// //                   return ListView.builder(
// //                     shrinkWrap: true,
// //                     physics: NeverScrollableScrollPhysics(),
// //                     itemCount: 5,
// //                     itemBuilder: (context, index) => Padding(
// //                       padding: const EdgeInsets.symmetric(vertical: 10.0),
// //                       child: Shimmer.fromColors(
// //                         baseColor: Colors.grey[300]!,
// //                         highlightColor: Colors.grey[100]!,
// //                         child: Row(
// //                           children: [
// //                             // Shimmer Image
// //                             Container(
// //                               height: 70,
// //                               width: 70,
// //                               margin: const EdgeInsets.only(right: 10),
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 color: Colors.grey[300],
// //                               ),
// //                             ),
// //                             // Shimmer Text
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Container(
// //                                     height: 15,
// //                                     width: 150,
// //                                     color: Colors.grey[300],
// //                                     margin: const EdgeInsets.only(bottom: 5),
// //                                   ),
// //                                   Container(
// //                                     height: 12,
// //                                     width: 100,
// //                                     color: Colors.grey[300],
// //                                     margin: const EdgeInsets.only(bottom: 10),
// //                                   ),
// //                                   Container(
// //                                     height: 12,
// //                                     width: 70,
// //                                     color: Colors.grey[300],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 }

// //                 return Column(
// //                   children: [
// //                     // ListView.builder for the cart items
// //                     ListView.builder(
// //                       shrinkWrap: true,
// //                       physics: NeverScrollableScrollPhysics(),
// //                       itemCount: cartProvider.getAddToCart.length,
// //                       itemBuilder: (context, index) {
// //                         final item = cartProvider.getAddToCart[index];

// //                         return Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                           child: Container(
// //                             height: MediaQuery.of(context).size.height * 0.12,
// //                             width: double.infinity,
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(20),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: Colors.grey.withOpacity(0.5),
// //                                   spreadRadius: 2,
// //                                   blurRadius: 5,
// //                                   offset: Offset(0, 3),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: Padding(
// //                               padding:
// //                                   const EdgeInsets.symmetric(horizontal: 5),
// //                               child: Row(
// //                                 mainAxisAlignment: MainAxisAlignment.start,
// //                                 children: [
// //                                   // Image Container
// //                                   Container(
// //                                     height: 70,
// //                                     width: 70,
// //                                     margin: const EdgeInsets.all(10),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.white,
// //                                       borderRadius: BorderRadius.circular(8),
// //                                       boxShadow: [
// //                                         BoxShadow(
// //                                           color: Colors.grey.withOpacity(0.5),
// //                                           spreadRadius: 1,
// //                                           blurRadius: 5,
// //                                           offset: Offset(0, 2),
// //                                         ),
// //                                       ],
// //                                       image: DecorationImage(
// //                                         image:
// //                                             NetworkImage(item.fruitImage ?? ''),
// //                                         fit: BoxFit.cover,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   SizedBox(width: 10),
// //                                   // Product Details Column
// //                                   Expanded(
// //                                     child: FittedBox(
// //                                       fit: BoxFit.scaleDown,
// //                                       child: Column(
// //                                         crossAxisAlignment:
// //                                             CrossAxisAlignment.start,
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.center,
// //                                         children: [
// //                                           Text(
// //                                             item.fruitName ?? 'Unknown',
// //                                             style: Styles.textStyleMedium(
// //                                                 context,
// //                                                 color: AppColor.fillColor),
// //                                             textScaleFactor: 1.0,
// //                                             overflow: TextOverflow.ellipsis,
// //                                           ),
// //                                           Text(
// //                                             item.fruitSubname ?? '',
// //                                             style: Styles.textStyleSmall(
// //                                                 context,
// //                                                 color: AppColor.hintTextColor),
// //                                             textScaleFactor: 1.0,
// //                                             overflow: TextOverflow.ellipsis,
// //                                           ),
// //                                           Text(
// //                                             item.fruitsQuantity ?? '',
// //                                             style: Styles.textStyleSmall(
// //                                                 context,
// //                                                 color: AppColor.hintTextColor),
// //                                             textScaleFactor: 1.0,
// //                                             overflow: TextOverflow.ellipsis,
// //                                           ),
// //                                           Row(
// //                                             children: [
// //                                               Text(
// //                                                 '₹${item.currentPrice?.toStringAsFixed(2) ?? '0.00'}',
// //                                                 style: Styles.textStyleSmall(
// //                                                     context,
// //                                                     color: AppColor.blackColor),
// //                                                 textScaleFactor: 1.0,
// //                                                 overflow: TextOverflow.ellipsis,
// //                                               ),
// //                                               SizedBox(width: 10),
// //                                               if (item.oldPrice != null)
// //                                                 Text(
// //                                                   '₹${item.oldPrice?.toStringAsFixed(2) ?? '0.00'}',
// //                                                   style: Styles
// //                                                           .textStyleExtraSmall(
// //                                                               context,
// //                                                               color: AppColor
// //                                                                   .hintTextColor)
// //                                                       .copyWith(
// //                                                           decoration:
// //                                                               TextDecoration
// //                                                                   .lineThrough),
// //                                                   textScaleFactor: 1.0,
// //                                                   overflow:
// //                                                       TextOverflow.ellipsis,
// //                                                 ),
// //                                             ],
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   // Counter Section
// //                                   Row(
// //                                     children: [
// //                                       // Decrease Button
// //                                       IconButton(
// //                                         icon: const Icon(
// //                                           Icons.remove,
// //                                           color: Colors.red,
// //                                         ),
// //                                         onPressed: () async {
// //                                           // Decrease the item count if it's not null and greater than 0
// //                                           setState(() {
// //                                             if (item.count != null &&
// //                                                 item.count! > 0) {
// //                                               item.count = item.count! - 1;
// //                                             }
// //                                             // Recalculate prices after updating the count
// //                                             recalculateTotalPrice();
// //                                           });
// //                                         },
// //                                       ),

// //                                       // Display the item count
// //                                       Text(
// //                                         item.count?.toString() ?? '0',
// //                                       ),

// //                                       // Increase Button
// //                                       IconButton(
// //                                         icon: const Icon(
// //                                           Icons.add,
// //                                           color: AppColor.fillColor,
// //                                         ),
// //                                         onPressed: () async {
// //                                           // Increase the item count if it's not null
// //                                           setState(() {
// //                                             if (item.count != null) {
// //                                               item.count = item.count! + 1;
// //                                             }
// //                                             // Recalculate prices after updating the count
// //                                             recalculateTotalPrice();
// //                                           });
// //                                         },
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),

// //                     // SizedBox for spacing between ListView and the total amount display
// //                     SizedBox(height: 20),
// //                   ],
// //                 );
// //               },
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //               child: Column(
// //                 children: [
// //                   Text(
// //                     'Total Current Price: ₹${TotalCurrentPrice.toStringAsFixed(2)}',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 18,
// //                       color: Colors.black,
// //                     ),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     'Total Old Price: ₹${TotalOldPrice.toStringAsFixed(2)}',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 18,
// //                       color: Colors.grey,
// //                       decoration: TextDecoration.lineThrough,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     ));
// //   }
// // }
// import 'dart:developer';



// import 'package:flutter/material.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/model/getAddToCart_model.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DemoPage extends StatefulWidget {
//   const DemoPage({super.key});

//   @override
//   State<DemoPage> createState() => _DemoPageState();
// }

// class _DemoPageState extends State<DemoPage> {
//   String token = '';
//   double TotalCurrentPrice = 0;
//   double TotalOldPrice = 0;
//   double totalSavings = 0;
//   final Map<String, int> itemCounts = {};
//   final Map<String, bool> isAddedToCartMap = {};
//   final Map<String, bool> isFavorite = {};
//   int currentIndex = 0;
//   Map<String, int> productCount = {};
//   // bool isAnyItemAdded() {
//   //   return isAddedToCartMap.values.contains(true);
//   // }

//   Map<String, String> selectedWeights = {};

//   GetProvider get getprovider => context.read<GetProvider>();

//   getdata() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token') ?? '';
//       log('Token: $token');
//     });
//    // await getprovider.fetchFruits();
//     recalculateTotalPrice();
//   }

//   void recalculateTotalPrice() {
//     double totalCurrentPrice = 0;
//     double totalOldPrice = 0;

//     getprovider.getAddToCart.forEach((item) {
//       totalCurrentPrice += (item.currentPrice ?? 0.0) * (item.count ?? 0);
//       totalOldPrice += (item.oldPrice ?? 0.0) * (item.count ?? 0);
//     });

//     setState(() {
//       TotalCurrentPrice = totalCurrentPrice;
//       TotalOldPrice = totalOldPrice;
//       totalSavings = totalOldPrice - totalCurrentPrice;
//     });
//   }

//   // Future<void> _fetchCartData() async {
//   //   try {
//   //     // Fetch cart data
//   //     final cartData = await context.read<GetProvider>().fetchAddToCart(token);

//   //     // Process the fetched data
//   //     for (var item in cartData) {
//   //       final categoryId = item.fruitCategoryId;
//   //       final count = item.count;

//   //       if (categoryId != null) {
//   //         itemCounts[categoryId] = count ?? 0;
//   //         isAddedToCartMap[categoryId] = true;
//   //         print('Cart Data: Category ID: $categoryId, Count: $count');
//   //         log('Cart Data: Category ID: $categoryId, Count: ${itemCounts[categoryId]}');
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching cart data: $e');
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     getdata();
//     // _fetchCartData();
//   }

//   // Add the isFruitInCart function here
//   bool isFruitInCart(String fruitId, List<GetaddtocartModel> cartItems) {
//     return cartItems.any((item) => item.fruitsId == fruitId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;

//     //final cartItems = getprovider.getAddToCart;
//     // Helper function for incrementing items
//     void incrementItem(String? categoryId) {
//       if (categoryId == null) return;
//       setState(() {
//         itemCounts[categoryId] = (itemCounts[categoryId] ?? 0) + 1;
//         isAddedToCartMap[categoryId] = true;
//       });

//       log("Incremented Item: Category ID: $categoryId, Count: ${itemCounts[categoryId]}");
//     }

//     // Helper function for decrementing items
//     void decrementItem(String? categoryId) {
//       if (categoryId == null) return;
//       setState(() {
//         if ((itemCounts[categoryId] ?? 0) > 0) {
//           itemCounts[categoryId] =
//               (itemCounts[categoryId]! - 1).clamp(0, double.infinity).toInt();
//         }
//         if (itemCounts[categoryId] == 0) {
//           isAddedToCartMap[categoryId] = false;
//         }
//       });

//       log("Decremented Item: Category ID: $categoryId, Count: ${itemCounts[categoryId]}");
//     }

//     // Helper function for toggling favorites
//     void toggleFavorite(String? fruitId) {
//       if (fruitId == null) return;
//       setState(() {
//         isFavorite[fruitId] = !(isFavorite[fruitId] ?? false);
//       });

//       log("Favorite Toggled for Fruit ID: $fruitId");
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 for (var item in [
//                   {
//                     'label': 'Total MRP Price:',
//                     'value': TotalOldPrice.toStringAsFixed(2)
//                   },
//                   {
//                     'label': 'Your Savings:',
//                     'value': totalSavings.toStringAsFixed(2)
//                   },
//                   {
//                     'label': 'Delivery Fees',
//                     'value': '30.00',
//                     'strikethrough': true
//                   },
//                 ])
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           item['label'] as String,
//                           style: Styles.textStyleMedium(context,
//                               color: const Color.fromARGB(255, 255, 255, 255)),
//                           textScaleFactor: 1.0,
//                         ),
//                         Text(
//                           '₹${item['value']}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: const Color.fromARGB(255, 255, 255, 255),
//                             decoration: item['strikethrough'] == true
//                                 ? TextDecoration.lineThrough
//                                 : null,
//                           ),
//                           textScaleFactor: 1.0,
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Consumer<GetProvider>(
//                 //   builder: (context, fruitProvider, child) {
//                 //     return FruitGridView(
//                 //       fruits: fruitProvider.fruits,
//                 //       screenHeight: screenHeight,
//                 //       screenWidth: screenWidth,
//                 //       isAdded: isAddedToCartMap,
//                 //       productCount: itemCounts,
//                 //       isFavorite: isFavorite,
//                 //       onAdd: (fruit) => incrementItem(fruit.fruitCategoryId),
//                 //       onRemove: (fruit) => decrementItem(fruit.fruitCategoryId),
//                 //       onFavoriteToggle: (fruit) =>
//                 //           toggleFavorite(fruit.fruitsId),
//                 //       onTap: (fruit) {
//                 //         Navigator.push(
//                 //           context,
//                 //           MaterialPageRoute(
//                 //             builder: (context) => ProductDetailsPage(
//                 //               productId: fruit.fruitsId ?? '',
//                 //             ),
//                 //           ),
//                 //         );
//                 //       },
//                 //     );
//                 //   },
//                 // ),
//                 // if (isAnyItemAdded()) SizedBox(height: screenHeight * 0.15),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
