// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:bh_finder/Screen/Owner/rooms.owner.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../fetch.dart';
import '../BHouse/bh.screen.dart';
import '../Map/nearme.map.dart';
import '../notification/notification.screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  TextEditingController _searchText = TextEditingController();
  bool searchActive = false;
  FocusNode _focusNode = FocusNode();


  @override
  void initState() {
    fetchOwnerData(setState);
    fetchOwnerBhouseData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        searchActive = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              _toNearMeMapScreen(),
              (Route<dynamic> route) => false,
            );
          },
          child: Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            height: 35,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 0.3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  // Shadow color with opacity
                  spreadRadius: 1,
                  // Spread radius
                  blurRadius: 1,
                  // Blur radius
                  offset: Offset(
                      0, 1), // Position of the shadow (horizontal, vertical)
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
        ),
        actions: [
          searchActive == false
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        _toNotificationScreen(),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
              FirebaseAuth.instance.signOut();
              },
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.login,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                              ), // Replace with your own image URL
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [],
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    '$BhouseName'.text.bold.size(20).make(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    '$currentEmail'.text.bold.size(4).color(Colors.grey).make(),
                                    Spacer(),
                                    Icon(Icons.edit_note, color: Colors.grey, size: 25)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20, left: 20),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: allRooms == null ? '0'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.red[400])
                              .make(): '$allRooms'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.blue)
                              .make(),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: roomAvailable == null ? '0'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.red[400])
                              .make(): '$roomAvailable'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.green[400])
                              .make(),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: roomUnavailable == null ? '0'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.red[400])
                              .make(): '$roomUnavailable'
                              .text
                              .bold
                              .size(25)
                              .center
                              .color(Colors.red[400])
                              .make(),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                _toRoomsOwnerScreen(),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 5, top: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFF31355C),
                                ),
                                child: 'Rooms'
                                    .text
                                    .lg
                                    .size(11)
                                    .center
                                    .color(Colors.white)
                                    .make(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 5, top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF31355C),
                              ),
                              child: 'Available'
                                  .text
                                  .lg
                                  .size(11)
                                  .center
                                  .color(Colors.white)
                                  .make(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 5, top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF31355C),
                              ),
                              child: 'Unavailable'
                                  .text
                                  .lg
                                  .size(8)
                                  .center
                                  .color(Colors.white)
                                  .make(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    //find nearby
                    Row(
                      children: [
                        'Reservations'
                            .text
                            .bold
                            .size(20)
                            .center
                            .color(Colors.black)
                            .make()
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 500,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              'Room 1 reservation'
                                                  .text
                                                  .bold
                                                  .size(15)
                                                  .make(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              'Mang Juan reserved room #'
                                                  .text
                                                  .color(Colors.grey)
                                                  .make(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              'Oct 2, 2024 - Wed - 12:21 PM'
                                                  .text.size(12)
                                                  .light
                                                  .color(Colors.grey)
                                                  .make(),
                                            ],
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector( onTap: (){
                                    Navigator.pushNamed(context, '/ViewReservationScreen');
                                  },
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'View', // Rating
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _toBhouseScreen() {
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
            child: BHouseScreen());
      },
    );
  }

  Route _toNotificationScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) =>
          NotificationScreen(),
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
            child: NotificationScreen());
      },
    );
  }

  Route _toRoomsOwnerScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => RoomsOwnerScreen(),
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
            child: RoomsOwnerScreen());
      },
    );
  }

  Route _toNearMeMapScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => NearMeMapScreen(),
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
            child: NearMeMapScreen());
      },
    );
  }
}
