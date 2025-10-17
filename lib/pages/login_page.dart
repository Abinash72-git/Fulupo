import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/otp.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/util/validator.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mobile = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;
  bool isManualInput = false;
  // List of country codes
  final List<String> countryCodes = ['+91', '+1', '+44', '+61', '+81'];
  String selectCountryCode = '+91'; // Default selected country code
  String phoneNumber = '';

  // Define expected phone number lengths based on country code
  final Map<String, int> expectedPhoneLengths = {
    '+91': 10, // India: 10 digits
    '+1': 10, // US/Canada: 10 digits
    '+44': 10, // UK: 10 digits
    '+61': 9, // Australia: 9 digits
    '+81': 10, // Japan: 10 digits
  };

  UserProvider get provider => context.read<UserProvider>();

  @override
  void initState() {
    super.initState();
    getPhoneNumbers();
  }

  Future<void> getPhoneNumbers() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      String? phoneNumber = await SmsAutoFill().hint;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        _showPhoneNumberDialog([phoneNumber]);
      } else {
        if (!mounted) return;
        setState(() {
          isManualInput = true;
        });
      }
    } catch (e) {
      print("Failed to get phone number: $e");
      if (!mounted) return;
      setState(() {
        isManualInput = true;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to show a dialog with detected phone numbers
  void _showPhoneNumberDialog(List<String> phoneNumbers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Your Number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ...phoneNumbers.map((phone) {
                  String phoneWithoutCountryCode = phone.length > 10
                      ? phone.substring(phone.length - 10)
                      : phone;

                  return ListTile(
                    title: Text(phoneWithoutCountryCode),
                    onTap: () {
                      setState(() {
                        mobile.text = phoneWithoutCountryCode;
                        isManualInput = false;
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                }).toList(),
                ListTile(
                  title: Text(
                    'None of the above',
                    style: Styles.textStyleMedium(context, color: Colors.blue),
                  ),
                  onTap: () {
                    setState(() {
                      isManualInput = true;
                      mobile.clear(); // Clear text for manual input
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      body: Container(
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
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                SizedBox(height: screenHeight * 0.3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Mobile',
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
                SizedBox(height: screenWidth * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaleFactor: 1.0),
                            child: TextFormField(
                              controller: mobile,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }

                                // Get expected length based on country code
                                int expectedLength =
                                    expectedPhoneLengths[selectCountryCode] ??
                                    10;

                                if (value.length != expectedLength) {
                                  return 'Please enter valid $expectedLength digit number';
                                }

                                return null;
                              },
                              keyboardType: TextInputType.number,
                              readOnly: !isManualInput,
                              obscureText: false,
                              onTap: () async {
                                if (!isManualInput) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await getPhoneNumbers();
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              // Add onChanged to handle keyboard dismissal
                              onChanged: (value) {
                                // Get expected length for the selected country code
                                int expectedLength =
                                    expectedPhoneLengths[selectCountryCode] ??
                                    10;

                                // If input length matches expected length, dismiss keyboard
                                if (value.length == expectedLength) {
                                  // Remove focus to dismiss keyboard
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 5.0,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectCountryCode,
                                      items: countryCodes.map((String code) {
                                        return DropdownMenuItem<String>(
                                          value: code,
                                          child: Text(
                                            code,
                                            style: Styles.textStyleLarge(
                                              context,
                                              color: AppColor.blackColor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != selectCountryCode) {
                                          setState(() {
                                            selectCountryCode =
                                                newValue ?? '+91';
                                            // Clear the field if country code changes
                                            mobile.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                hintText: isManualInput
                                    ? 'Enter your mobile number'
                                    : 'Select your number...',
                                hintStyle: Styles.textStyleLarge(
                                  context,
                                  color: AppColor.hintTextColor,
                                ).copyWith(fontSize: screenHeight * 0.017),
                                filled: true,
                                fillColor: AppColor.whiteColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 30.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  borderSide: const BorderSide(
                                    color: AppColor.fillColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  borderSide: const BorderSide(
                                    color: AppColor.fillColor,
                                    width: .5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  borderSide: const BorderSide(
                                    color: AppColor.fillColor,
                                    width: .5,
                                  ),
                                ),
                              ),
                              style: Styles.textStyleLarge(
                                context,
                                color: AppColor.blackColor,
                              ).copyWith(fontSize: screenHeight * 0.02),
                            ),
                          ),
                          if (isLoading)
                            const Positioned(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.whiteColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                MyButton(
                  text: isLoading ? 'Loading...' : "GET OTP",
                  textcolor: AppColor.whiteColor,
                  textsize: 23 * (screenWidth / 375),
                  fontWeight: FontWeight.bold,
                  letterspacing: 0.7,
                  buttoncolor: AppColor.fillColor,
                  borderColor: AppColor.fillColor,
                  buttonheight: 55 * (screenHeight / 812),
                  buttonwidth: screenWidth,
                  radius: 40,

                  // In your login.dart - Update the onTap method of GET OTP button:
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      try {
                        await AppDialogue.openLoadingDialogAfterClose(
                          context,
                          text: "Loading...",
                          load: () async {
                            return await provider.sendOTP(mobile: mobile.text);
                          },
                          afterComplete: (resp) async {
                            if (resp.statusCode == 200) {
                              print("Success");

                              // Extract data from response
                              final bool isExistingUser =
                                  resp.fullBody["isExistingUser"] ?? false;
                              final String otpNo =
                                  resp.fullBody["sent"]?["otpNo"] ?? "";

                              // Save all data locally
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                AppConstants.USERMOBILE,
                                mobile.text,
                              );
                              await prefs.setBool(
                                AppConstants.IS_EXISTING_USER,
                                isExistingUser,
                              );
                              await prefs.setString(
                                AppConstants.USEROTP,
                                otpNo,
                              );

                              AppDialogue.toast(resp.data);

                              // Navigate to OTP page
                              AppRouteName.otp.push(
                                context,
                                args: selectCountryCode,
                              );
                            }
                          },
                        );
                      } on Exception catch (e) {
                        ExceptionHandler.showMessage(context, e);
                      }
                    }
                  },
                ),
                SizedBox(height: screenHeight * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
