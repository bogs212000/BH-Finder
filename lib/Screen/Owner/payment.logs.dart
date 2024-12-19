import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../../cons.dart';
import '../Home/home.screen.dart';
import 'owner.home.screen.dart';

class PaymentLogs extends StatefulWidget {
  const PaymentLogs({super.key,});


  @override
  State<PaymentLogs> createState() => _PaymentLogsState();
}

class _PaymentLogsState extends State<PaymentLogs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Payment logs")
              .where('ownerUid',
              isEqualTo:
              ownerID.toString()).orderBy('createdAt', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        height: 100,
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
                        height: 100,
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
                                child: '${data['boardersName']}'
                                    .text.bold.overflow(TextOverflow.fade)
                                    .color(Colors.black)
                                    .make(),
                              ),
                            ],
                          ),
                          Row(children: [
                            'Paid : ₱${data['price']} '.text.make(),
                          ],),
                          Row(
                            children: [
                              '$formattedDate'
                                  .text
                                  .size(12)
                                  .light
                                  .color(Colors.grey)
                                  .make(),
                              Spacer(),
                              data['contactNumber'].toString()
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
            // textDirection: TextDirection.rtl,
            child: OwnerHomeScreen());
      },
    );
  }
}
