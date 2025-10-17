
import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/main_home_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUserSaveAddress extends StatefulWidget {
  const NewUserSaveAddress({super.key});

  @override
  State<NewUserSaveAddress> createState() => _NewUserSaveAddressState();
}

class _NewUserSaveAddressState extends State<NewUserSaveAddress> {
  GetProvider get getprovider => context.read<GetProvider>();

  String mobile = '';
  String name = '';
  bool isEditing = false;
  String selectedAddress = '';
  String token = '';
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

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Fetch using new keys
      mobile = prefs.getString('NEW_USER_MOBILE') ?? '';
      name = prefs.getString('NEW_USER_NAME') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';
      flatHouseNo =
          prefs.getString('FLAT_HOUSE_NO') ?? ''; // Fetch flat/house no.
      landmark = prefs.getString('NEARBY_LANDMARK') ?? ''; // Fetch landmark
      nameController.text = name;
      mobileController.text = mobile;
      flatHouseNoController.text = flatHouseNo; // Set text for flat/house no.
      landmarkController.text = landmark; // Set text for landmark
      token = prefs.getString(AppConstants.token)!;

      print(selectedAddress);
      print(landmark);
    });
  }

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
    // TODO: implement initState
    super.initState();
    getdata();
    _getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: screenHeight * 0.7, // Height of the bottom sheet
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
                                      text: '${selectedAddress}',
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
                              '${flatHouseNo},${_address},${landmark}',
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
                                  text: mobile,
                                  style: Styles.textStyleMedium(
                                    context,
                                    color: AppColor.hintTextColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ',  ${name}',
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
                    try {
                      await AppDialogue.openLoadingDialogAfterClose(
                        context,
                        text: "Saving...",
                        load: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(
                            'SELECTED_ADDRESS_TYPE',
                            selectedAddress,
                          );
                          await prefs.setString(
                            'SELECTED_FLAT_HOUSE_NO',
                            flatHouseNo,
                          );
                          await prefs.setString('SELECTED__ADDRESS', _address);
                          await prefs.setString('SELECTED_LANDMARK', landmark);
                          await prefs.setString('SELECTED_MOBILE', mobile);
                          await prefs.setString(
                            'SELECTED_USER_NAME',
                            name ?? '',
                          );

                          // Log the saved details for debugging
                          print('Address Details Saved:');
                          print('Address Type: $selectedAddress');
                          print('Flat/House No: $flatHouseNo');
                          print('Address: $_address');
                          print('Landmark: $landmark');
                          print('Mobile: $mobile');
                          print('User Name: ${name ?? 'Unknown'}');
                          return await getprovider.addAddress(
                            name: name,
                            phone: mobile,
                            token: token,
                            address:
                                _address.isEmpty
                                    ? 'No address found'
                                    : _address,

                            addressType: selectedAddress,
                            addAddressName: "",
                          );
                        },
                        afterComplete: (resp) async {
                          if (resp.statusCode==200) {
                            print("sucess");

                            AppDialogue.toast(resp.data);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainHomePage(),
                              ),
                            );
                          }
                        },
                      );
                    } on Exception catch (e) {
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
                  borderColor: AppColor.fillColor,
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
