// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/BordersReservation/boarder.reservation.screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import '../../cons.dart';
import '../../fetch.dart';
import '../Loading/loading.bhouse.screen.dart';
import 'bh.screen.dart';

class RoomScreen extends StatefulWidget {
  final String? token;

  const RoomScreen({super.key, this.token});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late Future<DocumentSnapshot> bHouseRoom;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String? room;

  @override
  void initState() {
    fetchBoarderData(setState);
    fetchRoomData(setState);
    super.initState();
    bHouseRoom =
        FirebaseFirestore.instance.collection('Rooms').doc(rRoomsDocId).get();
  }

  Future<void> _onRefresh() async {
    fetchBoarderData(setState);
    fetchRoomData(setState);
    setState(() {
      bHouseRoom =
          FirebaseFirestore.instance.collection('Rooms').doc(rRoomsDocId).get();
    });
    await Future.delayed(
        Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  @override
  void dispose() {
    super.dispose();
  }

  FirebaseStorage storage = FirebaseStorage.instance;
  String? docID;

  Future<List<String>> _loadImage() async {
    ListResult result =
        await storage.ref().child("roomImages/${docID.toString()}").listAll();
    List<String> imageUrls = [];

    for (Reference ref in result.items) {
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { Get.back();
      // Navigate back using GetX
      return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: bHouseRoom,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingBHouseScreen();
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No Reservation found'));
            }
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            docID = data['roomDocId'];
            room = data['roomDocId'];
            return Stack(
              children: [
                Container(
                  height: 450,
                  width: double.infinity,
                  child: FutureBuilder<List<String>>(
                    future: _loadImage(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          child: Container(
                            height: 450,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error loading images"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No images found"));
                      } else {
                        List<String> images = snapshot.data!;
                        return ImageSlideshow(
                          width: double.infinity,
                          height: 450,
                          initialPage: 0,
                          indicatorColor: Colors.blue,
                          // You can customize the indicator color
                          autoPlayInterval: 4000,
                          // Time for auto-sliding in milliseconds (3 seconds)
                          isLoop: true,
                          // Enable looping of the slideshow
                          children: images.map((imageUrl) {
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: 300,
                              height: 450,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.white,
                                child: Container(
                                  height: 450,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    // Assuming no pull-up loading is needed
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    header: WaterDropMaterialHeader(
                      distance: 30,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 400),
                          Container(
                            padding: EdgeInsets.only(
                                top: 30, left: 20, right: 20, bottom: 0),
                            height: 500,
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
                                                '${data['roomNameNumber']}'
                                                    .text
                                                    .bold
                                                    .size(18)
                                                    .make(),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                '${data['address']}'
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              'Price per Month'
                                                  .text
                                                  .size(10)
                                                  .make(),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              '₱ ${data['price']}'
                                                  .text
                                                  .size(20)
                                                  .bold
                                                  .make(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
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
                                        child: '${data['descriptions']}'
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
                                    'Set a Check-in date'
                                        .text
                                        .size(18)
                                        .bold
                                        .make(),
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
                              ],
                            ),
                          )
                        ],
                      ),
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
                      Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      CollectionReference collectionRef =
                                          FirebaseFirestore.instance
                                              .collection('Reservations');

                                      // Query to find the document where 'boarderUuId' equals the user ID and 'roomId' equals the room
                                      QuerySnapshot querySnapshot =
                                          await collectionRef
                                              .where('boarderEmail',
                                                  isEqualTo: FirebaseAuth
                                                      .instance.currentUser?.email
                                                      .toString())
                                              .where('roomId', isEqualTo: room)
                                              .where('status',
                                                  isEqualTo: 'pending')
                                              .get();

                                      // Check if the document exists
                                      if (querySnapshot.docs.isNotEmpty) {
                                        // Display alert that a reservation request already exists
                                        QuickAlert.show(
                                          onCancelBtnTap: () {
                                            FirebaseFirestore.instance
                                                .collection('Reservations')
                                                .where('boarderEmail',
                                                    isEqualTo: FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.email
                                                        ?.toLowerCase())
                                                .where('roomId', isEqualTo: room)
                                                .where('status',
                                                    isEqualTo: 'pending')
                                                .get()
                                                .then((querySnapshot) {
                                              for (var doc
                                                  in querySnapshot.docs) {
                                                doc.reference.update({
                                                  // Add the fields you want to update here
                                                  'status': 'canceled',
                                                });
                                              }
                                            }).catchError((error) {
                                              print(
                                                  "Failed to update documents: $error");
                                            });
                                            Navigator.pop(context);

                                            QuickAlert.show(
                                              text: 'Your reservation has been successfully canceled.',
                                                context: context,
                                                type: QuickAlertType.success,
                                                onConfirmBtnTap: () {
                                                  Navigator.pop(context);
                                                });
                                          },
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          text:
                                              "You have already submitted a reservation request. Would you like to cancel it?",
                                          titleAlignment: TextAlign.center,
                                          textAlignment: TextAlign.center,
                                          confirmBtnText: 'No',
                                          cancelBtnText: 'Yes',
                                          confirmBtnColor: Colors.blue,
                                        );
                                      } else {
                                        User? currentUser =
                                            FirebaseAuth.instance.currentUser;

                                        if (currentUser == null ||
                                            currentUser.email == null ||
                                            currentUser.email!.isEmpty) {
                                          // If the user is not signed in, prompt them to sign in
                                          QuickAlert.show(
                                            onCancelBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            onConfirmBtnTap: () {
                                              Navigator.pushNamed(
                                                  context, '/SignInScreen');
                                            },
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            text: 'Do you want to sign in first?',
                                            titleAlignment: TextAlign.center,
                                            textAlignment: TextAlign.center,
                                            confirmBtnText: 'Yes',
                                            cancelBtnText: 'No',
                                            confirmBtnColor: Colors.blue,
                                          );
                                        } else if (data['roomStatus'] ==
                                            'unavailable') {
                                          // If the room is unavailable, show an alert
                                          QuickAlert.show(
                                            onCancelBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            onConfirmBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            context: context,
                                            type: QuickAlertType.info,
                                            text:
                                                'Room is currently unavailable as it is occupied by a guest at the moment.',
                                            titleAlignment: TextAlign.center,
                                            textAlignment: TextAlign.center,
                                            confirmBtnText: 'Ok',
                                            confirmBtnColor: Colors.blue,
                                          );
                                        } else if (bUuId == data['boarderID'] &&
                                            currentUser != null) {
                                          // If the user is already renting the room, notify them
                                          QuickAlert.show(
                                            onCancelBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            onConfirmBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            context: context,
                                            type: QuickAlertType.info,
                                            text:
                                                'You are currently renting this room.',
                                            titleAlignment: TextAlign.center,
                                            textAlignment: TextAlign.center,
                                            confirmBtnText: 'Ok',
                                            confirmBtnColor: Colors.blue,
                                          );
                                        } else {
                                          Get.to(()=>BoarderReservationScreen(), arguments: [Get.arguments[0]]);
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           BoarderReservationScreen(
                                          //         token: Get.arguments[0],
                                          //       ),
                                          //     ));
                                          setState(() {
                                            BhouseName = data['bHouseName'];
                                            roomPrice = data['price'];
                                            roomNumber = data['roomNameNumber'];
                                            roomId = data['roomDocId'];
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      // Handle any errors that occur during Firestore operations
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: 'Error',
                                        text:
                                            'Something went wrong. Please try again later.',
                                        confirmBtnColor: Colors.red,
                                        confirmBtnText: 'Ok',
                                      );
                                      print(
                                          'Error fetching document: $e'); // Log the error for debugging
                                    }
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
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
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
