// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/Chat/chat.owner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../assets/fonts.dart';
import '../../assets/images.dart';
import '../../cons.dart';
import '../Home/home.screen.dart';
import '../Owner/list.rooms.screen.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              80.heightBox,
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                        child: VxBox(child: Image.asset(HomeImages.communication))
                            .white
                            .make()),
                    Expanded(
                      child: VxBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                'Chat'.text.size(30).blue900.bold.make(),
                              ],
                            ),
                            Row(
                              children: [
                                ' with Owner'
                                    .text
                                    .fontFamily(AppFonts.quicksand)
                                    .size(20)
                                    .bold
                                    .make(),
                              ],
                            ),
                            10.heightBox,
                          ],
                        ),
                      ).white.make(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Chats")
                      .where('email',
                          isEqualTo:
                              FirebaseAuth.instance.currentUser!.email.toString())
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Somthing went wrong!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 231, 25, 25),
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.data?.size == 0) {
                      return Center(
                        child: Text('No messages yet!'),
                      );
                    }
                    Row(children: const [
                      TextField(
                        decoration: InputDecoration(),
                      )
                    ]);
                    return ListView(
                      physics: snapshot.data!.size <= 4
                          ? NeverScrollableScrollPhysics()
                          : BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 0),
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 20, right: 20, top: 5),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                ownerEmail = data['ownerEmail'].toString();
                                bHouse = data['bHouse'];
                                btoken = data['ownerToken'];
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatOwner(
                                    emailOwner: data['ownerEmail'],
                                    ownerNumber: data['ownerNumber'],
                                    token: data['ownerToken'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shadowColor: Color.fromARGB(255, 34, 34, 34),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 0.5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ProfilePicture(
                                          name: '${data['bHouse']}',
                                          radius: 25,
                                          fontsize: 25,
                                        ),
                                        SizedBox(width: 5),
                                        data['seenOwner?'] == true ?
                                        Text(
                                          data['bHouse'].toString(),
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w200),
                                        ) :
                                        Text(
                                          data['bHouse'].toString(),
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Route _toHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => HomeScreen(),
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
            child: HomeScreen());
      },
    );
  }
}
