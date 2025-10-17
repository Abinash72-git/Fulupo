import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/subscription_pages/weekly_subscription/schedule_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WeeklyPackagesPages extends StatefulWidget {
  final String packageName;
  final String price;
  final String weekId;

  const WeeklyPackagesPages(
      {super.key,
      required this.packageName,
      required this.price,
      required this.weekId});

  @override
  State<WeeklyPackagesPages> createState() => _WeeklyPackagesPagesState();
}

class _WeeklyPackagesPagesState extends State<WeeklyPackagesPages> {
  GetProvider get getprovider => context.read<GetProvider>();

  Map<String, bool> isExpanded = {};
  Map<String, Set<String>> selectedFruits = {};
  bool isLoading = true;
  String packageId = '';

  Future<void> _fetchWeeklyPackageType() async {
    setState(() {
      isLoading = true;
    });

    try {
      await getprovider.fetchWeeklyPackageType(widget.weekId);
    } catch (e) {
      print("Error fetching subscription data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWeeklyPackageType();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(widget.packageName,
            style: Styles.textStyleLarge(context, color: AppColor.whiteColor),
            textScaleFactor: 1.0),
        backgroundColor: AppColor.fillColor,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.yellowColor,
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: getprovider.weeklyPackage
                          .asMap()
                          .entries
                          .map((entry) {
                        final int index = entry.key;
                        final item = entry.value;
                        packageId = item.weeklyId!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.03),
                            Container(
                              height: screenHeight * 0.33,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                  color: AppColor.whiteColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Container(
                                      height: screenHeight * 0.22,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                              image: NetworkImage(item.image!),
                                              fit: BoxFit.cover))),
                                  SizedBox(height: screenHeight * 0.01),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(item.packageType!,
                                          style: Styles.textStyleMedium(context,
                                              color: AppColor.fillColor),
                                          textScaleFactor: 1.0),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Container(
                                    width: screenWidth * 0.25,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: AppColor.fillColor),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            '${AppConstants.Rupees} ${item.packagePrice}',
                                            style: Styles.textStyleMedium(
                                                context,
                                                color: AppColor.whiteColor),
                                            textScaleFactor: 1.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text('Description',
                                style: Styles.textStyleLarge(context,
                                    color: AppColor.yellowColor),
                                textScaleFactor: 1.0),
                            SizedBox(height: screenHeight * 0.01),
                            Text(item.description!,
                                style: Styles.textStyleMedium(context,
                                    color: AppColor.whiteColor),
                                textScaleFactor: 1.0),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            ..._buildDaysList(List<Map<String, String>>.from(
                                getprovider.weeklyPackage.first.days ?? [])),
                            SizedBox(height: screenHeight * 0.15),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, // Position it at the bottom
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    decoration: const BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Column(
                      children: [
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
                              // Check if each day has exactly 3 selected items
                              bool isValid = selectedFruits.entries
                                  .every((entry) => entry.value.length == 3);

                              if (!isValid) {
                                // Show toast message if validation fails
                                Fluttertoast.showToast(
                                  msg:
                                      "Please select exactly three items for each day.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop function execution
                              }

                              // Collect selected fruits for each day
                              Map<String, List<String>> selectedData = {};
                              selectedFruits.forEach((day, fruits) {
                                selectedData[day] = fruits.toList();
                              });
                              // Print selected fruits for each day
                              selectedData.forEach((day, fruits) {
                                print("$day: ${fruits}");
                                log("$day: ${fruits}");
                              });

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SchedulePage(
                                            packageName: widget.packageName,
                                            price: widget.price,
                                            selectedFruits: selectedData,
                                            weekPackageId: packageId,
                                          )));
                            }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildDaysList(List<Map<String, String>> daysList) {
    // Group the data by day keys (e.g., "day1", "day2", "day3")
    Map<String, List<String>> groupedDays = {};

    for (var day in daysList) {
      day.forEach((key, value) {
        if (groupedDays.containsKey(key)) {
          groupedDays[key]!.add(value);
        } else {
          groupedDays[key] = [value];
        }
      });
    }

    List<Widget> dayWidgets = [];

    groupedDays.forEach((dayKey, fruits) {
      // Convert "day1" -> "Day 1"
      String displayDay = dayKey.replaceAll("day", "Day ");

      // Ensure expansion & selection tracking
      isExpanded.putIfAbsent(dayKey, () => false);
      selectedFruits.putIfAbsent(dayKey, () => {});

      dayWidgets.add(
        Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded[dayKey] = !isExpanded[dayKey]!;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayDay,
                      style: Styles.textStyleMedium(context,
                          color: AppColor.fillColor),
                    ),
                    Icon(
                      isExpanded[dayKey]!
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColor.fillColor,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded[dayKey]!)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 items per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: fruits.length,
                    itemBuilder: (context, index) {
                      String fruit = fruits[index];
                      bool isSelected = selectedFruits[dayKey]!.contains(fruit);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              // Deselect if already selected
                              selectedFruits[dayKey]!.remove(fruit);
                            } else if (selectedFruits[dayKey]!.length < 3) {
                              // Allow selection only if less than 3 are selected
                              selectedFruits[dayKey]!.add(fruit);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColor.fillColor : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Text(
                            fruit,
                            style: Styles.textStyleSmall(
                              context,
                              color: isSelected
                                  ? Colors.white
                                  : AppColor.fillColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 10),
          ],
        ),
      );
    });

    return dayWidgets;
  }
}
