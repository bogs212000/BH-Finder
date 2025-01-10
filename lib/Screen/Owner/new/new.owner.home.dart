import 'package:bh_finder/Screen/Owner/list.rooms.screen.dart';
import 'package:bh_finder/Screen/Owner/new/reservations.list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../assets/fonts.dart';
import '../../../assets/images.dart';
import '../../../cons.dart';
import '../../Search/search.screen.dart';

class NewOwnerHome extends StatefulWidget {
  const NewOwnerHome({super.key});

  @override
  State<NewOwnerHome> createState() => _NewOwnerHomeState();
}

class _NewOwnerHomeState extends State<NewOwnerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: VxBox(
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
                  List<dynamic> ratings = data['ratings'];
                  double average =
                      ratings.reduce((a, b) => a + b) / ratings.length;
                  double star = average;
                  double clampedRating = star.clamp(0.0, 5.0);
                  int numberOfReviews =
                  ratings.length > 1 ? ratings.length - 1 : 0;
                  addressLat = data['Lat'];
                  addressLong = data['Long'];
                  bHouse = data['BoardingHouseName'];
                  OwnerPhone = data['PhoneNumber'];
                  ownerID = data['OwnerUId'];
                  // chat = data['chat'];

                  return Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        VxBox(
                          child: Column(
                            children: [
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    '${data['address']}'.text.size(10).white.light.make(),
                                    Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
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
                                    '- $star'.text.size(15).white.make(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .width(MediaQuery.of(context).size.width)
                            .bgImage(DecorationImage(
                                image: NetworkImage(data['Image']), fit: BoxFit.cover))
                            .height(250)
                        .color(Vx.purple200)
                            .make(),
                        10.heightBox,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                              ),
                              ' Verified BH Owner'
                                  .text
                                  .fontFamily(AppFonts.quicksand)
                                  .make()
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child:
                                      VxBox(child: Image.asset(AppImages.pie))
                                          .white
                                          .make()),
                              Expanded(
                                child: VxBox(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                              child:
                                                  '${data['BoardingHouseName']}'
                                                      .text
                                                      .size(30)
                                                      .blue900
                                                      .bold
                                                      .make()),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: 'Welcome to BH Finder'
                                                .text
                                                .fontFamily(AppFonts.quicksand)
                                                .size(15)
                                                .bold
                                                .make(),
                                          ),
                                        ],
                                      ),
                                      10.heightBox,
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 110,
                                            child: GlowButton(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.bed,
                                                      color: Colors.white,
                                                    ),
                                                    ' Rooms'.text.white.make(),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Get.to(
                                                      () => ListRoomsScreen());
                                                }),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ).white.make(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              20.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Flexible(
                        child:
                            'Reservations'.text.size(30).blue900.bold.make()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Flexible(
                      child: 'Check if someone want to rent a room!'
                          .text
                          .fontFamily(AppFonts.quicksand)
                          .size(15)
                          .bold
                          .make(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: VxBox(
                            child: Image.asset(
                      AppImages.reservation_list,
                      height: 200,
                    )).white.make()),
                    Row(
                      children: [
                        SizedBox(
                          width: 128,
                          child: GlowButton(
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  'Check now'.text.white.make(),
                                  const Icon(
                                    Icons.navigate_next,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Get.to(() => ReservationListOwner());
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
