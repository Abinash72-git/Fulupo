import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/login_page.dart';
import 'package:fulupo/pages/order_history/order_details_page.dart';
import 'package:fulupo/pages/profile_page.dart';
import 'package:fulupo/pages/wishList_page.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

class CustomDrawer extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const CustomDrawer({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String token = '';
  bool isLoading = false;
  String selectedStore = '';

  UserProvider get provider => context.read<UserProvider>();

  Future<void> _getdata() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      token = prefs.getString('token') ?? '';
      selectedStore = prefs.getString('PRIMARY_STORE') ?? '';
      print("Token: $token");
      print("Selected Store: $selectedStore");
    } catch (e) {
      print('Error retrieving token: $e');
    }

    // Fetch user data
    await provider.fetchUser(token);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.whiteColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ListTile(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              width: widget.screenWidth * 0.2,
              decoration: BoxDecoration(
                color: AppColor.fillColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    // ✅ Prevents overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "Hi ",
                            style: Styles.textStyleLarge(
                              context,
                              color: AppColor.whiteColor,
                            ),
                            textScaleFactor: 1.0,
                          ),
                        ),
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            final userProfile = provider.profile;
                            if (isLoading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            // ✅ Check before accessing .first
                            if (userProfile.isNotEmpty) {
                              return Text(
                                userProfile.first.name ?? '',
                                style: Styles.textStyleMedium(
                                  context,
                                  color: AppColor.whiteColor,
                                ),
                              );
                            } else {
                              return const Text(
                                'No User',
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.02),
          _buildAccountAndNotification(context),
          _buildDrawerOptions(context),
        ],
      ),
    );
  }

 Widget _buildAccountAndNotification(BuildContext context) {
  return ListTile(
    title: Container(
      height: 140,
      width: widget.screenWidth * 0.2,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: _buildIconColumn(Icons.person, 'Account'),
          ),
          GestureDetector(
            onTap: () async { // ✅ Made async
              final result = await Navigator.push( // ✅ Added await
                context,
                MaterialPageRoute(builder: (context) => WishlistPage()),
              );
              
              // Close the drawer after returning from wishlist
              if (mounted) {
                Navigator.pop(context); // ✅ Close drawer
              }
            },
            child: _buildIconColumn(Icons.favorite, 'Wishlist'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildIconColumn(IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min, // ✅ Fix overflow
      children: [
        Container(
          height: 68,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.fillColor,
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textScaleFactor: 1.0,
        ),
      ],
    ),
  );
}


  Widget _buildDrawerOptions(BuildContext context) {
    return ListTile(
      title: Container(
        height: widget.screenHeight * 0.45,
        width: widget.screenWidth * 0.2,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderDetailsPage()),
                  );
                },
                child: _buildDrawerRow(Icons.history_rounded, "Orders"),
              ),
              GestureDetector(
                onTap: () {
                  AppRouteName.intro_privacy_page.push(context);
                },
                child: _buildDrawerRow(Icons.settings, "Settings & Privacy"),
              ),
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  print("logout");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
                  );
                },
                child: _buildDrawerRow(Icons.logout, "Logout"),
              ),
              GestureDetector(
                onTap: () {
                  AppRouteName.deletePage.push(context);
                },
                child: _buildDrawerRow(Icons.delete, "Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 25),
          const SizedBox(width: 15),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
