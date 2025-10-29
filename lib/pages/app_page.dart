import 'dart:developer';

import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/pages/cart/cartpage.dart';


import 'package:fulupo/pages/homepage.dart';
import 'package:fulupo/pages/subscription_pages/subscription_intro_page.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPage extends StatefulWidget {
  final int tabNumber;
  const AppPage({required this.tabNumber, Key? key}) : super(key: key);

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late int _currentIndex;
  late Widget _currentPage;
  bool isPageSet = false;
  DateTime? currentBackPressTime;
  String token = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabNumber;
    _currentPage = _getPage(_currentIndex);
  }

  //  Future<void> _getLocationData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   try {
  //     // Retrieve latitude and longitude as doubles

  //     token = prefs.getString('token') ?? '';
  //     print(token);
  //     log('Token: $token');

  //   } catch (e) {
  //     print('Error retrieving location data: $e');
  //     setState(() {

  //     });
  //   }
  //   getprovider.fetchAddToCart(token);
  //   recalculateTotalPrice();
  // }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Cartpage();
      case 1:
        return HomePage();
      case 2:
        return SubscriptionIntroPage();
      default:
        return HomePage();
    }
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = _getPage(index);
      isPageSet = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 1 && _currentIndex != 0 && _currentIndex != 2) {
      setState(() {
        _currentIndex = 1; // Set this to your Home Page index
        _currentPage = HomePage();
      });
      return Future.value(false);
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(msg: "Tap Again to Exit");
        return Future.value(false);
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColor.fillColor,
        body: isPageSet ? _currentPage : _getPage(_currentIndex),
        bottomNavigationBar: FancyBottomNavigation(
          tabs: [
            TabData(iconData: Icons.shopping_cart, title: ""),
            TabData(iconData: Icons.home, title: ""),
            TabData(iconData: Icons.shopping_bag_sharp, title: ""),
          ],
          initialSelection: widget.tabNumber,
          onTabChangedListener: (int position) {
            _selectTab(position);
          },
          barBackgroundColor: AppColor.fillColor,
          circleColor: const Color.fromARGB(255, 255, 255, 255),
          inactiveIconColor: Colors.white,
          textColor: Colors.black,
          activeIconColor: AppColor.fillColor,
        ),
      ),
    );
  }
}
