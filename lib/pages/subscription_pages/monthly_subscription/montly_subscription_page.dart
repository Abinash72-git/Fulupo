
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/color_constant.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MontlySubscriptionPage extends StatefulWidget {
  final DateTime startDate; // Pass the selected start date here
  const MontlySubscriptionPage({super.key, required this.startDate});

  @override
  State<MontlySubscriptionPage> createState() => _MontlySubscriptionPageState();
}

class _MontlySubscriptionPageState extends State<MontlySubscriptionPage> {
  int? selectedWeek; // Tracks the selected week index
  int? selectedPackage; // Tracks the selected package radio button
  Map<int, bool> expandedPackages = {
    3: false,
    5: false,
    7: false,
  }; // Tracks expanded state for each package
  Map<int, int?> selectedPackages = {};
  // Map to store selected dates for each week
  Map<int, List<DateTime>> selectedDates = {
    0: [], // Week 1
    1: [], // Week 2
    2: [], // Week 3
    3: [], // Week 4
  };

  // Declare the user-selected start date
  DateTime? userSelectedStartDate;

  Future<void> _selectDates(
    BuildContext context,
    int weekIndex,
    int packageDays,
  ) async {
    // Use the passed start date from the demo page
    DateTime startDate = widget.startDate;
    DateTime weekStartDate = startDate.add(Duration(days: 7 * weekIndex));
    DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            DateTime localFocusedDay = weekStartDate;

            return Dialog(
              child: SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaleFactor: 1.0),
                          child: TableCalendar(
                            focusedDay: localFocusedDay,
                            firstDay: weekStartDate,
                            lastDay: weekEndDate,
                            selectedDayPredicate: (day) {
                              // Check if the day is selected in the specific week
                              return selectedDates[weekIndex]?.any(
                                    (selectedDate) =>
                                        isSameDay(selectedDate, day),
                                  ) ??
                                  false;
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setDialogState(() {
                                // Update the local focused day
                                localFocusedDay = focusedDay;

                                // Initialize selectedDates map for the week if null
                                if (selectedDates[weekIndex] == null) {
                                  selectedDates[weekIndex] = [];
                                }

                                // Add or remove the selected day
                                if (selectedDates[weekIndex]!.contains(
                                  selectedDay,
                                )) {
                                  selectedDates[weekIndex]!.remove(selectedDay);
                                } else if (selectedDates[weekIndex]!.length <
                                    packageDays) {
                                  selectedDates[weekIndex]!.add(selectedDay);
                                }
                              });

                              // Update the parent widget state
                              setState(() {});
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
                              selectedDecoration: const BoxDecoration(
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
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.357,
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
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(false);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build package selection widgets
  List<Widget> buildPackageSelection(
    int weekIndex,
    BuildContext context,
    double screenHeight,
  ) {
    return [
      SizedBox(height: screenHeight * 0.05),
      ...[3, 5, 7].map((packageDays) {
        return Column(
          children: [
            PackageRow(
              packageDays: packageDays,
              weekIndex: weekIndex,
              isSelected: selectedPackages[weekIndex] == packageDays,
              isExpanded: expandedPackages[packageDays] ?? false,
              onRadioTap: () async {
                // Open the calendar for the same package to allow date adjustment
                await _selectDates(context, weekIndex, packageDays);

                // Update the selected package if it's different
                setState(() {
                  selectedPackages[weekIndex] = packageDays;
                });
              },
              onExpandTap: () {
                setState(() {
                  expandedPackages[packageDays] =
                      !(expandedPackages[packageDays] ?? false);
                });
              },
              selectedDates:
                  selectedDates[weekIndex]?.take(packageDays).toList(),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        );
      }).toList(),
    ];
  }

  @override
  void initState() {
    super.initState();
    selectedWeek = 0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Monthly Subscription",
            style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
            textScaleFactor: 1.0,
          ),
        ),
        backgroundColor: AppColor.fillColor,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Row(
        children: [
          // Static container with selectable weeks
          Container(
            height: screenHeight,
            width: screenWidth * 0.3,
            decoration: const BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  WeeklyContainer(
                    weekText: 'Week 1',
                    isSelected:
                        selectedWeek == 0, // Check if Week 1 is selected
                    onTap: () {
                      setState(() {
                        // Allow only Week 1 to be unselected
                        if (selectedWeek == 0) {
                          selectedWeek = null; // Unselect Week 1
                        } else {
                          selectedWeek =
                              0; // Always select Week 1 if it's not already selected
                        }

                        // Check if Week 1 selection is null (i.e., no package selected)
                        if (selectedPackages[0] == null &&
                            selectedWeek == null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //         'Please select any one of these three packages for Week 1.'),
                          //   ),
                          // );
                        }
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  WeeklyContainer(
                    weekText: 'Week 2',
                    isSelected: selectedWeek == 1,
                    onTap: () {
                      setState(() {
                        selectedWeek = selectedWeek == 1 ? null : 1;
                        if (selectedPackages[1] == null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //         'Please select any one of these three packages for Week 2.'),
                          //   ),
                          // );
                        }
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  WeeklyContainer(
                    weekText: 'Week 3',
                    isSelected: selectedWeek == 2,
                    onTap: () {
                      setState(() {
                        selectedWeek = selectedWeek == 2 ? null : 2;
                        if (selectedPackages[2] == null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //         'Please select any one of these three packages for Week 3.'),
                          //   ),
                          // );
                        }
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  WeeklyContainer(
                    weekText: 'Week 4',
                    isSelected: selectedWeek == 3,
                    onTap: () {
                      setState(() {
                        selectedWeek = selectedWeek == 3 ? null : 3;
                        if (selectedPackages[3] == null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //         'Please select any one of these three packages for Week 4.'),
                          //   ),
                          // );
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Scrollable content for selecting packages
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Select Any One Of This Three Packages For Every Weeks',
                    style: Styles.textStyleMedium(
                      context,
                      color: AppColor.yellowColor,
                    ),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                  // Week 1 package selection
                  // In your build method, replace the existing repetitive code with:
                  if (selectedWeek == 0)
                    ...buildPackageSelection(0, context, screenHeight),
                  if (selectedWeek == 1)
                    ...buildPackageSelection(1, context, screenHeight),
                  if (selectedWeek == 2)
                    ...buildPackageSelection(2, context, screenHeight),
                  if (selectedWeek == 3)
                    ...buildPackageSelection(3, context, screenHeight),

                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () async {
                        List<String> incompleteWeeks = [];

                        // Check for completeness across all four weeks
                        for (int week = 0; week < 4; week++) {
                          final selectedPackage = selectedPackages[week];
                          final selectedDatesForWeek = selectedDates[week];

                          // Check if package is selected and required number of dates is picked
                          if (selectedPackage == null ||
                              selectedDatesForWeek == null ||
                              selectedDatesForWeek.length < selectedPackage) {
                            incompleteWeeks.add('Week ${week + 1}');
                          }
                        }

                        if (incompleteWeeks.isEmpty) {
                          // All weeks are complete; print the selections
                          for (int week = 0; week < 4; week++) {
                            final selectedPackage = selectedPackages[week];
                            final selectedDatesForWeek = selectedDates[week];

                            print('Week ${week + 1}:');
                            print('  Selected Package: $selectedPackage Days');
                            print('  Selected Dates:');
                            for (var date in selectedDatesForWeek!) {
                              print(
                                '    ${date.day}/${date.month}/${date.year}',
                              );
                            }
                          }
                          await AppRouteName.apppage.push(context, args: 1);
                        } else {
                          // Show snackbar with incomplete weeks
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select a package and pick dates for: ${incompleteWeeks.join(', ')}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                  ),
                  SizedBox(height: screenHeight * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyContainer extends StatelessWidget {
  final String weekText;
  final bool isSelected;
  final VoidCallback onTap;

  const WeeklyContainer({
    Key? key,
    required this.weekText,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 35),
        width: screenWidth * 0.24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? AppColor.fillColor : AppColor.whiteColor,
          border: Border.all(color: AppColor.fillColor),
        ),
        child: Center(
          child: Text(
            weekText,
            style: Styles.textStyleMedium(
              context,
              color: isSelected ? AppColor.whiteColor : AppColor.fillColor,
            ),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}

class PackageRow extends StatelessWidget {
  final int packageDays;
  final int weekIndex;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onRadioTap;
  final VoidCallback onExpandTap;
  final List<DateTime>? selectedDates;

  const PackageRow({
    Key? key,
    required this.packageDays,
    required this.weekIndex,
    required this.isSelected,
    required this.isExpanded,
    required this.onRadioTap,
    required this.onExpandTap,
    this.selectedDates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onExpandTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isExpanded ? AppColor.fillColor : AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Radio(
                            value: packageDays,
                            groupValue: isSelected ? packageDays : null,
                            onChanged: (_) {
                              onRadioTap(); // Update selection
                              onExpandTap(); // Expand package
                            },
                            activeColor:
                                isExpanded
                                    ? AppColor.yellowColor
                                    : AppColor.fillColor,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$packageDays Days Package',
                              style: Styles.textStyleMedium(context).copyWith(
                                color:
                                    isExpanded
                                        ? AppColor.yellowColor
                                        : AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color:
                                isExpanded
                                    ? AppColor.whiteColor
                                    : AppColor.fillColor,
                          ),
                        ],
                      ),
                      // Show selected dates only for the active and selected package
                      if (isExpanded && isSelected)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You Selected Dates:',
                              style: Styles.textStyleMedium(
                                context,
                              ).copyWith(color: AppColor.whiteColor),
                              textScaleFactor: 1.0,
                            ),
                            if (selectedDates != null &&
                                selectedDates!.isNotEmpty)
                              Text(
                                DateFormat(
                                  'MMMM yyyy',
                                ).format(selectedDates![0]), // Full month name
                                style: Styles.textStyleMedium(
                                  context,
                                ).copyWith(color: AppColor.whiteColor),
                                textScaleFactor: 1.0,
                              ),
                            const SizedBox(height: 5),
                            if (selectedDates != null &&
                                selectedDates!.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children:
                                    selectedDates!
                                        .take(
                                          packageDays,
                                        ) // Display only the selected number of days
                                        .map(
                                          (date) => Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColor.yellowColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              '${date.day < 10 ? '0' : ''}${date.day}', // Ensure the day is 2 digits
                                              style: Styles.textStyleSmall(
                                                context,
                                              ).copyWith(
                                                color: AppColor.blackColor,
                                              ),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            // Add the "Change" button
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                onRadioTap();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.yellowColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'Change',
                                    style: Styles.textStyleMedium(
                                      context,
                                      color: AppColor.blackColor,
                                    ),
                                    textScaleFactor: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              // Show description for days, but only for the selected package
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(packageDays, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${index + 1}',
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'This is the description for Day ${index + 1}.',
                              style: Styles.textStyleSmall(context),
                              textScaleFactor: 1.0,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
