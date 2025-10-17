// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:place_picker/place_picker.dart'; // Assuming you have the required package
// // Import your Helper class here

// class YourPage extends StatefulWidget {
//   @override
//   _YourPageState createState() => _YourPageState();
// }

// class _YourPageState extends State<YourPage> {
//   // Function to get current user position
//   Future<Position> _determineUserCurrentPosition() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }

//     // Request permission for location access
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permission denied');
//       }
//     }

//     // Get the current position of the user
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   // Function to update camera position
//   Future<void> cameraUpdate(LatLng latLng) async {
//     // Implement the camera update functionality using Google Maps controller
//     // Example: _controller.animateCamera(CameraUpdate.newLatLng(latLng));
//   }

//   // Function to handle tap on location
//   Future<void> handletap(LatLng latLng) async {
//     // Handle the location tap (e.g., show address or perform other actions)
//     print("Tapped location: $latLng");
//   }

//   // Function to show place picker
//   void showPlacePicker() async {
//     // Get current position of the user
//     Position currentPosition = await _determineUserCurrentPosition();

//     // Show the place picker
//     LocationResult? result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => PlacePicker(
//           'AIzaSyDwhjklyhI-4KD30QyIw0eS7NjtqyRl0Vo', // your API key
//           displayLocation:
//               LatLng(currentPosition.latitude, currentPosition.longitude),
//         ),
//       ),
//     );

//     if (result != null && result.latLng != null) {
//       // Show loading dialog while processing the result
//       // showDialog(
//       //   context: context,
//       //   builder: (_) => Helper.of(context).loader(),
//       //   barrierDismissible: false,
//       // );

//       // Handle the location result
//       print(result.latLng);
//       await cameraUpdate(result.latLng!);
//       await handletap(result.latLng!);

//       // Close the loading dialog
//       Navigator.of(context, rootNavigator: true).pop();
//     } else {
//       // Handle the case where no result is returned or it's null
//       print('No location selected');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Place Picker Example')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar triggering the showPlacePicker function
//             TextField(
//               onTap: () {
//                 showPlacePicker();
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search for a place',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             // Other UI elements go here
//           ],
//         ),
//       ),
//     );
//   }
// }
