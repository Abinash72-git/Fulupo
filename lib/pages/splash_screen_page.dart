import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String phoneNumber = '';
  String locationMessage = '';
  String Address = '';
  String selectedAddress = '';
  String token = '';
  String selectedStore = '';

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  final newVersion = NewVersionPlus(androidId: 'com.tabsquare.Fulupo');

  Future<void> _checkVersion() async {
    try {
      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        _showUpdateDialog(status.appStoreLink);
      } else {
        getSelectedAddress();
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
      getSelectedAddress();
    }
  }

  void _showUpdateDialog(String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset("assets/map_pin/rocketGif.json", height: 190),
                const SizedBox(height: 20),
                Text(
                  "Please update your app to continue using it",
                  style: Styles.textStyleMedium(context),
                  textScaler: const TextScaler.linear(1.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fillColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    NewVersionPlus().launchAppStore(updateUrl);
                  },
                  child: Text(
                    'Update',
                    style: Styles.textStyleMedium(context, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getSelectedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';
    token = prefs.getString(AppConstants.token) ?? "";
    selectedStore = prefs.getString('PRIMARY_STORE') ?? '';
    await _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString(AppConstants.USERMOBILE) ?? '';
    selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';

   // await _getCurrentLocation();

    Timer(const Duration(seconds: 1), () async {
      bool isExpired = _isTokenExpired(token);
      print("🧾 Token expired: $isExpired");

      if (token.isEmpty || isExpired) {
        // Token empty or expired → go to login page
        AppRouteName.login.push(context);
      } else {
        // Valid token → go to app page
        AppRouteName.apppage.pushAndRemoveUntil(
          context,
          args: 1,
          (route) => false,
        );
      }
    });

    print("$phoneNumber phone number saved locally ✅");
  }

  /// ✅ Check if JWT token is expired
  bool _isTokenExpired(String token) {
    if (token.isEmpty) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print("Invalid token format");
        return true;
      }

      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];

      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  Future<void> _getCurrentLocation() async {
    const String googleApiKey = "AIzaSyCemA7pZSzNgEfnp77-LLvKJkODkPUGkCU";

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.openAppSettings();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey";

      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['results'] != null && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];
          setState(() => Address = formattedAddress);
          await _saveLocationData(position, formattedAddress);
        }
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _saveLocationData(Position position, String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.USERLATITUTE, position.latitude);
    await prefs.setDouble(AppConstants.USERLONGITUTE, position.longitude);
    await prefs.setString(AppConstants.USERADDRESS, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ConstantImageKey.SplashImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
