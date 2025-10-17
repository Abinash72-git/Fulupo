import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  bool isEditingName = false;
  bool isEditingPhone = false;
  String token = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers to avoid late initialization error
    nameController = TextEditingController();
    phoneController = TextEditingController();

    _getdata();
  }

  Future<void> _getdata() async {
    setState(() {
      isLoading = true; // Start loading
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      token = prefs.getString('token') ?? '';
      print(token);
    } catch (e) {
      print('Error retrieving token: $e');
    }

    // Fetch user data
    await context.read<UserProvider>().fetchUser(token);

    // Update controllers with fetched data
    final userProfile = context.read<UserProvider>().profile;
    if (userProfile.isNotEmpty) {
      nameController.text = userProfile.first.name ?? '';
      phoneController.text = userProfile.first.phone ?? '';
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  UserProvider get provider => context.read<UserProvider>();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Text(
          'Profile',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.15),
            Center(
              child: Consumer<UserProvider>(
                builder: (context, provider, child) {
                  final userProfile = provider.profile;

                  if (isLoading) {
                    return const CircularProgressIndicator(); // Show loader
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                              "assets/images/MAN.png"), // Dummy Profile Image
                        ),
                        SizedBox(height: 20),

                        // Name TextField
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  isEditingName ? Icons.check : Icons.edit,
                                  color: AppColor.fillColor),
                              onPressed: () {
                                setState(() {
                                  isEditingName = !isEditingName;
                                });
                              },
                            ),
                          ),
                          readOnly: !isEditingName,
                        ),
                        SizedBox(height: 20),

                        // Phone Number TextField
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  isEditingPhone ? Icons.check : Icons.edit,
                                  color: AppColor.fillColor),
                              onPressed: () {
                                setState(() {
                                  isEditingPhone = !isEditingPhone;
                                });
                              },
                            ),
                          ),
                          readOnly: !isEditingPhone,
                        ),
                        SizedBox(height: 30),

                        // Continue Button
                        MyButton(
                          text: 'Continue',
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
                            print("Updated Name: ${nameController.text}");
                            print("Updated Phone: ${phoneController.text}");

                            try {
                              await AppDialogue.openLoadingDialogAfterClose(
                                context,
                                text: "Updating...",
                                load: () async {
                                  return await provider.editProfile(
                                      userName: nameController.text,
                                      phone: phoneController.text,
                                      token: token);
                                },
                                afterComplete: (resp) async {
                                  if (resp.status) {
                                    print("sucess");
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        AppConstants.USERMOBILE,
                                        phoneController.text);
                                    AppDialogue.toast(resp.data);
                                    AppRouteName.apppage.pushAndRemoveUntil(
                                      args: 1,
                                      context,
                                      (route) => false,
                                    );
                                  }
                                },
                              );
                            } on Exception catch (e) {
                              ExceptionHandler.showMessage(context, e);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
