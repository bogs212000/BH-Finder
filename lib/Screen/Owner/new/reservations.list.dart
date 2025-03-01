import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import '../../../assets/images.dart';
import '../../../cons.dart';
import '../reservation/reservation.view.screen.dart';
import '../reservation/view.dart';

class ReservationListOwner extends StatefulWidget {
  const ReservationListOwner({super.key});

  @override
  State<ReservationListOwner> createState() => _ReservationListOwnerState();
}

class _ReservationListOwnerState extends State<ReservationListOwner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 'Reservations'.text.bold.make(),
        backgroundColor: Colors.white,
      ),
      body: VxBox(
          child: Column(
            children: [
              SizedBox(child: Image.asset(AppImages.calendar, height: 150,),),
              Expanded(
                  child: VxBox(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Reservations")
                          .where('OwnerId',
                          isEqualTo: ownerID)
                          .where('status',
                          isEqualTo: 'pending')
                          .orderBy('createdAt',
                          descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // Check if the snapshot has an error
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Something went wrong!",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 150,
                                  child: Row(children: [
                                    Expanded(
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.white,
                                        child: Container(
                                          height: 500,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.white,
                                        child: Container(
                                          height: 500,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]),
                                )
                              ],
                            ),
                          );
                        }

                        if (snapshot.data?.size == 0) {
                          return const Center(
                            child: Text('Nothing to fetch here.'),
                          );
                        }

                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          // Use the length of the fetched data
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = snapshot.data!.docs[index]
                                .data()! as Map<String, dynamic>;
                            String? roomUuId = data['roomDocId'];
                            Timestamp timestamp = data['createdAt'];
                            DateTime date = timestamp.toDate();
                            String formattedDate =
                            DateFormat('EEE - MMM d, yyyy').format(date);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rBHouseDocId = data['docID'];
                                });
                                print(rBHouseDocId);
                                Get.to(()=>OwnerViewReservationScreen());
                              },
                              child: Padding(
                                padding:
                                const EdgeInsets.only( right: 20, left: 20),
                                child: Container(
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  '${data['roomNumber']}'
                                                      .text
                                                      .bold
                                                      .size(15)
                                                      .make(),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  '${data['boardersName']}'
                                                      .text
                                                      .color(Colors.grey)
                                                      .make(),
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
                                                  Spacer(),
                                                  if (data['status'] == 'rejected')
                                                    'rejected'
                                                        .text
                                                        .color(Colors.red)
                                                        .size(10)
                                                        .make(),
                                                  if (data['status'] == 'pending')
                                                    'Pending'
                                                        .text
                                                        .color(Colors.grey)
                                                        .size(10)
                                                        .make(),
                                                  if (data['status'] == 'accepted')
                                                    'Accepted'
                                                        .text
                                                        .color(Colors.green)
                                                        .size(10)
                                                        .make(),
                                                  if (data['status'] == 'rejected')
                                                    'Rejected'
                                                        .text
                                                        .color(Colors.red)
                                                        .size(10)
                                                        .make(),
                                                  if (data['status'] == 'canceled')
                                                    'Canceled'
                                                        .text
                                                        .color(Colors.red)
                                                        .size(10)
                                                        .make(),
                                                ],
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ).make())
            ],
          ))
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
