import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/delivery_map_pages.dart';
import 'package:fulupo/pages/save_address_bottompage.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressBottomsheetPage extends StatefulWidget {
  final String page;
  const AddressBottomsheetPage({Key? key, required this.page}) : super(key: key);

  @override
  State<AddressBottomsheetPage> createState() => _AddressBottomsheetPageState();
}

class _AddressBottomsheetPageState extends State<AddressBottomsheetPage> {
  // Form controllers and state
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressNameController = TextEditingController();
  
  // Page state variables - initialized with defaults
  String _address = "Loading...";
  bool _isAddressLoaded = false;
  bool _isLoadingUserData = true;
  String selectedAddress = '';
  LatLng draggedLatLng = const LatLng(0.0, 0.0);
  
  // Create ValueNotifiers for performance optimization
  final ValueNotifier<bool> _formValidNotifier = ValueNotifier<bool>(false);
  
  // Cached decorations to reduce rebuilds
  final _nameFieldDecoration = const InputDecoration(
    labelText: "Name",
    border: OutlineInputBorder(),
  );
  
  final _mobileFieldDecoration = const InputDecoration(
    labelText: "Mobile",
    border: OutlineInputBorder(),
    counterText: '',
  );
  
  final _addressNameFieldDecoration = const InputDecoration(
    labelText: "Flat/House No/Floor/Building",
    labelStyle: TextStyle(
      color: AppColor.hintTextColor,
      fontSize: 15,
    ),
    border: OutlineInputBorder(),
  );

  UserProvider get provider => context.read<UserProvider>();

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() => _isLoadingUserData = true);
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
      final name = prefs.getString(AppConstants.USERNAME) ?? '';
      
      if (mounted) {
        // Set the values without triggering listeners
        nameController.text = name;
        mobileController.text = mobile;
        
        setState(() => _isLoadingUserData = false);
        
        // Check form validity after loading data
        _checkFormValidity();
      }
    } catch (e) {
      log('Error loading user data: $e');
      if (mounted) setState(() => _isLoadingUserData = false);
    }
  }

  // Load address data 
  Future<void> _loadLocationData() async {
    if (!mounted) return;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Get coordinates and address
      final latitude = prefs.getDouble(AppConstants.TEMP_USERLATITUTE);
      final longitude = prefs.getDouble(AppConstants.TEMP_USERLONGITUTE);
      final address = prefs.getString(AppConstants.TEMP_USERADDRESS);
      
      if (mounted) {
        setState(() {
          if (latitude != null && longitude != null && address != null) {
            draggedLatLng = LatLng(latitude, longitude);
            _address = address;
          } else {
            _address = "No address found.";
          }
          _isAddressLoaded = true;
        });
      }
    } catch (e) {
      log('Error loading location: $e');
      if (mounted) {
        setState(() {
          _address = "Error retrieving address.";
          _isAddressLoaded = true;
        });
      }
    }
  }

  // Update address type selection
  void _selectAddressType(String type) {
    if (selectedAddress == type) return; // Skip if already selected
    
    setState(() {
      selectedAddress = type;
      
      // Clear any previous custom name if needed
      if (type == 'Home' || type == 'Work') {
        // For Home/Work, we don't need additional input
        addressNameController.clear();
      } else if (type == 'Other') {
        // For Other, we need custom input - clear first
        addressNameController.clear();
      }
    });
    
    // Check form validity after changing selection
    _checkFormValidity();
  }
  
  // Form validation without rebuilding the entire widget
  void _checkFormValidity() {
    final isValid = _isFormValid();
    
    // Only notify if value changed to avoid unnecessary rebuilds
    if (_formValidNotifier.value != isValid) {
      _formValidNotifier.value = isValid;
    }
  }
  
  // Check if form is valid
  bool _isFormValid() {
    // Basic validation checks
    if (nameController.text.isEmpty || 
        mobileController.text.isEmpty || 
        selectedAddress.isEmpty) {
      return false;
    }
    
    // Additional validation for Other address type
    if (selectedAddress == 'Other' && addressNameController.text.isEmpty) {
      return false;
    }
    
    return true;
  }
  
  // Get error message for validation
  String _getErrorMessage() {
    if (nameController.text.isEmpty) {
      return 'Please enter your name';
    } else if (mobileController.text.isEmpty) {
      return 'Please enter your mobile number';
    } else if (selectedAddress.isEmpty) {
      return 'Please select an address type';
    } else if (selectedAddress == 'Other' && addressNameController.text.isEmpty) {
      return 'Please enter flat/house details';
    }
    return 'Please fill in all required fields';
  }
  
  // Handle the confirm button tap
  void _handleConfirmPressed() {
    // Validate form first
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage()))
      );
      return;
    }
    
    // Extract form data
    final enteredName = nameController.text.trim();
    final enteredMobile = mobileController.text.trim();
    final enteredAddressType = selectedAddress;
    
    // Get the address name based on selection
    final enteredAddressName = selectedAddress == 'Other'
        ? addressNameController.text.trim()
        : selectedAddress;
        
    // Navigate to next page
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SaveAddressBottompage(
        page: widget.page,
        name: enteredName,
        mobile: enteredMobile,
        addressType: enteredAddressType,
        flatHouseNo: enteredAddressName,
        fullAddress: _address,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // Add single listener for each controller
    nameController.addListener(_checkFormValidity);
    mobileController.addListener(_checkFormValidity);
    addressNameController.addListener(_checkFormValidity);
    
    // Load data after widget is built
    Future.microtask(() async {
      await Future.wait([
        _loadUserData(),
        _loadLocationData(),
      ]);
    });
  }

  @override
  void dispose() {
    // Remove listeners
    nameController.removeListener(_checkFormValidity);
    mobileController.removeListener(_checkFormValidity);
    addressNameController.removeListener(_checkFormValidity);
    
    // Dispose controllers
    nameController.dispose();
    mobileController.dispose();
    addressNameController.dispose();
    
    // Dispose notifiers
    _formValidNotifier.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
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
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
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
                  
                  // Receiver Details Section
                  _buildReceiverDetailsSection(),
                  
                  const SizedBox(height: 10),
                  
                  // Address Details Section
                  _buildAddressDetailsSection(
                    screenWidth: screenWidth,
                    isKeyboardVisible: isKeyboardVisible,
                  ),
                  
                  SizedBox(height: screenHeight * 0.06),
                  
                  // Confirm Button
                  ValueListenableBuilder<bool>(
                    valueListenable: _formValidNotifier,
                    builder: (context, isValid, _) {
                      return MyButton(
                        text: 'Confirm Address',
                        textcolor: isValid ? AppColor.blackColor : AppColor.whiteColor,
                        textsize: 20,
                        fontWeight: FontWeight.bold,
                        letterspacing: 0.7,
                        buttoncolor: isValid ? AppColor.yellowColor : Colors.grey.shade500,
                        borderColor: isValid ? AppColor.yellowColor : Colors.grey.shade500,
                        buttonheight: 55 * (screenHeight / 812),
                        buttonwidth: screenWidth,
                        radius: 40,
                        onTap: _handleConfirmPressed,
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Close Button
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
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build the receiver details section
  Widget _buildReceiverDetailsSection() {
    return Container(
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
            
            // Name field
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: _nameFieldDecoration,
              ),
            ),
            const SizedBox(height: 10),
            
            // Mobile field
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: TextField(
                controller: mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: _mobileFieldDecoration,
              ),
            ),
            
            // Helper text
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
    );
  }
  
  // Build the address details section
  Widget _buildAddressDetailsSection({
    required double screenWidth,
    required bool isKeyboardVisible,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
            const SizedBox(height: 5),
            Text(
              'Save address as *',
              style: Styles.textStyleMedium(
                context,
                color: AppColor.blackColor,
              ),
              textScaleFactor: 1.0,
            ),
            const SizedBox(height: 5),
            
            // Address type buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAddressTypeButton('Home', Icons.home),
                _buildAddressTypeButton('Work', Icons.work),
                _buildAddressTypeButton('Other', Icons.help_outline_sharp),
              ],
            ),
            const SizedBox(height: 15),
            
            // Custom address field (conditional)
            if (selectedAddress == 'Other') 
              MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: TextField(
                  controller: addressNameController,
                  keyboardType: TextInputType.text,
                  decoration: _addressNameFieldDecoration,
                ),
              ),
            
            const SizedBox(height: 15),
            
            // Address display with change button
            Container(
              width: screenWidth,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectAddressMap(
                              page: widget.page,
                              targetPage: AddressBottomsheetPage(page: widget.page),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.whiteColor,
                          border: Border.all(color: AppColor.fillColor),
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
            const SizedBox(height: 5),
            Text(
              'Updated based on your exact map pin',
              style: Styles.textStyleSmall(
                context,
                color: AppColor.hintTextColor,
              ),
              textScaleFactor: 1.0,
            ),
            const SizedBox(height: 20),
            
            // Add extra space when keyboard is visible
            if (isKeyboardVisible) const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
  
  // Build address type button
  Widget _buildAddressTypeButton(String label, IconData icon) {
    final bool isSelected = selectedAddress == label;
    
    return GestureDetector(
      onTap: () => _selectAddressType(label),
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
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
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
}



// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:fulupo/components/button.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/pages/delivery_map_pages.dart';
// import 'package:fulupo/pages/save_address_bottompage.dart';
// import 'package:fulupo/provider/user_provider.dart';
// import 'package:fulupo/util/app_constant.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:fulupo/util/validator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AddressBottomsheetPage extends StatefulWidget {
//   final String page;
//   const AddressBottomsheetPage({super.key, required this.page});

//   @override
//   State<AddressBottomsheetPage> createState() => _AddressBottomsheetPageState();
// }

// class _AddressBottomsheetPageState extends State<AddressBottomsheetPage> {
//   String mobile = '';
//   String name = '';
//   bool isEditing = false;
//   String selectedAddress = '';

//   String updatedName = '';
//   String updatedMobile = '';
//   String _address = "Loading..."; // Default value
//   LatLng draggedLatLng = LatLng(0.0, 0.0);
//   String flatHouseNo = ''; // New field for Flat/House No/Floor/Building
//   String landmark = ''; // New field for Nearby Landmark
//   String updatedFlatHouseNo = ''; // New local variable
//   String updatedLandmark = ''; // New local variable
//   bool isLoading = false;
//   String token = '';

//   bool isFlatHouseEnabled = false;
//   UserProvider get provider => context.read<UserProvider>();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController addressName =
//       TextEditingController(); // New controller
//   final TextEditingController landmarkController =
//       TextEditingController(); // New controller


//   getdata() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
  
//       mobile = prefs.getString(AppConstants.USERMOBILE) ?? '';
//       name = prefs.getString(AppConstants.USERNAME) ?? '';
 
//       token = prefs.getString(AppConstants.token) ?? '';
//       nameController.text = name;
//       mobileController.text = mobile;

//       print(selectedAddress);
//       print(landmark);
//       print(token);
//     });
//   }

//   Future<void> saveSelectedAddress(String address) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(AppConstants.ADDRESS_TYPE, address);

//     print('🔵 Address type selected: $address');

//     setState(() {
//       selectedAddress = address; // Update UI dynamically

//       // When Home or Work is selected, use the type as the name
//       if (address == 'Home' || address == 'Work') {
//         flatHouseNo = address; // Store Home/Work as the address name
//         addressName.clear(); // Clear the text field (won't be visible anyway)
//         print('🔵 Address name set to: $flatHouseNo');
//       } else if (address == 'Other') {
//         flatHouseNo = ''; // Clear for custom input
//         addressName.clear();
//         print('🔵 Address name field cleared for custom input');
//       }
//     });
//   }


//   Future<void> _getLocationData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     try {
//       // Retrieve latitude and longitude as doubles
//       double? latitude = prefs.getDouble(AppConstants.TEMP_USERLATITUTE);
//       double? longitude = prefs.getDouble(AppConstants.TEMP_USERLONGITUTE);
//       String? address = prefs.getString(AppConstants.TEMP_USERADDRESS);

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
//     nameController.clear();
//     mobileController.clear();
//     addressName.clear();
//     landmarkController.clear();
//     getdata();
//     _getLocationData();
//   }

//   @override
//   void dispose() {
//     // Dispose controllers to prevent memory leaks
//     nameController.dispose();
//     mobileController.dispose();
//     addressName.dispose();
//     landmarkController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Container(
//           height: screenHeight * 0.9,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: SingleChildScrollView(
//               child: Form(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 15),
//                       child: Text(
//                         "Enter Complete Address",
//                         style: Styles.textStyleLarge(
//                           context,
//                           color: AppColor.blackColor,
//                         ),
//                         textScaleFactor: 1.0,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       decoration: BoxDecoration(
//                         color: AppColor.whiteColor,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Enter Receiver Details',
//                               style: Styles.textStyleMedium(
//                                 context,
//                                 color: AppColor.hintTextColor,
//                               ),
//                               textScaleFactor: 1.0,
//                             ),
//                             const SizedBox(height: 10),
//                             MediaQuery(
//                               data: MediaQuery.of(
//                                 context,
//                               ).copyWith(textScaleFactor: 1.0),
//                               child: TextField(
//                                 controller: nameController,
//                                 keyboardType: TextInputType.name,
//                                 decoration: const InputDecoration(
//                                   labelText: "Name",
//                                   border: OutlineInputBorder(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             MediaQuery(
//                               data: MediaQuery.of(
//                                 context,
//                               ).copyWith(textScaleFactor: 1.0),
//                               child: TextField(
//                                 controller: mobileController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                   labelText: "Mobile",
//                                   border: OutlineInputBorder(),
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               'May be used to assist delivery',
//                               style: Styles.textStyleSmall(
//                                 context,
//                                 color: AppColor.hintTextColor,
//                               ),
//                               textScaleFactor: 1.0,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Container(
//                       padding: EdgeInsets.symmetric(vertical: 20),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppColor.whiteColor,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 5),
//                             Text(
//                               'Save address as *',
//                               style: Styles.textStyleMedium(
//                                 context,
//                                 color: AppColor.blackColor,
//                               ),
//                               textScaleFactor: 1.0,
//                             ),
//                             SizedBox(height: 5),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 addressButton('Home', Icons.home),
//                                 addressButton('Work', Icons.work),
//                                 addressButton(
//                                   'Other',
//                                   Icons.help_outline_sharp,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 15),

//                             // Replace the current TextFormField implementation with this
//                             selectedAddress == 'Other'
//                                 ? Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       MediaQuery(
//                                         data: MediaQuery.of(
//                                           context,
//                                         ).copyWith(textScaleFactor: 1.0),
//                                         child: TextFormField(
//                                           validator: Validator.notEmpty,
//                                           controller: addressName,
//                                           keyboardType: TextInputType.text,
//                                           decoration: const InputDecoration(
//                                             labelText:
//                                                 "Flat/House No/Floor/Building",
//                                             labelStyle: TextStyle(
//                                               color: AppColor.hintTextColor,
//                                               fontSize: 15,
//                                             ),
//                                             border: OutlineInputBorder(),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 15),
//                                     ],
//                                   )
//                                 : SizedBox(
//                                     height: 0,
//                                   ), // Empty container when not "Others"

//                             SizedBox(height: 15),
//                             Container(
//                               width: screenWidth,
//                               padding: EdgeInsets.symmetric(vertical: 15),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.grey.shade300,
//                                 border: Border.all(color: Colors.grey.shade400),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       width: screenWidth * 0.6,
//                                       child: Text(
//                                         _address,
//                                         style: Styles.textStyleSmall(
//                                           context,
//                                           color: AppColor.hintTextColor,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 3,
//                                         softWrap: true,
//                                         textAlign: TextAlign.start,
//                                         textScaleFactor: 1.0,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 SelectAddressMap(
//                                                   page: widget.page,
//                                                   targetPage:
//                                                       AddressBottomsheetPage(
//                                                         page: widget.page,
//                                                       ),
//                                                 ),
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         width: 80,
//                                         padding: EdgeInsets.symmetric(
//                                           vertical: 5,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                           color: AppColor.whiteColor,
//                                           border: Border.all(
//                                             color: AppColor.fillColor,
//                                           ),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             'Change',
//                                             style: Styles.textStyleSmall(
//                                               context,
//                                               color: AppColor.fillColor,
//                                             ),
//                                             textScaleFactor: 1.0,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               'Updated based on your exact map pin',
//                               style: Styles.textStyleSmall(
//                                 context,
//                                 color: AppColor.hintTextColor,
//                               ),
//                               textScaleFactor: 1.0,
//                             ),
//                             SizedBox(height: 20),
                           
//                             SizedBox(
//                               height: isKeyboardVisible
//                                   ? screenHeight * 0.3
//                                   : 0,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.06),
                   
//                     MyButton(
//                       text: 'Confirm Address',
//                       textcolor: _shouldEnableButton()
//                           ? AppColor.blackColor
//                           : AppColor.whiteColor,
//                       textsize: 20,
//                       fontWeight: FontWeight.bold,
//                       letterspacing: 0.7,
//                       buttoncolor: _shouldEnableButton()
//                           ? AppColor.yellowColor
//                           : Colors.grey.shade500,
//                       borderColor: _shouldEnableButton()
//                           ? AppColor.yellowColor
//                           : Colors.grey.shade500,
//                       buttonheight: 55 * (screenHeight / 812),
//                       buttonwidth: screenWidth,
//                       radius: 40,
                     
//                       onTap: () async {
//                         if (!_shouldEnableButton()) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text(_getErrorMessage())),
//                           );
//                           return;
//                         }

//                         // Collect all entered data
//                         final String enteredName = nameController.text.trim();
//                         final String enteredMobile = mobileController.text
//                             .trim();
//                         final String enteredAddressType =
//                             selectedAddress; // Home/Work/Others

//                         // Determine the address name based on type
//                         final String enteredAddressName;
//                         if (selectedAddress == 'Other') {
//                           enteredAddressName = addressName.text
//                               .trim(); // Custom flat/house input
//                         } else {
//                           enteredAddressName =
//                               selectedAddress; // Use "Home" or "Work" as name
//                         }

//                         final String enteredFullAddress = _address;

//                         // Navigate and pass all data to next page
//                         Navigator.pop(context);
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           builder: (context) {
//                             log('name -- $enteredName');
//                             log('mobile -- $enteredMobile');
//                             log('full address -- $enteredFullAddress');
//                             log('address name -- $enteredAddressName');
//                             log('address type -- $enteredAddressType');
//                             return SaveAddressBottompage(
//                               page: widget.page,
//                               name: enteredName,
//                               mobile: enteredMobile,
//                               addressType: enteredAddressType,
//                               flatHouseNo:
//                                   enteredAddressName, // This now correctly passes Home/Work or custom input
//                               fullAddress: enteredFullAddress,
//                             );
//                           },
//                         );
//                       },
                     
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           left: screenWidth * 0.45,
//           top: -screenHeight * 0.065,
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.black.withOpacity(0.4),
//                 width: screenWidth * 0.005,
//               ),
//             ),
//             child: CircleAvatar(
//               backgroundColor: Colors.black.withOpacity(0.5),
//               radius: 18,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//                 onPressed: () {
//                   Navigator.of(context, rootNavigator: true).pop(false);
//                 },
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget addressButton(String label, IconData icon) {
//     bool isSelected = selectedAddress == label;

//     print('🟡 Rendering address button: $label (Selected: $isSelected)');

//     return GestureDetector(
//       onTap: () {
//         print('🟡 Address button tapped: $label');
//         saveSelectedAddress(label);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
//         width: 90,
//         decoration: BoxDecoration(
//           color: isSelected ? AppColor.fillColor : AppColor.whiteColor,
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(color: AppColor.fillColor),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : Colors.black),
//             const SizedBox(width: 10),
//             Expanded(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   label,
//                   style: Styles.textStyleSmall(
//                     context,
//                     color: isSelected ? Colors.white : Colors.black,
//                   ),
//                   textScaleFactor: 1.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to determine if button should be enabled
//   bool _shouldEnableButton() {
//     bool nameEmpty = nameController.text.isEmpty;
//     bool mobileEmpty = mobileController.text.isEmpty;
//     bool addressTypeEmpty = selectedAddress.isEmpty;
//     bool customAddressEmpty =
//         selectedAddress == 'Other' && addressName.text.isEmpty;

//     print('🔵 Button validation check:');
//     print('🔵 Name empty: $nameEmpty');
//     print('🔵 Mobile empty: $mobileEmpty');
//     print('🔵 Address type empty: $addressTypeEmpty');
//     print('🔵 Custom address empty: $customAddressEmpty');

//     // Basic validation for all address types
//     if (nameEmpty || mobileEmpty || addressTypeEmpty) {
//       print('🔵 Button should be disabled: Basic validation failed');
//       return false;
//     }

//     // Additional validation for "Others" address type
//     if (customAddressEmpty) {
//       print('🔵 Button should be disabled: Custom address validation failed');
//       return false;
//     }

//     print('🔵 Button should be enabled: All validations passed');
//     return true;
//   }

//   // Helper method to get appropriate error message
//   String _getErrorMessage() {
//     if (nameController.text.isEmpty) {
//       return 'Please enter your name';
//     } else if (mobileController.text.isEmpty) {
//       return 'Please enter your mobile number';
//     } else if (selectedAddress.isEmpty) {
//       return 'Please select an address type';
//     } else if (selectedAddress == 'Other' && addressName.text.isEmpty) {
//       return 'Please enter flat/house details';
//     }

//     return 'Please fill in all required fields';
//   }
// }
