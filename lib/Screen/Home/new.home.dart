import 'package:bh_finder/Screen/BordersReservation/boarder.reservation.screen.dart';
import 'package:bh_finder/Screen/Home/my.reservations.dart';
import 'package:bh_finder/Screen/Home/view.current.room.dart';
import 'package:bh_finder/Screen/Owner/reservation/reservation.view.screen.dart';
import 'package:bh_finder/Screen/Search/search.screen.dart';
import 'package:bh_finder/assets/fonts.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';
import '../BHouse/bh.new.dart';
import '../BHouse/bh.screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: VxBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              80.heightBox,
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Rooms")
                    .where('boarderID', isEqualTo: bUuId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 40, top: 20),
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
                    return const Center(child: Text('Error fetching data'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        "You haven't started renting a room yet."
                            .text
                            .size(15)
                            .fontFamily(AppFonts.quicksand)
                            .bold
                            .make(),
                        Image.asset(
                          AppImages.street,
                        ),
                      ],
                    );
                  }

                  // Use a Column to display the fetched documents instead of ListView
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      cDocId = data['roomDocId'];
                      DateTime boardersIn = DateTime.fromMillisecondsSinceEpoch(
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
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                          children: [
                                            Image.asset(AppImages.street),
                                            10.heightBox,
                                            data['paid?'] == false ? Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: SizedBox(
                                                height: 30,
                                                width: double.infinity,
                                                child: GlowButton(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                    child: 'View room'
                                                        .text
                                                        .bold
                                                        .white
                                                        .make(),
                                                    onPressed: () {
                                                      Get.to(()=>ViewCurrentRoom(), arguments: [data['roomDocId'], data['roomDocId']]);
                                                    }),
                                              ),
                                            ) : Padding(
                                              padding: const EdgeInsets.only(left: 20, right: 20),
                                              child: SizedBox(
                                                height: 30,
                                                width: double.infinity,
                                                child: GlowButton(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                    child: 'View'
                                                        .text
                                                        .bold
                                                        .white
                                                        .make(),
                                                    onPressed: () {}),
                                              ),
                                            )
                                          ],
                                        )),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              '$daysLeft '
                                                  .text
                                                  .size(30)
                                                  .extraBold
                                                  .blue900
                                                  .make(),
                                              ' Days left'
                                                  .text
                                                  .fontFamily(
                                                      AppFonts.quicksand)
                                                  .size(15)
                                                  .make(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  'BH : ${data['bHouseName']}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AppFonts.quicksand)),
                                              const Spacer(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  'Room : ${data['roomNameNumber']}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AppFonts.quicksand)),
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
                                                        : Colors.red,
                                                    fontFamily:
                                                        AppFonts.quicksand),
                                              ),
                                              // const Spacer(),
                                              // if (daysLeft < 3)
                                              //   SizedBox(
                                              //     height: 25,
                                              //     child: ElevatedButton(
                                              //       onPressed: () {
                                              //         setState(() {
                                              //           rerentOwnerId =
                                              //               data['ownerUid'];
                                              //         });
                                              //         // Get.to(()=>RerentRoom(), arguments: [data['roomDocId'], data['roomDocId']]);
                                              //       },
                                              //       style: ElevatedButton
                                              //           .styleFrom(
                                              //         backgroundColor:
                                              //             const Color.fromRGBO(
                                              //                 26, 60, 105, 1.0),
                                              //         shape:
                                              //             RoundedRectangleBorder(
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(10),
                                              //         ),
                                              //       ),
                                              //       child: const Text(
                                              //         'Re-rent room',
                                              //         style: TextStyle(
                                              //             color: Colors.white,
                                              //             fontWeight:
                                              //                 FontWeight.bold),
                                              //       ),
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(
                                    //   height: 25,
                                    //   child: ElevatedButton(
                                    //
                                    //     onPressed: () {
                                    //       setState(() {
                                    //         fetchGcashEmail = data['Email'];
                                    //       });
                                    //       // Get.to(()=>ReceiptScreen(), arguments: [data['roomDocId']]);
                                    //       // Navigator.push(
                                    //       //     context,
                                    //       //     MaterialPageRoute(
                                    //       //       builder: (context) => ReceiptScreen(
                                    //       //         roomId: data['roomDocId'],
                                    //       //       ),
                                    //       //     ));
                                    //     },
                                    //     style: ElevatedButton.styleFrom(
                                    //       backgroundColor: Color.fromRGBO(
                                    //           26, 60, 105, 1.0),
                                    //       shape: RoundedRectangleBorder(
                                    //         borderRadius:
                                    //         BorderRadius.circular(10),
                                    //       ),
                                    //     ),
                                    //     child: data['paid?'] == false
                                    //         ? Text(
                                    //       'Pay Now',
                                    //       style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight:
                                    //           FontWeight.bold),
                                    //     )
                                    //         : Text(
                                    //       'See receipt',
                                    //       style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight:
                                    //           FontWeight.bold),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(), // Convert the documents to a list of widgets
                  );
                },
              ),
              SizedBox(
                height: 150,
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
                            10.heightBox,
                            Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: GlowButton(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.search,
                                            color: Colors.white,
                                          ),
                                          'Search'.text.white.make(),
                                        ],
                                      ),
                                      onPressed: () {
                                        Get.to(()=>SearchScreen());
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
              10.heightBox,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                                      Text(
                                        ' - $averageOneDecimal',
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
                    );
                  },
                ),
              ),
              10.heightBox,
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                        child: VxBox(
                                child: Image.asset(AppImages.reservation_list))
                            .white
                            .make()),
                    Expanded(
                      child: VxBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                'View'.text.size(30).blue900.bold.make(),
                              ],
                            ),
                            Row(
                              children: [
                                'your reservation'
                                    .text
                                    .fontFamily(AppFonts.quicksand)
                                    .size(20)
                                    .bold
                                    .make(),
                              ],
                            ),
                            10.heightBox,
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: GlowButton(
                                      borderRadius: BorderRadius.circular(20),
                                      child: 'View'.text.white.make(),
                                      onPressed: () {
                                        Get.to(()=>MyReservations());
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
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .padding(const EdgeInsets.only(left: 20, right: 20))
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
