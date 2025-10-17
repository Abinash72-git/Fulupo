
// import 'package:flutter/material.dart';
// import 'package:fulupo/components/api_validation_error_view.dart';
// import 'package:fulupo/components/button.dart';
// import 'package:fulupo/provider/user_provider.dart';
// import 'package:fulupo/route_genarator.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/util/constant_image.dart';
// import 'package:fulupo/util/exception.dart';
// import 'package:fulupo/util/textfields_widget.dart';
// import 'package:fulupo/util/validator.dart';
// import 'package:fulupo/widget/dilogue/dilogue.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RegisterPage2 extends StatefulWidget {
//   const RegisterPage2({super.key});

//   @override
//   State<RegisterPage2> createState() => _RegisterPage2State();
// }

// class _RegisterPage2State extends State<RegisterPage2> {
//   UserProvider get provider => context.read<UserProvider>();
//   bool isLoading = false;
//   String _address = "";
//   String token = '';
//   LatLng draggedLatLng = LatLng(0.0, 0.0);
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();

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

//   @override
//   void initState() {
//     super.initState();
//     getData();
//     _getLocationData();
//   }

//   Future<void> getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       mobileController.text =
//           prefs.getString(AppConstants.USERMOBILE) ?? 'No number saved';
//       token = prefs.getString(AppConstants.token)!;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       key: AppConstants.scaffoldKey,
//       resizeToAvoidBottomInset: false,
//       backgroundColor: AppColor.fillColor,
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(ConstantImageKey.Bg),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//           child: Form(
//             key: AppConstants.formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: screenHeight * 0.2,
//                 ),
//                 Center(
//                   child: Container(
//                     height: screenHeight * 0.13,
//                     width: screenWidth,
//                   ),
//                 ),
//                 // Text(token),
//                 SizedBox(
//                   height: screenHeight * 0.1,
//                 ),
//                 CustomTextFormField(
//                   controller: usernameController,
//                   read: false,
//                   obscureText: false,
//                   hintText: 'Enter your name',
//                   validator: Validator.notEmpty,
//                   keyboardType: TextInputType.text,
//                   maxlines: 1,
//                 ),
//                 if (provider.isApiValidationError)
//                   const SizedBox(
//                     height: 20,
//                   ),
//                 if (provider.isApiValidationError)
//                   ApiValidationErrorView(
//                     data: AppConstants.apiValidationModel,
//                   ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 CustomTextFormField(
//                   controller: mobileController,
//                   read: true,
//                   obscureText: false,
//                   hintText: 'Phone Number',
//                   validator: Validator.validateMobile,
//                   keyboardType: TextInputType.text,
//                   maxlines: 1,
//                 ),
//                 if (provider.isApiValidationError)
//                   const SizedBox(
//                     height: 20,
//                   ),
//                 if (provider.isApiValidationError)
//                   ApiValidationErrorView(
//                     data: AppConstants.apiValidationModel,
//                   ),
//                 Spacer(),
//                 MyButton(
//                   text: isLoading ? 'Loading...' : "Register",
//                   textcolor: AppColor.whiteColor,
//                   textsize: 20,
//                   fontWeight: FontWeight.bold,
//                   letterspacing: 0.7,
//                   buttoncolor: AppColor.fillColor,
//                   borderColor: AppColor.fillColor,
//                   buttonheight: 55 * (screenHeight / 812),
//                   buttonwidth: screenWidth,
//                   radius: 40,
//                   onTap: () async {
//                     if (AppConstants.formKey.currentState!.validate()) {
//                       FocusScope.of(context).unfocus();
//                       try {
//                         await AppDialogue.openLoadingDialogAfterClose(
//                           context,
//                           text: "Creating Profile...",
//                           load: () async {
//                             return await provider.createProfile(
//                                 userName: usernameController.text,
//                                 location: _address,
//                                 phone: mobileController.text);
//                           },
//                           afterComplete: (resp) async {
//                             if (resp.status) {
//                               print("Profile created successfully!");
//                               SharedPreferences prefs =
//                                   await SharedPreferences.getInstance();
//                               await prefs.setString(AppConstants.USERNAME,
//                                   usernameController.text);
//                               String? savedUserName =
//                                   prefs.getString(AppConstants.USERNAME);
//                               print(
//                                   'Saved User Name : $savedUserName---------------------------');
//                               //AppDialogue.toast(resp.data);
//                               await AppRouteName.allowlocationpage
//                                   .pushAndRemoveUntil(
//                                       context, (route) => false);
//                             } else {
//                               AppDialogue.toast(
//                                   "Failed to create profile. Please try again!");
//                             }
//                           },
//                         );
//                       } on Exception catch (e) {
//                         ExceptionHandler.showMessage(context, e);
//                       }
//                     } else {
//                       AppDialogue.toast("Please fill all fields!");
//                     }
//                   },
//                 ),
//                 SizedBox(
//                   height: screenHeight * 0.2,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
