import 'package:bh_finder/Screen/BHouse/room.list.new.dart';
import 'package:bh_finder/Screen/BHouse/room.screen.dart';
import 'package:bh_finder/Screen/Map/location.map.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';
import '../../fetch.dart';
import '../Chat/chat.owner.dart';
import '../Loading/loading.bhouse.screen.dart';
import '../Owner/list.rooms.screen.dart';
import '../Review/review.section.dart';
import '../SignUp/guest.screen.dart';

class BhouseScreenNew extends StatefulWidget {
  const BhouseScreenNew({super.key});

  @override
  State<BhouseScreenNew> createState() => _BhouseScreenNewState();
}

class _BhouseScreenNewState extends State<BhouseScreenNew> {
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

  @override
  void dispose() {
    super.dispose();
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _onRefresh() async {
    fetchBhouseData(setState);
    countAvailableRoom(setState);
    countAllRoom(setState);
    setState(() {
      bHouseData = FirebaseFirestore.instance
          .collection('BoardingHouses')
          .doc('${Get.arguments[1]}')
          .get();
    });
    await Future.delayed(
        const Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  //Get Image list
  Future<List<String>> _loadImage() async {
    try {
      ListResult result =
      await storage.ref('BHouseImages/${Get.arguments[0]}').listAll();
      List<String> imageUrls = [];
      for (Reference ref in result.items) {
        String imageUrl = await ref.getDownloadURL();
        if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
          imageUrls.add(imageUrl);
          print(imageUrl);
        } else {
          debugPrint("Invalid URL: $imageUrl");
        }
      }
      return imageUrls;
    } catch (e) {
      debugPrint("Error loading images: $e");
      return [];
    }
  }


  _callNumber(String num) async{
    QuickAlert.show(
      onCancelBtnTap: () {
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        await FlutterPhoneDirectCaller.callNumber(num);
        Navigator.pop(context);
      },
      context: context,
      type: QuickAlertType.confirm,
      text: 'Do you want to continue?',
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: VxBox(
        child: Column(
          children: [
            Expanded(
                child: VxBox(
              child: FutureBuilder<List<String>>(
                future: _loadImage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.deepPurpleAccent.shade200,
                      highlightColor: Colors.white,
                      child: Center(
                        child: Image.asset(
                          AppImages.logo,
                          height: 80,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading images"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No images found"));
                  } else {
                    List<String> images = snapshot.data!;
                    return SizedBox(
                      width: double.infinity,
                      height: 450,
                      child: ImageSlideshow(
                        width: double.infinity,
                        height: 450,
                        initialPage: 0,
                        indicatorColor: Colors.blue,
                        autoPlayInterval: 4000,
                        isLoop: true,
                        children: images.map((imageUrl) {
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ).make()),
            Expanded(
                child: VxBox(
              child: FutureBuilder<DocumentSnapshot>(
                future: bHouseData,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                  print(bUuId);
                  List<dynamic> ratings = data['ratings'];
                  double average =
                      ratings.reduce((a, b) => a + b) / ratings.length;
                  double star = average;
                  double clampedRating = star.clamp(0.0, 5.0);
                  int numberOfReviews =
                      ratings.length > 1 ? ratings.length - 1 : 0;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 30, left: 20, right: 20, bottom: 0),
                          height: 500,
                          width: double.infinity,
                          decoration: const BoxDecoration(
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
                                                            const EdgeInsets
                                                                .only(
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
                                                    return const Center(
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
                                                    return const Center(
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
                                                            const EdgeInsets
                                                                .only(
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
                                                    return const Center(
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
                                                    return const Center(
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
                                                    Get.to(
                                                        () =>
                                                            const ReviewSectionScreen(),
                                                        arguments: data['Email']
                                                            .toString());
                                                    // Navigator.pushNamed(
                                                    //   context,
                                                    //   '/ReviewSectionScreen',
                                                    //   arguments: data['Email'],
                                                    // );
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
                                              ' ${numberOfReviews.toString()} reviews'
                                                  .text
                                                  .bold
                                                  .gray500
                                                  .make(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              ' $average'
                                                  .text
                                                  .bold
                                                  .light
                                                  .make(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    child: GestureDetector(
                                      onTap: () {
                                        _callNumber(data['PhoneNumber']);
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
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.call,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  5.widthBox,
                                  Container(
                                    width: 35,
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
                                              emailOwner : data['Email'].toString(),
                                              token: data['token'],
                                              ownerNumber: data['PhoneNumber'].toString(), // pass the owner number here
                                            ),
                                          ),
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
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.chat,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  5.widthBox,
                                  Container(
                                    width: 35,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          bHouseLat = data['Lat'];
                                          bHouseLong = data['Long'];
                                        });
                                        Get.to(() => LocationScreen(),
                                            arguments: [
                                              data['Lat'],
                                              data['Long']
                                            ]);
                                        // Navigator.of(context)
                                        //     .pushAndRemoveUntil(
                                        //   _toLocationScreen(),
                                        //       (Route<dynamic> route) => false,
                                        // );
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
                                              offset: const Offset(0, 1),
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
                              const SizedBox(height: 10),
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
                                        .maxLines(5)
                                        .color(Colors.grey)
                                        .size(13)
                                        .make(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              //
                              Row(
                                children: [
                                 Expanded(child: Image.asset(AppImages.house, height: 100,)),
                                  10.widthBox,
                                  SizedBox(
                                    height: 50,
                                    width: 150,
                                    child: GlowButton(
                                        borderRadius: BorderRadius.circular(20),
                                        child: 'View rooms'.text.white.make(),
                                        onPressed: () {
                                          setState(() {
                                            btoken = data['token'];
                                          });
                                          Get.to(() => RoomListNew(), arguments: [
                                            data['OwnerUId'],
                                            data['OwnerUId']
                                          ]);
                                        }),
                                  )
                                ],
                              ),
                              //List rooms
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ).make()),
          ],
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .make(),
    );
  }
}
