
import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/address_bottomsheet_page.dart';
import 'package:fulupo/pages/delivery_map_pages.dart';
import 'package:fulupo/pages/new_user/new_user_save_address.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/validator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUserBottomSheet extends StatefulWidget {
  const NewUserBottomSheet({super.key});

  @override
  State<NewUserBottomSheet> createState() => _NewUserBottomSheetState();
}

class _NewUserBottomSheetState extends State<NewUserBottomSheet> {
  String mobile = '';
  String name = '';
  bool isEditing = false;
  String selectedAddress = '';

  String updatedName = '';
  String updatedMobile = '';
  String _address = "Loading..."; // Default value
  LatLng draggedLatLng = LatLng(0.0, 0.0);
  String flatHouseNo = ''; // New field for Flat/House No/Floor/Building
  String landmark = ''; // New field for Nearby Landmark
  String updatedFlatHouseNo = ''; // New local variable
  String updatedLandmark = ''; // New local variable
  bool isLoading = false;
  String token = '';
  UserProvider get provider => context.read<UserProvider>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController flatHouseNoController =
      TextEditingController(); // New controller
  final TextEditingController landmarkController =
      TextEditingController(); // New controller
  // Check if both text fields have data entered

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Fetch saved data but do NOT update text fields
      mobile = prefs.getString('NEW_USER_MOBILE') ?? '';
      name = prefs.getString('NEW_USER_NAME') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';
      flatHouseNo = prefs.getString('FLAT_HOUSE_NO') ?? '';
      landmark = prefs.getString('NEARBY_LANDMARK') ?? '';
      token = prefs.getString(AppConstants.token) ?? '';

      print(selectedAddress);
      print(landmark);
      print(token);
    });
    await provider.fetchUser(token);
  }

  Future<bool> saveData() async {
    try {
      // Get the updated text from controllers
      updatedName = nameController.text;
      updatedMobile = mobileController.text;
      updatedFlatHouseNo = flatHouseNoController.text;
      updatedLandmark = landmarkController.text;

      // Validation: Ensure that Flat/House No and Landmark are not empty
      if (updatedFlatHouseNo.isEmpty ||
          selectedAddress.isEmpty ||
          updatedMobile.isEmpty ||
          landmarkController.text.isEmpty ||
          updatedName.isEmpty) {
        // Show a message if any of the fields are empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return false; // Return false if validation fails
      }

      // Proceed to save data if all fields are filled
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('NEW_USER_NAME', updatedName);
      await prefs.setString('NEW_USER_MOBILE', updatedMobile);
      await prefs.setString('FLAT_HOUSE_NO', updatedFlatHouseNo);
      await prefs.setString('NEARBY_LANDMARK', updatedLandmark);

      // Update state after saving
      setState(() {
        name = updatedName;
        mobile = updatedMobile;
        flatHouseNo = updatedFlatHouseNo;
        landmark = updatedLandmark;
        isEditing = false;
      });

      print('Data saved successfully.');
      print('Name saved locally: $updatedName');
      print('Mobile saved locally: $updatedMobile');
      print('Flat/House No saved locally: $updatedFlatHouseNo');
      print('Landmark saved locally: $updatedLandmark');
      return true; // Return true to indicate success
    } catch (e) {
      // Handle any errors during the saving process
      print('Error saving data: $e');
      return false; // Return false to indicate failure
    }
  }

  // Save the selected address to SharedPreferences
  saveSelectedAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'SELECTED_ADDRESS',
      address,
    ); // Save the selected address
    setState(() {
      selectedAddress = address; // Update the selected address dynamically
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
    super.initState();
    nameController.clear();
    mobileController.clear();
    flatHouseNoController.clear();
    landmarkController.clear();
    getdata();
    _getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: screenHeight * 0.9,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Enter Complete Address",
                        style: Styles.textStyleLarge(
                          context,
                          color: AppColor.blackColor,
                        ),
                        textScaleFactor: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Receiver Details',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            const SizedBox(height: 10),
                            MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(textScaleFactor: 1.0),
                              child: TextField(
                                controller: nameController,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(textScaleFactor: 1.0),
                              child: TextField(
                                controller: mobileController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Mobile",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Text(
                              'May be used to assist delivery',
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              'Save address as *',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.blackColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    saveSelectedAddress('Home');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 5,
                                    ),
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedAddress == 'Home'
                                              ? AppColor.fillColor
                                              : AppColor.whiteColor,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: AppColor.fillColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color:
                                              selectedAddress == 'Home'
                                                  ? Colors.white
                                                  : AppColor.hintTextColor,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Home',
                                              style: Styles.textStyleSmall(
                                                context,
                                                color:
                                                    selectedAddress == 'Home'
                                                        ? Colors.white
                                                        : AppColor
                                                            .hintTextColor,
                                              ),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    saveSelectedAddress('Work');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 5,
                                    ),
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedAddress == 'Work'
                                              ? AppColor.fillColor
                                              : AppColor.whiteColor,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: AppColor.fillColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.work,
                                          color:
                                              selectedAddress == 'Work'
                                                  ? Colors.white
                                                  : AppColor.hintTextColor,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Work',
                                              style: Styles.textStyleSmall(
                                                context,
                                                color:
                                                    selectedAddress == 'Work'
                                                        ? Colors.white
                                                        : AppColor
                                                            .hintTextColor,
                                              ),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    saveSelectedAddress('Hotel');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 5,
                                    ),
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedAddress == 'Hotel'
                                              ? AppColor.fillColor
                                              : AppColor.whiteColor,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: AppColor.fillColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.hotel_rounded,
                                          color:
                                              selectedAddress == 'Hotel'
                                                  ? Colors.white
                                                  : AppColor.hintTextColor,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Hotel',
                                              style: Styles.textStyleSmall(
                                                context,
                                                color:
                                                    selectedAddress == 'Hotel'
                                                        ? Colors.white
                                                        : AppColor
                                                            .hintTextColor,
                                              ),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: screenWidth,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade300,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: screenWidth * 0.6,
                                      child: Text(
                                        _address.isEmpty
                                            ? 'No address is found'
                                            : _address,
                                        style: Styles.textStyleSmall(
                                          context,
                                          color: AppColor.hintTextColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        softWrap: true,
                                        textAlign: TextAlign.start,
                                        textScaleFactor: 1.0,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => SelectAddressMap(
                                                  page: '',
                                                  targetPage:
                                                      AddressBottomsheetPage(
                                                        page: '',
                                                      ),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 80,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColor.whiteColor,
                                          border: Border.all(
                                            color: AppColor.fillColor,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Change',
                                            style: Styles.textStyleSmall(
                                              context,
                                              color: AppColor.fillColor,
                                            ),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Updated based on your exact map pin',
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            SizedBox(height: 20),
                            MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(textScaleFactor: 1.0),
                              child: TextFormField(
                                validator: Validator.notEmpty,
                                controller: flatHouseNoController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "Flat/House No/Floor/Building",
                                  labelStyle: TextStyle(
                                    color: AppColor.hintTextColor,
                                    fontSize: 15,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(textScaleFactor: 1.0),
                              child: TextFormField(
                                controller: landmarkController,
                                validator: Validator.notEmpty,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "Nearby Landmark",
                                  labelStyle: TextStyle(
                                    color: AppColor.hintTextColor,
                                    fontSize: 15,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  isKeyboardVisible ? screenHeight * 0.3 : 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    MyButton(
                      text: 'Confirm Address',
                      textcolor:
                          flatHouseNoController.text.isEmpty ||
                                  landmarkController.text.isEmpty
                              ? AppColor.whiteColor
                              : AppColor.whiteColor,
                      textsize: 20,
                      fontWeight: FontWeight.bold,
                      letterspacing: 0.7,
                      buttoncolor:
                          flatHouseNoController.text.isEmpty ||
                                  selectedAddress.isEmpty ||
                                  landmarkController.text.isEmpty ||
                                  nameController.text.isEmpty ||
                                  mobileController.text.isEmpty
                              ? Colors.grey.shade500
                              : AppColor.fillColor,
                      borderColor:
                          flatHouseNoController.text.isEmpty ||
                                  selectedAddress.isEmpty ||
                                  landmarkController.text.isEmpty ||
                                  nameController.text.isEmpty ||
                                  mobileController.text.isEmpty
                              ? Colors.grey.shade500
                              : AppColor.fillColor,
                      buttonheight: 55 * (screenHeight / 812),
                      buttonwidth: screenWidth,
                      radius: 40,
                      onTap: () async {
                        bool isSaved = await saveData();
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => CartPage(
                        //             products: selectedProducts,
                        //             productCount: productCount,
                        //             selectedWeights: selectedWeights)));
                        if (isSaved) {
                          Navigator.pop(
                            context,
                          ); // Close the current bottom sheet

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled:
                                true, // Allows the bottom sheet to take up more space
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return const NewUserSaveAddress(); // Call the bottom sheet from the new file
                            },
                          );
                        } else {
                          // Handle the case where saveData fails or is incomplete
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill in all fields to proceed',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
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
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
