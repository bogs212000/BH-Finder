// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:bh_finder/Screen/BHouse/room.screen.dart';
import 'package:bh_finder/Screen/Chat/chat.owner.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../cons.dart';
import '../../fetch.dart';
import '../Loading/loading.bhouse.screen.dart';
import '../Map/location.map.dart';
import '../SignUp/guest.screen.dart';

class BHouseScreen extends StatefulWidget {
  const BHouseScreen({super.key}); // Rating value (0.0 to 5.0)

  @override
  State<BHouseScreen> createState() => _BHouseScreenState();
}

class _BHouseScreenState extends State<BHouseScreen> {
  late Future<DocumentSnapshot> bHouseData;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  double? rating;

  @override
  void initState() {
    fetchBhouseData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);
    super.initState();
    bHouseData = FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc(rBHouseDocId)
        .get();
  }

  Future<void> _onRefresh() async {
    fetchBhouseData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);
    setState(() {
      bHouseData = FirebaseFirestore.instance
          .collection('BoardingHouses')
          .doc(rBHouseDocId)
          .get();
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
  String? ownerId;

  Future<List<String>> _loadImage() async {
    ListResult result = await storage
        .ref()
        .child("BHouseImages/${ownerId.toString()}")
        .listAll();
    List<String> imageUrls = [];

    for (Reference ref in result.items) {
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: bHouseData,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingBHouseScreen();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No Reservation found'));
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          ownerId = data['OwnerUId'];
          print(ownerId);
          List<dynamic> ratings = data['ratings'];
          double average = ratings.reduce((a, b) => a + b) / ratings.length;
          double star = average;
          double clampedRating = star.clamp(0.0, 5.0);
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
                                              '$BhouseName'
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
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade200,
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Container(
                                                          height: 20,
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                    ); // Show loading spinner while fetching data
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error fetching data')); // Handle error
                                                  } else if (snapshot.hasData) {
                                                    final int
                                                        roomCountAvailable =
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
                                                future:
                                                    fetchRoomsWithOwnersID(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade200,
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Container(
                                                          height: 20,
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                    ); // Show loading spinner while fetching data
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error fetching data')); // Handle error
                                                  } else if (snapshot.hasData) {
                                                    final int
                                                        roomCountAvailable =
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
                                        setState(() {
                                          bHouseLat = data['Lat'];
                                          bHouseLong = data['Long'];
                                        });
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
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
                              Row(
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
                              ),
                              SizedBox(height: 20),
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
                                          Map<String, dynamic> data =
                                              snapshot.data!.docs[index].data()!
                                                  as Map<String, dynamic>;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  rRoomsDocId =
                                                      data['roomDocId'];
                                                });
                                                print('room ID: $roomId');

                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                  _toRoomsScreen(),
                                                  (Route<dynamic> route) =>
                                                      false,
                                                );
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
                                                            data['roomImage'] ??
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
                                                              '${data['roomNameNumber']}',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            Text(
                                                              data[
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
                                                                '₱ ${data['price'] ?? '---'} per month',
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
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 20,
                                                              ),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                data['rating']
                                                                        ?.toString() ??
                                                                    '4.8',
                                                                // Use data for rating
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
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
                              if (currentUser != null) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  _toHomeScreen(),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                Navigator.of(context).pushAndRemoveUntil(
                                  _toGuestScreen(),
                                  (Route<dynamic> route) => false,
                                );
                              }
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
                        currentUser != null
                            ? Padding(
                                padding: EdgeInsets.only(top: 40, right: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      ownerEmail = data['Email'].toString();
                                      bHouse =
                                          data['BoardingHouseName'].toString();
                                    });
                                    print('$ownerEmail, $bHouse');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatOwner(
                                          ownerNumber: data['PhoneNumber'].toString(), // pass the owner number here
                                        ),
                                      ),
                                    );

                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.chat_outlined,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
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

  Route _toGuestScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => GuestScreen(),
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
            child: GuestScreen());
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
