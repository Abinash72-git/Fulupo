import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/helper/helper.dart';
import 'package:fulupo/model/base_model.dart';
import 'package:fulupo/pages/app_page.dart';
import 'package:fulupo/pages/main_home_page.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:geocoding/geocoding.dart';
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
  String currentAddress = "Please wait....";
  String locality = "";
  Position? currentPosition;
  bool isLoading = false;
  String address = '';
  String locationMessage = '';
  String Address = "Please wait....";
  bool isExistingUser = false;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider get provider => context.read<UserProvider>();

  TextEditingController otp = TextEditingController();
  TextEditingController mobile = TextEditingController();
  late TextEditingController otpController;
  
  // OTP Display Variables
  bool showOtpMessage = false;
  String? receivedOtp;
  Timer? otpDisplayTimer;

  String formatPhoneNumber(String phone, String selectedCountryCode) {
    if (phone.length < 4) {
      return '$selectedCountryCode $phone';
    }

    // Reveal the first two and last two numbers, mask the rest
    String visibleStart = phone.substring(0, 2);
    String visibleEnd = phone.substring(phone.length - 2);
    String maskedMiddle = '*' * (phone.length - 4);

    String maskedNumber = '$visibleStart$maskedMiddle$visibleEnd';
    return '$selectedCountryCode $maskedNumber';
  }

  void initState() {
    super.initState();
    hp = Helper.of(context);
    otpController = TextEditingController();
    startTimer();
    getdata();
    

    simulateOtpReception();
  }

  void simulateOtpReception() async {
    SharedPreferences perfs = await SharedPreferences.getInstance();
    String demoOtp = perfs.getString(AppConstants.USEROTP) ?? '';

    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          receivedOtp = demoOtp;
          showOtpMessage = true;
        });
        otpDisplayTimer = Timer(Duration(seconds: 50), () {
          if (mounted) {
            setState(() {
              showOtpMessage = false;
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.message, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'OTP Received: $demoOtp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'USE',
              textColor: Colors.white,
              onPressed: () {
                _useReceivedOtp(demoOtp);
              },
            ),
          ),
        );
      }
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

  Future<void> getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile.text = prefs.getString(AppConstants.USERMOBILE) ?? '';
      isExistingUser = prefs.getBool(AppConstants.IS_EXISTING_USER) ?? false;
    });
    print("Mobile: ${mobile.text}, Is Existing User: $isExistingUser");
    await _getCurrentLocation();
  }

  late Timer _timer;
  int _start = 90;
  late Helper hp;
  bool haserror = false;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            _timer.cancel();
          });
        } else {
          _timer.cancel();
        }
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  bool isPinComplete = false;
  String pin = "";
  
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    otpDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 35,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        height: 1.9,
      ).copyWith(fontSize: MediaQuery.of(context).size.height * 0.045),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(color: const Color.fromARGB(255, 223, 211, 211)),
      ),
    );
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    String formattedPhoneNumber = formatPhoneNumber(
      mobile.text,
      widget.selectedCountryCode,
    );
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      body: Stack(
        children: [
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ConstantImageKey.Bg),
                fit: BoxFit.cover,
              ),
            ),
            child: Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    SizedBox(height: screenHeight * 0.25),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'OTP',
                        style: Styles.textStyleExtraHugeBold(
                          color: AppColor.fillColor,
                          context,
                        ),
                        textScaleFactor: 1.0,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Verfication',
                        style: Styles.textStyleExtraHugeBold(
                          color: AppColor.fillColor,
                          context,
                        ),
                        textScaleFactor: 1.0,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'We have send the code',
                      style: Styles.textStyleLarge(
                        color: AppColor.blackColor,
                        context,
                      ),
                      textScaleFactor: 1.0,
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'verification to ',
                          style: Styles.textStyleLarge(
                            color: AppColor.blackColor,
                            context,
                          ),
                          children: [
                            TextSpan(
                              text: formattedPhoneNumber,
                              style: Styles.textStyleLarge(
                                color: const Color.fromARGB(255, 223, 54, 42),
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Pinput(
                      length: 6,
                      controller: otpController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColor.blackColor),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          pin = value;
                          isPinComplete = value.length == 6;
                          print("${pin}----------------------------------------");
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    GestureDetector(
                      onTap: _start == 0
                          ? () {
                              setState(() {
                                _start = 90;
                                startTimer();
                              });
                              // Simulate new OTP for demo
                              simulateOtpReception();
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
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            " Resend",
                            style: Styles.textStyleLarge(
                              context,
                              color: _start == 0
                                  ? AppColor.fillColor
                                  : AppColor.fillColor,
                            ),
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                          ),
                          if (_start > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '($_start s)',
                                  style: Styles.textStyleMedium(
                                    context,
                                    color: const Color.fromARGB(255, 223, 54, 42),
                                  ),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Spacer(),
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
                      onTap: () async {
                        if (isPinComplete) {
                          FocusScope.of(context).unfocus();

                          try {
                            // Set loading state at the beginning
                            setState(() => isLoading = true);

                            // Read isExistingUser from SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            bool isExisting =
                                prefs.getBool(AppConstants.IS_EXISTING_USER) ??
                                false;

                            // Store this value for later use
                            final verifyCallback = () async {
                              if (isExisting) {
                                // Existing User → Verify and Login
                                await AppDialogue.openLoadingDialogAfterClose(
                                  context,
                                  text: "Verifying OTP...",
                                  load: () async {
                                    return await provider.verifyLogin(
                                      mobile: mobile.text,
                                      otp: pin,
                                    );
                                  },
                                  afterComplete: (resp) async {
                                    if (resp.status) {
                                      print("✅ OTP Verified. Navigating to Home.");
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AppPage(tabNumber: 1),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      // Reset loading state if verification fails
                                      if (mounted) {
                                        setState(() => isLoading = false);
                                      }
                                      AppDialogue.toast(
                                        "Invalid OTP, please try again!",
                                      );
                                    }
                                  },
                                );
                              } else {
                                // 🚀 New User → Go to Register Page
                                print(
                                  "🆕 New user detected, navigating to registration page...",
                                );
                                await AppRouteName.register.pushAndRemoveUntil(
                                  context,
                                  (route) => false,
                                  args: {'otp': pin, 'mobile': mobile.text},
                                );
                              }
                            };

                            // Call the verification flow
                            await verifyCallback();
                          } on Exception catch (e) {
                            ExceptionHandler.showMessage(context, e);
                            // Reset loading state on error
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        } else {
                          AppDialogue.toast("Please enter a valid 6-digit OTP");
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ),

          // OTP Message Overlay - Same UI as Document 1
          if (showOtpMessage && receivedOtp != null)
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.message, color: Colors.green, size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OTP Message Received',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your verification code: $receivedOtp',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            'for ${formatPhoneNumber(mobile.text, widget.selectedCountryCode)}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _useReceivedOtp(receivedOtp!);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'USE',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showOtpMessage = false;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    const String googleApiKey = "AIzaSyCemA7pZSzNgEfnp77-LLvKJkODkPUGkCU";

    // ✅ Step 1: Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are disabled. Please enable them.";
      });
      await Geolocator.openLocationSettings();
      return;
    }

    // ✅ Step 2: Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permission denied. Please enable it.";
        });
        await Geolocator.openAppSettings();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage =
            "Location permission permanently denied. Please enable in settings.";
      });
      await Geolocator.openAppSettings();
      return;
    }

    // ✅ Step 3: Get the current coordinates
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        locationMessage =
            "Lat: ${position.latitude}, Long: ${position.longitude}";
      });

      // ✅ Step 4: Get address using Google Geocoding API
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey";

      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['results'] != null && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];

          setState(() {
            Address = formattedAddress;
          });

          print("📍 Address from API: $Address");
          await _saveLocationData(position, formattedAddress);
        } else {
          setState(() {
            Address = "No address found";
          });
        }
      } else {
        setState(() {
          Address = "Failed to fetch address (${response.statusCode})";
        });
      }
    } catch (e) {
      print("❌ Error while fetching location/address: $e");
      if (mounted) {
        setState(() {
          Address = "Failed to get location or address.";
        });
      }
    }
  }

  Future<void> _saveLocationData(Position position, String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.USERLATITUTE, position.latitude);
    await prefs.setDouble(AppConstants.USERLONGITUTE, position.longitude);
    await prefs.setString(AppConstants.USERADDRESS, address);
    print("✅ Location data saved: $address");
  }
}