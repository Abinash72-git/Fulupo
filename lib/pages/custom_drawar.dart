import 'package:flutter/material.dart';
import 'package:fulupo/config/app_config.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/replacement_history/getReplacement_model.dart';
import 'package:fulupo/pages/login_page.dart';
import 'package:fulupo/pages/order_history/order_histroy.dart';
import 'package:fulupo/pages/profile_page.dart';
import 'package:fulupo/pages/replacement/replacement.dart';
import 'package:fulupo/pages/whilist/wishList_page.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ✅ Local storage keys
  static const String USERNAME = 'user_name';
  static const String USEREMAIL = 'user_mail';
  static const String USEROTP = 'user_otp';
  static const String TOKEN = 'token';
  static const String PRIMARY_STORE = 'PRIMARY_STORE';

  String token = '';
  String selectedStore = '';
  String userName = '';
  String userEmail = '';
  String userOtp = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      token = prefs.getString(TOKEN) ?? '';
      selectedStore = prefs.getString(PRIMARY_STORE) ?? '';
      userName = prefs.getString(AppConstants.USERNAME) ?? 'No User';
      userEmail = prefs.getString(USEREMAIL) ?? '';
      userOtp = prefs.getString(USEROTP) ?? '';
      print("Token: $token");
      print("Selected Store: $selectedStore");
      print("UserName: $userName");
    } catch (e) {
      print("Error loading user data: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.whiteColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          _buildHeader(context),
          SizedBox(height: widget.screenHeight * 0.02),
          _buildAccountAndNotification(context),
          _buildDrawerOptions(context),
        ],
      ),
    );
  }

  /// 🔹 Drawer header with user info
  Widget _buildHeader(BuildContext context) {
    return ListTile(
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "Hi,",
                            style: Styles.textStyleLarge(
                              context,
                              color: AppColor.whiteColor,
                            ),
                            textScaleFactor: 1.0,
                          ),
                        ),
                        Text(
                          userName,
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Account & Wishlist section
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
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishlistPage()),
                );
                if (mounted) Navigator.pop(context);
              },
              child: _buildIconColumn(Icons.favorite, 'Wishlist'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Drawer options (Orders, Settings, Logout, Delete)
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
                    MaterialPageRoute(builder: (context) => OrderHistory()),
                  );
                },
                child: _buildDrawerRow(Icons.history_rounded, "Orders"),
              ),
               GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReplacementPage()),
                  );
                },
                child: _buildDrawerRow(Icons.repeat_sharp, "Replacement"),
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
                  print("Logout successful");
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

  /// 🔹 Common reusable widget for icons + label
  Widget _buildIconColumn(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

  /// 🔹 Common drawer row (icon + text)
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
