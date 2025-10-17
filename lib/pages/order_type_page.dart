import 'dart:async'; // For Timer

import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/booking_slot.dart';
import 'package:fulupo/pages/pre_booking_slot.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class OrderTypePage extends StatefulWidget {
  final double oldPrice;
  final double savings;
  final double gstAmount;
  final double totalWithGst;

  const OrderTypePage({
    super.key,
    required this.oldPrice,
    required this.savings,
    required this.gstAmount,
    required this.totalWithGst,
  });

  @override
  State<OrderTypePage> createState() => _OrderTypePageState();
}

class _OrderTypePageState extends State<OrderTypePage> {
  late String todayDate;
  late String currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize date and time
    todayDate = _getFormattedDate(DateTime.now());
    currentTime = _getFormattedTime(DateTime.now());

    // Update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = _getFormattedTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    // Cancel timer to avoid memory leaks
    _timer?.cancel();
    super.dispose();
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(date); // Example: Monday, November 25, 2024
  }

  String _getFormattedTime(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time); // Example: 10:15:30 AM
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(
          "Booking",
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
          textScaleFactor: 1.0,
        ),
        backgroundColor: AppColor.fillColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            // // Display today's date and current time
            // Text(
            //   "Today's Date: $todayDate",
            //   style: Styles.textStyleSmall(context, color: AppColor.whiteColor),
            // ),
            // Text(
            //   "Current Time: $currentTime",
            //   style: Styles.textStyleSmall(context, color: AppColor.whiteColor),
            // ),
            SizedBox(height: screenHeight * 0.04),
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingSlot(
                          selectedDate: DateTime.now(),
                          oldPrice: widget.oldPrice,
                          savings: widget.savings,
                          gstAmount: widget.gstAmount,
                          totalWithGst: widget.totalWithGst,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      image: DecorationImage(
                        image: AssetImage(ConstantImageKey.fruits),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSlot(
                            selectedDate: DateTime.now(),
                            oldPrice: widget.oldPrice,
                            savings: widget.savings,
                            gstAmount: widget.gstAmount,
                            totalWithGst: widget.totalWithGst,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.whiteColor,
                        image: DecorationImage(
                          image: AssetImage(ConstantImageKey.dailyOrder),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingSlot(
                      selectedDate: DateTime.now(),
                      oldPrice: widget.oldPrice,
                      savings: widget.savings,
                      gstAmount: widget.gstAmount,
                      totalWithGst: widget.totalWithGst,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "DAILY BOOKING",
                      style: Styles.textStyleLarge(
                        context,
                        color: AppColor.fillColor,
                      ),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "With Daily Booking, enjoy fixed pricing\nevey day!",
                        style: Styles.textStyleSmall(
                          context,
                          color: AppColor.hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreBookingSlot(
                          oldPrice: widget.oldPrice,
                          savings: widget.savings,
                          gstAmount: widget.gstAmount,
                          totalWithGst: widget.totalWithGst,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      image: DecorationImage(
                        image: AssetImage(ConstantImageKey.Pre),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreBookingSlot(
                            oldPrice: widget.oldPrice,
                            savings: widget.savings,
                            gstAmount: widget.gstAmount,
                            totalWithGst: widget.totalWithGst,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.whiteColor,
                        image: DecorationImage(
                          image: AssetImage(ConstantImageKey.PreOrder),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreBookingSlot(
                      oldPrice: widget.oldPrice,
                      savings: widget.savings,
                      gstAmount: widget.gstAmount,
                      totalWithGst: widget.totalWithGst,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "PRE BOOKING",
                      style: Styles.textStyleLarge(
                        context,
                        color: AppColor.fillColor,
                      ),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Opt for Pre-Booking to unlock potential\ndiscounts and save more!",
                          style: Styles.textStyleSmall(
                            context,
                            color: AppColor.hintTextColor,
                          ),
                          textAlign: TextAlign.center,
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
      ),
    );
  }
}
