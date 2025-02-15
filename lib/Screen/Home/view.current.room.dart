import 'package:bh_finder/assets/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
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

import '../../assets/images.dart';
import '../../assets/text.dart';
import '../../cons.dart';
import '../../fetch.dart';
import '../BordersReservation/boarder.reservation.screen.dart';
import '../Chat/chat.owner.dart';
import '../Loading/loading.bhouse.screen.dart';
import 'new.home.dart';

class ViewCurrentRoom extends StatefulWidget {
  const ViewCurrentRoom({super.key});

  @override
  State<ViewCurrentRoom> createState() => _ViewCurrentRoomState();
}

class _ViewCurrentRoomState extends State<ViewCurrentRoom> {
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
    bHouseRoom = FirebaseFirestore.instance
        .collection('Rooms')
        .doc('$roomId')
        .get();
  }

  Future<void> _onRefresh() async {
    fetchBoarderData(setState);
    fetchRoomData(setState);
    setState(() {
      bHouseRoom = FirebaseFirestore.instance
          .collection('Rooms')
          .doc('${Get.arguments[1].toString()}')
          .get();
    });
    await Future.delayed(
        Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  FirebaseStorage storage = FirebaseStorage.instance;
  String? docID;

  Future<List<String>> _loadImage() async {
    ListResult result = await storage
        .ref()
        .child("roomImages/${Get.arguments[1].toString()}")
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

    _callNumber(String number) async {
      QuickAlert.show(
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
        onConfirmBtnTap: () async {
          bool? res = await FlutterPhoneDirectCaller.callNumber(number);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: VxBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
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
                              placeholder: (context, url) =>
                                  Shimmer.fromColors(
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
                VxBox(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: bHouseRoom,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingBHouseScreen();
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching data'));
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                            child: Text('No Reservation found'));
                      }
                      Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 30, left: 20, right: 20, bottom: 0),
                            height: 650,
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
                                                'Room ${data['roomNameNumber']}'
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
                                            .maxLines(5)
                                            .color(Colors.grey)
                                            .size(13)
                                            .make(),
                                      ),
                                    ],
                                  ),
                                ),
                                10.heightBox,
                                SizedBox(
                                  child: Row(children: [
                                    Expanded(child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            'Note'.text
                                                .size(20)
                                                .blue900
                                                .bold
                                                .make(),
                                          ],
                                        ),
                                        Image.asset(AppImages.notif),
                                      ],
                                    )),
                                    Expanded(child: Column(children: [
                                      SizedBox(
                                        width: 150,
                                        child: GlowButton(
                                          borderRadius: BorderRadius.circular(20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(Icons.call, color: Colors.white, size: 15,),
                                                'Call Owner'.text.light.white
                                                    .size(15).make(),
                                              ],
                                            ), onPressed: () {
                                          _callNumber(data['contactNumber']);
                                        }),
                                      ),
                                      10.heightBox,
                                      SizedBox(
                                        width: 150,
                                        child: GlowButton(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(Icons.chat, color: Colors.white, size: 15,),
                                                'Chat Owner'.text.light.white
                                                    .size(15).make(),
                                              ],
                                            ), onPressed: () {
                                          setState(() {
                                            bHouse =
                                                data['bHouseName'].toString();
                                          });
                                          print('haha $ownerEmail, $bHouse');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatOwner(
                                                emailOwner: ownerEmail,
                                                ownerNumber: data['contactNumber'],
                                                token: token,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      20.heightBox,
                                      AppText.current_room_note.text.fontFamily(
                                          AppFonts.quicksand).make()
                                    ],))
                                  ],),
                                ),
                                30.heightBox,
                              ],
                            ),
                          ),
                          30.heightBox,
                        ],
                      );
                    },
                  ),
                ).height(680).width(double.infinity).make(),
              ],
            ),
          ))
          .height(MediaQuery
          .of(context)
          .size
          .height)
          .white
          .width(MediaQuery
          .of(context)
          .size
          .width)
          .make(),
    );
  }
}
