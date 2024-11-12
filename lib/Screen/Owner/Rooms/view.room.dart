// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:bh_finder/Screen/Chat/chat.boarders.dart';
import 'package:bh_finder/Screen/Owner/Rooms/edit.room.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:intl/intl.dart';
import '../../../cons.dart';
import '../../BHouse/bh.screen.dart';
import '../list.rooms.screen.dart';
import 'package:http/http.dart' as http;

final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

class ViewRoom extends StatefulWidget {
  final String? viewRoomId, boarderToken;

  const ViewRoom({super.key, this.viewRoomId, this.boarderToken});

  @override
  State<ViewRoom> createState() => _ViewRoomState();
}

class _ViewRoomState extends State<ViewRoom> {
  late Future<DocumentSnapshot> bHouseRoom;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? left;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    bHouseRoom = FirebaseFirestore.instance
        .collection('Rooms')
        .doc(widget.viewRoomId)
        .get();
  }

  @override
  void dispose() {
    super.dispose();
  }

  FirebaseStorage storage = FirebaseStorage.instance;
  String? roomID;

  Future<List<String>> _loadImage() async {
    ListResult result =
        await storage.ref().child("roomImages/${roomID.toString()}").listAll();
    List<String> imageUrls = [];

    for (Reference ref in result.items) {
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<void> _onRefresh() async {
    setState(() {
      bHouseRoom = FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.viewRoomId)
          .get();
    });
    await Future.delayed(
        Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  void sendPushMessage(String body, String title) async {
    try {
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle.loadString(
            'assets/firebase/bh-finder-50ccf-firebase-adminsdk-qu8mx-b15f6f7f15.json'),
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
            'token': widget.boarderToken,
            // Send notification to all users subscribed to this topic
            'notification': {
              'body': body,
              'title': title,
              'image': 'https://firebasestorage.googleapis.com/v0/b/bh-finder-50ccf.appspot.com/o/App%2Fic_launcher.png?alt=media&token=68ac0062-7cd4-4e43-a39f-0e40d612ad01',
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
      body: FutureBuilder<DocumentSnapshot>(
        future: bHouseRoom,
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
          roomID = data['roomDocId'];
          Timestamp? boardersIn = data['boardersIn'];
          Timestamp? boardersOut = data['boardersOut'];
          DateTime boardersInCount = DateTime.fromMillisecondsSinceEpoch(
              data['boardersIn'].millisecondsSinceEpoch);
          DateTime boardersOutCount = DateTime.fromMillisecondsSinceEpoch(
              data['boardersOut'].millisecondsSinceEpoch);
          Duration difference = boardersOutCount.difference(DateTime.now());
          int daysLeft = difference.inDays;
          print('IN: ${boardersInCount.toLocal()}, Days Left: $daysLeft');

          String formattedDateIn = (boardersIn != null)
              ? DateFormat('EEE - MMM d, yyyy').format(boardersIn.toDate())
              : 'No boarders';

          String formattedDateOut = (boardersOut != null)
              ? DateFormat('EEE - MMM d, yyyy').format(boardersOut.toDate())
              : 'No boarders';

          return Stack(
            children: [
              Container(
                height: 450,
                width: double.infinity,
                child: FutureBuilder<List<String>>(
                  future: _loadImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 450,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error loading images"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No images found"));
                    } else {
                      List<String> images = snapshot.data!;

                      return ImageSlideshow(
                        width: double.infinity,
                        height: 450,
                        initialPage: 0,
                        indicatorColor: Colors.blue,
                        // You can customize the indicator color
                        autoPlayInterval: 4000,
                        // Time for auto-sliding in milliseconds (3 seconds)
                        isLoop: true,
                        // Enable looping of the slideshow
                        children: images.map((imageUrl) {
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: 300,
                            height: 450,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.white,
                              child: Container(
                                height: 450,
                                width: 300,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  // Assuming no pull-up loading is needed
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  header: WaterDropMaterialHeader(
                    distance: 30,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 400),
                        Container(
                          padding: EdgeInsets.only(
                              top: 30, left: 20, right: 20, bottom: 0),
                          height: 600,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              '${data['roomNameNumber']}'
                                                  .text
                                                  .bold
                                                  .size(18)
                                                  .make(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            'Price per Month'
                                                .text
                                                .size(10)
                                                .make(),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            '₱ ${data['price']}'
                                                .text
                                                .size(20)
                                                .bold
                                                .make(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  'Description'.text.semiBold.size(16).make(),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: '${data['descriptions']}'
                                          .text
                                          .light
                                          .overflow(TextOverflow.fade)
                                          .maxLines(3)
                                          .color(Colors.grey)
                                          .size(13)
                                          .make(),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              data['boardersName'] == ""
                                  ? 'This room is available and currently unoccupied.'
                                      .text
                                      .make()
                                  : Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              'This room is currently occupied'
                                                  .text
                                                  .bold
                                                  .make(),
                                            ],
                                          ),
                                          Divider(),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    'Days left: '.text.make(),
                                                    Spacer(),
                                                    '$daysLeft Days'
                                                        .text
                                                        .bold
                                                        .size(20)
                                                        .overflow(
                                                            TextOverflow.fade)
                                                        .make(),
                                                    SizedBox(width: 10),
                                                    if (daysLeft < 7)
                                                      SizedBox(
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              try {
                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .loading,
                                                                  title:
                                                                      'Loading...',
                                                                  text:
                                                                      'Please wait',
                                                                );

                                                                // Send notification
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Notifications')
                                                                    .doc()
                                                                    .set({
                                                                  'boarderID': data[
                                                                      'boarderID'],
                                                                  'createdAt':
                                                                      DateTime
                                                                          .now(),
                                                                  'message':
                                                                      'Hi ${data['boardersName']}, we noticed that your rent for room ${data['roomNameNumber']} is still unpaid, and you have less than 7 days remaining in your stay. Please contact the owner as soon as possible to settle your payment.',
                                                                  'status':
                                                                      false,
                                                                });
                                                                String title = '$BhouseName';
                                                                String body = 'Hi ${data['boardersName']}, we noticed that your rent for room ${data['roomNameNumber']} is still unpaid, and you have less than 7 days remaining in your stay. Please contact the owner as soon as possible to settle your payment.';
                                                                sendPushMessage(body, title);
                                                                // Update notification count for the boarder
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(
                                                                        '${data['boarderEmail']}')
                                                                    .update({
                                                                  'notification':
                                                                      FieldValue
                                                                          .increment(
                                                                              1),
                                                                });

                                                                Navigator.pop(
                                                                    context); // Close the loading dialog

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .success,
                                                                  title:
                                                                      'Success!',
                                                                  text:
                                                                      'You successfully notified ${data['boardersName']}.',
                                                                );
                                                              } catch (e) {
                                                                Navigator.pop(
                                                                    context); // Close the loading dialog if there's an error

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type:
                                                                      QuickAlertType
                                                                          .error,
                                                                  title:
                                                                      'Error!',
                                                                  text:
                                                                      'Failed to notify ${data['boardersName']}. Please try again.',
                                                                );

                                                                print(
                                                                    'Error: $e'); // Log the error for debugging
                                                              }
                                                            },
                                                            child: 'Notify'
                                                                .text
                                                                .make(),
                                                          )),
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    'Boarders name: '
                                                        .text
                                                        .make(),
                                                    Spacer(),
                                                    Flexible(
                                                      child:
                                                          '${data['boardersName']} '
                                                              .text
                                                              .overflow(
                                                                  TextOverflow
                                                                      .fade)
                                                              .make(),
                                                    )
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    'Check-in date: '
                                                        .text
                                                        .make(),
                                                    Spacer(),
                                                    Flexible(
                                                      child: '$formattedDateIn '
                                                          .text
                                                          .overflow(
                                                              TextOverflow.fade)
                                                          .make(),
                                                    )
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    'Check-out date: '
                                                        .text
                                                        .make(),
                                                    Spacer(),
                                                    Flexible(
                                                      child:
                                                          '$formattedDateOut '
                                                              .text
                                                              .overflow(
                                                                  TextOverflow
                                                                      .fade)
                                                              .make(),
                                                    )
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    if (data['paid?'] == true)
                                                      'Paid'
                                                          .text
                                                          .color(Colors.green)
                                                          .overflow(
                                                              TextOverflow.fade)
                                                          .make(),
                                                    if (data['paid?'] == false)
                                                      'Not Paid yet'
                                                          .text
                                                          .color(Colors.red)
                                                          .overflow(
                                                              TextOverflow.fade)
                                                          .make(),
                                                    Spacer(),
                                                    if (data['paid?'] == false)
                                                      SizedBox(
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              try {
                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .loading,
                                                                  title:
                                                                      'Loading...',
                                                                  text:
                                                                      'Please wait',
                                                                );

                                                                // Send notification
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Notifications')
                                                                    .doc()
                                                                    .set({
                                                                  'boarderID': data[
                                                                      'boarderID'],
                                                                  'createdAt':
                                                                      DateTime
                                                                          .now(),
                                                                  'message':
                                                                      'Hi ${data['boardersName']}, our records show that your rent for room ${data['roomNameNumber']} is still unpaid. Please reach out to the owner to settle your payment at your earliest convenience.',
                                                                  'status':
                                                                      false,
                                                                });

                                                                String title = '$BhouseName';
                                                                String body = 'Hi ${data['boardersName']}, our records show that your rent for room ${data['roomNameNumber']} is still unpaid. Please reach out to the owner to settle your payment at your earliest convenience.';
                                                                sendPushMessage(body, title);
                                                                // Update notification count for the boarder
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(
                                                                        '${data['boarderEmail']}')
                                                                    .update({
                                                                  'notification':
                                                                      FieldValue
                                                                          .increment(
                                                                              1),
                                                                });

                                                                Navigator.pop(
                                                                    context); // Close the loading dialog

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .success,
                                                                  title:
                                                                      'Success!',
                                                                  text:
                                                                      'You successfully notified ${data['boardersName']}.',
                                                                );
                                                              } catch (e) {
                                                                Navigator.pop(
                                                                    context); // Close the loading dialog if there's an error

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type:
                                                                      QuickAlertType
                                                                          .error,
                                                                  title:
                                                                      'Error!',
                                                                  text:
                                                                      'Failed to notify ${data['boardersName']}. Please try again.',
                                                                );

                                                                print(
                                                                    'Error: $e'); // Log the error for debugging
                                                              }
                                                            },
                                                            child: 'Notify'
                                                                .text
                                                                .make(),
                                                          )),
                                                    SizedBox(width: 10),
                                                    if (data['paid?'] == false)
                                                      SizedBox(
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              try {
                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .loading,
                                                                  title:
                                                                      'Loading...',
                                                                  text:
                                                                      'Please wait',
                                                                );

                                                                // Send notification
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Notifications')
                                                                    .doc()
                                                                    .set({
                                                                  'boarderID': data[
                                                                      'boarderID'],
                                                                  'createdAt':
                                                                      DateTime
                                                                          .now(),
                                                                  'message':
                                                                      'Hi ${data['boardersName']}, thank you for settling your rent!',
                                                                  'status':
                                                                      false,
                                                                });
                                                                String title = '$BhouseName';
                                                                String body = 'Hi ${data['boardersName']}, thank you for settling your rent!';
                                                                sendPushMessage(body, title);
                                                                // Update notification count for the boarder
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Rooms')
                                                                    .doc(
                                                                        '${data['roomDocId']}')
                                                                    .update({
                                                                  'paid?': true,
                                                                });

                                                                Navigator.pop(
                                                                    context); // Close the loading dialog

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
                                                                      .success,
                                                                  title:
                                                                      'Success!',
                                                                  text:
                                                                      '${data['boardersName']} has been paid.',
                                                                );
                                                              } catch (e) {
                                                                Navigator.pop(
                                                                    context); // Close the loading dialog if there's an error

                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type:
                                                                      QuickAlertType
                                                                          .error,
                                                                  title:
                                                                      'Error!',
                                                                  text:
                                                                      'Failed to update ${data['boardersName']} data. Please try again.',
                                                                );

                                                                print(
                                                                    'Error: $e'); // Log the error for debugging
                                                              }
                                                            },
                                                            child: 'Paid'
                                                                .text
                                                                .make(),
                                                          ))
                                                  ],
                                                ),
                                                SizedBox(height: 20)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ListRoomsScreen()),
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(top: 40, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              QuickAlert.show(
                                onCancelBtnTap: () {
                                  Navigator.pop(context);
                                },
                                onConfirmBtnTap: () async {
                                  Navigator.pop(context);
                                  QuickAlert.show(
                                      text: 'Cleaning room',
                                      title: 'Please wait...',
                                      context: (context),
                                      type: QuickAlertType.loading);
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('Rooms')
                                        .doc(data['roomDocId'].toString())
                                        .update({
                                      'boarderEmail': '',
                                      'boarderID': '',
                                      'boardersConNumber': '',
                                      'boardersName': '',
                                      'roomStatus': 'available',
                                    });
                                    Navigator.pop(context);
                                    QuickAlert.show(
                                        text: 'Cleaning successful',
                                        title: 'Cleaning successful',
                                        context: (context),
                                        type: QuickAlertType.success);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                context: context,
                                type: QuickAlertType.confirm,
                                text:
                                    'Would you like to proceed with cleaning the room? This will make it available for others to reserve.',
                                titleAlignment: TextAlign.center,
                                textAlignment: TextAlign.center,
                                confirmBtnText: 'Yes',
                                cancelBtnText: 'No',
                                confirmBtnColor: Colors.blue,
                                backgroundColor: Colors.white,
                                headerBackgroundColor: Colors.grey,
                                confirmBtnTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                titleColor: Colors.black,
                                textColor: Colors.black,
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  size: 17,
                                  Icons.cleaning_services,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40, right: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push( context,
                                MaterialPageRoute(
                                  builder: (context) => ChatBoarders(
                                      token: data['token'],
                                      boarderNumber: data['boardersConNumber'],
                                      boarderEmail: data['boarderEmail'],
                                      ownerToken: ownerToken,
                                      name: data['boardersName'],
                                      bhouseName: data['bHouseName'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  size: 17,
                                  Icons.chat,
                                  color: Colors.white,
                                ),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRoomScreen(
                                        roomId: data['roomDocId'],
                                        roomPrice: data['price'],
                                        roomName: data['roomNameNumber'],
                                        roomDescriptions: data['descriptions'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF31355C),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: 'EDIT ROOM DETAILS'
                                          .text
                                          .size(20)
                                          .color(Colors.white)
                                          .bold
                                          .make()),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Route _toListRoomsScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => ListRoomsScreen(),
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
            child: ListRoomsScreen());
      },
    );
  }
}
