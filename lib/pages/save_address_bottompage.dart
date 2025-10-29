import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/main_home_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveAddressBottompage extends StatefulWidget {
  final String page;
  final String name;
  final String mobile;
  final String addressType;
  final String flatHouseNo;
  final String fullAddress;

  const SaveAddressBottompage({
    super.key,
    required this.page,
    required this.name,
    required this.mobile,
    required this.addressType,
    required this.flatHouseNo,
    required this.fullAddress,
  });

  @override
  State<SaveAddressBottompage> createState() => _SaveAddressBottompageState();
}

class _SaveAddressBottompageState extends State<SaveAddressBottompage> {
  GetProvider get getprovider => context.read<GetProvider>();

  String mobile = '';
  String name = '';
  bool isEditing = false;
  String selectedAddress = '';
  String? token = '';
  String updatedName = '';
  String updatedMobile = '';
  String _address = "Loading..."; // Default value
  LatLng draggedLatLng = LatLng(0.0, 0.0);
  String flatHouseNo = '';
  String landmark = '';
  String updatedFlatHouseNo = '';
  String updatedLandmark = '';
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController flatHouseNoController = TextEditingController();
  final TextEditingController landmarkController =
      TextEditingController(); // New controller

  gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(AppConstants.token);
    log("$token");
  }

 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gettoken();
    // _getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: screenHeight * 0.7,
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Your Address',
                  style: Styles.textStyleLarge(
                    context,
                    color: AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(ConstantImageKey.mapimage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColor.hintTextColor,
                              ),
                              SizedBox(width: 15),
                              RichText(
                                text: TextSpan(
                                  text: 'Delivery at ',
                                  style: Styles.textStyleMedium(
                                    context,
                                    color: AppColor.hintTextColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${widget.flatHouseNo?.toUpperCase() ?? ''}',
                                      style: Styles.textStyleMedium(
                                        context,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Container(
                            width: screenWidth * 0.6,
                            child: Text(
                              '${widget.fullAddress}',
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              softWrap: true,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: AppColor.hintTextColor),
                              SizedBox(width: 15),
                              RichText(
                                text: TextSpan(
                                  text: widget.mobile,
                                  style: Styles.textStyleMedium(
                                    context,
                                    color: AppColor.hintTextColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ',  ${widget.name}',
                                      style: Styles.textStyleMedium(
                                        context,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: screenWidth * 0.45,
          top: -screenHeight * 0.065,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.4),
                width: screenWidth * 0.005,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0, // Position it at the bottom
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                MyButton(
                  text: 'Save Address',
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
                    try {
                      await AppDialogue.openLoadingDialogAfterClose(
                        context,
                        text: "Saving...",
                        load: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          // Get latitude and longitude from temp storage
                          double? latitude = prefs.getDouble(
                            AppConstants.TEMP_USERLATITUTE,
                          );
                          double? longitude = prefs.getDouble(
                            AppConstants.TEMP_USERLONGITUTE,
                          );

                          // Save to permanent storage
                          if (latitude != null && longitude != null) {
                            await prefs.setDouble(
                              AppConstants.USERLATITUTE,
                              latitude,
                            );
                            await prefs.setDouble(
                              AppConstants.USERLONGITUTE,
                              longitude,
                            );
                          }
await prefs.setString(AppConstants.DEV_USERNAME, widget.name);
                          // Save address details
                          await prefs.setString(
                            AppConstants.ADDRESS_TYPE,
                            widget.addressType,
                          );
                          await prefs.setString(
                            AppConstants.ADDRESS_NAME,
                            widget.flatHouseNo,
                          );
                          await prefs.setString(
                            AppConstants.USERADDRESS,
                            widget.fullAddress,
                          );

                          log('🟢 Saved address details to SharedPreferences:');
                          log(
                            'Address Type: ${widget.addressType}',
                          ); // Home/Work/Others
                          log(
                            'Address Name: ${widget.flatHouseNo}',
                          ); // Home/Work or custom input
                          log('Full Address: ${widget.fullAddress}');

                          // Call API with correct data
                          return await getprovider.addAddress(
                            name: widget.name,
                            phone: widget.mobile,
                            token: token.toString(),
                            address: widget.fullAddress,
                            addressType: widget.addressType, // Home/Work/Others
                            addAddressName: widget
                                .flatHouseNo, // Home/Work or flat/house number
                          );
                        },
                        afterComplete: (resp) async {
                          bool isSuccess =
                              resp.statusCode == 200 ||
                              (resp.data is Map &&
                                  resp.data['message']
                                          ?.toString()
                                          .toLowerCase()
                                          .contains('success') ==
                                      true);

                          if (isSuccess) {
                            log("🟢 Address saved successfully");
                            AppRouteName.apppage.push(context, args: 1);
                            AppDialogue.toast("Address saved successfully");
                          } else {
                            log("🔴 Error saving address: ${resp.data}");
                            AppDialogue.toast("Failed to save address");
                          }
                        },
                      );
                    } on Exception catch (e) {
                      log("🔴 Exception when saving address: $e");
                      ExceptionHandler.showMessage(context, e);
                    }
                  },
               
                ),
                SizedBox(height: 20),
                MyButton(
                  text: 'Change',
                  textcolor: AppColor.blackColor,
                  textsize: 20,
                  fontWeight: FontWeight.bold,
                  letterspacing: 0.7,
                  buttoncolor: Colors.transparent,
                  borderColor: AppColor.yellowColor,
                  buttonheight: 55 * (screenHeight / 812),
                  buttonwidth: screenWidth,
                  radius: 40,
                  onTap: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
