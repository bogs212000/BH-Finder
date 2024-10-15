import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/reservation/reservation.success.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../../cons.dart';
import '../BHouse/room.screen.dart';

class BoarderReservationScreen extends StatefulWidget {
  const BoarderReservationScreen({super.key});

  @override
  State<BoarderReservationScreen> createState() =>
      _BoarderReservationScreenState();
}

class _BoarderReservationScreenState extends State<BoarderReservationScreen> {
  late CleanCalendarController calendarController;
  TextEditingController _message = TextEditingController();
  DateTime? checkIn;
  DateTime? checkOut;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    DateTime checkInDate = selectedDateCheckIn;
    DateTime checkOutDate = checkInDate.add(const Duration(days: 30));
    setState(() {
      checkIn = checkInDate;
      checkOut = checkOutDate;
    });
    print('$checkIn - $checkOut');
    calendarController = CleanCalendarController(
      readOnly: true,
      minDate: checkInDate,
      maxDate: DateTime.now().add(const Duration(days: 365)),
      weekdayStart: DateTime.sunday,
      initialFocusDate: checkInDate,
      initialDateSelected: checkInDate,
      endDateSelected: checkOutDate, // Automatically setting 1 month later
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedCheckInDate = checkIn != null
        ? DateFormat('EEE - MMM/d/yyyy').format(checkIn!)
        : 'N/A';
    String formattedCheckOutDate = checkOut != null
        ? DateFormat('EEE - MMM/d/yyyy').format(checkOut!)
        : 'N/A';
    return loading
        ? LoadingScreen()
        : Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: 500,
                          child: ScrollableCleanCalendar(
                            calendarController: calendarController,
                            layout: Layout.BEAUTY,
                            // You can change this to Layout.CLASSIC or Layout.CLEAN if needed
                            calendarCrossAxisSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 40, left: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  _toRoomScreen(),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(top: 40, right: 20),
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.support_agent,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/BoarderReservationScreen');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(0.3, 0.0),
                                          blurRadius:
                                              0.5, // Example blur radius
                                          spreadRadius:
                                              0.3, // Example spread radius
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        'Confirmation'
                                            .text
                                            .bold
                                            .size(20)
                                            .make(),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            'Boarding House :'
                                                .text
                                                .size(15)
                                                .light
                                                .make(),
                                            Spacer(),
                                            '$BhouseName'
                                                .text
                                                .size(15)
                                                .light
                                                .make(),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            'Room :'.text.size(15).light.make(),
                                            Spacer(),
                                            '$roomNumber'
                                                .text
                                                .size(15)
                                                .light
                                                .make(),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            'Check-in date : '
                                                .text
                                                .size(15)
                                                .light
                                                .make(),
                                            Spacer(),
                                            '$formattedCheckInDate'
                                                .text
                                                .size(12)
                                                .light
                                                .make(),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            'Check-out date : '
                                                .text
                                                .size(15)
                                                .light
                                                .make(),
                                            Spacer(),
                                            '$formattedCheckOutDate'
                                                .text
                                                .size(12)
                                                .light
                                                .make(),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            'Total to Pay : '
                                                .text
                                                .size(15)
                                                .semiBold
                                                .make(),
                                            Spacer(),
                                            '₱ $roomPrice'
                                                .text
                                                .size(18)
                                                .bold
                                                .color(Colors.green)
                                                .make(),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5, bottom: 5),
                                          child: TextField(
                                            controller: _message,
                                            keyboardType: TextInputType.name,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  Colors.grey.withOpacity(0.1),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.white),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              labelText: 'Message(Optional)',
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            String docID = Uuid().v4();
                                            try {
                                              setState(() {
                                                loading = true;
                                              });
                                              FirebaseFirestore.instance
                                                  .collection('Reservations')
                                                  .doc('$docID')
                                                  .set({
                                                'createdAt': DateTime.now(),
                                                'docID': docID,
                                                'roomNumber': roomNumber,
                                                'status': false,
                                                'OwnerId': OwnerUuId,
                                                'boarderUuId': bUuId,
                                                'roomId': roomId,
                                                'message': _message.text,
                                                'checkIn': checkIn,
                                                'checkOut': checkOut,
                                                'boardersName':
                                                    '$fName $mName $lName',
                                                'boardersConNumber':
                                                    '$bPhoneNumber',
                                                'boarderAddress': '',
                                              });
                                              setState(() {
                                                loading = false;
                                              });
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReservationSuccess()), // Change NextScreen() to your desired screen
                                              );
                                            } on FirebaseAuthException catch (e) {
                                              setState(() {
                                                loading = false;
                                              });
                                              print(e);
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green[50],
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.green,
                                                  offset: Offset(0.5, 0.0),
                                                  blurRadius: 0.5,
                                                  // Example blur radius
                                                  spreadRadius:
                                                      1.0, // Example spread radius
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                'RESERVE'
                                                    .text
                                                    .bold
                                                    .color(Colors.green)
                                                    .size(20)
                                                    .make()
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }

  Route _toRoomScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => RoomScreen(),
      transitionDuration: Duration(milliseconds: 1000),
      reverseTransitionDuration: Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
            parent: animation,
            reverseCurve: Curves.fastOutSlowIn,
            curve: Curves.fastLinearToSlowEaseIn);

        return SlideTransition(
            position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                .animate(animation),
            child: RoomScreen());
      },
    );
  }
}
