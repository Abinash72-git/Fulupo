import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/dailyBookingSlot_model.dart';
import 'package:fulupo/pages/demo_payment/payment_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import for DateFormat

class BookingSlot extends StatefulWidget {
  final DateTime selectedDate;

  final double oldPrice;
  final double savings;
  final double gstAmount;
  final double totalWithGst;

  const BookingSlot({
    super.key,
    required this.selectedDate,
    required this.oldPrice,
    required this.savings,
    required this.gstAmount,
    required this.totalWithGst,
  });

  @override
  State<BookingSlot> createState() => _BookingSlotState();
}

class _BookingSlotState extends State<BookingSlot> {
  String? selectedSlot;
  late bool isToday;
  bool isLoading = true;
  String token = '';
  Map<String, int> itemCounts = {};
  List<Map<String, dynamic>> items = [];
  GetProvider get getprovider => context.read<GetProvider>();
  String orderAddress = '';

  DateTime? convertToDateTime(String time) {
    try {
      DateTime now = DateTime.now();
      DateFormat format =
          DateFormat("hh:mm a"); // Expecting time in AM/PM format
      DateTime parsedTime = format.parse(time);
      return DateTime(
          now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
    } catch (e) {
      print("Time Parsing Error: $e");
      return null; // Return null for invalid format
    }
  }

  // // Function to check if a slot is clickable (present/future slots)
  // bool isSlotClickable(DateTime slotStart, DateTime slotEnd) {
  //   return currentTime.isBefore(slotStart); // Only clickable if future slot
  // }

  Widget buildBookingSlot(
      String title, String imagePath, List<Map<String, String>> slots) {
    bool isToday = widget.selectedDate.year == DateTime.now().year &&
        widget.selectedDate.month == DateTime.now().month &&
        widget.selectedDate.day == DateTime.now().day;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height *
                0.025, // Dynamic Vertical Padding
            horizontal: MediaQuery.of(context).size.width *
                0.03, // Dynamic Horizontal Padding
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage(ConstantImageKey.slotBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.fillColor),
                  textScaleFactor: 1,
                ),
              ),
              const SizedBox(height: 20),
              // ** Generate Slot Rows **
              Column(
                children: _buildSlotRows(slots, isToday, title),
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          left: 25,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColor.fillColor, width: 7),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

// ** Function to Group Slots into Rows (Max 2 Per Row) **
  List<Widget> _buildSlotRows(
      List<Map<String, String>> slots, bool isToday, String title) {
    List<Widget> rows = [];
    for (int i = 0; i < slots.length; i += 2) {
      List<Map<String, String>> rowSlots =
          slots.sublist(i, (i + 2 > slots.length) ? slots.length : i + 2);

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: rowSlots.length == 1
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly, // **Better Spacing**
            children: rowSlots.map((slot) {
              return _buildSlotItem(slot, isToday, title);
            }).toList(),
          ),
        ),
      );
    }
    return rows;
  }

// ** Slot Item UI with Fixed Size **
  Widget _buildSlotItem(Map<String, String> slot, bool isToday, String title) {
    String startTime = slot['start']!;
    String endTime = slot['end']!;

    DateTime now = DateTime.now();
    DateTime? slotStart = convertToDateTime(startTime);
    DateTime? slotEnd = convertToDateTime(endTime);

    Color slotColor;
    bool isSlotEnabled;

    if (!isToday) {
      slotColor = AppColor.fillColor;
      isSlotEnabled = true;
    } else if (slotStart == null || slotEnd == null) {
      slotColor = Colors.grey;
      isSlotEnabled = false;
    } else if (now.isBefore(slotEnd)) {
      slotColor = AppColor.fillColor;
      isSlotEnabled = true;
    } else {
      slotColor = Colors.grey;
      isSlotEnabled = false;
    }

    return GestureDetector(
      onTap: isSlotEnabled
          ? () async {
              print("Selected Slot: $startTime - $endTime");

              showSlotDetailsBottomSheet(
                  title
                      .split(" ")[0], // Extract "Morning", "Afternoon", "Night"
                  startTime,
                  endTime,
                  widget.oldPrice,
                  widget.savings,
                  widget.gstAmount,
                  widget.totalWithGst,
                  widget.selectedDate);
            }
          : null,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42, // 42% of screen width
        height: 50, // Keep height fixed
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        decoration: BoxDecoration(
          color: slotColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(
              '$startTime - $endTime',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void showSlotDetailsBottomSheet(
    String slotPeriod,
    String startTime,
    String endTime,
    double oldPrice,
    double savings,
    double gstAmount,
    double totalWithGst,
    DateTime selectedDate,
  ) {
    String formattedTitle =
        "$slotPeriod Booking Slot"; // Example: "Morning Booking Slot"

    // Check if the selected date is today
    // bool isToday = selectedDate.year == DateTime.now().year &&
    //     selectedDate.month == DateTime.now().month &&
    //     selectedDate.day == DateTime.now().day;

    // Adjust totalWithGst if it's a future date by subtracting 5.00 for "Pre Order"
    double adjustedTotal = totalWithGst;
    if (!isToday) {
      adjustedTotal -= 5.00; // Subtracting 5.00 for future dates
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Allow dynamic height
      builder: (BuildContext context) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      20, // Handle keyboard overlap
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Allow flexible height
                  children: [
                    if (!isToday)
                      Text(
                        'Your Booking Date ',
                        style: Styles.textStyleLarge(context,
                            color: AppColor.fillColor),
                        textScaleFactor: 1.0,
                      ),
                    SizedBox(height: 10),
                    if (!isToday)
                      Text(
                        '(${selectedDate.toLocal().toString().split(' ')[0]})',
                        style: Styles.textStyleMedium(context,
                            color: AppColor.hintTextColor),
                        textScaleFactor: 1.0,
                      ),
                    SizedBox(height: 20),
                    Text(
                      'You Chose $formattedTitle',
                      style: Styles.textStyleLarge(context,
                          color: AppColor.fillColor),
                      textScaleFactor: 1.0,
                    ),
                    Text(
                      '(${slotPeriod} $startTime to $endTime)',
                      style: Styles.textStyleMedium(context,
                          color: AppColor.hintTextColor),
                      textScaleFactor: 1.0,
                    ),
                    SizedBox(height: 20),
                    // Price Details Section
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var item in [
                            {
                              'label': 'Old Price:',
                              'value': oldPrice.toStringAsFixed(2)
                            },
                            {
                              'label': 'Savings:',
                              'value': savings.toStringAsFixed(2)
                            },
                            {
                              'label': 'GST Amount:',
                              'value': gstAmount.toStringAsFixed(2)
                            },
                            {
                              'label': 'Delivery Fees',
                              'value': '30.00',
                              'strikethrough': true
                            },
                            if (!isToday)
                              {'label': 'Pre Order', 'value': '-5.00'},
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['label'] as String,
                                    style: Styles.textStyleMedium(context,
                                        color: AppColor.fillColor),
                                    textScaleFactor: 1.0,
                                  ),
                                  Text(
                                    '₹${item['value']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.hintTextColor,
                                      decoration: item['strikethrough'] == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 10),
                          // Total Pay Row
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColor.fillColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Pay',
                                  style: Styles.textStyleMedium(context,
                                      color: AppColor.whiteColor),
                                  textScaleFactor: 1.0,
                                ),
                                Text(
                                  '₹${adjustedTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
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

                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {
                          print('8788888888888888');
                          try {
                            await AppDialogue.openLoadingDialogAfterClose(
                                context,
                                text: "Order Booking...", load: () async {
                              return await getprovider.addBooking(
                                  token: token,
                                  items: items,
                                  bookingDate: selectedDate,
                                  slotSchedule: slotPeriod,
                                  startTime: startTime,
                                  endTime: endTime,
                                  oldPrice: oldPrice,
                                  savings: savings,
                                  gst: gstAmount,
                                  deliveryFees: 30.0,
                                  order_Address: orderAddress,
                                  totalPay: adjustedTotal);
                            }, afterComplete: (resp) async {
                              if (resp.statusCode==200) {
                                AppDialogue.toast(resp.data);
                              } else {
                                AppDialogue.toast(resp.data);
                              }
                            });
                          } catch (e) {
                            ExceptionHandler.showMessage(context, e);
                          }
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Payment(
                                        grandTotal: adjustedTotal,
                                      )), // Go to Home
                              (route) => false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.yellowColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Pay Now',
                              style: Styles.textStyleLarge(context,
                                  color: AppColor.blackColor),
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.45,
              top: -MediaQuery.of(context).size.height * 0.065,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.4),
                    width: MediaQuery.of(context).size.width * 0.005,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _fetchBookingSlots() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      print(widget.selectedDate);
      log('${widget.selectedDate}--------------------------');

      isToday = widget.selectedDate.year == DateTime.now().year &&
          widget.selectedDate.month == DateTime.now().month &&
          widget.selectedDate.day == DateTime.now().day;

      if (isToday) {
        print('Yes---------------');
        log('Yes---------------');
        await Provider.of<GetProvider>(context, listen: false)
            .fetchDailyBookingSlot();
      } else {
        print('No-----------------');
        log('No-----------------');
        await Provider.of<GetProvider>(context, listen: false)
            .fetchPreBookingSlot();
      }
    } catch (e) {
      print('Error fetching booking slots: $e');
      log('Error fetching booking slots: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading when finished
      });
    }
  }

  // ** Convert "hh:mm a" to DateTime (Handles AM/PM) **

  @override
  void initState() {
    super.initState();

    _fetchBookingSlots();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(
          "Booking Slot",
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
          textScaleFactor: 1.0,
        ),
        backgroundColor: AppColor.fillColor,
      ),
      body: Consumer<GetProvider>(
        builder: (context, getProvider, child) {
          final List<DailybookingslotModel> slots = getProvider.getDailySlot;

          if (isLoading) {
            return buildShimmerEffect(screenHeight);
          }

          // ** Group Slots Based on Schedule **
          List<Map<String, String>> morningSlots = [];
          List<Map<String, String>> afternoonSlots = [];
          List<Map<String, String>> eveningSlots = [];

          for (var slot in slots) {
            Map<String, String> slotData = {
              'start': slot.startTime ?? "N/A",
              'end': slot.endTime ?? "N/A",
              'schedule': slot.slotschedule ?? "N/A"
            };

            if (slot.slotschedule == "Morning booking slot") {
              morningSlots.add(slotData);
            } else if (slot.slotschedule == "Afternoon booking slot") {
              afternoonSlots.add(slotData);
            } else if (slot.slotschedule == "Evening booking slot" ||
                slot.slotschedule == "Evening  booking slot") {
              eveningSlots.add(slotData);
            }
          }
// ** Sorting function to order slots by start time **
          int compareSlots(Map<String, String> a, Map<String, String> b) {
            DateTime? startA = convertToDateTime(a['start']!);
            DateTime? startB = convertToDateTime(b['start']!);

            if (startA == null || startB == null) return 0;
            return startA.compareTo(startB);
          }

// ** Sort each slot list **
          morningSlots.sort(compareSlots);
          afternoonSlots.sort(compareSlots);
          eveningSlots.sort(compareSlots);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  buildBookingSlot("Morning Booking Slot",
                      ConstantImageKey.morning, morningSlots),
                  SizedBox(height: screenHeight * 0.05),
                  buildBookingSlot("Afternoon Booking Slot",
                      ConstantImageKey.evening, afternoonSlots),
                  SizedBox(height: screenHeight * 0.05),
                  buildBookingSlot("Evening Booking Slot",
                      ConstantImageKey.night, eveningSlots),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ** Build Shimmer Effect Instead of CircularProgressIndicator **
  Widget buildShimmerEffect(double screenHeight) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            shimmerSlotBox(),
            SizedBox(height: screenHeight * 0.05),
            shimmerSlotBox(),
            SizedBox(height: screenHeight * 0.05),
            shimmerSlotBox(),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  // ** Shimmer UI Placeholder **
  Widget shimmerSlotBox() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.green[300]!,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                )
              ],
            ),
            Container(
              height: 15,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _fetchCartData() async {
    try {
      // Fetch cart data
      final cartData = await context.read<GetProvider>().fetchAddToCart(token);

      // Clear current states
      itemCounts.clear();

      // Process the fetched data
      for (var item in cartData) {
        final categoryId = item.fruitCategoryId;
        final count = item.count;

        if (categoryId != null) {
          // Update item counts
          itemCounts[categoryId] = count ?? 0;

          // Print and log the categoryId and count
          print("Category ID: $categoryId, Count: ${itemCounts[categoryId]}");
          log("Category ID: $categoryId, Count: ${itemCounts[categoryId]}");

          // Add to items list for booking
          items.add({
            "sub_category_id": categoryId,
            "count": count ?? 0,
          });
        }
      }

      // Call addBooking function if there are items
    } catch (e) {
      print('Error fetching cart data: $e');
    }
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Retrieve latitude and longitude as doubles

      token = prefs.getString('token') ?? '';
      orderAddress = prefs.getString(AppConstants.USERADDRESS) ?? '';
      print(token);
      print(orderAddress);
      log('Token: $token');
      log('Order Address: $orderAddress');
    } catch (e) {
      print('Error retrieving location data: $e');
      setState(() {});
    }
    await _fetchCartData();
  }
}
