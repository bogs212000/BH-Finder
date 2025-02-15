import 'package:bh_finder/Screen/Search/search.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:bh_finder/Screen/about/about.screen.dart';
import 'package:bh_finder/assets/fonts.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';
import '../BHouse/bh.new.dart';
import '../BHouse/bh.screen.dart';

class HomeGuest extends StatefulWidget {
  const HomeGuest({super.key});

  @override
  State<HomeGuest> createState() => _HomeGuestState();
}

class _HomeGuestState extends State<HomeGuest> {
  //
  // Future<void> clearCache() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: VxBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              40.heightBox,
              Row(
                children: [
                  Image.asset(AppImages.logo, height: 50),
                  'BH Finder Version 1.1'
                      .text
                      .size(13)
                      .fontFamily(AppFonts.quicksand)
                      .bold
                      .make(),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        Get.to(() => AboutScreen());
                      },
                      child: Icon(Icons.info_outline)),
                ],
              ),
              20.heightBox,
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                        child: VxBox(
                                child: Image.asset(AppImages.welcome)
                                    .animate()
                                    .fade(duration: 200.ms)
                                    .scale(delay: 200.ms))
                            .white
                            .make()),
                    Expanded(
                      child: VxBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                "Welcome".text.size(30).blue900.bold.make(),
                              ],
                            ),
                            'Sign in first to explore more!'
                                .text
                                .fontFamily(AppFonts.quicksand)
                                .size(20)
                                .bold
                                .make(),
                            10.heightBox,
                            Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: GlowButton(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          'Sign in'.text.white.make(),
                                        ],
                                      ),
                                      onPressed: () {
                                        Get.to(() => SignInScreen());
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
              20.heightBox,
              Row(
                children: [
                  'New Boarding House added'
                      .text
                      .size(15)
                      .fontFamily(AppFonts.quicksand)
                      .bold
                      .make(),
                ],
              ),
              10.heightBox,
              SizedBox(
                width: double.infinity,
                height: 240, // Adjust height as needed
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("BoardingHouses")
                      .where('verified', isEqualTo: true)
                      .where('deleted?', isEqualTo: false)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: List.generate(
                          2, // Example number of shimmer placeholders
                          (index) => Expanded(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.white,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final datas = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      itemCount: datas.length > 5 ? 5 : datas.length,
                      itemBuilder: (context, index) {
                        final data =
                            datas[index].data() as Map<String, dynamic>;
                        List<dynamic> ratings = data['ratings'];
                        double average =
                            ratings.reduce((a, b) => a + b) / ratings.length;
                        String averageOneDecimal = average.toStringAsFixed(1);
                        double clampedRating = average.clamp(0.0, 5.0);

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
                            margin: EdgeInsets.all(5),
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        data['address'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                      Row(
                                        children: List.generate(5, (index) {
                                          if (index < clampedRating.toInt()) {
                                            return Icon(Icons.star,
                                                color: Colors.amber, size: 15);
                                          } else if (index < clampedRating) {
                                            return Icon(Icons.star_half,
                                                color: Colors.amber, size: 15);
                                          } else {
                                            return Icon(Icons.star_border,
                                                color: Colors.amber, size: 15);
                                          }
                                        }),
                                      ),
                                      Text(
                                        ' - $averageOneDecimal',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              20.heightBox,
              Row(
                children: [
                  "Search".text.size(20).blue900.bold.make(),
                  Spacer(),
                  SizedBox(
                    width: 110,
                    child: GlowButton(
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            5.widthBox,
                            'Search'.text.white.make(),
                          ],
                        ),
                        onPressed: () {
                          Get.to(() => SearchScreen());
                        }),
                  ),
                ],
              ),
              Row(
                children: [
                  "Search Boarding House near"
                      .text
                      .size(15)
                      .fontFamily(AppFonts.quicksand)
                      .make(),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: Image.asset(AppImages.empty),
              ),
            ],
          ),
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .padding(EdgeInsets.only(left: 20, right: 20))
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
