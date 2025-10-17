import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  String token = '';
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider get provider => context.read<UserProvider>();

  TextEditingController storeCode = TextEditingController();

  //save the store name

  Future<void> saveStoreCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.StoreCode,
      storeCode.text,
    ); // ✅ Save entered store code
    print('✅ Store Code Saved: ${storeCode.text}');
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(AppConstants.USERNAME);
    String? mobile = prefs.getString(AppConstants.USERMOBILE);
    String? otp = prefs.getString(AppConstants.USEROTP);
    String? email = prefs.getString(AppConstants.USEREMAIL);

    log("📌 USERNAME: $name");
    log("📌 MOBILE: $mobile");
    log("📌 OTP: $otp");
    log("📌 EMAIL: $email");
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ConstantImageKey.Bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.3),
                Text(
                  'Store Code',
                  style: Styles.textStyleMedium(
                    context,
                    color: AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 10),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0, // Set the desired text scale factor
                  ),
                  child: TextFormField(
                    controller: storeCode,

                    keyboardType: TextInputType.text,

                    obscureText: false,
                    onTap: () async {},
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      ),
                      hintText: 'Enter Store Code',
                      hintStyle: Styles.textStyleLarge(
                        context,
                        color: AppColor.hintTextColor,
                      ).copyWith(fontSize: screenHeight * 0.017),
                      filled: true,
                      fillColor: AppColor.whiteColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 30.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: AppColor.fillColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: AppColor.fillColor,
                          width: .5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: AppColor.fillColor,
                          width: .5,
                        ),
                      ),
                    ),
                    style: Styles.textStyleLarge(
                      context,
                      color: AppColor.blackColor,
                    ).copyWith(fontSize: screenHeight * 0.02),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                MyButton(
                  text: "Submit".toUpperCase(),
                  textcolor: AppColor.whiteColor,
                  textsize: 23 * (screenWidth / 375),
                  fontWeight: FontWeight.bold,
                  letterspacing: 0.7,
                  buttoncolor: AppColor.fillColor,
                  borderColor: AppColor.fillColor,
                  buttonheight: 55 * (screenHeight / 812),
                  buttonwidth: screenWidth,
                  radius: 40,
                  onTap: () async {
                    if (storeCode.text.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Please enter the store code",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      return;
                    } else {
                      await saveStoreCode();
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? name = prefs.getString(AppConstants.USERNAME);
                        String? mobile = prefs.getString(
                          AppConstants.USERMOBILE,
                        );
                        String? otp = prefs.getString(AppConstants.USEROTP);
                        String? email = prefs.getString(AppConstants.USEREMAIL);

                        await AppDialogue.openLoadingDialogAfterClose(
                          context,
                          text: "Verifying OTP...",
                          load: () async {
                            return await provider.verifyLogin(
                              name: name ?? '',
                              mobile: mobile ?? '',
                              otp: otp ?? '',
                              email: email ?? '',
                              storeId: storeCode.text,
                            );
                          },
                          afterComplete: (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreIntroPage(),
                            ),
                          ),
                        );
                      } catch (e) {
                        log('❌ Error verifying login: $e');
                        Fluttertoast.showToast(msg: "Something went wrong");
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//=============Store Image Page==============================================

class StoreIntroPage extends StatefulWidget {
  @override
  State<StoreIntroPage> createState() => _StoreIntroPageState();
}

class _StoreIntroPageState extends State<StoreIntroPage>
    with SingleTickerProviderStateMixin {
  String storeCode = '';
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start animation after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });

    getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storeCode = prefs.getString(AppConstants.StoreCode) ?? '';

    log('📌 Store Code: $storeCode');

    Future.delayed(const Duration(seconds: 1), () {
      AppRouteName.apppage.push(context, args: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
          child: AnimatedOpacity(
            opacity: opacity,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Container(
              width: screenHeight,
              height: screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ConstantImageKey.storeImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
