// import 'package:farms/pages/product_cart_widget.dart';
// import 'package:farms/provider/get_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class FruitListScreen extends StatefulWidget {
//   @override
//   _FruitListScreenState createState() => _FruitListScreenState();
// }

// class _FruitListScreenState extends State<FruitListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Call fetchFruits only once when the widget is initialized
//     final fruitProvider = Provider.of<GetProvider>(context, listen: false);
//     fruitProvider.fetchFruits();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fruits'),
//       ),
//       body: SingleChildScrollView(
//         child: Consumer<GetProvider>(
//           builder: (context, fruitProvider, child) {
//             if (fruitProvider.fruits.isEmpty) {
//               return Center(child: CircularProgressIndicator());
//             }

//             return GridView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // Adjust the number of columns as needed
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: (screenHeight * 0.125) / (screenWidth * 0.43),
//               ),
//               itemCount: fruitProvider.fruits.length,
//               itemBuilder: (context, index) {
//                 final fruit = fruitProvider.fruits[index];
//                 return ProductCard(
//                   image: fruit.fruitImage,
//                   name: fruit.fruitName,
//                   subname: fruit.fruitSubname,
//                   price: fruit.currentPrice,
//                   oldPrice: fruit.oldPrice ?? '', // Handling null for oldPrice
//                   weights: fruit.fruitsquntity,
//                   // Example, you can change based on your needs
//                   selectedWeight:
//                       fruit.fruitsquntity, // Default selected weight
//                   onChanged: (newValue) {
//                     // Handle weight selection
//                   },
//                   isAdded: false, // Adjust based on your cart management logic
//                   onAdd: () {
//                     // Handle Add to cart action
//                   },
//                   onRemove: () {
//                     // Handle Remove from cart action
//                   },
//                   count: 0, // The count of the selected product
//                   onFavoriteToggle: () {
//                     // Handle favorite toggle
//                   },
//                   isFavorite:
//                       false, // Adjust based on whether the item is a favorite
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// // }
// import 'package:farms/provider/get_provider.dart';
// import 'package:farms/util/app_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AddressListView extends StatefulWidget {
//   const AddressListView({Key? key}) : super(key: key);

//   @override
//   State<AddressListView> createState() => _AddressListViewState();
// }

// class _AddressListViewState extends State<AddressListView> {
//   String token = '';
//   late GetProvider getprovider;

//   @override
//   void initState() {
//     super.initState();
//     getprovider = context.read<GetProvider>();
//     _getData();
//   }

//   Future<void> _getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final fetchedToken = prefs.getString(AppConstants.token);

//     if (fetchedToken != null && fetchedToken.isNotEmpty) {
//       setState(() {
//         token = fetchedToken;
//       });
//       await getprovider.fetchOrderAddress(token);
//     } else {
//       // Handle missing token
//       print("Token not found");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Order Addresses"),
//         backgroundColor: Colors.green,
//       ),
//       body: Consumer<GetProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.getOrderAddress.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No addresses found!",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: provider.getOrderAddress.length,
//             itemBuilder: (context, index) {
//               final address = provider.getOrderAddress[index];
//               final selectedAddress = address.addressType ?? "Unknown";
//               final flatHouseNo = address.buildingNumber ?? "";
//               final _address = address.address ?? "";
//               final landmark = address.nearbyLandmark ?? "";
//               final Delmobile = address.mobile ?? "N/A";

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 26),
//                   width: screenWidth,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 5,
//                         spreadRadius: 2,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'DELIVERS TO',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.01),
//                         Row(
//                           children: [
//                             Icon(
//                               selectedAddress == 'Home'
//                                   ? Icons.home
//                                   : selectedAddress == 'Work'
//                                       ? Icons.work
//                                       : selectedAddress == 'Hotel'
//                                           ? Icons.hotel_rounded
//                                           : Icons.location_on,
//                               color: Colors.green,
//                             ),
//                             const SizedBox(width: 25),
//                             Expanded(
//                               child: Text(
//                                 selectedAddress,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 45),
//                           child: Text(
//                             _address.isEmpty && flatHouseNo.isEmpty
//                                 ? 'No address is added'
//                                 : '$flatHouseNo, $_address, $landmark',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 3,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 45, top: 5),
//                           child: Text(
//                             'Phone Number: $Delmobile',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'dart:developer';

// import 'package:farms/model/dailyBookingSlot_model.dart';
// import 'package:farms/util/constant_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:farms/provider/get_provider.dart';

// class Demo2 extends StatefulWidget {
//   @override
//   _Demo2State createState() => _Demo2State();
// }

// class _Demo2State extends State<Demo2> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       Provider.of<GetProvider>(context, listen: false).fetchDailyBookingSlot();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(title: Text("Available Slots")),
//       body: Consumer<GetProvider>(
//         builder: (context, getProvider, child) {
//           final List<DailybookingslotModel> slots = getProvider.getDailySlot;

//           if (slots.isEmpty) {
//             return Center(child: CircularProgressIndicator());
//           }

//           // ** Group Slots Based on Schedule **
//           List<Map<String, String>> morningSlots = [];
//           List<Map<String, String>> afternoonSlots = [];
//           List<Map<String, String>> eveningSlots = [];

//           for (var slot in slots) {
//             Map<String, String> slotData = {
//               'start': slot.startTime ?? "N/A",
//               'end': slot.endTime ?? "N/A",
//               'schedule': slot.slotschedule ?? "N/A"
//             };

//             if (slot.slotschedule == "Morning booking slot") {
//               morningSlots.add(slotData);
//             } else if (slot.slotschedule == "Afternoon booking slot") {
//               afternoonSlots.add(slotData);
//             } else if (slot.slotschedule == "Evening booking slot" ||
//                 slot.slotschedule == "Evening  booking slot") {
//               eveningSlots.add(slotData);
//             }
//           }
// // ** Sorting function to order slots by start time **
//           int compareSlots(Map<String, String> a, Map<String, String> b) {
//             DateTime? startA = convertToDateTime(a['start']!);
//             DateTime? startB = convertToDateTime(b['start']!);

//             if (startA == null || startB == null) return 0;
//             return startA.compareTo(startB);
//           }

// // ** Sort each slot list **
//           morningSlots.sort(compareSlots);
//           afternoonSlots.sort(compareSlots);
//           eveningSlots.sort(compareSlots);

//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 5,
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(height: screenHeight * 0.07),
//                   buildBookingSlot("Morning Booking Slot",
//                       ConstantImageKey.morning, morningSlots),
//                   SizedBox(height: screenHeight * 0.05),
//                   buildBookingSlot("Afternoon Booking Slot",
//                       ConstantImageKey.evening, afternoonSlots),
//                   SizedBox(height: screenHeight * 0.05),
//                   buildBookingSlot("Evening Booking Slot",
//                       ConstantImageKey.night, eveningSlots),
//                   SizedBox(height: screenHeight * 0.05),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildBookingSlot(
//       String title, String imagePath, List<Map<String, String>> slots) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: 30,
//           ),
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             children: [
//               SizedBox(height: 40),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: slots.map((slot) {
//                   String startTime = slot['start']!;
//                   String endTime = slot['end']!;
//                   String schedule = slot['schedule']!;

//                   // ** Convert Time Strings to DateTime **
//                   DateTime now = DateTime.now();
//                   DateTime? slotStart = convertToDateTime(startTime);
//                   DateTime? slotEnd = convertToDateTime(endTime);

//                   // ** Determine Slot Color **
//                   Color slotColor;
//                   bool isSlotEnabled;

//                   if (slotStart == null || slotEnd == null) {
//                     slotColor = Colors.grey;
//                     isSlotEnabled = false;
//                   } else if (now.isBefore(slotStart)) {
//                     // Future slot (Enable)
//                     slotColor = Colors.green;
//                     isSlotEnabled = true;
//                   } else if (now.isAfter(slotEnd)) {
//                     // Past slot (Disable)
//                     slotColor = Colors.grey;
//                     isSlotEnabled = false;
//                   } else {
//                     // Active slot (Enable)
//                     slotColor = Colors.green;
//                     isSlotEnabled = true;
//                   }

//                   return GestureDetector(
//                     onTap: isSlotEnabled
//                         ? () {
//                             print(
//                                 "Selected Slot: $startTime - $endTime, Schedule: $schedule");
//                             log("Selected Slot: $startTime - $endTime, Schedule: $schedule");
//                           }
//                         : null, // Disable tap for past slots
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//                       decoration: BoxDecoration(
//                         color: slotColor,
//                         borderRadius: BorderRadius.circular(5),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.alarm, color: Colors.white),
//                           SizedBox(width: 5),
//                           Text(
//                             '$startTime - $endTime',
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//         Positioned(
//           bottom: MediaQuery.of(context).size.height * 0.185,
//           left: 25,
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.1,
//             width: MediaQuery.of(context).size.width * 0.8,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(color: Colors.blue, width: 5),
//               image: DecorationImage(
//                 image: AssetImage(imagePath),
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ** Convert "hh:mm a" to DateTime (Handles AM/PM) **
//   DateTime? convertToDateTime(String time) {
//     try {
//       DateTime now = DateTime.now();
//       DateFormat format =
//           DateFormat("hh:mm a"); // Expecting time in AM/PM format
//       DateTime parsedTime = format.parse(time);
//       return DateTime(
//           now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
//     } catch (e) {
//       print("Time Parsing Error: $e");
//       return null; // Return null for invalid format
//     }
//   }
// }

// import 'package:farms/customs/styles.dart';
// import 'package:farms/model/getAll_categeory/getAll_category_model.dart';
// import 'package:farms/provider/get_provider.dart';
// import 'package:farms/util/color_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'dart:developer';

// class CategoryScroller extends StatefulWidget {
//   @override
//   _CategoryScrollerState createState() => _CategoryScrollerState();
// }

// class _CategoryScrollerState extends State<CategoryScroller> {
//   List<GetallCategoryModel> categories = [];
//   int currentIndex = 2; // Default middle index
//   GetProvider get getprovider => context.read<GetProvider>();
//   @override
//   void initState() {
//     super.initState();
//     fetchCategories();
//   }

//   Future<void> fetchCategories() async {
//     try {
//       categories =  getprovider.category;
//       setState(() {});
//     } catch (e) {
//       print("Error fetching categories: $e");
//     }
//   }

//   void scrollRight() async {
//     setState(() {
//       GetallCategoryModel first = categories.removeAt(0);
//       categories.add(first);
//     });
//     await _handleIndexChange();
//   }

//   void scrollLeft() async {
//     setState(() {
//       GetallCategoryModel last = categories.removeLast();
//       categories.insert(0, last);
//     });
//     await _handleIndexChange();
//   }

//   Future<void> _handleIndexChange() async {
//     String currentCategory = categories[currentIndex].name!;
//     print("Current Index: $currentIndex, Category: $currentCategory");
//     log("Current Index: $currentIndex, Category: $currentCategory");

//     try {
//       switch (currentIndex) {
//         case 0:
//           await getprovider.fetchDairy();
//           break;
//         case 1:
//           await getprovider.fetchGrocery();
//           break;
//         case 2:
//           await getprovider.fetchVegetable();
//           break;
//         case 3:
//           await getprovider.fetchFoodCorts();
//           break;
//         case 4:
//           //await getprovider.fetchFruits();
//           break;
//         default:
//           print("No API call for Index: $currentIndex");
//       }
//     } catch (e) {
//       print("Error fetching data for index $currentIndex: $e");
//     }
//   }

//   void selectIndex(int index) async {
//     if (index == 2) return; // Prevent swapping with itself

//     setState(() {
//       GetallCategoryModel temp = categories[index];
//       categories[index] = categories[2];
//       categories[2] = temp;
//     });
//     await _handleIndexChange();
//   }

//   Widget buildImageContainer(GetallCategoryModel category) {
//     return Container(
//       height: 50,
//       width: 50,
//       decoration: BoxDecoration(
//         color: AppColor.fillColor,
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(
//           image: NetworkImage(category.image!),
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }

//   Widget buildAnimatedContainer(GetallCategoryModel category) {
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
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: NetworkImage(category.image!),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Expanded(
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 category.name!,
//                 style:
//                     Styles.textStyleSmall(context, color: AppColor.blackColor),
//                 textScaleFactor: 1.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
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
//           children: List.generate(categories.length, (index) {
//             return GestureDetector(
//               onTap: () {
//                 selectIndex(index);
//               },
//               child: index == 2
//                   ? buildAnimatedContainer(categories[index])
//                   : buildImageContainer(categories[index]),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Demo2 extends StatefulWidget {
  @override
  _Demo2State createState() => _Demo2State();
}

class _Demo2State extends State<Demo2> {
  Completer<GoogleMapController> _controller = Completer();
  final TextEditingController searchController = TextEditingController();

  static const String googleApiKey = 'AIzaSyCemA7pZSzNgEfnp77-LLvKJkODkPUGkCU';
  LatLng? currentLatLng;
  List<dynamic> placePredictions = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng!, 15));
  }

  Future<void> getPlacePredictions(String input) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': googleApiKey,
          'components': 'country:in',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          placePredictions = data['predictions'];
        });
      } else {
        print('Failed to fetch predictions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching place predictions: $e');
    }
  }

  Future<LatLng?> getPlaceLatLng(String placeId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {'place_id': placeId, 'key': googleApiKey},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final location = data['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return null;
  }

  Future<void> _gotoLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  currentLatLng ?? LatLng(20.5937, 78.9629), // Default India
              zoom: 5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        getPlacePredictions(value);
                      } else {
                        setState(() => placePredictions.clear());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Search for a location",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (placePredictions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: placePredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(placePredictions[index]['description']),
                          onTap: () async {
                            final placeId = placePredictions[index]['place_id'];
                            final location = await getPlaceLatLng(placeId);
                            if (location != null) {
                              searchController.text =
                                  placePredictions[index]['description'];
                              setState(() => placePredictions.clear());
                              _gotoLocation(location);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: Icon(Icons.my_location),
              label: Text("Use Current Location"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _determinePosition(),
            ),
          ),
        ],
      ),
    );
  }
}









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

//   // List<GetfruitsCategoryModel> selectProduct = [];

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

//     getprovider.fetchBanner();
//     fetchCategories();

//     // _fetchCartData();
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
//     await _fetchCartData();
//     await _fetchWishlistData();
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
//                               builder: (context, allCategoryProvider, child) {
//                                 if (isLoading) {
//                                   return const Center(
//                                     child:
//                                         CircularProgressIndicator(), // Show loader while fetching
//                                   );
//                                 }

//                                 // 🔥 Combine all products from all categories
//                                 List<ProductModel> allProducts =
//                                     allCategoryProvider.category
//                                         .expand((category) => category.products)
//                                         .toList();

//                                 // 🔍 Filter products based on search query
//                                 List<ProductModel> filteredProducts =
//                                     allProducts
//                                         .where(
//                                           (product) => product.name
//                                               .toLowerCase()
//                                               .contains(
//                                                 _searchQuery.toLowerCase(),
//                                               ),
//                                         )
//                                         .toList();

//                                 // 🛒 Convert to custom Product model if needed
//                                 List<Product>
//                                 finalProducts = filteredProducts.map((product) {
//                                   return Product(
//                                     id: product.id,
//                                     categoryId:
//                                         '', // You can pass category id if needed
//                                     name: product.name,
//                                     subname:
//                                         '', // If you don't have subname, leave blank
//                                     image: product.productImage,
//                                     // weights: [], // If quantity list is available, map here
//                                     currentPrice:
//                                         product.discountPrice ??
//                                         product.mrpPrice,
//                                     oldPrice: product.mrpPrice,
//                                     count: product.showAvlQty,
//                                   );
//                                 }).toList();
//                                 // Consumer<GetProvider>(
//                                 //   builder: (context, allproductprovider, child) {
//                                 //     if (isLoading) {
//                                 //       return Center(
//                                 //         child:
//                                 //             CircularProgressIndicator(), // Show loader
//                                 //       );
//                                 //     }

//                                 //     // 🔥 Filter products based on search query
//                                 //     List<Product>
//                                 //     filteredProducts = allproductprovider.getproduct
//                                 //         .where(
//                                 //           (getproduct) =>
//                                 //               getproduct.name
//                                 //                   ?.toLowerCase()
//                                 //                   .contains(_searchQuery) ??
//                                 //               false,
//                                 //         )
//                                 //         .map((getproduct) {
//                                 //           return Product(
//                                 //             id: getproduct.id,
//                                 //             categoryId: getproduct.subcategoryid,
//                                 //             name: getproduct.name,
//                                 //             subname: getproduct.subname,
//                                 //             image: getproduct.image,
//                                 //             weights: getproduct.quantity,
//                                 //             currentPrice: getproduct.currentPrice,
//                                 //             oldPrice: getproduct.oldPrice,
//                                 //             count: getproduct.count,
//                                 //           );
//                                 //         })
//                                 //         .toList();

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
//                                           categoryId: product.id!,
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
//                                       if (!(isAdded[product.id] ?? false)) {
//                                         isAdded[product.id!] = true;
//                                         itemCounts[product.id!] = 1;
//                                       } else {
//                                         itemCounts[product.id!] = 1;
//                                       }
//                                       print(
//                                         "Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                       );
//                                       log(
//                                         "Added Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                       );
//                                     });

//                                     try {
//                                       await AppDialogue.openLoadingDialogAfterClose(
//                                         context,
//                                         text: "Adding to cart...",
//                                         load: () async {
//                                           // return await allproductprovider
//                                           //     .addToCart(
//                                           //       fruitId: product.id!,
//                                           //       categoryId: product.id!,
//                                           //       count:
//                                           //           itemCounts[product
//                                           //               .id] ??
//                                           //           0,
//                                           //       token: token,
//                                           //     );
//                                         },
//                                         afterComplete: (resp) async {
//                                           // if (resp.status) {
//                                           //   AppDialogue.toast(resp.data);
//                                           // }
//                                         },
//                                       );
//                                     } on Exception catch (e) {
//                                       ExceptionHandler.showMessage(context, e);
//                                     }

//                                     // await allproductprovider.fetchAddToCart(
//                                     //   token,
//                                     // );
//                                     await recalculateTotalPrice();
//                                   },
//                                   onRemove: (product) async {
//                                     setState(() {
//                                       if ((itemCounts[product.id!] ?? 0) > 0) {
//                                         itemCounts[product.id!] =
//                                             (itemCounts[product.id!] ?? 0) - 1;

//                                         print(
//                                           "Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                         );
//                                         log(
//                                           "Decremented Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                         );

//                                         recalculateTotalPrice();

//                                         if (itemCounts[product.id!] == 0) {
//                                           isAdded[product.id!] = false;
//                                         }
//                                       }
//                                     });

//                                     _debounceApiCall(
//                                       product.id ?? '',
//                                       itemCounts[product.id!] ?? 0,
//                                       token,
//                                     );
//                                   },
//                                   onIncrease: (product) async {
//                                     setState(() {
//                                       itemCounts[product.id!] =
//                                           (itemCounts[product.id!] ?? 0) + 1;

//                                       print(
//                                         "Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                       );
//                                       log(
//                                         "Increased Item: Name: ${product.name}, ID: ${product.id}, Count: ${itemCounts[product.id!]}",
//                                       );

//                                       recalculateTotalPrice();
//                                     });

//                                     _debounceApiCall(
//                                       product.id ?? '',
//                                       itemCounts[product.id!] ?? 0,
//                                       token,
//                                     );
//                                   },
//                                   onFavoriteToggle: (product) async {
//                                     setState(() {
//                                       bool favoriteStatus =
//                                           !(isFavorite[product.id] ?? false);
//                                       isFavorite[product.id ?? ''] =
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
//                                             categoryId: product.id!,
//                                             token: token,
//                                             isCondtion:
//                                                 isFavorite[product.id] ?? false,
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
//           allCategories = List.from(getprovider.category);

//           if (allCategories.isNotEmpty) {
//             visibleCategories = allCategories.length >= 5
//                 ? allCategories.take(5).toList()
//                 : List.from(allCategories);
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
//     _handleIndexChange();
//   }

//   void scrollRight() {
//     if (allCategories.length < 5) return;

//     setState(() {
//       if (allCategories.length == 5) {
//         // Rotate cyclically for exactly 5 items
//         GetAllCategoryModel first = visibleCategories.removeAt(0);
//         visibleCategories.add(first);
//       } else {
//         // Normal scrolling for more than 5 items
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
//     return Container(
//       height: 50,
//       width: 50,
//       decoration: BoxDecoration(
//         color: AppColor.fillColor,
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(
//           image: NetworkImage(category.categoryimage!),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget buildCategoryList() {
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
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: NetworkImage(category.categoryimage!),
//                 fit: BoxFit.cover,
//               ),
//             ),
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

//   // List<GetfruitsCategoryModel> selectProduct = [];

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

//     getprovider.fetchBanner();
//     fetchCategories();

//     // _fetchCartData();
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
//     await _fetchCartData();
//     await _fetchWishlistData();
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
//           image: DecorationImage(image: AssetImage("assets/images/bg.jpg"),fit:BoxFit.cover),
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

//   List<GetallCategoryModel> allCategories = [];
//   List<GetallCategoryModel> visibleCategories = [];
//   int currentIndex = 2; // Middle index
//   bool isLoading = true; // Track API loading state // Middle index
//   Future<void> fetchCategories() async {
//     try {
//       await getprovider.fetchCategory();
//       if (mounted) {
//         setState(() {
//           allCategories = List.from(getprovider.category);

//           if (allCategories.isNotEmpty) {
//             visibleCategories = allCategories.length >= 5
//                 ? allCategories.take(5).toList()
//                 : List.from(allCategories);
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
//     _handleIndexChange();
//   }

//   void scrollRight() {
//     if (allCategories.length < 5) return;

//     setState(() {
//       if (allCategories.length == 5) {
//         // Rotate cyclically for exactly 5 items
//         GetallCategoryModel first = visibleCategories.removeAt(0);
//         visibleCategories.add(first);
//       } else {
//         // Normal scrolling for more than 5 items
//         GetallCategoryModel first = visibleCategories.removeAt(0);
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
//         GetallCategoryModel last = visibleCategories.removeLast();
//         visibleCategories.insert(0, last);
//       } else {
//         // Normal scrolling for more than 5 items
//         GetallCategoryModel last = visibleCategories.removeLast();
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
//     String currentCategory = visibleCategories[currentIndex].name!;
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
//   Widget buildImageContainer(GetallCategoryModel category) {
//     return Container(
//       height: 50,
//       width: 50,
//       decoration: BoxDecoration(
//         color: AppColor.fillColor,
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(
//           image: NetworkImage(category.image!),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget buildCategoryList() {
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

//   // Container for the animated middle image

//   Widget buildAnimatedContainer(GetallCategoryModel category) {
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
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: NetworkImage(category.image!),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Expanded(
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 category.name!,
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
//       GetallCategoryModel temp = visibleCategories[index];
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



// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// // TODO: keep your own style/color imports if you have them
// // import 'package:fulupo/customs/styles.dart';
// // import 'package:fulupo/util/color_constant.dart';

// class AppColor {
//   static const fillColor = Color(0xFF2E7D32);
//   static const whiteColor = Colors.white;
//   static const yellowColor = Color(0xFFFFC107);
//   static const blackColor = Colors.black;
//   static const hintTextColor = Colors.grey;
// }

// TextStyle _tSmall(BuildContext c, {Color? color}) =>
//     TextStyle(fontSize: 12, color: color ?? Colors.white);
// TextStyle _tMedium(BuildContext c, {Color? color}) =>
//     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? Colors.white);
// TextStyle _tLarge(BuildContext c, {Color? color}) =>
//     TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color ?? Colors.white);

// class Product {
//   final String id;
//   final String categoryId;
//   final String name;
//   final String? subname;
//   final String image;
//   final List<String> weights;
//   final double currentPrice;
//   final double oldPrice;
//   int count;

//   Product({
//     required this.id,
//     required this.categoryId,
//     required this.name,
//     this.subname,
//     required this.image,
//     required this.weights,
//     required this.currentPrice,
//     required this.oldPrice,
//     this.count = 0,
//   });
// }

// class GetallCategoryModel {
//   final String id;
//   final String name;
//   final String image;
//   GetallCategoryModel({required this.id, required this.name, required this.image});
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String _address = "221B Baker Street, London";
//   LatLng draggedLatLng = const LatLng(0.0, 0.0);

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;

//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   // UI state only
//   int myCurrentIndex = 0;
//   double TotalCurrentPrice = 0;
//   double TotalOldPrice = 0;
//   double totalSavings = 0;

//   Map<String, bool> isFavorite = {};
//   Map<String, bool> isAdded = {};
//   Map<String, int> itemCounts = {};
//   final Map<String, Timer?> _debounceTimers = {};

//   String selectedAddress = 'Home';

//   // Mock banners (use assets or remote URLs)
//   final List<String> _banners = [
//     'https://picsum.photos/1200/400?1',
//     'https://picsum.photos/1200/400?2',
//     'https://picsum.photos/1200/400?3',
//   ];

//   // Mock categories
//   List<GetallCategoryModel> allCategories = [
//     GetallCategoryModel(id: 'c1', name: 'Fruits', image: 'https://picsum.photos/200?f'),
//     GetallCategoryModel(id: 'c2', name: 'Vegetables', image: 'https://picsum.photos/200?v'),
//     GetallCategoryModel(id: 'c3', name: 'Dairy', image: 'https://picsum.photos/200?d'),
//     GetallCategoryModel(id: 'c4', name: 'Bakery', image: 'https://picsum.photos/200?b'),
//     GetallCategoryModel(id: 'c5', name: 'Snacks', image: 'https://picsum.photos/200?s'),
//     GetallCategoryModel(id: 'c6', name: 'Beverages', image: 'https://picsum.photos/200?be'),
//   ];
//   List<GetallCategoryModel> visibleCategories = [];
//   int currentIndex = 2;
//   bool isLoading = false;

//   // Mock products per category
//   final Map<String, List<Product>> _catalog = {
//     'c1': List.generate(
//       10,
//       (i) => Product(
//         id: 'p_f_$i',
//         categoryId: 'c1',
//         name: 'Apple $i',
//         subname: 'Fresh',
//         image: 'https://picsum.photos/300?apple=$i',
//         weights: ['500g', '1kg'],
//         currentPrice: 89.0,
//         oldPrice: 120.0,
//       ),
//     ),
//     'c2': List.generate(
//       10,
//       (i) => Product(
//         id: 'p_v_$i',
//         categoryId: 'c2',
//         name: 'Tomato $i',
//         subname: 'Organic',
//         image: 'https://picsum.photos/300?tomato=$i',
//         weights: ['500g', '1kg'],
//         currentPrice: 45.0,
//         oldPrice: 60.0,
//       ),
//     ),
//     'c3': List.generate(
//       8,
//       (i) => Product(
//         id: 'p_d_$i',
//         categoryId: 'c3',
//         name: 'Milk $i',
//         subname: 'Toned',
//         image: 'https://picsum.photos/300?milk=$i',
//         weights: ['500ml', '1L'],
//         currentPrice: 54.0,
//         oldPrice: 60.0,
//       ),
//     ),
//   };

//   List<Product> _currentProducts = [];

//   @override
//   void initState() {
//     super.initState();

//     _scrollController.addListener(() {
//       if (_scrollController.offset > 100 && !_isScrolled) {
//         setState(() => _isScrolled = true);
//       } else if (_scrollController.offset <= 100 && _isScrolled) {
//         setState(() => _isScrolled = false);
//       }
//     });

//     // initial visible categories
//     visibleCategories = allCategories.length >= 5
//         ? allCategories.take(5).toList()
//         : List.of(allCategories);

//     // initial products for middle category
//     _handleIndexChange();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     for (var t in _debounceTimers.values) {
//       t?.cancel();
//     }
//     super.dispose();
//   }

//   void _debounceCartUpdate(String categoryId) {
//     _debounceTimers[categoryId]?.cancel();
//     _debounceTimers[categoryId] = Timer(const Duration(milliseconds: 400), () {
//       _recalculateTotalPrice();
//     });
//   }

//   void _recalculateTotalPrice() {
//     double tc = 0, to = 0;
//     for (final p in _currentProducts) {
//       tc += p.currentPrice * p.count;
//       to += p.oldPrice * p.count;
//     }
//     setState(() {
//       TotalCurrentPrice = tc;
//       TotalOldPrice = to;
//       totalSavings = to - tc;
//     });
//   }

//   // Categories scrollers
//   void scrollRight() {
//     if (allCategories.length < 5) return;
//     setState(() {
//       if (allCategories.length == 5) {
//         final first = visibleCategories.removeAt(0);
//         visibleCategories.add(first);
//       } else {
//         final first = visibleCategories.removeAt(0);
//         final nextIndex =
//             (allCategories.indexOf(visibleCategories.last) + 1) % allCategories.length;
//         visibleCategories.add(allCategories[nextIndex]);
//       }
//     });
//     _handleIndexChange();
//   }

//   void scrollLeft() {
//     if (allCategories.length < 5) return;
//     setState(() {
//       if (allCategories.length == 5) {
//         final last = visibleCategories.removeLast();
//         visibleCategories.insert(0, last);
//       } else {
//         final last = visibleCategories.removeLast();
//         final prevIndex = (allCategories.indexOf(visibleCategories.first) - 1 + allCategories.length) %
//             allCategories.length;
//         visibleCategories.insert(0, allCategories[prevIndex]);
//       }
//     });
//     _handleIndexChange();
//   }

//   // refresh product list for middle category
//   void _handleIndexChange() {
//     if (visibleCategories.length < 3) return;
//     currentIndex = 2;
//     final catId = visibleCategories[currentIndex].id;
//     final items = _catalog[catId] ?? [];
//     // hydrate UI state for counts/favorites
//     for (final p in items) {
//       isAdded[p.categoryId] = (isAdded[p.categoryId] ?? false);
//       itemCounts[p.categoryId] = itemCounts[p.categoryId] ?? 0;
//     }
//     setState(() => _currentProducts = List.of(items));
//     _recalculateTotalPrice();
//   }

//   void selectIndex(int index) {
//     if (index == 2 || visibleCategories.isEmpty) return;
//     setState(() {
//       final temp = visibleCategories[index];
//       visibleCategories[index] = visibleCategories[2];
//       visibleCategories[2] = temp;
//     });
//     _handleIndexChange();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenH = MediaQuery.of(context).size.height;
//     final screenW = MediaQuery.of(context).size.width;

//     final filtered = _currentProducts.where((p) {
//       return p.name.toLowerCase().contains(_searchQuery);
//     }).toList();

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: const _DummyDrawer(),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage('https://picsum.photos/1200/2000?bg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: [
//             SafeArea(
//               child: Stack(
//                 children: [
//                   SingleChildScrollView(
//                     controller: _scrollController,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Top bar
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 5),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () => _scaffoldKey.currentState?.openDrawer(),
//                                   child: const Icon(Icons.menu, color: Colors.white, size: 30),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 const SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           selectedAddress == 'Home'
//                                               ? Icons.home
//                                               : selectedAddress == 'Work'
//                                                   ? Icons.work
//                                                   : Icons.location_on,
//                                           color: Colors.red,
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Text(
//                                           selectedAddress,
//                                           style: _tMedium(context, color: AppColor.yellowColor),
//                                         ),
//                                         const SizedBox(width: 5),
//                                         const Icon(Icons.keyboard_arrow_down, size: 35, color: Colors.white70),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       width: screenW * 0.6,
//                                       child: Text(
//                                         _address,
//                                         style: _tSmall(context),
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 1,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 const Icon(Icons.person_2_rounded, color: Colors.white),
//                               ],
//                             ),
//                           ),

//                           SizedBox(height: screenH * 0.02),

//                           // Search
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10.0),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.3),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: SizedBox(
//                               height: 40,
//                               child: TextField(
//                                 controller: _searchController,
//                                 decoration: InputDecoration(
//                                   hintText: "Search...",
//                                   hintStyle: _tMedium(context, color: AppColor.hintTextColor),
//                                   prefixIcon: Icon(Icons.search, color: AppColor.hintTextColor),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                                   border: InputBorder.none,
//                                 ),
//                                 onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: screenH * 0.03),

//                           // Banners
//                           CarouselSlider(
//                             options: CarouselOptions(
//                               autoPlay: true,
//                               height: screenH * 0.18,
//                               autoPlayInterval: const Duration(seconds: 4),
//                               viewportFraction: 1,
//                               enlargeCenterPage: true,
//                               onPageChanged: (i, _) => setState(() => myCurrentIndex = i),
//                             ),
//                             items: _banners.map((url) {
//                               return ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: CachedNetworkImage(
//                                   imageUrl: url,
//                                   width: screenW * 0.9,
//                                   fit: BoxFit.cover,
//                                   placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
//                                   errorWidget: (c, u, e) => const Icon(Icons.error, color: Colors.red, size: 50),
//                                 ),
//                               );
//                             }).toList(),
//                           ),

//                           const SizedBox(height: 8),

//                           Center(
//                             child: AnimatedSmoothIndicator(
//                               activeIndex: myCurrentIndex,
//                               count: _banners.length,
//                               effect: const JumpingDotEffect(
//                                 dotHeight: 5,
//                                 dotWidth: 5,
//                                 spacing: 5,
//                                 dotColor: Color.fromARGB(255, 172, 171, 171),
//                                 activeDotColor: AppColor.whiteColor,
//                                 paintStyle: PaintingStyle.fill,
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: screenH * 0.02),

//                           Center(child: Text('Shop By Category', style: _tLarge(context, color: AppColor.yellowColor))),

//                           SizedBox(height: screenH * 0.02),

//                           visibleCategories.length < 3
//                               ? const Center(child: CircularProgressIndicator())
//                               : _buildCategoryList(),

//                           SizedBox(height: screenH * 0.02),

//                           Center(child: Text('Upto 50% Off', style: _tLarge(context, color: AppColor.yellowColor))),

//                           SizedBox(height: screenH * 0.02),

//                           // Products grid
//                           if (filtered.isEmpty)
//                             Center(
//                               child: Lottie.network(
//                                 "https://lottie.host/6b5d0bcb-6c8a-40c4-9b71-1b8b7d0.json",
//                                 height: screenH * 0.2,
//                                 fit: BoxFit.contain,
//                               ),
//                             )
//                           else
//                             _ProductGrid(
//                               products: filtered,
//                               onAdd: (p) {
//                                 setState(() {
//                                   isAdded[p.categoryId] = true;
//                                   p.count = 1;
//                                   itemCounts[p.categoryId] = 1;
//                                 });
//                                 _recalculateTotalPrice();
//                               },
//                               onIncrease: (p) {
//                                 setState(() {
//                                   p.count += 1;
//                                   itemCounts[p.categoryId] = p.count;
//                                 });
//                                 _debounceCartUpdate(p.categoryId);
//                               },
//                               onRemove: (p) {
//                                 setState(() {
//                                   if (p.count > 0) p.count -= 1;
//                                   itemCounts[p.categoryId] = p.count;
//                                   if (p.count == 0) isAdded[p.categoryId] = false;
//                                 });
//                                 _debounceCartUpdate(p.categoryId);
//                               },
//                               onFavoriteToggle: (p) {
//                                 setState(() {
//                                   final v = !(isFavorite[p.categoryId] ?? false);
//                                   isFavorite[p.categoryId] = v;
//                                 });
//                               },
//                               isAdded: isAdded,
//                               isFavorite: isFavorite,
//                               itemCounts: itemCounts,
//                             ),

//                           if (TotalCurrentPrice != 0) SizedBox(height: screenH * 0.13),
//                         ],
//                       ),
//                     ),
//                   ),

//                   if (_isScrolled)
//                     Positioned(
//                       bottom: 130,
//                       right: 10,
//                       child: GestureDetector(
//                         onTap: () {
//                           _scrollController.animateTo(0,
//                               duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//                         },
//                         child: Container(
//                           height: 40,
//                           width: 40,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.black.withOpacity(0.4),
//                           ),
//                           child: const Icon(Icons.arrow_upward, color: AppColor.yellowColor, size: 25),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             if (TotalCurrentPrice != 0)
//               Positioned(
//                 bottom: 10,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       children: [
//                         Align(
//                           alignment: Alignment.topCenter,
//                           child: Container(
//                             height: 30,
//                             width: 30,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white,
//                               boxShadow: [BoxShadow(blurRadius: 8, color: Colors.grey, offset: Offset(0, 4))],
//                             ),
//                             child: const Icon(Icons.arrow_drop_up_outlined, color: AppColor.fillColor),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Container(
//                               height: 60,
//                               width: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.white,
//                                 image: const DecorationImage(
//                                   image: NetworkImage('https://picsum.photos/200?basket'),
//                                   fit: BoxFit.cover,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.5),
//                                     spreadRadius: 2,
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 20),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Text(
//                                     '${_currentProducts.where((p) => p.count > 0).length} '
//                                     'Item${_currentProducts.where((p) => p.count > 0).length > 1 ? 's' : ''} '
//                                     '| ₹${TotalCurrentPrice.toStringAsFixed(2)}',
//                                     style: _tMedium(context, color: AppColor.blackColor),
//                                   ),
//                                 ),
//                                 FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Text(
//                                     'You Saved ₹${totalSavings.toStringAsFixed(2)}',
//                                     style: _tSmall(context, color: AppColor.fillColor),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: AppColor.fillColor,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text('Go to Cart', style: _tSmall(context, color: AppColor.whiteColor)),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- UI bits ---

//   Widget _buildCategoryList() {
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
//               child: index == 2 ? _buildAnimatedCategory(visibleCategories[index]) : _buildCategory(visibleCategories[index]),
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategory(GetallCategoryModel category) {
//     return Container(
//       height: 50,
//       width: 50,
//       decoration: BoxDecoration(
//         color: AppColor.fillColor,
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(image: NetworkImage(category.image), fit: BoxFit.cover),
//       ),
//     );
//   }

//   Widget _buildAnimatedCategory(GetallCategoryModel category) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
//       width: 70,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5)],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 50,
//             width: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(image: NetworkImage(category.image), fit: BoxFit.cover),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(category.name, style: _tSmall(context, color: AppColor.fillColor).copyWith(fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget shimmerSlotBox() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         height: 250,
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//       ),
//     );
//   }
// }

// class _ProductGrid extends StatelessWidget {
//   final List<Product> products;
//   final void Function(Product) onAdd;
//   final void Function(Product) onIncrease;
//   final void Function(Product) onRemove;
//   final void Function(Product) onFavoriteToggle;
//   final Map<String, bool> isAdded;
//   final Map<String, bool> isFavorite;
//   final Map<String, int> itemCounts;

//   const _ProductGrid({
//     required this.products,
//     required this.onAdd,
//     required this.onIncrease,
//     required this.onRemove,
//     required this.onFavoriteToggle,
//     required this.isAdded,
//     required this.isFavorite,
//     required this.itemCounts,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       padding: const EdgeInsets.symmetric(horizontal: 6),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2, mainAxisExtent: 240, crossAxisSpacing: 8, mainAxisSpacing: 8,
//       ),
//       itemCount: products.length,
//       itemBuilder: (ctx, i) {
//         final p = products[i];
//         final added = (isAdded[p.categoryId] ?? false) || p.count > 0;
//         final fav = isFavorite[p.categoryId] ?? false;
//         final count = itemCounts[p.categoryId] ?? p.count;

//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: CachedNetworkImage(imageUrl: p.image, fit: BoxFit.cover),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 2),
//                 Text(p.subname ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Text('₹${p.currentPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(width: 6),
//                     Text(
//                       '₹${p.oldPrice.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => onFavoriteToggle(p),
//                       child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : Colors.grey),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (!added)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => onAdd(p),
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColor.fillColor, minimumSize: const Size.fromHeight(36)),
//                       child: const Text('Add', style: TextStyle(color: Colors.white)),
//                     ),
//                   )
//                 else
//                   Row(
//                     children: [
//                       _qtyBtn(icon: Icons.remove, onTap: () => onRemove(p)),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                       _qtyBtn(icon: Icons.add, onTap: () => onIncrease(p)),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: BoxDecoration(
//           color: AppColor.fillColor, borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }
// }

// class _DummyDrawer extends StatelessWidget {
//   const _DummyDrawer();
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: SafeArea(
//         child: ListView(
//           children: const [
//             ListTile(title: Text('Menu Item 1')),
//             ListTile(title: Text('Menu Item 2')),
//             ListTile(title: Text('Menu Item 3')),
//           ],
//         ),
//       ),
//     );
//   }
// }

