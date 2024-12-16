// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:bh_finder/Screen/BHouse/room.screen.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../cons.dart';
import '../../fetch.dart';
import '../Auth/auth.wrapper.dart';
import '../Screen/Map/location.map.dart';
import 'admin.home.dart';

class AdminBHouseScreen extends StatefulWidget {
  const AdminBHouseScreen({super.key});

  @override
  State<AdminBHouseScreen> createState() => _AdminBHouseScreenState();
}

class _AdminBHouseScreenState extends State<AdminBHouseScreen> {
  late Future<DocumentSnapshot> bHouseData;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    bHouseData = FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc(rBHouseDocId)
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
        future: bHouseData,
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
          List<dynamic> ratings = data['ratings'];
          double average = ratings.reduce((a, b) => a + b) / ratings.length;
          double star = average;
          double clampedRating = star.clamp(0.0, 5.0);
          return Stack(
            children: [
              Container(
                height: 450,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        data['Image']), // Replace with your own image URL
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
                        height: 700,
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
                                            '${data['BoardingHouseName']}'
                                                .text
                                                .bold
                                                .size(18)
                                                .make(),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            'Available room : '
                                                .text
                                                .light
                                                .size(15)
                                                .make(),
                                            FutureBuilder<int>(
                                              future: fetchRoomsAvailable(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator()); // Show loading spinner while fetching data
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error fetching data')); // Handle error
                                                } else if (snapshot.hasData) {
                                                  final int roomCountAvailable =
                                                      snapshot.data ??
                                                          0; // Get the count of rooms with the OwnersID
                                                  return roomCountAvailable ==
                                                          null
                                                      ? '0'
                                                          .text
                                                          .bold
                                                          .size(25)
                                                          .center
                                                          .color(
                                                              Colors.red[400])
                                                          .make()
                                                      : '$roomCountAvailable'
                                                          .text
                                                          .light
                                                          .color(Colors.green)
                                                          .size(15)
                                                          .make();
                                                } else {
                                                  return Center(
                                                      child: Text(
                                                          'No data available'));
                                                }
                                              },
                                            ),
                                            FutureBuilder<int>(
                                              future: fetchRoomsWithOwnersID(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator()); // Show loading spinner while fetching data
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error fetching data')); // Handle error
                                                } else if (snapshot.hasData) {
                                                  final int roomCountAvailable =
                                                      snapshot.data ??
                                                          0; // Get the count of rooms with the OwnersID
                                                  return roomCountAvailable ==
                                                          null
                                                      ? '0'
                                                          .text
                                                          .bold
                                                          .size(25)
                                                          .center
                                                          .color(
                                                              Colors.red[400])
                                                          .make()
                                                      : '/$roomCountAvailable'
                                                          .text
                                                          .light
                                                          .color(Colors.green)
                                                          .size(15)
                                                          .make();
                                                } else {
                                                  return Center(
                                                      child: Text(
                                                          'No data available'));
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (currentUser != null) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/ReviewSectionScreen',
                                                    arguments: data['Email'],
                                                  );
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children:
                                                    List.generate(5, (index) {
                                                  if (index <
                                                      clampedRating.toInt()) {
                                                    // Filled star
                                                    return const Icon(
                                                        Icons.star,
                                                        color: Colors.amber);
                                                  } else if (index <
                                                      clampedRating) {
                                                    // Half star
                                                    return const Icon(
                                                        Icons.star_half,
                                                        color: Colors.amber);
                                                  } else {
                                                    // Empty star
                                                    return const Icon(
                                                        Icons.star_border,
                                                        color: Colors.amber);
                                                  }
                                                }),
                                              ),
                                            ),
                                            ' - $average'.text.light.make(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 35,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        _toLocationScreen(),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
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
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                'Description'.text.semiBold.size(16).make(),
                              ],
                            ),
                            data['Rules'] == ''
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: '${data['Rules']}'
                                            .text
                                            .light
                                            .overflow(TextOverflow.fade)
                                            .maxLines(3)
                                            .color(Colors.grey)
                                            .size(13)
                                            .make(),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                'Owner info'.text.light.make(),
                              ],
                            ),
                            Divider(),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(data['Email'])
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade200,
                                    highlightColor: Colors.white,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Container(
                                        height: 35,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error fetching data'));
                                }
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Center(
                                      child: Text('No Reservation found'));
                                }
                                Map<String, dynamic> datas = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          '${datas['FirstName']} ${datas['MiddleName']} ${datas['LastName']}'
                                              .text
                                              .bold
                                              .make(),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          '${datas['Email']}'.text.bold.make(),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          '${datas['PhoneNumber']}'
                                              .text
                                              .bold
                                              .make(),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          '${datas['OwnerUId']}'
                                              .text
                                              .bold
                                              .make(),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: InteractiveViewer(
                                                      child: CachedNetworkImage(
                                                        imageUrl: datas['ImageID']!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 100,
                                              child: CachedNetworkImage(
                                                imageUrl: datas['ImageID'],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          GestureDetector(
                                            onTap: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: InteractiveViewer(
                                                      child: CachedNetworkImage(
                                                        imageUrl: datas['ImageIdPermit']!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 100,
                                              child: CachedNetworkImage(
                                                imageUrl: datas['ImageIdPermit'],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                );
                              },
                            ),
                            Divider(),
                            Row(
                              children: [
                                'Rooms'.text.semiBold.size(16).make(),
                              ],
                            ),

                            //List rooms
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("Rooms")
                                      .where('ownerUid', isEqualTo: OwnerUuId)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    // Check if the snapshot has an error
                                    if (snapshot.hasError) {
                                      return Center(
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

                                    // Show loading spinner while waiting for data
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Column(
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade200,
                                            highlightColor: Colors.white,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Container(
                                                height: 90,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade200,
                                            highlightColor: Colors.white,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Container(
                                                height: 90,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    // Show message if no data is found
                                    if (snapshot.data?.size == 0) {
                                      return Center(
                                        child: Text('Nothing to fetch here.'),
                                      );
                                    }

                                    // Data is available, display it
                                    return ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: snapshot.data!.docs.length,
                                      // Use the length of the fetched data
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> datas =
                                        snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                rRoomsDocId =
                                                datas['roomDocId'];
                                              });
                                              print('room ID: $roomId');
                                              Get.to(()=>RoomScreen(), arguments: [data['token']]);
                                              // Navigator.pushNamedAndRemoveUntil(
                                              //   context,
                                              //   '/RoomScreen',
                                              //       (Route<dynamic> route) => false, // Remove all previous routes
                                              //   arguments: {
                                              //     'token': data['token'],
                                              //   },
                                              // );
                                              print(data['token']);
                                            },
                                            child: Container(
                                              height: 90,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 90,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          datas['roomImage'] ??
                                                              'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            '${datas['roomNameNumber']}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            datas[
                                                            'roomStatus'],
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .orangeAccent,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w300,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 110,
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .end,
                                                          children: [
                                                            Text(
                                                              '₱ ${datas['price'] ?? '---'} per month',
                                                              style:
                                                              TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
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
                                _toHomeScreen(),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
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
                  ],
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
                                _toHomeScreen(),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
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
                    data['verified'] != true
                        ? Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        QuickAlert.show(
                                          onCancelBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                          onConfirmBtnTap: () async {
                                            Navigator.pop(context);
                                            QuickAlert.show(
                                                context: context,
                                                type: QuickAlertType.loading,
                                                title: 'Loading...',
                                                text: 'Please wait');
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('BoardingHouses')
                                                  .doc('${data['Email']}')
                                                  .update({
                                                'verified': true,
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc('${data['Email']}')
                                                  .update({
                                                'verified': true,
                                              });
                                              Navigator.pop(context);
                                              QuickAlert.show(
                                                  barrierDismissible: true,
                                                  context: (context),
                                                  type: QuickAlertType.success,
                                                  title: 'Verified',
                                                  text:
                                                      'Boarding House has been verified',
                                                  onConfirmBtnTap: () {
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AuthWrapper(),
                                                      ),
                                                      (Route<dynamic> route) =>
                                                          false, // Removes all previous routes
                                                    );
                                                  });
                                            } on FirebaseAuthException catch (e) {
                                              print(e);
                                              Navigator.pop(context);
                                              QuickAlert.show(
                                                  context: (context),
                                                  type: QuickAlertType.error,
                                                  title: 'Error',
                                                  text: '$e');
                                            }
                                          },
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          text: 'Verify this Boarding House.',
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
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                26, 60, 105, 1.0),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: 'Verify'
                                                .text
                                                .size(20)
                                                .color(Colors.white)
                                                .bold
                                                .make()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Route _toHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => AdminHomeScreen(),
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
            child: AdminHomeScreen());
      },
    );
  }

  Route _toRoomsScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => RoomScreen(),
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
            child: RoomScreen());
      },
    );
  }

  Route _toLocationScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => LocationScreen(),
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
            child: LocationScreen());
      },
    );
  }
}
