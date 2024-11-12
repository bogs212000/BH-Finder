// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/Chat/chat.boarders.dart';
import 'package:bh_finder/Screen/Chat/chat.owner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';
import '../Home/home.screen.dart';

class OwnerChatList extends StatefulWidget {
  const OwnerChatList({super.key});

  @override
  State<OwnerChatList> createState() => _OwnerChatListState();
}

class _OwnerChatListState extends State<OwnerChatList> {
  String? myEmail = FirebaseAuth.instance.currentUser?.email.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Chats")
                .where('ownerEmail',
                    isEqualTo:
                        FirebaseAuth.instance.currentUser!.email.toString())
                .orderBy('createdAt', descending: true)
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
                        const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          boardersEmail = data['email'].toString();
                          bHouse = data['bHouse'];
                          chatName = data['name'];
                        });
                        await FirebaseFirestore.instance
                            .collection('BoardingHouses')
                            .doc(myEmail)
                            .update({'chat': 0});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatBoarders(
                                    boarderNumber:
                                        data['boarderNumber'].toString(),
                                    token: data['myToken'],
                                    ownerToken: data['ownerToken'],
                                    boarderEmail: data['email'],
                                    name: data['name'],
                                    bhouseName: data['bHouse'],
                                  )),
                        );
                      },
                      child: Card(
                        shadowColor: Color.fromARGB(255, 34, 34, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
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
                                    name: '${data['name']}',
                                    radius: 25,
                                    fontsize: 25,
                                  ),
                                  SizedBox(width: 5),
                                  data['seenBorder?'] == true
                                      ? Text(
                                          data['name'].toString(),
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w200),
                                        )
                                      : Text(
                                          data['name'].toString(),
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
