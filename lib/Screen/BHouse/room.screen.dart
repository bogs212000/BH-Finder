// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
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


  @override
  void initState() {
    fetchRoomData(setState);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                                        '$roomNumber'.text.bold.size(18).make(),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        'Street'
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
                                      '₱ $roomPrice'.text.size(20).bold.make(),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],                      ),
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
                                child: '$roomDescriptions'
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
                    Padding(
                      padding: EdgeInsets.only(top: 40, right: 20),
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
                            Icons.support_agent,
                            size: 20,
                            color: Colors.white,
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
                          child: GestureDetector( onTap: (
                              ){
                            Navigator.pushNamed(context, '/BoarderReservationScreen');
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
