import 'dart:convert';
import 'dart:io';

import 'package:bh_finder/Screen/Chat/chat.boarders.dart';
import 'package:bh_finder/Screen/Owner/new/new.nav.owner.dart';
import 'package:bh_finder/Screen/Owner/owner.nav.dart';
import 'package:bh_finder/Screen/Owner/reservation/view.user.dart';
import 'package:bh_finder/assets/fonts.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../../api.dart';
import '../../../cons.dart';
import '../owner.home.screen.dart';
import 'package:http/http.dart' as http;

final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

class ViewReservationScreen extends StatefulWidget {
  final String? token;
  final String? bName;

  const ViewReservationScreen({Key? key, this.token, this.bName})
      : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: ''.text.bold.blue800.make(),
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
            body: Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(AppImages.logo, height: 30),
                      'Info'.text.fontFamily(AppFonts.quicksand).make(),
                    ],
                  ),
                  'Before proceeding with renting, please ensure to thoroughly check the details and verify the user.'
                      .text
                      .fontFamily(AppFonts.quicksand)
                      .bold
                      .size(10)
                      .make(),
                  // Image.asset(AppImages.calendar, height: 100),
                  20.heightBox,
                  Row(
                    children: [
                      'Reservation Details'.text.bold.size(15).make(),
                      Spacer(),
                      userRole == 'Boarder'
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () async {
                                Get.to(() => ViewUser(), arguments: [
                                  data['boarderEmail'],
                                  data['boarderUuId']
                                ]);
                              },
                              child: const CircleAvatar(
                                radius: 15,
                                child: Icon(
                                  Icons.person,
                                  size: 15,
                                ),
                              ),
                            ),
                      10.widthBox,
                      userRole == 'Boarder'
                          ? SizedBox()
                          : GestureDetector(
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
                      'Name :'.text.size(15).light.make(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ViewUser(), arguments: [
                            data['boarderEmail'],
                            data['boarderUuId']
                          ]);
                        },
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
                      '${data['roomNumber']}'.text.size(15).light.make(),
                    ],
                  ),
                  Row(
                    children: [
                      'Check-in date :'.text.size(15).light.make(),
                      const Spacer(),
                      formattedCheckInDate.text.size(15).light.make(),
                    ],
                  ),
                  Row(
                    children: [
                      'Check-out date :'.text.size(15).light.make(),
                      const Spacer(),
                      formattedCheckOutDate.text.size(15).light.make(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      '${data['boardersConNumber']}'.text.size(15).light.make(),
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
                              borderRadius: BorderRadius.circular(10)),
                          child:
                              '${data['message']}'.text.size(15).light.make(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  userRole == 'Boarder'
                      ? SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            data['status'] == 'rejected'
                                ? 'Reservation has been rejected.'
                                    .text
                                    .color(Colors.red)
                                    .make()
                                : SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.loading,
                                          title: 'Loading',
                                          text: 'Please Wait...',
                                        );
                                        await FirebaseFirestore.instance
                                            .collection('Reservations')
                                            .doc(data['docID'])
                                            .update({
                                          'status': 'canceled',
                                        });
                                        //increment notification
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(data['boarderEmail'])
                                            .update({
                                          'notification':
                                              FieldValue.increment(1),
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('Notifications')
                                            .doc()
                                            .set({
                                          'createdAt': DateTime.now(),
                                          'message':
                                              "Hi ${data['boardersName']}, unfortunately, we regret to inform you that your reservation for room ${data['roomNumber']} has been rejected. If you have any questions or need assistance, please don't hesitate to reach out. - ${widget.bName}",
                                          'boarderID': data['boarderUuId'],
                                          'status': false,
                                        });
                                        String title = '$BhouseName';
                                        String body =
                                            "Hi ${data['boardersName']}, unfortunately, we regret to inform you that your reservation for room ${data['roomNumber']} has been rejected. If you have any questions or need assistance, please don't hesitate to reach out. - ${widget.bName}";
                                        sendPushMessage(body, title);
                                        Navigator.pop(context);

                                        // Show a success dialog
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.success,
                                          title: 'Success!',
                                          text:
                                              'The reservation has been rejected',
                                          onConfirmBtnTap: () {
                                            Navigator.pop(
                                                context); // Close the success dialog
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewOwnerNav()),
                                              (Route<dynamic> route) =>
                                                  false, // Remove all previous routes
                                            );
                                          },
                                        );
                                      },
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
                            if (data['status'] == 'accepted')
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
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
                                      await FirebaseFirestore.instance
                                          .collection('Rooms')
                                          .doc('${data['roomId']}')
                                          .update({
                                        'boarderID': '',
                                        'boardersConNumber': '',
                                        'boardersIn': '',
                                        'boardersOut': '',
                                        'boardersName': '',
                                        'totalToPay': '',
                                        'roomStatus': 'available',
                                        'paid?': false,
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('Reservations')
                                          .doc(data['docID'])
                                          .update({
                                        'status': 'canceled',
                                      });

                                      //increment notification
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(data['boarderEmail'])
                                          .update({
                                        'notification': FieldValue.increment(1),
                                      });

                                      // Add a notification in the 'Notifications' collection
                                      await FirebaseFirestore.instance
                                          .collection('Notifications')
                                          .doc()
                                          .set({
                                        'createdAt': DateTime.now(),
                                        'message':
                                            "Hi ${data['boardersName']}, unfortunately, we regret to inform you that your reservation for room ${data['roomNumber']} has been canceled. If you have any questions or need assistance, please don't hesitate to reach out. - ${widget.bName}",
                                        'boarderID': data['boarderUuId'],
                                        'status': false,
                                      });
                                      String title = '$BhouseName';
                                      String body =
                                          "HHi ${data['boardersName']}, unfortunately, we regret to inform you that your reservation for room ${data['roomNumber']} has been canceled. If you have any questions or need assistance, please don't hesitate to reach out. - ${widget.bName}";
                                      sendPushMessage(body, title);
                                      Navigator.pop(context);

                                      // Show a success dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: 'Success!',
                                        text:
                                            'The reservation has been successfully canceled',
                                        onConfirmBtnTap: () {
                                          Navigator.pop(
                                              context); // Close the success dialog
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OwnerNav()),
                                            (Route<dynamic> route) =>
                                                false, // Remove all previous routes
                                          );
                                        },
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      // Handle authentication errors (e.g., user not authenticated)
                                      Navigator.pop(
                                          context); // Close the loading dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error',
                                        text:
                                            'Failed to process the reservation. Please try again.',
                                      );
                                    } catch (e) {
                                      // Handle other potential exceptions
                                      Navigator.pop(
                                          context); // Close the loading dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error',
                                        text:
                                            'An unexpected error occurred: $e',
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
                                  child: 'CANCEL'.text.bold.size(15).make(),
                                ),
                              ),
                            if (data['status'] == 'pending')
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
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
                                      await FirebaseFirestore.instance
                                          .collection('Rooms')
                                          .doc('${data['roomId']}')
                                          .update({
                                        'boarderToken': data['token'],
                                        'boarderID': data['boarderUuId'],
                                        'boardersConNumber':
                                            data['boardersConNumber'],
                                        'boardersIn': data['checkIn'],
                                        'boardersOut': data['checkOut'],
                                        'boardersName': data['boardersName'],
                                        'totalToPay': '',
                                        'roomStatus': 'unavailable',
                                        'paid?': false,
                                        'boarderEmail': data['boarderEmail']
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('Reservations')
                                          .doc(data['docID'])
                                          .update({
                                        'status': 'accepted',
                                      });

                                      //increment notification
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(data['boarderEmail'])
                                          .update({
                                        'notification': FieldValue.increment(1),
                                      });

                                      // Add a notification in the 'Notifications' collection
                                      await FirebaseFirestore.instance
                                          .collection('Notifications')
                                          .doc()
                                          .set({
                                        'createdAt': DateTime.now(),
                                        'message':
                                            "Hi ${data['boardersName']}, great news! Your reservation for room ${data['roomNumber']} has been confirmed. You're all set to check in on the expected date. We look forward to welcoming you! - ${widget.bName}",
                                        'boarderID': data['boarderUuId'],
                                        'status': false,
                                      });
                                      String title = '$BhouseName';
                                      String body =
                                          "Hi ${data['boardersName']}, great news! Your reservation for room ${data['roomNumber']} has been confirmed. You're all set to check in on the expected date. We look forward to welcoming you! - ${widget.bName}";
                                      sendPushMessage(body, title);
                                      // Update the 'read' field for all reservations where boarderUuId is not equal to the given ID
                                      QuerySnapshot querySnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('Reservations')
                                              .where('roomId',
                                                  isEqualTo: data['roomId'])
                                              .where('boarderUuId',
                                                  isNotEqualTo:
                                                      data['boarderUuId'])
                                              .get();

                                      for (QueryDocumentSnapshot doc
                                          in querySnapshot.docs) {
                                        await doc.reference.update({
                                          'status': 'rejected',
                                          // The field and value to update
                                        });
                                      }

                                      // Close the loading dialog
                                      Navigator.pop(context);

                                      // Show a success dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: 'Success!',
                                        text:
                                            'The reservation has been successfully accepted.',
                                        onConfirmBtnTap: () {
                                          Navigator.pop(
                                              context); // Close the success dialog
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OwnerNav()),
                                            (Route<dynamic> route) =>
                                                false, // Remove all previous routes
                                          );
                                        },
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      // Handle authentication errors (e.g., user not authenticated)
                                      Navigator.pop(
                                          context); // Close the loading dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error',
                                        text:
                                            'Failed to process the reservation. Please try again.',
                                      );
                                    } catch (e) {
                                      // Handle other potential exceptions
                                      Navigator.pop(
                                          context); // Close the loading dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error',
                                        text:
                                            'An unexpected error occurred: $e',
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
                            if (data['status'] == 'canceled')
                              'Reservations has been canceled'.text.make(),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
