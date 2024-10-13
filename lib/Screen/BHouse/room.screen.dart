// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import '../../cons.dart';
import '../../fetch.dart';
import 'bh.screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late Future<DocumentSnapshot> bHouseRoom;

  @override
  void initState() {
    fetchRoomData(setState);
    super.initState();
    bHouseRoom = FirebaseFirestore.instance
        .collection('Rooms')
        .doc(rRoomsDocId)
        .get();
  }

  @override
  void dispose() {
    super.dispose();
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
          return Stack(
            children: [
              Container(
                height: 450,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                    ), // Replace with your own image URL
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [],
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
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
                                            '${data['bHouseName']}'.text.bold.size(18).make(),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            '${data['address']}'
                                                .text
                                                .light
                                                .color(Colors.grey)
                                                .size(13)
                                                .make(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          'Price per Month'.text.size(10).make(),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          '₱ ${data['price']}'.text.size(20).bold.make(),
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
                              padding: const EdgeInsets.all(8.0),
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
                            Row(
                              children: [
                                'Set a Check-in date'.text.size(18).bold.make(),
                              ],
                            ),
                            EasyDateTimeLine(
                              initialDate: DateTime.now(),
                              onDateChange: (newDate) {
                                setState(() {
                                  selectedDateCheckIn = newDate;
                                });
                                print('$selectedDateCheckIn');
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                'Images'.text.size(18).bold.make(),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 100,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                                                ),
                                                // Replace with your own image URL
                                                fit: BoxFit.cover,
                                              ),
                                              boxShadow: [],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                              Navigator.of(context).pushAndRemoveUntil(
                                _toBHouseScreen(),
                                    (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.grey, width: 0.3),
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
                                  User? currentUser =
                                      FirebaseAuth.instance.currentUser;

                                  if (currentUser == null ||
                                      currentUser.email == null ||
                                      currentUser.email!.isEmpty) {
                                    QuickAlert.show(
                                      onCancelBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirmBtnTap: () {
                                        Navigator.pushNamed(context, '/SignInScreen');
                                      },
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      text: 'Do you want to sign in first?',
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
                                  } else if(data['roomStatus'] == 'unavailable' ){
                                    QuickAlert.show(
                                      onCancelBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirmBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      context: context,
                                      type: QuickAlertType.info,
                                      text: 'Room is currently unavailable as it is occupied by a guest at the moment.',
                                      titleAlignment: TextAlign.center,
                                      textAlignment: TextAlign.center,
                                      confirmBtnText: 'Ok',
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
                                  } else if(data['roomStatus'] == 'unavailable' && data['boarderID'] == bUuId){
                                    QuickAlert.show(
                                      onCancelBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirmBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      context: context,
                                      type: QuickAlertType.info,
                                      text: 'You are currently renting this room.',
                                      titleAlignment: TextAlign.center,
                                      textAlignment: TextAlign.center,
                                      confirmBtnText: 'Ok',
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
                                  } else {
                                    setState(() {
                                      BhouseName = data['bHouseName'];
                                      roomPrice = data['price'];
                                      roomNumber = data['roomNameNumber'];
                                    });
                                    Navigator.pushNamed(
                                        context, '/BoarderReservationScreen');
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF31355C),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: 'Reserve Now'
                                          .text
                                          .size(20)
                                          .color(Colors.white)
                                          .bold
                                          .make()),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Center(
                                child: Icon(
                                  Icons.call,
                                  color: Colors.blueAccent,
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
          );
        },
      ),
    );
  }

  Route _toBHouseScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => BHouseScreen(),
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
            textDirection: TextDirection.rtl,
            child: BHouseScreen());
      },
    );
  }
}
