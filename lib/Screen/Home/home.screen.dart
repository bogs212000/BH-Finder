// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:bh_finder/Screen/Home/rerent.dart';
import 'package:bh_finder/Screen/Home/tab.widget.dart';
import 'package:bh_finder/Screen/Receipt/receipt.screen.dart';
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
import '../../fetch.dart';
import '../BHouse/bh.screen.dart';
import '../Loading/loading.bhouse.screen.dart';
import '../Map/nearme.map.dart';
import '../NearBHouse/bhouse.near.dart';
import '../notification/notification.screen.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    Navigator.of(context).popUntil((route) => route.isFirst);
    fetchBoarderData(setState);
    checkGps();
    checkGPS();
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
    return WillPopScope(
        onWillPop: () async { Get.back();
          // Navigate back using GetX
        return false; // Prevent default back button behavior
        },
      child: Scaffold(
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
                currentUser == null ? Padding(
                  padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                ) : SizedBox(),
                bUuId != null || searchActive == false && currentUser != null
                    ? FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Rooms")
                            .where('boarderID', isEqualTo: bUuId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20, right: 40, top: 20),
                                    child: Container(
                                      height: 50,
                                      width: 200,
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
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching data'));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return SizedBox();
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
                                          Shimmer.fromColors(
                                            baseColor: Colors.blue,
                                            highlightColor: Colors.white,
                                            child: '$daysLeft '
                                                .text
                                                .size(25)
                                                .bold
                                                .make(),
                                          ),
                                          'Days left'.text.size(15).make(),
                                          Spacer(),
                                          SizedBox(
                                            height: 25,
                                            child: ElevatedButton(
      
                                              onPressed: () {
                                                setState(() {
                                                  fetchGcashEmail = data['Email'];
                                                });
                                                Get.to(()=>ReceiptScreen(), arguments: [data['roomDocId']]);
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //       builder: (context) => ReceiptScreen(
                                                //         roomId: data['roomDocId'],
                                                //       ),
                                                //     ));
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
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                              'Boarding House : ${data['bHouseName']}',
                                              style: TextStyle(fontSize: 12)), Spacer(),
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
                                          if(daysLeft < 3)
                                            SizedBox(
                                              height: 25,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    rerentOwnerId = data['ownerUid'];
                                                  });
                                                      Get.to(()=>RerentRoom(), arguments: [data['roomDocId'], data['roomDocId']]);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromRGBO(
                                                      26, 60, 105, 1.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Re-rent room',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                            ),
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
      
                SizedBox(height: 20),
                //List BH
                currentUser != null
                    ? Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            // TabBar
                            TabBar(
                              tabs: [
                                'Boarding Houses'.text.bold.make(),
                                'Reservations'.text.bold.make(),
                              ],
                            ),
      
                            // Expanded TabBarView to take up remaining space
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5, left: 5, top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: search == null || search == ""
                                            ? FirebaseFirestore.instance
                                                .collection("BoardingHouses")
                                                .where('verified',
                                                    isEqualTo: true)
                                                .snapshots()
                                            : FirebaseFirestore.instance
                                                .collection("BoardingHouses")
                                                .where('BoardingHouseName',
                                                    isGreaterThanOrEqualTo:
                                                        search)
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
                                                  rBHouseDocId =
                                                      data['Email'];
                                                  print("$OwnerUuId");
                                                  List<dynamic> ratings = data['ratings'];
                                                  double average = ratings.reduce((a, b) => a + b) / ratings.length;
                                                  String averageOneDecimal = average.toStringAsFixed(1);
                                                  double star = average;
                                                  double clampedRating = star.clamp(0.0, 5.0);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        OwnerUuId =
                                                            data['OwnerUId'];
                                                        rBHouseDocId =
                                                            data['Email'];
                                                        print(
                                                            "$OwnerUuId, $rBHouseDocId");
                                                      });
                                                      Get.to(()=>BHouseScreen(), arguments: [data['OwnerUId'],data['Email'], data["OwnerUId"] ]);
                                                      // Navigator.of(context)
                                                      //     .pushAndRemoveUntil(
                                                      //   _toBhouseScreen(),
                                                      //   (Route<dynamic>
                                                      //           route) =>
                                                      //       false,
                                                      // );
                                                    },
                                                    child: Container(
                                                      width: 150,
                                                      height: 225,
                                                      margin:
                                                          EdgeInsets.all(5),
                                                      // Add margin for spacing
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      2),
                                                          color:
                                                              Colors.white),
                                                      child: Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        220,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.grey.withOpacity(0.2),
                                                                            spreadRadius: 1,
                                                                            blurRadius: 3,
                                                                            offset: Offset(0, 0.5),
                                                                          ),
                                                                        ]),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              150,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius: const BorderRadius.only(
                                                                              topLeft: Radius.circular(5),
                                                                              topRight: Radius.circular(5),
                                                                            ),
                                                                            image: DecorationImage(
                                                                              image: CachedNetworkImageProvider(data['Image'],),
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.all(5),
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              70,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius: const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(5),
                                                                              bottomRight: Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(child: '${data['BoardingHouseName']}'.text.overflow(TextOverflow.ellipsis).light.make())
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(child: '${data['address']}'.text.overflow(TextOverflow.ellipsis).size(10).color(Colors.grey).make())
                                                                                ],
                                                                              ),
                                                                              Spacer(),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  GestureDetector( onTap: (){
                                                                                  },
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: List.generate(5, (index) {
                                                                                        if (index < clampedRating.toInt()) {
                                                                                          // Filled star
                                                                                          return const Icon(Icons.star, color: Colors.amber, size: 15,);
                                                                                        } else if (index < clampedRating) {
                                                                                          // Half star
                                                                                          return const Icon(Icons.star_half, color: Colors.amber, size: 15);
                                                                                        } else {
                                                                                          // Empty star
                                                                                          return const Icon(Icons.star_border, color: Colors.amber, size: 15);
                                                                                        }
                                                                                      }),
                                                                                    ),
                                                                                  ), ' - $averageOneDecimal'.text.size(10).light.make(),
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
                                                              SizedBox(
                                                                  height: 5),
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
      
                                  //Reservations
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("Reservations")
                                        .where('boarderUuId',
                                            isEqualTo: bUuId)
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
                                        return Container(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 150,
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors
                                                          .grey.shade200,
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Container(
                                                        height: 500,
                                                        width: 300,
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
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors
                                                          .grey.shade200,
                                                      highlightColor:
                                                          Colors.white,
                                                      child: Container(
                                                        height: 500,
                                                        width: 300,
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
                                                  )
                                                ]),
                                              )
                                            ],
                                          ),
                                        );
                                      }
      
                                      if (snapshot.data?.size == 0) {
                                        return Center(
                                          child:
                                              Text('Nothing to fetch here.'),
                                        );
                                      }
      
                                      return ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: snapshot.data!.docs.length,
                                        // Use the length of the fetched data
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> data = snapshot
                                                  .data!.docs[index]
                                                  .data()!
                                              as Map<String, dynamic>;
                                          String? roomUuId =
                                              data['roomDocId'];
                                          Timestamp timestamp =
                                              data['createdAt'];
                                          DateTime date = timestamp.toDate();
                                          String formattedDate =
                                              DateFormat('EEE - MMM d, yyyy')
                                                  .format(date);
      
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                rBHouseDocId = data['docID'];
                                              });
                                              print(rBHouseDocId);
                                              Navigator.pushNamed(context,
                                                  '/ViewReservationScreen');
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 10, left: 10),
                                              child: Container(
                                                height: 90,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                  boxShadow: [],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        color: Colors.white,
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
                                                                    .size(15)
                                                                    .make(),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                '${data['boardersName']}'
                                                                    .text
                                                                    .color(Colors
                                                                        .grey)
                                                                    .make(),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                '$formattedDate'
                                                                    .text
                                                                    .size(12)
                                                                    .light
                                                                    .color(Colors
                                                                        .grey)
                                                                    .make(),
                                                                Spacer(),
                                                                if (data[
                                                                        'status'] ==
                                                                    'pending')
                                                                  'Pending'
                                                                      .text
                                                                      .color(Colors
                                                                          .grey)
                                                                      .size(
                                                                          10)
                                                                      .make(),
                                                                if (data[
                                                                        'status'] ==
                                                                    'accepted')
                                                                  'Accepted'
                                                                      .text
                                                                      .color(Colors
                                                                          .green)
                                                                      .size(
                                                                          10)
                                                                      .make(),
                                                                if (data[
                                                                        'status'] ==
                                                                    'rejected')
                                                                  'Rejected'
                                                                      .text
                                                                      .color(Colors
                                                                          .red)
                                                                      .size(
                                                                          10)
                                                                      .make(),
                                                                if (data[
                                                                        'status'] ==
                                                                    'canceled')
                                                                  'Canceled'
                                                                      .text
                                                                      .color(Colors
                                                                          .red)
                                                                      .size(
                                                                          10)
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
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    : Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                    final data = datas[index].data()
                                        as Map<String, dynamic>;
                                    List<dynamic> ratings = data['ratings'];
                                    double average = ratings.reduce((a, b) => a + b) / ratings.length;
                                    String averageOneDecimal = average.toStringAsFixed(1);
                                    double star = average;
                                    double clampedRating = star.clamp(0.0, 5.0);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          OwnerUuId = data['OwnerUId'];
                                          rBHouseDocId = data['Email'];
      
                                        });
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          _toBhouseScreen(),
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 225,
                                        margin: EdgeInsets.all(5),
                                        // Add margin for spacing
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
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
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2),
                                                              spreadRadius: 1,
                                                              blurRadius: 3,
                                                              offset: Offset(
                                                                  0, 0.5),
                                                            ),
                                                          ]),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 150,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5),
                                                              ),
                                                              image:
                                                                  DecorationImage(
                                                                image: CachedNetworkImageProvider(
                                                                    data[
                                                                        'Image']),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            width:
                                                                double.infinity,
                                                            height: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
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
                                                                            .overflow(TextOverflow.ellipsis)
                                                                            .light
                                                                            .make())
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Flexible(
                                                                        child: '${data['address']}'
                                                                            .text
                                                                            .overflow(TextOverflow.ellipsis)
                                                                            .size(10)
                                                                            .color(Colors.grey)
                                                                            .make())
                                                                  ],
                                                                ),
                                                                Spacer(),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    GestureDetector( onTap: (){
                                                                    },
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: List.generate(5, (index) {
                                                                          if (index < clampedRating.toInt()) {
                                                                            // Filled star
                                                                            return const Icon(Icons.star, color: Colors.amber, size: 15,);
                                                                          } else if (index < clampedRating) {
                                                                            // Half star
                                                                            return const Icon(Icons.star_half, color: Colors.amber, size: 15);
                                                                          } else {
                                                                            // Empty star
                                                                            return const Icon(Icons.star_border, color: Colors.amber, size: 15);
                                                                          }
                                                                        }),
                                                                      ),
                                                                    ), ' - $averageOneDecimal'.text.size(10).light.make(),
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
                //
              ],
            ),
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
