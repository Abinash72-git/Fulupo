import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/setting&privacy/privacy_policy.dart';
import 'package:fulupo/pages/setting&privacy/terms_condition.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Text(
          'Setting & Privacy',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.08,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _buildPolicyRow(
                      context,
                      "Privacy & Policy",
                      ConstantImageKey
                          .privacy, // Replace with the actual image path
                      onTap: () {
                        log("Privacy & Policy tapped");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicy()));
                      },
                    ),
                    // const Divider(),
                    _buildPolicyRow(
                      context,
                      "Terms & Condition",
                      ConstantImageKey.terms,
                      onTap: () {
                        log("Terms & Condition tapped");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TermsCondtion()));
                      },
                    ),
                    // const Divider(),
                    // _buildPolicyRow(
                    //   context,
                    //   "Cancellation & Refund Policy",
                    //   ConstantImageKey.cancellation,
                    //   onTap: () {
                    //     log("Cancellation & Refund Policy tapped");
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => ReturnReplacementPage()));
                    //   },
                    // ),
                    // const Divider(),
                    // _buildPolicyRow(
                    //   context,
                    //   "Shipping & Delivery Policy",
                    //   ConstantImageKey.shipping,
                    //   onTap: () {
                    //     log("Shipping & Delivery Policy tapped");
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => ShippingDeliveryPage()));
                    //   },
                    // ),
                    // const Divider(),
                    // _buildPolicyRow(
                    //   context,
                    //   "Contact Us",
                    //   ConstantImageKey.contact,
                    //   onTap: () {
                    //     debugPrint("Contact Us tapped");
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       'Deactivate account',
            //       style: Styles.textStyleExtraLarge(context,
            //           color: const Color.fromARGB(255, 255, 0, 0)),
            //       textScaleFactor: 1,
            //     ),
            //     // const SizedBox(
            //     //   width: 15,
            //     // ),
            //     // const Icon(
            //     //   Icons.delete,
            //     //   color: Colors.white,
            //     // )
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyRow(BuildContext context, String title, String imagePath,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style:
                    Styles.textStyleMedium(context, color: AppColor.blackColor),
                textScaleFactor: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
