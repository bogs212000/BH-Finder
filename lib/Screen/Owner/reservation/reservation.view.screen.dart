// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

class ViewReservationScreen extends StatefulWidget {
  const ViewReservationScreen({super.key});

  @override
  State<ViewReservationScreen> createState() => _ViewReservationScreenState();
}

class _ViewReservationScreenState extends State<ViewReservationScreen> {
  final calendarController = CleanCalendarController(
    readOnly: true,
    minDate: DateTime(2024, 10, 1),
    maxDate: DateTime.now().add(const Duration(days: 365)),
    // onRangeSelected: (firstDate, secondDate) {
    //   print('Range selected: $firstDate - $secondDate');
    // },
    // onDayTapped: (date) {
    //   print('Day tapped: $date');
    // },
    // onPreviousMinDateTapped: (date) {
    //   print('Tried to select before minDate: $date');
    // },
    // onAfterMaxDateTapped: (date) {
    //   print('Tried to select after maxDate: $date');
    // },
    weekdayStart: DateTime.sunday,
    initialFocusDate: DateTime(2024, 10),
    initialDateSelected: DateTime(2024, 10, 15),
    endDateSelected: DateTime(2024, 11, 15),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Container( width: double.infinity, height: 500,
                child: ScrollableCleanCalendar(
                  calendarController: calendarController,
                  layout: Layout.BEAUTY, // You can change this to Layout.CLASSIC or Layout.CLEAN if needed
                  calendarCrossAxisSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
