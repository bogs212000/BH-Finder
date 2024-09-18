// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'bh.screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
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
                                        'Room 1'.text.bold.size(18).make(),
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
                              width: 35,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3),
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
                                    Icons.pin_drop_outlined,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            'Description'.text.semiBold.size(16).make(),
                          ],
                        ),
                        'BH Room means an area that is designed and constructed to be occupied by one or more persons.'
                            .text
                            .light
                            .color(Colors.grey)
                            .size(13)
                            .make(),

                        //List rooms
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
                                        height: 80,
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
                        )
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
