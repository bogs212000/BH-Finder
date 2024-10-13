// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../fetch.dart';
import '../BHouse/bh.screen.dart';
import '../Map/nearme.map.dart';
import '../NearBHouse/bhouse.near.dart';
import '../notification/notification.screen.dart';
import 'package:location/location.dart' as loc;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchText = TextEditingController();
  bool searchActive = false;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  loc.Location location = loc.Location();
  late Position position;
  FocusNode _focusNode = FocusNode();
  User? currentUser = FirebaseAuth.instance.currentUser;
  String search = "";

  @override
  void initState() {
    // fetchBoarderData(setState);
    checkGps();
    checkGPS();
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        searchActive = _focusNode.hasFocus;
      });
    });
  }

  Future checkGPS() async {
    if (!await location.serviceEnabled()) {
      print('Location enabled');
      getLocation();
    }
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print(position.longitude);
    print(position.latitude);

    double long = position.longitude;
    double lat = position.latitude;
    setState(() {
      userLat = position.latitude;
      userLong = position.longitude;
    });
    print('$userLat, $userLong');
    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best, //accuracy of the location data
      distanceFilter: 50, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude as double;
      lat = position.latitude as double;
      lat as double;
      long as double;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              _toNearMeMapScreen(),
              (Route<dynamic> route) => false,
            );
          },
          child: searchActive == false && userLat != null
              ? Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  height: 35,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        // Shadow color with opacity
                        spreadRadius: 1,
                        // Spread radius
                        blurRadius: 1,
                        // Blur radius
                        offset: Offset(0,
                            1), // Position of the shadow (horizontal, vertical)
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_outlined,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                          SizedBox(width: 5),
                          'Street'
                              .text
                              .color(Colors.grey.withOpacity(0.8))
                              .size(12)
                              .bold
                              .make()
                        ],
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ),
        actions: [
          searchActive == false && currentUser != null
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        _toNotificationScreen(),
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
                          Icons.notifications_active_outlined,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          searchActive == false && currentUser != null
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/ChatList');
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
                          Icons.chat_outlined,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          searchActive == false && currentUser != null
              ? Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                     Navigator.pushNamed(context, '/UserProfile');
                     print('hahaha');
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
                          Icons.account_circle_outlined,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              bUuId != null && searchActive == false && currentUser != null
                  ? FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("Rooms")
                          .where('boarderID', isEqualTo: bUuId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error fetching data'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No Reservation found'));
                        }

                        // Use a Column to display the fetched documents instead of ListView
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            cDocId = data['roomDocId'];
                            DateTime boardersIn =
                                DateTime.fromMillisecondsSinceEpoch(
                                    data['boardersIn'].millisecondsSinceEpoch);
                            DateTime boardersOut =
                                DateTime.fromMillisecondsSinceEpoch(
                                    data['boardersOut'].millisecondsSinceEpoch);
                            Duration difference =
                                boardersOut.difference(DateTime.now());
                            int daysLeft = difference.inDays;
                            print(
                                'IN: ${boardersIn.toLocal()}, Days Left: $daysLeft');
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 10),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue[50]),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('Currently Boarding',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300)),
                                        Spacer(),
                                        SizedBox(
                                          height: 25,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/ReceiptScreen');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                  26, 60, 105, 1.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: data['paid?'] == false
                                                ? Text(
                                                    'Pay Now',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : Text(
                                                    'See receipt',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            'Boarding House : ${data['bHouseName']}',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Room : ${data['roomNameNumber']}',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Status : ${data['paid?'] ? "Paid" : "Unpaid"}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: data['paid?']
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                        Spacer(),
                                        'You have $daysLeft days left'
                                            .text
                                            .make()
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(), // Convert the documents to a list of widgets
                        );
                      },
                    )
                  : SizedBox(height: 1),

              Container(
                padding: searchActive == false
                    ? EdgeInsets.all(20)
                    : EdgeInsets.only(left: 20, right: 20),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    searchActive == false
                        ? Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                scale: 5,
                              ),
                            ],
                          )
                        : SizedBox(),
                    searchActive == false
                        ? Row(
                            children: [
                              'Discover your'
                                  .text
                                  .light
                                  .color(Colors.grey)
                                  .size(25)
                                  .make(),
                            ],
                          )
                        : SizedBox(),
                    searchActive == false
                        ? Row(
                            children: [
                              'perfect place to stay'
                                  .text
                                  .bold
                                  .color(Colors.black)
                                  .size(25)
                                  .make(),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                        focusNode: _focusNode,
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Center(
                                  child: Icon(
                                    Icons.filter_list,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelText: 'Search',
                            labelStyle:
                                TextStyle(color: Colors.grey.withOpacity(0.8))),
                      ),
                    ),
                  ],
                ),
              ),
              //List BH
              searchActive == false
                  ? Container(
                      padding: EdgeInsets.only(right: 20, left: 20),
                      color: Colors.white,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 150,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFF31355C),
                                ),
                                child: 'Boarding Houses'
                                    .text
                                    .lg
                                    .size(11)
                                    .center
                                    .color(Colors.white)
                                    .make(),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Container(
                  height: 500,
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: search == null || search == ""
                        ? FirebaseFirestore.instance
                            .collection("BoardingHouses")
                            .where('verified', isEqualTo: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection("BoardingHouses")
                            .where('BoardingHouseName',
                                isGreaterThanOrEqualTo: search)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final datas = snapshot.data?.docs ?? [];
                      return Scaffold(
                        body: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                          child: AlignedGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            itemCount: datas.length,
                            itemBuilder: (context, index) {
                              final data =
                                  datas[index].data() as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    OwnerUuId = data['OwnerUId'];
                                    rBHouseDocId = data['Email'];
                                  });
                                  Navigator.of(context).pushAndRemoveUntil(
                                    _toBhouseScreen(),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  height: 300,
                                  margin: EdgeInsets.all(5),
                                  // Add margin for spacing
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Colors.white),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 220,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset:
                                                            Offset(0, 0.5),
                                                      ),
                                                    ]),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      height: 150,
                                                      decoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                        image:
                                                            DecorationImage(
                                                          image:
                                                              CachedNetworkImageProvider(
                                                                  data[
                                                                      'Image']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      width: double.infinity,
                                                      height: 70,
                                                      decoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                  child: '${data['BoardingHouseName']}'
                                                                      .text
                                                                      .overflow(
                                                                          TextOverflow.ellipsis)
                                                                      .light
                                                                      .make())
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                  child: '${data['address']}'
                                                                      .text
                                                                      .overflow(TextOverflow
                                                                          .ellipsis)
                                                                      .size(
                                                                          10)
                                                                      .color(Colors
                                                                          .grey)
                                                                      .make())
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 10,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 10,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 10,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 10,
                                                              ),
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 10,
                                                              ),
                                                              ' 4.5'
                                                                  .text
                                                                  .size(10)
                                                                  .light
                                                                  .make(),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Route _toSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => SignInScreen(),
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
            child: SignInScreen());
      },
    );
  }

  Route _toBhouseScreen() {
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
            child: BHouseScreen());
      },
    );
  }

  Route _toNotificationScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) =>
          NotificationScreen(),
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
            child: NotificationScreen());
      },
    );
  }

  Route _toNearMeMapScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => BHouseNearMe(),
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
            child: BHouseNearMe());
      },
    );
  }
}
