import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../../cons.dart';
import '../owner.home.screen.dart';

class ViewReservationScreen extends StatefulWidget {
  const ViewReservationScreen({Key? key}) : super(key: key);

  @override
  State<ViewReservationScreen> createState() => _ViewReservationScreenState();
}

class _ViewReservationScreenState extends State<ViewReservationScreen> {
  late Future<DocumentSnapshot> reservationData;

  @override
  void initState() {
    super.initState();
    reservationData = FirebaseFirestore.instance
        .collection('Reservations')
        .doc(rBHouseDocId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: reservationData,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No Reservation found'));
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          String formattedCheckInDate = DateFormat('EEE - MMM/d/yyyy')
              .format((data['checkIn'] as Timestamp).toDate());
          String formattedCheckOutDate = DateFormat('EEE - MMM/d/yyyy')
              .format((data['checkOut'] as Timestamp).toDate());
          DateTime checkIn = (data['checkIn'] as Timestamp).toDate();
          DateTime checkOut = (data['checkOut'] as Timestamp).toDate();

          return Scaffold(
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
                            calendarController: CleanCalendarController(
                              readOnly: true,
                              minDate: checkIn,
                              maxDate:
                                  DateTime.now().add(const Duration(days: 130)),
                              weekdayStart: DateTime.sunday,
                              initialFocusDate: checkIn,
                              initialDateSelected: checkIn,
                              endDateSelected:
                                  checkOut, // Automatically setting 1 month later
                            ),
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
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0.3, 0.0),
                                blurRadius: 0.5, // Example blur radius
                                spreadRadius: 0.3, // Example spread radius
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  'Reservation Details'
                                      .text
                                      .bold
                                      .size(15)
                                      .make(),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      FlutterPhoneDirectCaller.callNumber(
                                          '${data['boardersConNumber']}');
                                    },
                                    child: const CircleAvatar(
                                      radius: 15,
                                      child: Icon(
                                        Icons.call,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  'Boarding House :'.text.size(15).light.make(),
                                  const Spacer(),
                                  Flexible(
                                    child: '${data['boardersName']}'
                                        .text
                                        .overflow(TextOverflow.fade)
                                        .size(15)
                                        .light
                                        .make(),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  'Room :'.text.size(15).light.make(),
                                  const Spacer(),
                                  '${data['roomNumber']}'
                                      .text
                                      .size(15)
                                      .light
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  'Check-in date :'.text.size(15).light.make(),
                                  const Spacer(),
                                  formattedCheckInDate.text
                                      .size(15)
                                      .light
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  'Check-out date :'.text.size(15).light.make(),
                                  const Spacer(),
                                  formattedCheckOutDate.text
                                      .size(15)
                                      .light
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  '${data['boardersConNumber']}'
                                      .text
                                      .size(15)
                                      .light
                                      .make(),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  'Message'.text.size(15).semiBold.make(),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: '${data['message']}'
                                          .text
                                          .size(15)
                                          .light
                                          .make(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: 'REJECT'.text.bold.size(15).make(),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  SizedBox(
                                    height: 40,
                                    child:ElevatedButton(
                                      onPressed: () async {
                                        // Show a loading dialog while processing
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.loading,
                                          title: 'Loading',
                                          text: 'Please Wait...',
                                        );

                                        try {
                                          // Update the 'Rooms' collection
                                          await FirebaseFirestore.instance.collection('Rooms').doc('${data['roomId']}').update({
                                            'boarderID': data['boarderUuId'],
                                            'boardersConNumber': data['boardersConNumber'],
                                            'boardersIn': data['checkIn'],
                                            'boardersOut': data['checkOut'],
                                            'boardersName': data['boardersName'],
                                            'totalToPay': '',
                                            'roomStatus': 'unavailable',
                                            'paid?': false,
                                          });

                                          // Add a notification in the 'Notifications' collection
                                          await FirebaseFirestore.instance.collection('Notifications').doc().set({
                                            'createdAt': DateTime.now(),
                                            'message': "Hi ${data['boardersName']}, great news! Your reservation for room ${data['roomNumber']} has been confirmed. You're all set to check in on the expected date. We look forward to welcoming you!",
                                            'boarderID': data['boarderUuId'],
                                            'status': false,
                                          });

                                          // Update the 'read' field for all reservations where boarderUuId is not equal to the given ID
                                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Reservations').where('boarderUuId', isNotEqualTo: data['boarderUuId']).get();

                                          for (QueryDocumentSnapshot doc in querySnapshot.docs) {
                                            await doc.reference.update({
                                              'read': true, // The field and value to update
                                            });
                                          }

                                          // Close the loading dialog
                                          Navigator.pop(context);

                                          // Show a success dialog
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.success,
                                            title: 'Success!',
                                            text: 'The reservation has been successfully accepted.',
                                            onConfirmBtnTap: () {
                                              Navigator.pop(context); // Close the success dialog
                                              Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (context) => OwnerHomeScreen()),
                                                    (Route<dynamic> route) => false, // Remove all previous routes
                                              );
                                            },
                                          );
                                        } on FirebaseAuthException catch (e) {
                                          // Handle authentication errors (e.g., user not authenticated)
                                          Navigator.pop(context); // Close the loading dialog
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            title: 'Error',
                                            text: 'Failed to process the reservation. Please try again.',
                                          );
                                        } catch (e) {
                                          // Handle other potential exceptions
                                          Navigator.pop(context); // Close the loading dialog
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            title: 'Error',
                                            text: 'An unexpected error occurred: $e',
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: 'ACCEPT'.text.bold.size(15).make(),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
