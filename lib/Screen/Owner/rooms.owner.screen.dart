// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/cons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Home/home.screen.dart';
import 'owner.home.screen.dart';

class RoomsOwnerScreen extends StatefulWidget {
  const RoomsOwnerScreen({super.key});

  @override
  State<RoomsOwnerScreen> createState() => _RoomsOwnerScreenState();
}

class _RoomsOwnerScreenState extends State<RoomsOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    _toHomeScreen(),
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
                      Icons.arrow_back_ios_new,
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
            'Rooms'.text.make(),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/AddRoomsScreen');
                              }, child: 'Add room'.text.make())
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Rooms")
                      .where('uuid', isEqualTo: OwnerUuId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData == true) {
                      return Center(
                          child: CircularProgressIndicator(color: Colors.red));
                    } else if (snapshot.data?.size == 0) {
                      return Center(
                        child: Column(
                          children: [Text('Nothing to fetch here.')],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Something went wrong!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 231, 25, 25),
                            ),
                          )
                        ],
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: SpinKitFadingFour(
                            color: Color(0xFF31355C), size: 50.0),
                      );
                    } else {
                      return ListView(
                        physics: BouncingScrollPhysics(),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          // String? first = data['firstName'];
                          // String? middle = data['middleName'];
                          // String? last = data['lastname'];
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
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
                                        SizedBox(width: 10),
                                        Text("Room name",
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.black,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(width: 5),
                                        Spacer(),
                                        Icon(Icons.edit_note,
                                            color: Colors.grey, size: 25)
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Spacer(),
                                        'Available - '
                                            .text
                                            .size(15)
                                            .light
                                            .make(),
                                        '4.5'.text.size(15).light.make(),
                                        Icon(Icons.star,
                                            color: Colors.yellow, size: 15)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Spacer(),
                                        '1,500 /Month '
                                            .text
                                            .bold
                                            .size(15)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _toHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => OwnerHomeScreen(),
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
            child: OwnerHomeScreen());
      },
    );
  }
}
