import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  final String weekPackageId;
  final String packageName;
  final String price;
  final Map<String, List<String>> selectedFruits;

  const SchedulePage({
    super.key,
    required this.packageName,
    required this.weekPackageId,
    required this.price,
    required this.selectedFruits,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<DateTime> selectedDates = [];

  GetProvider get getprovider => context.read<GetProvider>();

  late int allowedDays;
  DateTime? firstSelectedDay; // First selected date
  DateTime? rangeEnd; // End of the 7-day range
  late DateTime focusedDay;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();

    // Determine the allowed days based on the package name
    if (widget.packageName.toLowerCase().contains("3 days")) {
      allowedDays = 3;
    } else if (widget.packageName.toLowerCase().contains("5 days")) {
      allowedDays = 5;
    } else if (widget.packageName.toLowerCase().contains("7 days")) {
      allowedDays = 7;
    } else {
      allowedDays = 0; // Default to no selection if package is undefined
    }
    startDate = DateTime.now().add(Duration(days: 1));
    endDate = startDate.add(Duration(days: 27));
    focusedDay = startDate;
    _getdata();
  }

  bool isLoading = false;
  String token = '';

  Future<void> _getdata() async {
    // setState(() {
    //   isLoading = true; // Start loading
    // });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      token = prefs.getString('token') ?? '';
      print(token);
      log(token);
    } catch (e) {
      print('Error retrieving token: $e');
    }

    // Fetch user data

    // setState(() {
    //   isLoading = false; // Stop loading
    // });
  }

  Future<void> saveWeekPackageId(String weekPackageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('weekPackageId', weekPackageId);
    print('Week Package ID saved: $weekPackageId');
  }

  @override
  Widget build(BuildContext context) {
    String cleanedPrice = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
    double fullPrice = double.tryParse(cleanedPrice) ?? 0.0;
    double gstAmount = fullPrice * 0.02;
    double discountAmount = fullPrice * 0.05; // 5% Discount
    double totalAmount = fullPrice + gstAmount - discountAmount; // Final Total

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Function to show the bottom sheet
    void _showPackageDetailsBottomSheet() {
      // Clean and parse the price
      String cleanedPrice = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double fullPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // Calculate GST, discount, and total amount
      double gstAmount = fullPrice * 0.02; // 2% GST
      double discountAmount = fullPrice * 0.05; // 5% Discount
      double totalAmount =
          fullPrice + gstAmount - discountAmount; // Final Total

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) {
          return Container(
            height: screenHeight * 0.612,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            width: screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'You selected ${widget.packageName}',
                      style: Styles.textStyleLarge(
                        context,
                        color: AppColor.fillColor,
                      ),
                      textScaleFactor: 1.0,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 2,
                              spreadRadius: 2,
                              offset: Offset(1, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cancel_rounded,
                          color: AppColor.fillColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: 'Selected Dates: ',
                          style: Styles.textStyleLarge(
                            context,
                            color: AppColor.fillColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              selectedDates
                                  .map((date) {
                                    return DateFormat('d MMM').format(date);
                                  })
                                  .join(', ') +
                              ' ',
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Price Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price:',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            Text(
                              '₹${fullPrice.toStringAsFixed(2)}',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // GST Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GST (2%):',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            Text(
                              '₹${gstAmount.toStringAsFixed(2)}',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Discount Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount (5%):',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            Text(
                              '-₹${discountAmount.toStringAsFixed(2)}',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.fillColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pay',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.whiteColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.whiteColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async {
                      List<String> formattedDates =
                          selectedDates
                              .map(
                                (date) => DateFormat('yyyy-MM-dd').format(date),
                              )
                              .toList();
                      await saveWeekPackageId(widget.weekPackageId);
                      try {
                        await AppDialogue.openLoadingDialogAfterClose(
                          context,
                          text: "Order Booking...",
                          load: () async {
                            return await getprovider.addWeeklyBooking(
                              token: token,
                              weeklyPackageId: widget.weekPackageId,
                              packageType: widget.packageName,
                              date1:
                                  formattedDates.length > 0
                                      ? formattedDates[0]
                                      : '',
                              date2:
                                  formattedDates.length > 1
                                      ? formattedDates[1]
                                      : '',
                              date3:
                                  formattedDates.length > 2
                                      ? formattedDates[2]
                                      : '',
                              date4:
                                  formattedDates.length > 3
                                      ? formattedDates[3]
                                      : '',
                              date5:
                                  formattedDates.length > 4
                                      ? formattedDates[4]
                                      : '',
                              date6:
                                  formattedDates.length > 5
                                      ? formattedDates[5]
                                      : '',
                              date7:
                                  formattedDates.length > 6
                                      ? formattedDates[6]
                                      : '',
                              price: fullPrice,
                              gst: gstAmount,
                              discount: discountAmount,
                              totalPay: totalAmount,
                              items:
                                  widget.selectedFruits.entries
                                      .map(
                                        (entry) => {
                                          'fruit': entry.key,
                                          'dates': entry.value,
                                        },
                                      )
                                      .toList(),
                              selectedDates: formattedDates,
                            );
                          },
                          afterComplete: (resp) async {
                            if (resp.statusCode==200) {
                              AppDialogue.toast(resp.data);
                              AppRouteName.apppage.push(context, args: 1);
                            } else {
                              AppDialogue.toast(resp.data);
                            }
                          },
                        );
                      } catch (e) {
                        ExceptionHandler.showMessage(context, e);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.yellowColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'Pay Now',
                          style: Styles.textStyleLarge(
                            context,
                            color: AppColor.blackColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Center(
          child: Text(
            '${widget.packageName} Schedule',
            style: Styles.textStyleLarge(context, color: AppColor.whiteColor),
            textScaleFactor: 1.0,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: AppColor.whiteColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Text(
                'Schedule',
                style: Styles.textStyleExtraLarge(
                  context,
                  color: AppColor.yellowColor,
                ),
                textScaleFactor: 1.0,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaleFactor: 1.0),
                      child: TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: startDate,
                        lastDay: endDate,
                        selectedDayPredicate: (day) {
                          return selectedDates.any(
                            (selectedDate) => isSameDay(selectedDate, day),
                          );
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          _handleDaySelection(selectedDay);
                        },
                        calendarStyle: CalendarStyle(
                          defaultDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          todayDecoration: const BoxDecoration(
                            color: AppColor.yellowColor,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColor.fillColor,
                            shape: BoxShape.circle,
                          ),
                          weekendDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            color: AppColor.fillColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: AppColor.fillColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          weekendStyle: TextStyle(
                            color: AppColor.fillColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //const SizedBox(height: 10),
            Center(
              child: Text(
                'Booking Date',
                style: Styles.textStyleExtraLarge(
                  context,
                  color: AppColor.yellowColor,
                ),
                textScaleFactor: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColor.whiteColor,
              ),
              child: Column(
                children: [
                  Text(
                    'You Picked Booking Dates',
                    style: Styles.textStyleLarge(
                      context,
                      color: AppColor.fillColor,
                    ),
                    textScaleFactor: 1.0,
                  ),
                  Text(
                    selectedDates.isNotEmpty
                        ? selectedDates
                            .map(
                              (date) => DateFormat('dd/MM/yyyy').format(date),
                            )
                            .join(', ')
                        : 'No dates selected',
                    style: Styles.textStyleSmall(
                      context,
                      color: AppColor.hintTextColor,
                    ),
                    textScaleFactor: 1.0,
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                if (selectedDates.length != allowedDays) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please select exactly $allowedDays days before continuing.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _showPackageDetailsBottomSheet();
                  // Navigate to the next page
                  // Replace with your desired navigation logic
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.yellowColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Continue',
                    style: Styles.textStyleLarge(
                      context,
                      color: AppColor.blackColor,
                    ),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleDaySelection(DateTime selectedDay) {
    setState(() {
      if (selectedDates.contains(selectedDay)) {
        // If the user unselects the first date
        selectedDates.remove(selectedDay);

        if (selectedDates.isNotEmpty) {
          // Adjust the first selected day and range
          selectedDates.sort();
          firstSelectedDay = selectedDates.first;
          rangeEnd = firstSelectedDay!.add(const Duration(days: 6));
        } else {
          // Reset if no dates are selected
          firstSelectedDay = null;
          rangeEnd = null;
        }
      } else {
        if (firstSelectedDay == null) {
          // First date selected, set the range
          firstSelectedDay = selectedDay;
          rangeEnd = selectedDay.add(const Duration(days: 6));
        }

        // Validate the new selection
        if (selectedDay.isBefore(firstSelectedDay!) ||
            selectedDay.isAfter(rangeEnd!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please select dates between ${DateFormat('dd/MM/yyyy').format(firstSelectedDay!)} and ${DateFormat('dd/MM/yyyy').format(rangeEnd!)}.',
              ),
              backgroundColor: const Color.fromARGB(255, 255, 17, 0),
            ),
          );
          return;
        }

        // Add the selected date
        if (selectedDates.length < allowedDays) {
          selectedDates.add(selectedDay);
          selectedDates.sort();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select $allowedDays days.'),
              backgroundColor: const Color.fromARGB(255, 255, 17, 0),
            ),
          );
        }
      }
    });
  }
}
