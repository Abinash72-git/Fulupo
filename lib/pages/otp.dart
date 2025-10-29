import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/helper/helper.dart';
import 'package:fulupo/model/login_model.dart';
import 'package:fulupo/pages/app_page.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  final String selectedCountryCode;
  final String initialOtp;

  const OtpPage({
    super.key,
    required this.selectedCountryCode,
    required this.initialOtp,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController otpController;
  late Helper hp;

  bool isLoading = false;
  bool showOtpMessage = false;
  bool isExistingUser = false;
  bool isPinComplete = false;

  String? receivedOtp;
  String pin = "";
  String locationMessage = "";
  String Address = "Please wait...";
  String mobile = "";
  Timer? otpDisplayTimer;
  late Timer _timer;

  int _start = 90;
  Position? currentPosition;

  UserProvider get provider => context.read<UserProvider>();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    otpController = TextEditingController();
    _startTimer();
    _loadUserData();
    _simulateOtpReception();
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    otpDisplayTimer?.cancel();
    super.dispose();
  }

  // Mask middle digits for display
  String formatPhoneNumber(String phone, String selectedCountryCode) {
    if (phone.length < 4) return '$selectedCountryCode $phone';
    String start = phone.substring(0, 2);
    String end = phone.substring(phone.length - 2);
    return '$selectedCountryCode $start${'*' * (phone.length - 4)}$end';
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
      isExistingUser = prefs.getBool(AppConstants.IS_EXISTING_USER) ?? false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        _timer.cancel();
      } else {
        setState(() => _start--);
      }
    });
  }

  void _simulateOtpReception() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String demoOtp = prefs.getString(AppConstants.USEROTP) ?? widget.initialOtp;

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        receivedOtp = demoOtp;
        showOtpMessage = true;
      });
      otpDisplayTimer = Timer(const Duration(seconds: 50), () {
        if (mounted) setState(() => showOtpMessage = false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.message, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'OTP Received: $demoOtp',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'USE',
            textColor: Colors.white,
            onPressed: () => _useReceivedOtp(demoOtp),
          ),
        ),
      );
    });
  }

  void _useReceivedOtp(String otp) {
    setState(() {
      otpController.text = otp;
      pin = otp;
      isPinComplete = otp.length == 6;
      showOtpMessage = false;
    });
  }

  // Future<void> _verifyOtp() async {
  //   if (!isPinComplete) {
  //     AppDialogue.toast("Please enter a valid 6-digit OTP");
  //     return;
  //   }

  //   FocusScope.of(context).unfocus();
  //   setState(() => isLoading = true);

  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     bool isExisting = prefs.getBool(AppConstants.IS_EXISTING_USER) ?? false;

  //     if (isExisting) {
  //       await AppDialogue.openLoadingDialogAfterClose(
  //         context,
  //         text: "Verifying OTP...",
  //         load: () async {
  //           return await provider.verifyLogin(mobile: mobile, otp: pin);
  //         },
  //         afterComplete: (resp) async {
  //           // ✅ Parse the response to get LoginModel
  //           if (resp.statusCode == 200) {
  //             try {
  //               final loginData = LoginModel.fromMap(resp.fullBody);

  //               if (loginData.success) {
  //                 // ✅ Add a small delay to ensure dialog is closed
  //                 await Future.delayed(const Duration(milliseconds: 300));

  //                 // ✅ Check if widget is still mounted before navigating
  //                 if (mounted) {
  //                   Navigator.pushAndRemoveUntil(
  //                     context,
  //                     MaterialPageRoute(builder: (_) => const AppPage(tabNumber: 1)),
  //                     (route) => false,
  //                   );
  //                 }
  //               } else {
  //                 if (mounted) setState(() => isLoading = false);
  //                 AppDialogue.toast(loginData.message ?? "Invalid OTP, please try again!");
  //               }
  //             } catch (e) {
  //               if (mounted) setState(() => isLoading = false);
  //               AppDialogue.toast("Error processing response: $e");
  //             }
  //           } else {
  //             if (mounted) setState(() => isLoading = false);
  //             AppDialogue.toast("Invalid OTP, please try again!");
  //           }
  //         },
  //       );
  //     } else {
  //       // ✅ Ensure loading state is reset before navigation
  //       if (mounted) setState(() => isLoading = false);

  //       await AppRouteName.register.pushAndRemoveUntil(
  //         context,
  //         (route) => false,
  //         args: {'otp': pin, 'mobile': mobile},
  //       );
  //     }
  //   } on Exception catch (e) {
  //     ExceptionHandler.showMessage(context, e);
  //     if (mounted) setState(() => isLoading = false);
  //   }
  // }

  Future<void> _verifyOtp() async {
    if (!isPinComplete) {
      AppDialogue.toast("Please enter a valid 6-digit OTP");
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isExisting = prefs.getBool(AppConstants.IS_EXISTING_USER) ?? false;

      if (isExisting) {
        await AppDialogue.openLoadingDialogAfterClose(
          context,
          text: "Verifying OTP...",
          load: () async {
            return await provider.verifyLogin(mobile: mobile, otp: pin);
          },
          afterComplete: (resp) async {
            await Future.delayed(const Duration(milliseconds: 300));

            if (resp.status == true) {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppPage(tabNumber: 1),
                  ),
                  (route) => false,
                );
              }
            } else {
              if (mounted) setState(() => isLoading = false);
              AppDialogue.toast(resp.data ?? "Invalid OTP, please try again!");
            }
          },
        );
      } else {
        if (mounted) setState(() => isLoading = false);
        await AppRouteName.register.pushAndRemoveUntil(
          context,
          (route) => false,
          args: {'otp': pin, 'mobile': mobile},
        );
      }
    } on Exception catch (e) {
      ExceptionHandler.showMessage(context, e);
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Optional location logic (kept intact)
  Future<void> _getCurrentLocation() async {
    const String googleApiKey = "AIzaSyCemA7pZSzNgEfnp77-LLvKJkODkPUGkCU";

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => locationMessage = "Enable location services.");
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => locationMessage = "Permission denied.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(
        () => locationMessage = "Permission permanently denied. Open settings.",
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey";

      final response = await Dio().get(url);
      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final formattedAddress =
            response.data['results'][0]['formatted_address'];
        await _saveLocationData(position, formattedAddress);
        setState(() => Address = formattedAddress);
      } else {
        setState(() => Address = "No address found");
      }
    } catch (e) {
      setState(() => Address = "Failed to get address.");
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.045,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 223, 211, 211)),
      ),
    );

    String formattedPhone = formatPhoneNumber(
      mobile,
      widget.selectedCountryCode,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ConstantImageKey.Bg),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.35),
                  Text(
                    "OTP Verification",
                    style: Styles.textStyleExtraHugeBold(
                      color: AppColor.fillColor,
                      context,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We have sent the code verification to",
                    style: Styles.textStyleLarge(
                      color: AppColor.blackColor,
                      context,
                    ),
                  ),
                  Text(
                    formattedPhone,
                    style: Styles.textStyleLarge(
                      color: const Color.fromARGB(255, 223, 54, 42),
                      context,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Pinput(
                    length: 6,
                    controller: otpController,
                    obscureText: true,
                    obscuringCharacter: '*',
                    // defaultPinTheme: defaultPinTheme,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.045,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        height: 2, // ✅ Adjust text vertical centering
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 223, 211, 211),
                        ),
                      ),
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppColor.blackColor),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        pin = value;
                        isPinComplete = value.length == 6;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  GestureDetector(
                    onTap: _start == 0
                        ? () {
                            setState(() {
                              _start = 90;
                              _startTimer();
                            });
                            _simulateOtpReception();
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Did not get OTP? ",
                          style: Styles.textStyleLarge(
                            context,
                            color: AppColor.blackColor,
                          ),
                        ),
                        Text(
                          "Resend",
                          style: Styles.textStyleLarge(
                            context,
                            color: AppColor.fillColor,
                          ),
                        ),
                        if (_start > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '($_start s)',
                              style: Styles.textStyleMedium(
                                context,
                                color: const Color.fromARGB(255, 223, 54, 42),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  MyButton(
                    text: isLoading ? 'Loading...' : "VERIFY OTP",
                    textcolor: AppColor.whiteColor,
                    textsize: 20,
                    fontWeight: FontWeight.bold,
                    letterspacing: 0.7,
                    buttoncolor: AppColor.fillColor,
                    borderColor: AppColor.fillColor,
                    buttonheight: 55 * (screenHeight / 812),
                    buttonwidth: screenWidth,
                    radius: 40,
                    onTap: () {
                      _verifyOtp(); // ✅ works fine
                    },
                  ),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),

          // OTP received overlay
          if (showOtpMessage && receivedOtp != null)
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.message, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'OTP: $receivedOtp for $formattedPhone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _useReceivedOtp(receivedOtp!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'USE',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
