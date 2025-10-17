
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/subscription_pages/monthly_subscription/montly_subscription_page.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlySchedule extends StatefulWidget {
  const MonthlySchedule({super.key});

  @override
  _MonthlyScheduleState createState() => _MonthlyScheduleState();
}

class _MonthlyScheduleState extends State<MonthlySchedule> {
  DateTime? selectedStartDate; // Store the selected start date
  late DateTime focusedDay; // Store the focused day
  late DateTime startDate; // The initial start date (tomorrow)
  late DateTime endDate; // The last available date (28 days from tomorrow)

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().add(Duration(days: 1)); // Start from tomorrow
    endDate = startDate.add(Duration(days: 27)); // 28 days from tomorrow
    focusedDay = startDate; // Focused on the starting date initially
  }

  // Function to handle day selection
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedStartDate = day; // Set the selected day
      this.focusedDay = focusedDay; // Update the focused day
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.fillColor, // Replace with AppColor.fillColor
      appBar: AppBar(
        backgroundColor: AppColor.fillColor, // Replace with AppColor.fillColor
        title: Center(
          child: Text('Select a Date for Monthly Subscription',
              style:
                  Styles.textStyleMedium(context, color: AppColor.whiteColor),
              textScaleFactor: 1.0),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Text('Select Starting Date',
                  style: Styles.textStyleExtraLarge(context,
                      color: AppColor.yellowColor),
                  textScaleFactor: 1.0),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: TableCalendar(
                    focusedDay: focusedDay,
                    firstDay: startDate,
                    lastDay: endDate,
                    selectedDayPredicate: (day) =>
                        selectedStartDate != null &&
                        isSameDay(day, selectedStartDate),
                    onDaySelected: _onDaySelected,
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: TextStyle(
                        color: AppColor.fillColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Center(
              child: Text('Selected Date',
                  style: Styles.textStyleExtraLarge(context,
                      color: AppColor.yellowColor),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Text('Your Starting Date',
                      style: Styles.textStyleLarge(context,
                          color: AppColor.fillColor),
                      textScaleFactor: 1.0),
                  Text(
                      selectedStartDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedStartDate!)
                          : 'No date selected',
                      style: Styles.textStyleMedium(context,
                          color: AppColor.hintTextColor),
                      textScaleFactor: 1.0),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (selectedStartDate == null) {
                  // Show snackbar if no date is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No date selected.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Navigate to the next page with the selected date
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MontlySubscriptionPage(
                        startDate: selectedStartDate!,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.yellowColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text('Continue',
                      style: Styles.textStyleLarge(context,
                          color: AppColor.blackColor),
                      textScaleFactor: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
