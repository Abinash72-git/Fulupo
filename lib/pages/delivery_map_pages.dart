import 'dart:async';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/address_bottomsheet_page.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

const appBlue = Color.fromARGB(255, 0, 0, 0);

class SelectAddressMap extends StatefulWidget {
  final String page;
  final Widget targetPage; // The page you want to navigate to
  const SelectAddressMap({
    super.key,
    required this.targetPage, // Make it a required parameter
    required this.page,
  });

  @override
  State<SelectAddressMap> createState() => _SelectAddressMapState();
}

class _SelectAddressMapState extends State<SelectAddressMap> {
 
  Completer<GoogleMapController> googleMapController = Completer();
  CameraPosition? cameraPosition;
  late LatLng defaultLatLng;
  late LatLng draggedLatLng;

  String draggedAddress = "";
  bool isLoading = false;

  Placemark? address;
  List<Placemark>? placeMarks;
  List<dynamic> placePredictions = [];
  TextEditingController searchController = TextEditingController();
  final String googleApiKey = 'AIzaSyCemA7pZSzNgEfnp77-LLvKJkODkPUGkCU';

  @override
  void initState() {
    _gotoUserCurrentPosition();
    _init();
    super.initState();
  }

  _init() {
    defaultLatLng = const LatLng(0.0, 0.0);
    draggedLatLng = defaultLatLng;
    cameraPosition = CameraPosition(target: defaultLatLng, zoom: 18);
  }

  // Function to store latitude, longitude, and address as separate strings in SharedPreferences
  Future<void> storeLocationData(
    double latitude,
    double longitude,
    String address,
  ) async {
    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store latitude, longitude, and address separately
    await prefs.setDouble(AppConstants.USERLATITUTE, latitude);
    await prefs.setDouble(AppConstants.USERLONGITUTE, longitude);
    await prefs.setString(AppConstants.USERADDRESS, address);

    // After saving, retrieve and print the saved values to check if they are stored
    double? storedLatitude = prefs.getDouble(AppConstants.USERLATITUTE);
    double? storedLongitude = prefs.getDouble(AppConstants.USERLONGITUTE);
    String? storedAddress = prefs.getString(AppConstants.USERADDRESS);

    // Print the stored values for verification
    print('Stored Latitude: $storedLatitude');
    print('Stored Longitude: $storedLongitude');
    print('Stored Address: $storedAddress');
  }

  Future<void> getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }

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
      print('Error fetching place details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double sh = MediaQuery.of(context).size.height;
    double sw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'Select the delivery location',
            style: Styles.textStyleMedium(color: AppColor.blackColor, context),
            textScaleFactor: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                _getMap(),
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        _gotoUserCurrentPosition();
                      },
                      child: const Icon(Icons.gps_fixed, size: 30),
                    ),
                  ),
                ),
                _getCustomPin(),
                Positioned(
                  top: 20,
                  left: 15,
                  right: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(3, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search for a place",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            getPlacePredictions(value);
                          },
                        ),
                        if (placePredictions.isNotEmpty)
                          Container(
                            height: 200,
                            color: Colors.white,
                            child: ListView.builder(
                              itemCount: placePredictions.length,
                              itemBuilder: (context, index) {
                                final prediction = placePredictions[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(prediction['description']),
                                  onTap: () async {
                                    // Store or use the description if needed
                                    final selectedDescription =
                                        prediction['description'];

                                    // Clear the search bar and prediction list
                                    searchController.clear();
                                    setState(() {
                                      placePredictions = [];
                                    });

                                    // Fetch location and move map
                                    LatLng? latLng = await getPlaceLatLng(
                                      prediction['place_id'],
                                    );
                                    if (latLng != null) {
                                      await _gotoSpecificPosition(latLng);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _showDraggedAddress(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _showDraggedAddress() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30, right: 10, top: 15),
          child: Row(
            children: [
              Icon(Icons.location_on),
              SizedBox(width: 10),
              Text(
                "Address",
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textScaleFactor: 1.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 10, top: 15),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: <Widget>[
                    Shimmer.fromColors(
                      enabled: false,
                      baseColor: Colors.black,
                      highlightColor: Colors.grey,
                      child: Text(
                        draggedAddress,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontFamily: "Gilroy",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
          child: MyButton(
            text: isLoading ? 'Loading...' : "Add More Address Details",
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
              print('Latitude: ------------------- ${draggedLatLng.latitude}');
              print('Longitude:------------------- ${draggedLatLng.longitude}');
              print('Address:---------------------- $draggedAddress');

              // Store location data and await completion
              await storeLocationData(
                draggedLatLng.latitude,
                draggedLatLng.longitude,
                draggedAddress,
              );
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddressBottomsheetPage(page: widget.page),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                // ),
              );

              // After data is stored, navigate back to the HomePage
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => widget.targetPage),
              // );
            },
          ),
        ),
      ],
    );
  }

  Widget _getMap() {
    return GoogleMap(
      initialCameraPosition: cameraPosition!,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      onCameraIdle: () {
        _getAddress(draggedLatLng);
      },
      onCameraMove: (cameraPosition) {
        draggedLatLng = cameraPosition.target;
      },
      onMapCreated: (GoogleMapController controller) {
        if (!googleMapController.isCompleted) {
          googleMapController.complete(controller);
        }
      },
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: SizedBox(
        width: 150,

        /// I used the map pin from the lottie. You can also use it if you want. Otherwise you can delete.
        child: Lottie.asset(
          "assets/map_pin/map_pin.json",
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${position.latitude},${position.longitude}',
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];
          setState(() {
            draggedAddress = formattedAddress;
          });
        } else {
          print('No address found');
        }
      } else {
        print('Failed to get address from Geocoding API');
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  ///
  Future<void> _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    await _gotoSpecificPosition(
      LatLng(currentPosition.latitude, currentPosition.longitude),
    );
  }

  Future<Position> _determineUserCurrentPosition() async {
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // You can show a dialog asking user to enable location service.
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  Future<void> _gotoSpecificPosition(LatLng position) async {
    final controller = await googleMapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 18),
      ),
    );

    draggedLatLng = position;
    await _getAddress(position);
  }

}
