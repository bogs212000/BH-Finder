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
import 'package:location/location.dart' as loc;

import 'admin.view.bhouse.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ''.text.make(),
        actions: [],
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
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
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Expanded(
                  child: Container(
                    height: 500,
                    width: double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("BoardingHouses")
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
                                      _toAdminBhouseScreen(),
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
                                                              children: [
                                                                data['verified'] ==
                                                                        true
                                                                    ? 'Verified'
                                                                        .text
                                                                        .color(Colors
                                                                            .green)
                                                                        .make()
                                                                    : 'Unverified'
                                                                        .text
                                                                        .color(Colors
                                                                            .red)
                                                                        .make(),
                                                                Spacer(),
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

  Route _toAdminBhouseScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) =>
          AdminBHouseScreen(),
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
            child: AdminBHouseScreen());
      },
    );
  }
}
