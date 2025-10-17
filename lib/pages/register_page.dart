import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fulupo/components/api_validation_error_view.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/util/textfields_widget.dart';
import 'package:fulupo/util/validator.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  final String Otp;
  const RegisterPage({super.key, required this.Otp});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserProvider get provider => context.read<UserProvider>();
  bool isLoading = false;
  String _address = "";
  String token = '';
  LatLng draggedLatLng = LatLng(0.0, 0.0);
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
      print('Error retrieving location data: $e');
      setState(() {
        _address = "Error retrieving address."; // Update with error message
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    _getLocationData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobileController.text =
          prefs.getString(AppConstants.USERMOBILE) ?? 'No number saved';
      token = prefs.getString(AppConstants.token) ?? '';
    });
    log(widget.Otp);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: AppConstants.scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.fillColor,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ConstantImageKey.Bg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Form(
            key: AppConstants.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.3),
                CustomTextFormField(
                  controller: usernameController,
                  read: false,
                  obscureText: false,
                  hintText: 'Enter your name',
                  validator: Validator.notEmpty,
                  keyboardType: TextInputType.text,
                  maxlines: 1,
                ),
                if (provider.isApiValidationError) const SizedBox(height: 20),
                if (provider.isApiValidationError)
                  ApiValidationErrorView(data: AppConstants.apiValidationModel),
                SizedBox(height: 20),
                CustomTextFormField(
                  controller: mobileController,
                  read: true,
                  obscureText: false,
                  hintText: 'Phone Number',
                  validator: Validator.validateMobile,
                  keyboardType: TextInputType.text,
                  maxlines: 1,
                ),
                if (provider.isApiValidationError) const SizedBox(height: 20),
                if (provider.isApiValidationError)
                  ApiValidationErrorView(data: AppConstants.apiValidationModel),
                SizedBox(height: 20),
                CustomTextFormField(
                  controller: emailController,
                  read: false,
                  obscureText: false,
                  hintText: 'Enter your Email',
                  validator: Validator.notEmpty,
                  keyboardType: TextInputType.text,
                  maxlines: 1,
                ),
                SizedBox(height: 30),
                MyButton(
                  text: isLoading ? 'Loading...' : "Register",
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
                    if (AppConstants.formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();

                      // Simulate registration (no API call)
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString(
                        AppConstants.USERNAME,
                        usernameController.text,
                      );
                      await prefs.setString(
                        AppConstants.USERMOBILE,
                        mobileController.text,
                      );
                      await prefs.setString(
                        AppConstants.USEREMAIL,
                        emailController.text,
                      );
                      await prefs.setString(AppConstants.USEROTP, widget.Otp);
                      await prefs.setString(AppConstants.USERADDRESS, _address);

                      // Navigate to next page (without API)
                      await AppRouteName.mainhomepage.pushAndRemoveUntil(
                        context,
                        (route) => false,
                      );
                    } else {
                      AppDialogue.toast("Please fill all fields!");
                    }
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}