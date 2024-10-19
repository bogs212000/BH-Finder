import 'dart:math';
import 'package:bh_finder/cons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class ReviewSectionScreen extends StatefulWidget {
  const ReviewSectionScreen({super.key});

  @override
  State<ReviewSectionScreen> createState() => _ReviewSectionScreenState();
}

class _ReviewSectionScreenState extends State<ReviewSectionScreen> {
  TextEditingController _reviews = TextEditingController();
  double? rating; // State to hold the user's rating
  bool isSubmitting = false; // To prevent multiple submissions

  @override
  Widget build(BuildContext context) {
    final String bHouseEmail = ModalRoute.of(context)!.settings.arguments as String;

    Future<void> addRatingAndReview() async {
      if (rating == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Please select a rating.',
        );
        return;
      }

      setState(() {
        isSubmitting = true;
      });

      try {
        // Add rating to the BoardingHouse document
        await FirebaseFirestore.instance.collection('BoardingHouses').doc(bHouseEmail).update({
          'ratings': FieldValue.arrayUnion([rating]),
        });

        // Add review to the reviews sub-collection
        await FirebaseFirestore.instance
            .collection('BoardingHouses')
            .doc(bHouseEmail)
            .collection('reviews')
            .doc()
            .set({
          'docId': FirebaseFirestore.instance.collection('reviews').doc().id,
          'name': "$fName $mName $lName", // Replace with actual user name
          'createdAt': DateTime.now(),
          'reviews': _reviews.text,
          'rate': rating, // Ensure the rating is stored as double
        });
        Navigator.pop(context);
        // Clear the input fields and display success alert
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Review has been posted successfully!',
        );
        _reviews.clear();
        setState(() {
          rating = null;
          isSubmitting = false;
        });
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Review has been posted successfully!',
        );
      } catch (e) {
        setState(() {
          isSubmitting = false;
        });
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Failed to post review. Please try again.',
        );
        print('Error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: 'Reviews'.text.bold.make(),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: 0, // Start with no rating
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (newRating) {
                      setState(() {
                        rating = newRating; // Update the rating state
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: ['Give a review (Optional)'.text.make()],
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: TextField(
                      maxLines: 3,
                      controller: _reviews,
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelText: '',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                              // Show loading alert
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.loading,
                                title: 'Uploading',
                                text: 'Please Wait...',
                              );
                              await addRatingAndReview();
                              Navigator.pop(context); // Dismiss loading dialog
                            },
                            child: 'Review'.text.size(10).make(),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  'Reviews'.text.size(15).bold.make(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("BoardingHouses")
                      .doc(bHouseEmail)
                      .collection('reviews')
                      .orderBy('createdAt', descending: true)
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
                        Map<String, dynamic> data = snapshot.data!.docs[index]
                            .data()! as Map<String, dynamic>;
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
              ),
            )
          ],
        ),
      ),
    );
  }

  // Method to create a review tile
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
                        Flexible(
                          child: name.text.light
                              .overflow(TextOverflow.ellipsis)
                              .size(12)
                              .make(),
                        ),
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

  // Loading shimmer for when data is loading
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

  // Method to mask the user's name
  String _formatName(String name) {
    List<String> parts = name.split(' ');
    if (parts.isEmpty) return ''; // Return empty if no parts
    if (parts.length == 1) return parts[0]; // Return if only first name

    String formattedName = parts[0]; // Always show the first name

    // If there are more parts, add a masked version of the last name
    if (parts.length > 1) {
      formattedName += ' ${parts[1][0]}.';
    }

    return formattedName;
  }
}
