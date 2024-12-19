import 'dart:math';
import 'package:bh_finder/cons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for Firebase Authentication

class ReviewSectionScreen extends StatefulWidget {
  const ReviewSectionScreen({super.key});

  @override
  State<ReviewSectionScreen> createState() => _ReviewSectionScreenState();
}

class _ReviewSectionScreenState extends State<ReviewSectionScreen> {
  TextEditingController _reviews = TextEditingController();
  double? rating; // State to hold the user's rating
  bool isSubmitting = false; // To prevent multiple submissions
  bool hasUserReviewed = false; // Flag to check if the user has reviewed
  double? reviewed;
  String reviewId = ''; // Store the review ID for updating the review

  @override
  void initState() {
    super.initState();
    _checkUserReviewStatus();
  }

// Method to check if the user has already reviewed
  // Method to check if the user has already reviewed
  Future<void> _checkUserReviewStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case when no user is logged in
      return;
    }

    final String bHouseEmail = Get
        .arguments as String; // Boarding house email (or ID)

    try {
      // Query the reviews sub-collection of the specific boarding house
      final reviewQuery = await FirebaseFirestore.instance
          .collection('BoardingHouses')
          .doc(bHouseEmail)
          .collection('reviews')
          .where('userId',
          isEqualTo: currentUser.uid) // Check for reviews by the current user
          .get();

      if (reviewQuery.docs.isNotEmpty) {
        setState(() {
          hasUserReviewed = true; // User has already reviewed
          // Extract review data from the first review document
          var reviewData = reviewQuery.docs[0].data();
          rating = reviewData['rate']; // Store the existing rating
          _reviews.text = reviewData['reviews']; // Pre-populate review text
          reviewId = reviewQuery.docs[0]
              .id; // Store the review document ID for future updates
        });
      } else {
        setState(() {
          hasUserReviewed = false; // User has not reviewed yet
        });
      }
    } catch (e) {
      print("Error checking user review status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bHouseEmail = Get.arguments as String;
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
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Handle case where user is not logged in
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'You need to be logged in to submit a review.',
          );
          return;
        }

        final userId = currentUser.uid; // Get the UID of the logged-in user

        // Add rating to the BoardingHouse document
        await FirebaseFirestore.instance.collection('BoardingHouses').doc(
            '$bHouseEmail').update({
          'ratings': FieldValue.arrayUnion([rating]),
        });

        // Add review to the reviews sub-collection with userId
        await FirebaseFirestore.instance
            .collection('BoardingHouses')
            .doc('$bHouseEmail')
            .collection('reviews')
            .add({
          'userId': userId, // Store the user's UID to track ownership
          'name': "$fName $mName $lName", // Replace with actual user name
          'createdAt': DateTime.now(),
          'reviews': _reviews.text,
          'rate': rating,
        });

        Navigator.pop(context);
        // await Get.snackbar('Success', 'Review has been posted successfully!', backgroundColor: Colors.green, margin: EdgeInsets.all(10));
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
        _checkUserReviewStatus();
        setState(() {
        });
        // Get.back();
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
                    initialRating: rating ?? 0.0,  // Use null-aware operator to default to 0.0 if rating is null
                    // Start with no rating
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) =>
                    const Icon(
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
                              if (hasUserReviewed) {
                                try {
                                  // Update the existing review
                                  await FirebaseFirestore.instance
                                      .collection('BoardingHouses')
                                      .doc(bHouseEmail)
                                      .collection('reviews')
                                      .doc(
                                      reviewId) // Use the stored review ID to update the existing review
                                      .update({
                                    'reviews': _reviews.text,
                                    'rate': rating,
                                  });

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                        'Review updated successfully!')),
                                  );
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                await addRatingAndReview();
                              }

                              Navigator.pop(context); // Dismiss loading dialog
                            },
                            child: hasUserReviewed == true ? 'Update review'.text.size(10).make(): 'Review'.text.size(10).make(),
                          ),
                        ),
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
                  'Reviews'.text
                      .size(15)
                      .bold
                      .make(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("BoardingHouses")
                      .doc('$bHouseEmail')
                      .collection('reviews')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong!"),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingShimmer();
                    }

                    if (snapshot.data?.size == 0) {
                      return Center(child: Text('No reviews yet.'));
                    }

                    final currentUser = FirebaseAuth.instance.currentUser;

                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                        snapshot.data!.docs[index].data()! as Map<
                            String,
                            dynamic>;
                        String name = data['name'];
                        Timestamp timestamp = data['createdAt'];
                        DateTime date = timestamp.toDate();
                        String formattedDate =
                        DateFormat('EEE - MMM d, yyyy').format(date);
                        String review = data['reviews'];
                        double rate = data['rate'];
                        String userId = data['name']; // The UID of the person who posted this review

                        // Mask the name for privacy
                        String maskedName = _formatName(name);

                        // Check if the review belongs to the current user
                        bool isCurrentUserReview = currentUser?.uid == userId;

                        return _buildReviewTile(
                          maskedName,
                          formattedDate,
                          review,
                          rate,
                          isCurrentUserReview,
                          userId,
                        );
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
  Widget _buildReviewTile(String name, String date, String review, double rate,
      bool isCurrentUserReview, String userId) {
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
                        date.text
                            .size(10)
                            .light
                            .color(Colors.grey)
                            .make(),
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
                          Icon(
                              Icons.star_border, color: Colors.amber, size: 15),
                        SizedBox(width: 5),
                        '$rate'.text
                            .size(10)
                            .light
                            .make(),
                      ],
                    ),
                    if (isCurrentUserReview) ...[
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editReview(userId);
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.delete, color: Colors.red),
                          //   onPressed: () {
                          //     _deleteReview(userId);
                          //   },
                          // ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to edit a review
  Future<void> _editReview(String userId) async {
    // Add logic to edit review here.
    // You can either fetch the existing review data and allow the user to edit it
    // or navigate to a separate screen where they can edit the review.
  }

  // Method to delete a review
  // Future<void> _deleteReview(String userId) async {
  //   // Add logic to delete the review from Firestore
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //
  //   if (currentUser?.uid != userId) {
  //     QuickAlert.show(
  //       context: context,
  //       type: QuickAlertType.error,
  //       title: 'Error',
  //       text: 'You can only delete your own reviews.',
  //     );
  //     return;
  //   }
  //
  //   try {
  //     // Deleting review from Firestore
  //     await FirebaseFirestore.instance
  //         .collection('BoardingHouses')
  //         .doc('$bHouseEmail')
  //         .collection('reviews')
  //         .doc(userId) // Here you should delete the correct review using its document ID
  //         .delete();
  //
  //     QuickAlert.show(
  //       context: context,
  //       type: QuickAlertType.success,
  //       title: 'Success',
  //       text: 'Review has been deleted.',
  //     );
  //   } catch (e) {
  //     print('Error: $e');
  //     QuickAlert.show(
  //       context: context,
  //       type: QuickAlertType.error,
  //       title: 'Error',
  //       text: 'Failed to delete the review.',
  //     );
  //   }
  // }

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
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0];

    String formattedName = parts[0];
    if (parts.length > 1) {
      formattedName += ' ${parts[1][0]}.';
    }

    return formattedName;
  }
}
