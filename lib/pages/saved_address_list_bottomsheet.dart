import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/delivery_map_pages.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressListBottomsheet extends StatefulWidget {
  final String page;
  const SavedAddressListBottomsheet({super.key, required this.page});

  @override
  State<SavedAddressListBottomsheet> createState() =>
      _SavedAddressListBottomsheetState();
}

class _SavedAddressListBottomsheetState
    extends State<SavedAddressListBottomsheet> {
  bool isAddress = false;

  String _address = "Loading..."; // Default value

  LatLng draggedLatLng = LatLng(0.0, 0.0);

  String Delmobile = '';
  String Delname = '';
  bool isEditing = false;
  String selectedAddress = '';
  String token = '';
  String updatedName = '';
  String updatedMobile = '';
  late GetProvider getprovider;

  String flatHouseNo = '';
  String landmark = '';
  String updatedFlatHouseNo = '';
  String updatedLandmark = '';
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController flatHouseNoController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  UserProvider get _provider => context.read<UserProvider>();

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Fetch using new keys
      Delmobile = prefs.getString('NEW_USER_MOBILE') ?? '';
      Delname = prefs.getString('NEW_USER_NAME') ?? '';
      selectedAddress = prefs.getString('SELECTED_ADDRESS') ?? '';
      flatHouseNo =
          prefs.getString('FLAT_HOUSE_NO') ?? ''; // Fetch flat/house no.
      landmark = prefs.getString('NEARBY_LANDMARK') ?? ''; // Fetch landmark
      nameController.text = Delname;
      mobileController.text = Delmobile;
      flatHouseNoController.text = flatHouseNo; // Set text for flat/house no.
      landmarkController.text = landmark; // Set text for landmark

      print(selectedAddress);
      print(landmark);
      print(token);
    });
    await _getData();
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

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fetchedToken = prefs.getString(AppConstants.token);

    if (fetchedToken != null && fetchedToken.isNotEmpty) {
      setState(() {
        token = fetchedToken;
      });
      await getprovider.fetchOrderAddress(token);
    } else {
      // Handle missing token
      print("Token not found");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprovider = context.read<GetProvider>();
    _getLocationData();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 226, 224, 224),
                borderRadius: BorderRadius.circular(30),
              ),
              width: screenWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Select an Address',
                          style: Styles.textStyleExtraLarge(
                            context,
                            color: AppColor.blackColor,
                          ),
                          textScaleFactor: 1,
                        ),
                        Spacer(),
                        widget.page == 'Home'
                            ? IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.cancel),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectAddressMap(
                              page: widget.page,
                              targetPage: SavedAddressListBottomsheet(
                                page: widget.page,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '+   Add Address',
                            style: Styles.textStyleLarge(
                              context,
                              color: AppColor.fillColor,
                            ),
                            textScaleFactor: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Colors.grey, // Adjust color as needed
                            thickness: 1,
                            endIndent:
                                10, // Adds space between divider and text
                          ),
                        ),
                        Text(
                          'SAVED ADDRESS',
                          style: Styles.textStyleLarge(
                            context,
                            color: AppColor.hintTextColor,
                          ),
                          textScaleFactor: 1,
                        ),
                        const Expanded(
                          child: Divider(
                            color: Colors.grey, // Adjust color as needed
                            thickness: 1,
                            indent: 10, // Adds space between text and divider
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Consumer<GetProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (provider.getOrderAddress.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return Expanded(
                          child: ListView.builder(
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount: provider.getOrderAddress.length,
                            itemBuilder: (context, index) {
                              final address = provider.getOrderAddress[index];
                              final addressId = address.id ?? "";
                              final selectedAddress =
                                  address.addressType ?? "Unknown";
                              final flatHouseNo = address.addressLine ?? "";
                              final _address = address.addressType ?? "";
                              final _addressName = address.addressName ?? "";
                              // final landmark = address.nearbyLandmark ?? "";
                              final Delmobile = address.mobile ?? "N/A";

                              return GestureDetector(
                                onTap: () async {
                                  // Save the selected address details to local storage
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    AppConstants.ADDRESS_ID,
                                    addressId,
                                  );
                                  log('Saved Address ID: $addressId');

                                  await prefs.setString(
                                    'SELECTED_ADDRESS_TYPE',
                                    selectedAddress,
                                  );
                                  await prefs.setString(
                                    'SELECTED_FLAT_HOUSE_NO',
                                    flatHouseNo,
                                  );
                                  await prefs.setString(
                                    'SELECTED_ADDRESS_NAME',
                                    _addressName,
                                  );
                                  await prefs.setString(
                                    AppConstants.USERADDRESS,
                                    _address,
                                  );
                                  await prefs.setString(
                                    'SELECTED_LANDMARK',
                                    landmark,
                                  );
                                  await prefs.setString(
                                    'SELECTED_MOBILE',
                                    Delmobile,
                                  );
                                  await prefs.setString(
                                    'SELECTED_USER_NAME',
                                    address.name ?? '',
                                  );

                                  // Log the saved details for debugging
                                  print('✅ Address Details Saved:');
                                  print('Address Details Saved:');
                                  print('Address Type: $selectedAddress');
                                  print('Flat/House No: $flatHouseNo');
                                  print('Address: $_address');
                                  print('Landmark: $landmark');
                                  print('Mobile: $Delmobile');
                                  print(
                                    'User Name: ${address.name ?? 'Unknown'}',
                                  );

                                  Fluttertoast.showToast(
                                    msg: "Address selected successfully!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity
                                        .BOTTOM, // Position of the toast
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  Navigator.pop(context, "Yes");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 26,
                                    ),
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'DELIVERS TO',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Spacer(),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  print(address.addressType);
                                                  log('${address.addressType}');

                                                  try {
                                                    await AppDialogue.openLoadingDialogAfterClose(
                                                      context,
                                                      text: "Deleting...",
                                                      load: () async {
                                                        if (address.id !=
                                                            null) {
                                                          return await _provider
                                                              .deleteOrderAddress(
                                                                addressId:
                                                                    address.id!,
                                                                token: token,
                                                              );
                                                        } else {
                                                          throw Exception(
                                                            "Address ID is null",
                                                          );
                                                        }
                                                      },
                                                      afterComplete:
                                                          (resp) async {
                                                            if (resp.status) {
                                                              print("Success");
                                                              AppDialogue.toast(
                                                                resp.data,
                                                              );
                                                            }
                                                          },
                                                    );
                                                  } catch (e) {
                                                    ExceptionHandler.showMessage(
                                                      context,
                                                      e,
                                                    );
                                                  }
                                                  await _getData();
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Row(
                                            children: [
                                              Icon(
                                                selectedAddress == 'Home'
                                                    ? Icons.home
                                                    : selectedAddress == 'Work'
                                                    ? Icons.work
                                                    : selectedAddress ==
                                                          'Others'
                                                    ? Icons.hotel_rounded
                                                    : Icons.location_on,
                                                color: AppColor.fillColor,
                                              ),
                                              const SizedBox(width: 25),
                                              Expanded(
                                                child: Text(
                                                  selectedAddress,
                                                  style:
                                                      Styles.textStyleMedium(
                                                        context,
                                                        color:
                                                            AppColor.blackColor,
                                                      ).copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textScaleFactor: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 45,
                                            ),
                                            child: Text(
                                              _address.isEmpty &&
                                                      flatHouseNo.isEmpty
                                                  ? 'No address is added'
                                                  : '$flatHouseNo',
                                              style: Styles.textStyleSmall(
                                                context,
                                                color: AppColor.hintTextColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textScaleFactor: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 45,
                                              top: 5,
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'phone Number: ',
                                                    style:
                                                        Styles.textStyleSmall(
                                                          context,
                                                          color: AppColor
                                                              .hintTextColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        Delmobile ?? 'Unknown',
                                                    style:
                                                        Styles.textStyleSmall(
                                                          context,
                                                          color: AppColor
                                                              .blackColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textScaleFactor: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 45,
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Name: ',
                                                    style:
                                                        Styles.textStyleSmall(
                                                          context,
                                                          color: AppColor
                                                              .hintTextColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        address.name ??
                                                        'Unknown',
                                                    style:
                                                        Styles.textStyleSmall(
                                                          context,
                                                          color: AppColor
                                                              .blackColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textScaleFactor: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            widget.page == 'Home'
                ? Container()
                : Positioned(
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
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
