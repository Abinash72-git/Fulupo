import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/delivery_map_pages.dart';
import 'package:fulupo/pages/save_address_bottompage.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/validator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressBottomsheetPage extends StatefulWidget {
  final String page;
  const AddressBottomsheetPage({super.key, required this.page});

  @override
  State<AddressBottomsheetPage> createState() => _AddressBottomsheetPageState();
}

class _AddressBottomsheetPageState extends State<AddressBottomsheetPage> {
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

bool isFlatHouseEnabled = false;
  UserProvider get provider => context.read<UserProvider>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressName =
      TextEditingController(); // New controller
  final TextEditingController landmarkController =
      TextEditingController(); // New controller
  // Check if both text fields have data entered

  // void saveSelectedAddress(String address) {
  //   setState(() {
  //     selectedAddresss = address;
  //   });
  // }
  

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Fetch saved data but do NOT update text fields
      // mobile = prefs.getString('NEW_USER_MOBILE') ?? '';
      mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
      name = prefs.getString('NEW_USER_NAME') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';
      flatHouseNo = prefs.getString('ADDRESS_TYPE') ?? '';
      landmark = prefs.getString('NEARBY_LANDMARK') ?? '';
      token = prefs.getString(AppConstants.token) ?? '';

      print(selectedAddress);
      print(landmark);
      print(token);
    });

    await provider.fetchUser(token);
  }

  // Future<bool> saveData() async {
  //   try {
  //     // Get the updated text from controllers
  //     updatedName = nameController.text;
  //     updatedMobile = mobileController.text;
  //     updatedFlatHouseNo = addressName.text;
  //     updatedLandmark = landmarkController.text;

  //     // Validation: Ensure that Flat/House No and Landmark are not empty
  //     if (updatedFlatHouseNo.isEmpty ||
  //         updatedLandmark.isEmpty ||
  //         updatedMobile.isEmpty ||
  //         selectedAddress.isEmpty ||
  //         updatedName.isEmpty) {
  //       // Show a message if any of the fields are empty
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please fill in all fields')),
  //       );
  //       return false; // Return false if validation fails
  //     }

  //     // Proceed to save data if all fields are filled
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('NEW_USER_NAME', updatedName);
  //     await prefs.setString('NEW_USER_MOBILE', updatedMobile);
  //     await prefs.setString('FLAT_HOUSE_NO', updatedFlatHouseNo);
  //     await prefs.setString('NEARBY_LANDMARK', updatedLandmark);

  //     // Update state after saving
  //     setState(() {
  //       name = updatedName;
  //       mobile = updatedMobile;
  //       flatHouseNo = updatedFlatHouseNo;
  //       landmark = updatedLandmark;
  //       isEditing = false;
  //     });

  //     print('Data saved successfully.');
  //     print('Name saved locally: $updatedName');
  //     print('Mobile saved locally: $updatedMobile');
  //     print('Flat/House No saved locally: $updatedFlatHouseNo');
  //     print('Landmark saved locally: $updatedLandmark');
  //     return true; // Return true to indicate success
  //   } catch (e) {
  //     // Handle any errors during the saving process
  //     print('Error saving data: $e');
  //     return false; // Return false to indicate failure
  //   }
  // }

Future<bool> saveData() async {
  try {
    print('🟢 Starting saveData process...');
    
    // Get the updated text from controllers
    updatedName = nameController.text;
    updatedMobile = mobileController.text;
    
    print('🟢 Name from controller: $updatedName');
    print('🟢 Mobile from controller: $updatedMobile');
    print('🟢 Selected address type: $selectedAddress');

    // Handle address name based on selection
    if (selectedAddress == 'Home' || selectedAddress == 'Work') {
      updatedFlatHouseNo = selectedAddress; // Use the selected type directly
      print('🟢 Using address type directly: $updatedFlatHouseNo');
    } else if (selectedAddress == 'Others') {
      updatedFlatHouseNo = addressName.text; // Use the custom text input
      print('🟢 Using custom address name: $updatedFlatHouseNo');
      
      // Validation for "Others" address type
      if (updatedFlatHouseNo.isEmpty) {
        print('🔴 Error: Custom address name is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a name for this address')),
        );
        return false;
      }
    }

    // Basic validation for all address types
    if (updatedMobile.isEmpty || selectedAddress.isEmpty || updatedName.isEmpty) {
      print('🔴 Error: Basic validation failed');
      print('🔴 Mobile empty: ${updatedMobile.isEmpty}');
      print('🔴 Address type empty: ${selectedAddress.isEmpty}');
      print('🔴 Name empty: ${updatedName.isEmpty}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return false;
    }

    // Proceed to save data if validation passes
    print('🟢 All validation passed, saving data...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('NEW_USER_NAME', updatedName);
    await prefs.setString('NEW_USER_MOBILE', updatedMobile);
    await prefs.setString('ADDRESS_TYPE', updatedFlatHouseNo);
    await prefs.setString('ADDRESS_NAME', selectedAddress == 'Others' ? 'Others' : selectedAddress);

    print('🟢 Data saved to SharedPreferences:');
    print('🟢 NEW_USER_NAME: $updatedName');
    print('🟢 NEW_USER_MOBILE: $updatedMobile');
    print('🟢 ADDRESS_TYPE: $updatedFlatHouseNo');
    print('🟢 ADDRESS_NAME: ${selectedAddress == 'Others' ? 'Others' : selectedAddress}');

    // Update state after saving
    setState(() {
      name = updatedName;
      mobile = updatedMobile;
      flatHouseNo = updatedFlatHouseNo;
      isEditing = false;
      
      print('🟢 State updated with new values');
    });

    print('🟢 Save process completed successfully');
    return true;
  } catch (e) {
    print('🔴 Error saving data: $e');
    return false;
  }
}


  // Future<bool> saveData() async {
  //   try {
  //     // Get the updated text from controllers
  //     updatedName = nameController.text;
  //     updatedMobile = mobileController.text;

  //     // For "Others" address, we need the flat/house info
  //     if (selectedAddress == 'Others') {
  //       updatedFlatHouseNo = addressName.text;

  //       // Validation for "Others" address type
  //       if (updatedFlatHouseNo.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Please enter flat/house details')),
  //         );
  //         return false;
  //       }
  //     } else {
  //       // For other address types, use default or empty value
  //       updatedFlatHouseNo = '';
  //     }

  //     // Basic validation for all address types
  //     if (updatedMobile.isEmpty ||
  //         selectedAddress.isEmpty ||
  //         updatedName.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please fill in all required fields')),
  //       );
  //       return false;
  //     }

  //     // Proceed to save data if validation passes
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('NEW_USER_NAME', updatedName);
  //     await prefs.setString('NEW_USER_MOBILE', updatedMobile);
  //     await prefs.setString('FLAT_HOUSE_NO', updatedFlatHouseNo);

  //     // Update state after saving
  //     setState(() {
  //       name = updatedName;
  //       mobile = updatedMobile;
  //       flatHouseNo = updatedFlatHouseNo;
  //       isEditing = false;
  //     });

  //     return true;
  //   } catch (e) {
  //     print('Error saving data: $e');
  //     return false;
  //   }
  // }

  // Load the selected address from local storage
  Future<void> loadSelectedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAddress =
          prefs.getString('SELECTED_ADDRESS') ?? ''; // Load saved address
    });
  }

  // Save selected address and update UI
  // Future<void> saveSelectedAddress(String address) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('SELECTED_ADDRESS', address); // Save address
  //   setState(() {
  //     selectedAddress = address; // Update UI dynamically
  //   });
  // }


Future<void> saveSelectedAddress(String address) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('SELECTED_ADDRESS', address); // Save address type
  
  print('🔵 Address type selected: $address');
  
  setState(() {
    selectedAddress = address; // Update UI dynamically
    
    // When Home or Work is selected, pre-fill the addressName controller
    if (address == 'Home' || address == 'Work') {
      addressName.text = address; // Set the value to match the selection
      print('🔵 Address name auto-filled with: ${addressName.text}');
    } else if (address == 'Others') {
      // For Others, clear the field to let user enter custom name
      addressName.clear();
      print('🔵 Address name field cleared for custom input');
    }
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
    addressName.clear();
    landmarkController.clear();
    getdata();
    _getLocationData();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    mobileController.dispose();
    addressName.dispose();
    landmarkController.dispose();
    super.dispose();
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
                                addressButton('Home', Icons.home),
                                addressButton('Work', Icons.work),
                                addressButton(
                                  'Others',
                                  Icons.help_outline_sharp,
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            // Replace the current TextFormField implementation with this
                            selectedAddress == 'Others'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MediaQuery(
                                        data: MediaQuery.of(
                                          context,
                                        ).copyWith(textScaleFactor: 1.0),
                                        child: TextFormField(
                                          validator: Validator.notEmpty,
                                          controller: addressName,
                                          keyboardType: TextInputType.text,
                                          decoration: const InputDecoration(
                                            labelText:
                                                "Flat/House No/Floor/Building",
                                            labelStyle: TextStyle(
                                              color: AppColor.hintTextColor,
                                              fontSize: 15,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  )
                                : SizedBox(
                                    height: 0,
                                  ), // Empty container when not "Others"

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
                                        _address,
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
                                            builder: (context) =>
                                                SelectAddressMap(
                                                  page: widget.page,
                                                  targetPage:
                                                      AddressBottomsheetPage(
                                                        page: widget.page,
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
                            // MediaQuery(
                            //   data: MediaQuery.of(context)
                            //       .copyWith(textScaleFactor: 1.0),
                            //   child: TextFormField(
                            //     validator: Validator.notEmpty,
                            //     controller: addressName,
                            //     keyboardType: TextInputType.text,
                            //     decoration: const InputDecoration(
                            //       labelText: "Flat/House No/Floor/Building",
                            //       labelStyle: TextStyle(
                            //           color: AppColor.hintTextColor,
                            //           fontSize: 15),
                            //       border: OutlineInputBorder(),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            // MediaQuery(
                            //   data: MediaQuery.of(context)
                            //       .copyWith(textScaleFactor: 1.0),
                            //   child: TextFormField(
                            //     controller: landmarkController,
                            //     validator: Validator.notEmpty,
                            //     keyboardType: TextInputType.text,
                            //     decoration: const InputDecoration(
                            //       labelText: "Nearby Landmark (optional)",
                            //       labelStyle: TextStyle(
                            //           color: AppColor.hintTextColor,
                            //           fontSize: 15),
                            //       border: OutlineInputBorder(),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: isKeyboardVisible
                                  ? screenHeight * 0.3
                                  : 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    // MyButton(
                    //     text: 'Confirm Address',
                    //     textcolor: nameController.text.isEmpty ||
                    //             mobileController.text.isEmpty
                    //         ? AppColor.whiteColor
                    //         : AppColor.blackColor,
                    //     textsize: 20,
                    //     fontWeight: FontWeight.bold,
                    //     letterspacing: 0.7,
                    //     buttoncolor:
                    //             nameController.text.isEmpty ||
                    //             selectedAddress.isEmpty ||
                    //             mobileController.text.isEmpty
                    //         ? Colors.grey.shade500
                    //         : AppColor.yellowColor,
                    //     borderColor:
                    //             nameController.text.isEmpty ||
                    //             selectedAddress.isEmpty ||
                    //             mobileController.text.isEmpty
                    //         ? Colors.grey.shade500
                    //         : AppColor.yellowColor,
                    //     buttonheight: 55 * (screenHeight / 812),
                    //     buttonwidth: screenWidth,
                    //     radius: 40,
                    //     onTap: () async {
                    //       bool isSaved = await saveData();
                    //       // Navigator.push(
                    //       //     context,
                    //       //     MaterialPageRoute(
                    //       //         builder: (context) => CartPage(
                    //       //             products: selectedProducts,
                    //       //             productCount: productCount,
                    //       //             selectedWeights: selectedWeights)));
                    //       if (isSaved) {
                    //         Navigator.pop(
                    //             context); // Close the current bottom sheet

                    //         showModalBottomSheet(
                    //           context: context,
                    //           isScrollControlled:
                    //               true, // Allows the bottom sheet to take up more space
                    //           shape: const RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.vertical(
                    //                 top: Radius.circular(20)),
                    //           ),
                    //           builder: (context) {
                    //             return SaveAddressBottompage(
                    //               page: widget.page,
                    //             ); // Call the bottom sheet from the new file
                    //           },
                    //         );
                    //       } else {
                    //         // Handle the case where saveData fails or is incomplete
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           const SnackBar(
                    //               content: Text(
                    //                   'Please fill in all fields to proceed')),
                    //         );
                    //       }
                    //     }),
                    MyButton(
                      text: 'Confirm Address',
                      textcolor: _shouldEnableButton()
                          ? AppColor.blackColor
                          : AppColor.whiteColor,
                      textsize: 20,
                      fontWeight: FontWeight.bold,
                      letterspacing: 0.7,
                      buttoncolor: _shouldEnableButton()
                          ? AppColor.yellowColor
                          : Colors.grey.shade500,
                      borderColor: _shouldEnableButton()
                          ? AppColor.yellowColor
                          : Colors.grey.shade500,
                      buttonheight: 55 * (screenHeight / 812),
                      buttonwidth: screenWidth,
                      radius: 40,
                      onTap: () async {
                        if (!_shouldEnableButton()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getErrorMessage())),
                          );
                          return;
                        }

                        bool isSaved = await saveData();
                        if (isSaved) {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return SaveAddressBottompage(page: widget.page);
                            },
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

  // Widget addressButton(String label, IconData icon) {
  //   bool isSelected = selectedAddress == label; // Check if selected

  //   return GestureDetector(
  //     onTap: () {
  //       saveSelectedAddress(label);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
  //       width: 90,
  //       decoration: BoxDecoration(
  //         color: isSelected ? AppColor.fillColor : AppColor.whiteColor,
  //         borderRadius: BorderRadius.circular(5),
  //         border: Border.all(color: AppColor.fillColor),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: isSelected ? Colors.white : Colors.black, // Default black
  //           ),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: FittedBox(
  //               fit: BoxFit.scaleDown,
  //               child: Text(
  //                 label,
  //                 style: Styles.textStyleSmall(
  //                   context,
  //                   color: isSelected
  //                       ? Colors.white
  //                       : Colors.black, // Default black
  //                 ),
  //                 textScaleFactor: 1.0,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  Widget addressButton(String label, IconData icon) {
  bool isSelected = selectedAddress == label;
  
  print('🟡 Rendering address button: $label (Selected: $isSelected)');

  return GestureDetector(
    onTap: () {
      print('🟡 Address button tapped: $label');
      saveSelectedAddress(label);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      width: 90,
      decoration: BoxDecoration(
        color: isSelected ? AppColor.fillColor : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColor.fillColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: Styles.textStyleSmall(
                  context,
                  color: isSelected ? Colors.white : Colors.black,
                ),
                textScaleFactor: 1.0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // Helper method to determine if button should be enabled
 bool _shouldEnableButton() {
  bool nameEmpty = nameController.text.isEmpty;
  bool mobileEmpty = mobileController.text.isEmpty;
  bool addressTypeEmpty = selectedAddress.isEmpty;
  bool customAddressEmpty = selectedAddress == 'Others' && addressName.text.isEmpty;
  
  print('🔵 Button validation check:');
  print('🔵 Name empty: $nameEmpty');
  print('🔵 Mobile empty: $mobileEmpty');
  print('🔵 Address type empty: $addressTypeEmpty');
  print('🔵 Custom address empty: $customAddressEmpty');
  
  // Basic validation for all address types
  if (nameEmpty || mobileEmpty || addressTypeEmpty) {
    print('🔵 Button should be disabled: Basic validation failed');
    return false;
  }

  // Additional validation for "Others" address type
  if (customAddressEmpty) {
    print('🔵 Button should be disabled: Custom address validation failed');
    return false;
  }

  print('🔵 Button should be enabled: All validations passed');
  return true;
}


  // Helper method to get appropriate error message
  String _getErrorMessage() {
    if (nameController.text.isEmpty) {
      return 'Please enter your name';
    } else if (mobileController.text.isEmpty) {
      return 'Please enter your mobile number';
    } else if (selectedAddress.isEmpty) {
      return 'Please select an address type';
    } else if (selectedAddress == 'Others' &&
        addressName.text.isEmpty) {
      return 'Please enter flat/house details';
    }

    return 'Please fill in all required fields';
  }
}
