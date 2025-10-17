
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/booking_slot.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Import intl package

class PreBookingSlot extends StatefulWidget {
  final double oldPrice;
  final double savings;
  final double gstAmount;
  final double totalWithGst;
  const PreBookingSlot({
    super.key,
    required this.oldPrice,
    required this.savings,
    required this.gstAmount,
    required this.totalWithGst,
  });

  @override
  State<PreBookingSlot> createState() => _PreBookingSlotState();
}

class _PreBookingSlotState extends State<PreBookingSlot> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  List<DateTime> selectedDates = [];
  late DateTime focusedDay;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDate = DateTime.now().add(const Duration(days: 1));
    endDate = startDate.add(const Duration(days: 27));
    focusedDay = startDate;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Center(
          child: Text(
            'Pre Booking',
            style: Styles.textStyleLarge(context, color: AppColor.whiteColor),
            textScaleFactor: 1.0,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.whiteColor,
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
              child: Text(
                'Schedule',
                style: Styles.textStyleExtraLarge(context,
                    color: AppColor.yellowColor),
                textScaleFactor: 1.0,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MediaQuery(
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: startDate,
                        lastDay: endDate,
                        selectedDayPredicate: (day) {
                          // Highlight days that are in the selectedDates list
                          return selectedDates.any((selectedDate) =>
                              isSameDay(selectedDate, day)); // Compare days
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (_isValidDate(selectedDay)) {
                            _onDaySelected(selectedDay); // Handle selection
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select today\'s date or a future date.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                            color: AppColor
                                .fillColor, // Selected day color (green)
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
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text('Booking Date',
                  style: Styles.textStyleExtraLarge(context,
                      color: AppColor.yellowColor),
                  textScaleFactor: 1.0),
            ),
            const SizedBox(height: 20),

            // Display the selected date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColor.whiteColor,
              ),
              child: Column(
                children: [
                  Text('You Picked Booking Date',
                      style: Styles.textStyleLarge(context,
                          color: AppColor.fillColor),
                      textScaleFactor: 1.0),
                  Text(
                      selectedDates.isNotEmpty
                          ? 'Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDates.first)}'
                          : 'No date selected',
                      style: Styles.textStyleSmall(context,
                          color: AppColor.hintTextColor),
                      textScaleFactor: 1.0),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (selectedDate == null || selectedDates.isEmpty) {
                  // Show Snackbar if no date is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a date before continuing.'),
                      backgroundColor: Color.fromARGB(255, 230, 15, 0),
                    ),
                  );
                } else {
                  // Navigate to BookingSlot only if the date is selected
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingSlot(
                        selectedDate: selectedDate, // Pass the selected date
                        oldPrice: widget.oldPrice,
                        savings: widget.savings,
                        gstAmount: widget.gstAmount,
                        totalWithGst: widget.totalWithGst,
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
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now(); // Default to today's date

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      selectedDate = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      ); // Strip time for accurate comparison
      selectedDates = [selectedDate]; // Update the list of selected dates
    });
  }

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day); // Strip time for comparison
    return date.isAtSameMomentAs(today) || date.isAfter(today);
  }
}
