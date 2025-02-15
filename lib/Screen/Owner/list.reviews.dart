import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class ListReviews extends StatefulWidget {
  const ListReviews({super.key});

  @override
  State<ListReviews> createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {
  String _formatName(String name) {
    List<String> parts = name.split(' ');

    if (parts.isEmpty) return ''; // Return empty if no parts
    if (parts.length == 1) return parts[0]; // Return if only first name

    String formattedName = parts[0]; // Always show the first name

    // If there are more parts, add a masked version of the last name
    if (parts.length > 1) {
      formattedName += ' ${parts[1][0]}.';
    }

    return formattedName; // Ensure to return the formatted name
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.2),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomInfo(
      BuildContext context, String label, Future<int> future, String? route) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200.withOpacity(0.5),
            highlightColor: Colors.white.withOpacity(0.3),
            child: Container(
              height: 30,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (snapshot.hasData) {
          final int roomCount = snapshot.data ?? 0;
          return Row(
            children: [
              Text(
                roomCount.toString(),
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                ' - $label',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Spacer(),
            ],
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: 'Reviews'.text.make(), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("BoardingHouses")
            .doc(FirebaseAuth.instance.currentUser?.email.toString())
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.data?.size == 0) {
            return Center(
              child: Text('No reviews yet.'),
            );
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>;
              String name = data['name'];
              Timestamp timestamp = data['createdAt'];
              DateTime date = timestamp.toDate();
              String formattedDate =
                  DateFormat('EEE - MMM d, yyyy').format(date);

              // Mask the name for privacy
              String maskedName = _formatName(name);

              return _buildReviewTile(
                  maskedName, formattedDate, data['reviews'], data['rate']);
            },
          );
        },
      ),
    );
  }
}

Widget _buildReviewTile(String name, String date, String review, double rate) {
  return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 0.5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      name.text.light
                          .overflow(TextOverflow.ellipsis)
                          .size(12)
                          .make(),
                      Spacer(),
                      date.text.size(10).light.color(Colors.grey).make(),
                    ],
                  ),
                  SizedBox(height: 5),
                  review.text.size(15).overflow(TextOverflow.ellipsis).make(),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = 0; i < rate.toInt(); i++)
                        Icon(Icons.star, color: Colors.amber, size: 15),
                      for (int i = 0; i < 5 - rate.toInt(); i++)
                        Icon(Icons.star_border, color: Colors.amber, size: 15),
                      SizedBox(width: 5),
                      '$rate'.text.size(10).light.make(),
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
}
