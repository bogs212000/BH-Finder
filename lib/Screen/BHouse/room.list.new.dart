import 'package:bh_finder/Screen/BHouse/room.new.dart';
import 'package:bh_finder/Screen/BHouse/room.screen.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

class RoomListNew extends StatefulWidget {
  const RoomListNew({super.key});

  @override
  State<RoomListNew> createState() => _RoomListNewState();
}

class _RoomListNewState extends State<RoomListNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: 'Rooms'.text.bold.make(),
          centerTitle: true),
      body: VxBox(
              child: Column(
        children: [
          Image.asset(AppImages.house, height: 130),
          20.heightBox,
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Rooms")
                    .where('ownerUid', isEqualTo: Get.arguments[0].toString())
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
                  // Show loading spinner while waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 90,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 90,
                              width: double.infinity,
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
                  // Show message if no data is found
                  if (snapshot.data?.size == 0) {
                    return const Center(
                      child: Text('Nothing to fetch here.'),
                    );
                  }

                  // Data is available, display it
                  return ListView.builder(
                    // physics:
                    //     const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    // Use the length of the fetched data
                    itemBuilder: (context, index) {
                      Map<String, dynamic> datas = snapshot.data!.docs[index]
                          .data()! as Map<String, dynamic>;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => RoomNew(),
                              arguments: [datas['roomDocId'],datas['roomDocId'],]
                            );
                          },
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        datas['roomImage'] ??
                                            'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${datas['roomNameNumber']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          datas['roomStatus'],
                                          style: const TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₱ ${datas['price'] ?? '---'} per month',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
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
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ))
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
