// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:bh_finder/Screen/Home/tab.widget.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../assets/fonts.dart';
import '../../assets/images.dart';
import '../../fetch.dart';
import '../BHouse/bh.new.dart';
import '../BHouse/bh.screen.dart';
import '../Loading/loading.bhouse.screen.dart';
import '../Map/nearme.map.dart';
import '../NearBHouse/bhouse.near.dart';
import '../notification/notification.screen.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<DocumentSnapshot> notification;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
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
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    if (userEmail != null) {
      notification =
          FirebaseFirestore.instance.collection('Users').doc(userEmail).get();
    }

    _focusNode.addListener(() {
      setState(() {
        searchActive = _focusNode.hasFocus;
      });
    });
  }


  Future<void> _onRefresh() async {
    fetchBoarderData(setState);
    if (userEmail != null) {
      notification =
          FirebaseFirestore.instance.collection('Users').doc(userEmail).get();
    }
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }


  @override
  void dispose() {
    _refreshController.dispose(); // Dispose of the controller
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
          enablePullUp: false, // Assuming no pull-up loading is needed
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: WaterDropMaterialHeader(
            distance: 30,
          ),
          child: Column(
            children: [
              80.heightBox,
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                        child: VxBox(child: Image.asset(HomeImages.search))
                            .white
                            .make()),
                    Expanded(
                      child: VxBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                'Search'.text.size(30).blue900.bold.make(),
                              ],
                            ),
                            Row(
                              children: [
                                'and Discover'
                                    .text
                                    .fontFamily(AppFonts.quicksand)
                                    .size(20)
                                    .bold
                                    .make(),
                              ],
                            ),
                          ],
                        ),
                      ).white.make(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
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
                      fillColor: Colors.grey.withOpacity(0.2),
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
                      TextStyle(color: Colors.grey.withOpacity(0.9))),
                ),
              ),
              //List BH
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 10),
                  child: Container(
                    width: double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: search == null || search == ""
                          ? FirebaseFirestore.instance
                          .collection("BoardingHouses")
                          .where('verified',
                          isEqualTo: true)
                          .where('deleted?',
                          isEqualTo: false)
                          .snapshots()
                          : FirebaseFirestore.instance
                          .collection("BoardingHouses")
                          .where('BoardingHouseName',
                          isGreaterThanOrEqualTo:
                          search)
                          .where('verified',
                          isEqualTo: true)
                          .where('deleted?',
                          isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Error: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 150,
                                  child: Row(children: [
                                    Expanded(
                                      child: Shimmer
                                          .fromColors(
                                        baseColor: Colors
                                            .grey.shade200,
                                        highlightColor:
                                        Colors.white,
                                        child: Container(
                                          height: 500,
                                          width: 300,
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            Colors.grey,
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Shimmer
                                          .fromColors(
                                        baseColor: Colors
                                            .grey.shade200,
                                        highlightColor:
                                        Colors.white,
                                        child: Container(
                                          height: 500,
                                          width: 300,
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            Colors.grey,
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                20),
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
                        final datas =
                            snapshot.data?.docs ?? [];
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
                              itemBuilder:
                                  (context, index) {
                                final data = datas[index]
                                    .data()
                                as Map<String, dynamic>;
                                OwnerUuId =
                                data['OwnerUId'];
                                rBHouseDocId =
                                data['Email'];
                                print("$OwnerUuId");
                                List<dynamic> ratings = data['ratings'];
                                double average = ratings.reduce((a, b) => a + b) / ratings.length;
                                String averageOneDecimal = average.toStringAsFixed(1);
                                double star = average;
                                double clampedRating = star.clamp(0.0, 5.0);
                                int numberOfReviews =
                                ratings.length > 1 ? ratings.length - 1 : 0;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      OwnerUuId = data['OwnerUId'];
                                      rBHouseDocId = data['Email'];
                                    });
                                    Get.to(() => const BhouseScreenNew(), arguments: [
                                      data['OwnerUId'].toString(),
                                      data['Email'],
                                      data["OwnerUId"]
                                    ]);
                                  },
                                  child: Container(
                                    width: 150, // Width for horizontal scrolling
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                            ),
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  data['Image']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['BoardingHouseName'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                data['address'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 10, color: Colors.grey),
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: List.generate(5, (index) {
                                                      if (index < clampedRating.toInt()) {
                                                        return const Icon(Icons.star,
                                                            color: Colors.amber, size: 15);
                                                      } else if (index < clampedRating) {
                                                        return const Icon(Icons.star_half,
                                                            color: Colors.amber, size: 15);
                                                      } else {
                                                        return const Icon(Icons.star_border,
                                                            color: Colors.amber, size: 15);
                                                      }
                                                    }),
                                                  ),
                                                  ' $averageOneDecimal'.text.bold.size(10).make()
                                                ],
                                              ),
                                              Text(
                                                '  ${numberOfReviews.toString()} reviews',
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
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
                ),
              ),
              //
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
          NotificationScreen(boardersID: bUuId),
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
            child: NotificationScreen(boardersID: bUuId));
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
