import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../Home/home.screen.dart';

class NotificationScreen extends StatefulWidget {
  final String? boardersID;
  const NotificationScreen({super.key, this.boardersID});
  
  
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
                        (Route<dynamic> route) =>
                    false,
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
            'Notification'.text.make(),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Notifications")
              .where('boarderID',
              isEqualTo:
              widget.boardersID.toString())
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
              return Center(
                child: Lottie.asset('assets/lottie/animation_loading.json',
                    width: 100, height: 100),
              );
            }
            if (snapshot.data?.size == 0) {
              return const Center(
                child: Text('No notifications yet!'),
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
                Timestamp timestamp = data['createdAt'];
                DateTime date = timestamp.toDate();
                String formattedDate =
                DateFormat('EEE - MMM d, yyyy : hh:mm aa').format(date);
                return GestureDetector(
                  onTap: () {
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, right: 20, left: 20),
                    child:   Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: '${data['message']}'
                                    .text.overflow(TextOverflow.fade)
                                    .color(Colors.black)
                                    .make(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              '$formattedDate'
                                  .text
                                  .size(12)
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
                );
              }).toList(),
            );
          },
        ),
      ),
    );
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
            // textDirection: TextDirection.rtl,
            child: HomeScreen());
      },
    );
  }
}
