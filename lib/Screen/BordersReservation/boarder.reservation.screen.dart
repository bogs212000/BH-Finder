import 'dart:convert';

import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/reservation/reservation.success.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../../api.dart';
import '../../cons.dart';
import '../../fetch.dart';
import '../BHouse/room.screen.dart';
import 'package:http/http.dart' as http;

final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

class BoarderReservationScreen extends StatefulWidget {
  final String? token;

  const BoarderReservationScreen({super.key, this.token});

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
    fetchBoarderData(setState);
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

  void sendPushMessage(String body, String title) async {
    try {
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle
            .loadString('assets/firebase/${Api.notifications}'),
      );

      final client =
          await clientViaServiceAccount(serviceAccountCredentials, _scopes);
      final accessToken = client.credentials.accessToken.data;

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/bh-finder-50ccf/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': widget.token,
            // Send notification to all users subscribed to this topic
            'notification': {
              'body': body,
              'title': title,
              'image':
                  'https://firebasestorage.googleapis.com/v0/b/bh-finder-50ccf.appspot.com/o/App%2Fic_launcher.png?alt=media&token=68ac0062-7cd4-4e43-a39f-0e40d612ad01',
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'body': body, // Include additional data if needed
              'title': title,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully to all users');
      } else {
        print(
            'Failed to send push notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print("Error sending push notification: $e");
    }
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
        : WillPopScope(
            onWillPop: () async {
              Get.back();
              // Navigate back using GetX
              return false; // Prevent default back button behavior
            },
            child: Scaffold(
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
                                 Get.back();
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
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3),
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
                                              'Room :'
                                                  .text
                                                  .size(15)
                                                  .light
                                                  .make(),
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
                                                fillColor: Colors.grey
                                                    .withOpacity(0.1),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                            onTap: () async {
                                              String docID = Uuid().v4();
                                              QuickAlert.show(
                                                context: context,
                                                type: QuickAlertType.loading,
                                                title: 'Pleas wait...',
                                                text:
                                                    'Reserving room on process.',
                                              );
                                              try {
                                                // Query to find the document where 'boarderUuId' equals the user ID and 'roomId' equals the room
                                                QuerySnapshot querySnapshot =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Rooms')
                                                        .where('boarderID',
                                                            isEqualTo: bUuId)
                                                        .get();

                                                // Check if the document exists
                                                if (querySnapshot
                                                    .docs.isNotEmpty) {
                                                  Navigator.pop(context);
                                                  // Display alert that a reservation request already exists
                                                  QuickAlert.show(
                                                    onCancelBtnTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    onConfirmBtnTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    context: context,
                                                    type: QuickAlertType.info,
                                                    text:
                                                        "You are currently renting a room right now!",
                                                    titleAlignment:
                                                        TextAlign.center,
                                                    textAlignment:
                                                        TextAlign.center,
                                                    confirmBtnText: 'Ok',
                                                    confirmBtnColor:
                                                        Colors.blue,
                                                  );
                                                } else {
                                                  try {
                                                    String title = 'BH Finder';
                                                    String body =
                                                        'Someone wants to rent or reserve a room, check it now!';
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'Reservations')
                                                        .doc('$docID')
                                                        .set({
                                                      'createdAt':
                                                          DateTime.now(),
                                                      'docID': docID,
                                                      'roomNumber': roomNumber,
                                                      'status': 'pending',
                                                      'OwnerId': OwnerUuId,
                                                      'boarderUuId': bUuId,
                                                      'boarderEmail':
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.email
                                                              .toString(),
                                                      'roomId': roomId,
                                                      'message': _message.text,
                                                      'checkIn': checkIn,
                                                      'checkOut': checkOut,
                                                      'boardersName':
                                                          '$fName $mName $lName',
                                                      'boardersConNumber':
                                                          '$bPhoneNumber',
                                                      'boarderAddress': '',
                                                      'read': false,
                                                      'token': myToken,
                                                    });
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'Notifications')
                                                        .doc()
                                                        .set({
                                                      'boarderID': OwnerUuId,
                                                      'createdAt':
                                                          DateTime.now(),
                                                      'message':
                                                          '$fName $mName $lName want to reserve or rent Room $roomNumber',
                                                      'status': true
                                                    });
                                                    sendPushMessage(
                                                        body, title);
                                                    QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType
                                                          .success,
                                                      title:
                                                          'Room reserved successfully!',
                                                      text:
                                                          'Kindly review your reservation status on the homepage.',
                                                      onConfirmBtnTap: () {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  HomeScreen()), // Change NextScreen() to your desired screen
                                                        );
                                                      },
                                                    );
                                                  } on FirebaseAuthException catch (e) {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    print(e);
                                                  }
                                                }
                                              } catch (e) {
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
