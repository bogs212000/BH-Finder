// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';
import 'package:bh_finder/Auth/auth.wrapper.dart';
import 'package:bh_finder/Screen/Home/guest.home.screen.dart';
import 'package:bh_finder/Screen/Loading/home.loading.screen.dart';
import 'package:bh_finder/Screen/Owner/BHouseProfile/bhouse.profile.dart';
import 'package:bh_finder/Screen/Owner/reservation/reservation.view.screen.dart';
import 'package:bh_finder/Screen/Owner/rooms.owner.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../fetch.dart';
import '../BHouse/bh.screen.dart';
import 'package:http/http.dart' as http;
import 'Map/location.dart';
import 'owner.notification.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  late Future<DocumentSnapshot> ownersBHouseData;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? myEmail = FirebaseAuth.instance.currentUser?.email.toString();
  TextEditingController _searchText = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool searchActive = false;
  FocusNode _focusNode = FocusNode();
  int? chat;

  @override
  void initState() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ownersBHouseData = FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    fetchOwnerData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);

    _focusNode.addListener(() {
      setState(() {
        searchActive = _focusNode.hasFocus;
      });
    });

    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    super.initState();
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      saveToken(token); // Save the token to your Firestore or your server
      // Subscribe the user to a topic
    } else {
      print("Failed to get FCM token");
    }
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      'token': token,
    });
    await FirebaseFirestore.instance
        .collection("BoardingHouses")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      'token': token,
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _onRefresh() async {
    fetchRoomData(setState);
    fetchOwnerData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);
    setState(() {
      ownersBHouseData = FirebaseFirestore.instance
          .collection('BoardingHouses')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .get();
    });
    await Future.delayed(
        Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
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
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('BoardingHouses')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.white.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching data'));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('No data found'));
                    }
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    addressLat = data['Lat'];
                    addressLong = data['Long'];
                    bHouse = data['BoardingHouseName'];
                    OwnerPhone = data['PhoneNumber'];
                    ownerID = data['OwnerUId'];
                    chat = data['chat'];

                    return Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        data['Image']),
                                    // Replace with your own image URL
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [],
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(onTap: (){
                                            setState(() {
                                              selectedIndex = 3;
                                            });
                                          },
                                            child: '${data['BoardingHouseName']}'
                                                .text
                                                .bold
                                                .size(20)
                                                .make(),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          '${data['Email']}'
                                              .text
                                              .bold
                                              .size(4)
                                              .color(Colors.grey)
                                              .make(),
                                          Spacer(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    padding:  EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade500, Colors.green.shade800],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bed, color: Colors.white, size: 30),
                            '  Rooms'.text.bold.color(Colors.white).size(20).make(),
                            Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/ListRoomsScreen'),
                              child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                            ),
                          ],
                        ),
                        // All Rooms Section
                        _buildRoomInfo(context, 'All Rooms',
                            fetchRoomsWithOwnersID(), '/ListRoomsScreen'),
                        const SizedBox(height: 5),
                        // Available Rooms Section
                        _buildRoomInfo(context, 'Available Rooms',
                            fetchRoomsAvailable(), null),
                        const SizedBox(height: 5),
                        // Unavailable Rooms Section
                        _buildRoomInfo(context, 'Unavailable Rooms',
                            fetchRoomsUnavailable(), null),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 500, // Specify height for the tab container
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          // TabBar
                          TabBar(
                            tabs: [
                              'Reservations'.text.bold.make(),
                              'Reviews'.text.bold.make(),
                            ],
                          ),

                          // Expanded TabBarView to take up remaining space
                          Expanded(
                            child: TabBarView(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 20, left: 20),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Container(
                                        height: 400,
                                        width: double.infinity,
                                        child: StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection("Reservations")
                                              .where('OwnerId',
                                                  isEqualTo: OwnerUuId)
                                              .where('status',
                                                  isEqualTo: 'pending')
                                              .orderBy('createdAt',
                                                  descending: true)
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
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
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Column(
                                                children: [
                                                  Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade200,
                                                    highlightColor: Colors.white
                                                        .withOpacity(0.3),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20),
                                                      child: Container(
                                                        height: 50,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade200,
                                                    highlightColor: Colors.white
                                                        .withOpacity(0.3),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20),
                                                      child: Container(
                                                        height: 50,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            if (snapshot.data?.size == 0) {
                                              return Center(
                                                child: Text(
                                                    'Nothing to fetch here.'),
                                              );
                                            }

                                            return ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              // Use the length of the fetched data
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> data =
                                                    snapshot.data!.docs[index]
                                                            .data()!
                                                        as Map<String, dynamic>;
                                                String? roomUuId =
                                                    data['roomDocId'];
                                                Timestamp timestamp =
                                                    data['createdAt'];
                                                DateTime date =
                                                    timestamp.toDate();
                                                String formattedDate =
                                                    DateFormat(
                                                            'EEE - MMM d, yyyy')
                                                        .format(date);

                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      rBHouseDocId =
                                                          data['docID'];
                                                    });
                                                    print(rBHouseDocId);
                                                    Navigator.push(
                                                        context,
                                                    MaterialPageRoute(
                                                        builder: (context) => ViewReservationScreen(
                                                          token: data['token'], bName: data['BoardingHouseName'],
                                                        )));
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: Container(
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              color:
                                                                  Colors.white,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      '${data['roomNumber']}'
                                                                          .text
                                                                          .bold
                                                                          .size(
                                                                              15)
                                                                          .make(),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      '${data['boardersName']}'
                                                                          .text
                                                                          .color(
                                                                              Colors.grey)
                                                                          .make(),
                                                                    ],
                                                                  ),
                                                                  if (data[
                                                                          'status'] ==
                                                                      'pending')
                                                                    Row(
                                                                      children: [
                                                                        'Pending'
                                                                            .text
                                                                            .color(Colors.grey)
                                                                            .size(10)
                                                                            .make(),
                                                                      ],
                                                                    ),
                                                                  if (data[
                                                                          'status'] ==
                                                                      'accepted')
                                                                    Row(
                                                                      children: [
                                                                        'Accepted'
                                                                            .text
                                                                            .color(Colors.green)
                                                                            .size(10)
                                                                            .make(),
                                                                      ],
                                                                    ),
                                                                  if (data[
                                                                          'status'] ==
                                                                      'rejected')
                                                                    Row(
                                                                      children: [
                                                                        'Rejected'
                                                                            .text
                                                                            .color(Colors.red)
                                                                            .size(10)
                                                                            .make(),
                                                                      ],
                                                                    ),
                                                                  if (data[
                                                                          'status'] ==
                                                                      'canceled')
                                                                    Row(
                                                                      children: [
                                                                        'Canceled'
                                                                            .text
                                                                            .color(Colors.red)
                                                                            .size(10)
                                                                            .make(),
                                                                      ],
                                                                    ),
                                                                  Row(
                                                                    children: [
                                                                      '$formattedDate'
                                                                          .text
                                                                          .size(
                                                                              12)
                                                                          .light
                                                                          .color(
                                                                              Colors.grey)
                                                                          .make(),
                                                                    ],
                                                                  ),
                                                                  Divider(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'View',
                                                                  // Rating
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                  ),
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
                                      )
                                    ],
                                  ),
                                ),

                                //Reservations
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("BoardingHouses")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.email
                                          .toString())
                                      .collection('reviews')
                                      .orderBy('createdAt', descending: true)
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
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingShimmer();
                                    }

                                    if (snapshot.data?.size == 0) {
                                      return Center(
                                        child: Text('No reviews yet.'),
                                      );
                                    }

                                    return ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> data =
                                            snapshot.data!.docs[index].data()!
                                                as Map<String, dynamic>;
                                        String name = data['name'];
                                        Timestamp timestamp = data['createdAt'];
                                        DateTime date = timestamp.toDate();
                                        String formattedDate =
                                            DateFormat('EEE - MMM d, yyyy')
                                                .format(date);

                                        // Mask the name for privacy
                                        String maskedName = _formatName(name);

                                        return _buildReviewTile(
                                            maskedName,
                                            formattedDate,
                                            data['reviews'],
                                            data['rate']);
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

  }






    void _showToast() async {
      print('Showing Toast'); // Debugging
      SmartDialog.showToast(
        'This is a test toast message.',
      );
    }

    void _getLocationSuc() async {
      print('Showing Toast'); // Debugging
      SmartDialog.showToast(
        maskColor: Colors.green,
        'Success fetching location.',
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
            OwnerNotificationScreen(),
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
              child: OwnerNotificationScreen());
        },
      );
    }

    Route _toRoomsOwnerScreen() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation) =>
            RoomsOwnerScreen(),
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
              child: RoomsOwnerScreen());
        },
      );
    }

    Route _toMapScreen() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation) => BHouseAddress(),
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
              child: BHouseAddress());
        },
      );
    }
  }

// Method to mask the user's name
String _formatName(String name) {
  List<String> parts = name.split(' ');

  if (parts.isEmpty) return ''; // Return empty if no parts
  if (parts.length == 1) return parts[0]; // Return if only first name

  String formattedName = parts[0]; // Always show the first name

  // If there are more parts, add a masked version of the last name
  if (parts.length > 1) {
    formattedName += ' ${parts[1][0]}.';
  }

  return formattedName; // Ensure to return the formatted name
}




  // Loading shimmer for when data is loading
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.2),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildRoomInfo(
      BuildContext context, String label, Future<int> future, String? route) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200.withOpacity(0.5),
            highlightColor: Colors.white.withOpacity(0.3),
            child: Container(
              height: 30,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (snapshot.hasData) {
          final int roomCount = snapshot.data ?? 0;
          return Row(
            children: [
              Text(
                roomCount.toString(),
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white),
              ),
              Text(
                ' - $label',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Spacer(),

            ],
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

// Method to create a review tile
Widget _buildReviewTile(String name, String date, String review, double rate) {
  return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        padding: EdgeInsets.all(10),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      name.text.light
                          .overflow(TextOverflow.ellipsis)
                          .size(12)
                          .make(),
                      Spacer(),
                      date.text.size(10).light.color(Colors.grey).make(),
                    ],
                  ),
                  SizedBox(height: 5),
                  review.text.size(15).overflow(TextOverflow.ellipsis).make(),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = 0; i < rate.toInt(); i++)
                        Icon(Icons.star, color: Colors.amber, size: 15),
                      for (int i = 0; i < 5 - rate.toInt(); i++)
                        Icon(Icons.star_border, color: Colors.amber, size: 15),
                      SizedBox(width: 5),
                      '$rate'.text.size(10).light.make(),
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
}
