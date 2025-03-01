import 'package:bh_finder/Auth/auth.wrapper.dart';
import 'package:bh_finder/Screen/BHouse/room.cache.dart';
import 'package:bh_finder/Screen/Chat/chat.list.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/PrivacyPolicy/privacy.policy.dart';
import 'package:bh_finder/Screen/Profile/user.profile.dart';
import 'package:bh_finder/Screen/Search/search.screen.dart';
import 'package:bh_finder/Screen/TermsAndConditons/terms.conditions.dart';
import 'package:bh_finder/Screen/about/about.screen.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../../cons.dart';
import '../../fetch.dart';
import '../../main.dart';
import '../UserGuide/UsersGuide.dart';
import '../notification/notification.screen.dart';
import 'new.home.dart';

class NavHome extends StatefulWidget {
  @override
  _NavHomeState createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  int _selectedIndex = 0;
  bool _isRefreshed = false;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> notification;
  List<Widget> tabItems = [
    Home(),
    ChatList(),
    SearchScreen(),
    UserProfile(),
  ];

  @override
  void initState() {
    loadSharedPrefs();
    print('room cache $roomCache');
    fetchBoarderData(setState);
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (userEmail != null) {
      notification =
          FirebaseFirestore.instance.collection('Users').doc(userEmail).get();
    }

    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    FirebaseMessaging.instance.subscribeToTopic("Users");

    super.initState();

  }

  Future<void> loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roomCache = prefs.getString('roomCache') ?? ''; // Handle null case
    });
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      saveToken(token); // Save the token to your Firestore or your server
      // Subscribe the user to a topic
      FirebaseMessaging.instance.subscribeToTopic("Users");
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

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return
      roomCache != '' ? RoomCache() :
    Scaffold(
      backgroundColor: Colors.transparent,
      // drawer: Drawer(
      //   backgroundColor: Colors.white,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       SizedBox(height: 40),
      //       const Row(children: [
      //         SizedBox(width: 10),
      //         Text(
      //           "BH Finder",
      //           style: TextStyle(
      //               fontSize: 20.0,
      //               color: Colors.blueAccent,
      //               letterSpacing: 1.0,
      //               fontWeight: FontWeight.bold),
      //         ),
      //       ]),
      //
      //       //profile
      //       ListTile(
      //         contentPadding: EdgeInsets.only(left: 20),
      //         leading:
      //             Icon(Icons.person_outline, size: 30, color: Colors.black),
      //         title: const Text('Profile',
      //             style: TextStyle(
      //                 fontWeight: FontWeight.bold, color: Colors.black)),
      //         onTap: () {},
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppImages.logo, height: 50),
            ' BH FINDER'.text.size(20).extraBold.blue900.make(),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          currentUser != null && userEmail != null
              ? StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userEmail)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching data'));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          border:
                          Border.all(color: Colors.grey, width: 0.3),
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
                        child: const Center(
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser?.email
                                  .toString())
                              .update({
                            'notification': 0,
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen(
                                      boardersID: bUuId,
                                    )),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3),
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
                              child: const Center(
                                child: Icon(
                                  Icons.notifications_active_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            data['notification'] != 0
                                ? Container(
                                    height: 35,
                                    width: 35,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 8,
                                              child: Center(
                                                  child:
                                                      '${data['notification']}'
                                                          .text
                                                          .size(1)
                                                          .color(Colors.white)
                                                          .make()),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : SizedBox(),
          currentUser != null && userEmail != null
              ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Chats')
                .doc('${userEmail}+${bemail}')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      height: 35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching data'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      border:
                      Border.all(color: Colors.grey, width: 0.3),
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
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }
              Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('Chats')
                        .doc('${FirebaseAuth.instance.currentUser?.email}+${bemail}'
                        .toString())
                        .update({
                      'bcount': 0,
                    });
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          border:
                          Border.all(color: Colors.grey, width: 0.3),
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
                        child: const Center(
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      data['bcount'] != 0
                          ? Container(
                        height: 35,
                        width: 35,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 8,
                                  child: Center(
                                      child:
                                      '${data['bcount']}'
                                          .text
                                          .size(1)
                                          .color(Colors.white)
                                          .make()),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
          )
              : SizedBox(),
        ],
      ),
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: Column(
          children: [
            20.heightBox,
            Row(
              children: [
                10.widthBox,
                Image.asset(
                  AppImages.logo,
                  height: 70,
                ),
                'BH Finder'.text.bold.size(20).make(),
              ],
            ),
            20.heightBox,
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'Profile'.text.size(15).make(),
              onTap: (){
                setState(() {
                  _selectedIndex = 3;
                });
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.book_outlined,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'User guide'.text.size(15).make(),
              onTap: (){
                Get.to(() => UsersGuideScreen());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.security,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'Privacy policy'.text.size(15).make(),
              onTap: (){
                Get.to(() => PrivacyPolicyScreen());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.bookmark_border,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'Terms and Conditions'.text.size(15).make(),
              onTap: (){
                Get.to(() => TermsAndConditionsScreen());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'About'.text.size(15).make(),
              onTap: (){
                Get.to(() => AboutScreen());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.outbond_outlined,
                color: Colors.blue.shade900,
                size: 20,
              ),
              title: 'Sign out'.text.size(15).make(),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('roomCache', '');
                await FirebaseAuth.instance.signOut();
                Get.offAll(AuthWrapper());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: tabItems[_selectedIndex],
      ),
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: false,
        // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.chat_rounded),
            title: Text('Chats'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
