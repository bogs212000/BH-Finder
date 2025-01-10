import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Profile/user.edit.profile.dart';
import 'package:bh_finder/Screen/about/about.screen.dart';
import 'package:bh_finder/assets/images.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

import '../../../Auth/auth.wrapper.dart';
import 'bhouse.edit.profle.dart';

class BHouseProfile extends StatefulWidget {
  const BHouseProfile({super.key});

  @override
  State<BHouseProfile> createState() => _BHouseProfileState();
}

class _BHouseProfileState extends State<BHouseProfile> {
  late Future<DocumentSnapshot> profile;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  bool loading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    profile = FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc('$userEmail')
        .get();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: Colors.white,
            body: VxBox(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('BoardingHouses')
                          .doc(FirebaseAuth.instance.currentUser!.email
                              .toString())
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error fetching data'));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(
                              child: Text('No Reservation found'));
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
                        return Column(
                          children: [
                            VxBox(
                              child: Column(
                                children: [
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        '${data['address']}'
                                            .text
                                            .size(10)
                                            .white
                                            .light
                                            .make(),
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: List.generate(5, (index) {
                                            if (index < clampedRating.toInt()) {
                                              // Filled star
                                              return const Icon(Icons.star,
                                                  color: Colors.amber);
                                            } else if (index < clampedRating) {
                                              // Half star
                                              return const Icon(Icons.star_half,
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
                                    image: NetworkImage(data['Image']),
                                    fit: BoxFit.cover))
                                .height(250)
                                .make(),
                            20.heightBox,
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  Expanded(child: Image.asset(AppImages.house)),
                                  Expanded(
                                      child: Column(
                                    children: [
                                      '${data['BoardingHouseName']}'
                                          .text
                                          .size(20)
                                          .bold
                                          .make(),
                                      '${data['PhoneNumber']}'
                                          .text
                                          .size(10)
                                          .light
                                          .make(),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Divider(),
                            ),
                            10.heightBox,
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            'Descriptions'.text.blue800.size(20).bold.make(),
                                          ],
                                        ),
                                        '${data['Rules']}'.text.light.make(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          GlowButton(
                                            borderRadius: BorderRadius.circular(20),
                                              child: 'Edit info'.text.white.make(),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BHouseEditProfile(
                                                      rules: data['Rules'],
                                                      OwnerUId: data['OwnerUId'],
                                                      bHouseName: data['BoardingHouseName'],
                                                      first: data['FirstName'],
                                                      middle: data['MiddleName'],
                                                      last: data['LastName'],
                                                      address: data['address'],
                                                      email: data['Email'],
                                                      phoneNum: data['PhoneNumber'],
                                                      lat: data['Lat'],
                                                      long: data['Long'],
                                                      gcashNum: data['gcashNum'],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            10.heightBox,
                           
                            SizedBox(height: 10),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     SizedBox(
                            //       height: 40,
                            //       child: ElevatedButton(
                            //         onPressed: () async {
                            //           QuickAlert.show(
                            //             onCancelBtnTap: () {
                            //               Navigator.pop(context);
                            //             },
                            //             onConfirmBtnTap: () async {
                            //               Navigator.pop(context);
                            //               try {
                            //                 await FirebaseAuth.instance
                            //                     .sendPasswordResetEmail(
                            //                         email: data['Email']
                            //                             .toString());
                            //                 message =
                            //                     "Password reset email sent.";
                            //               } catch (e) {
                            //                 message =
                            //                     "Error sending password reset email";
                            //               }
                            //               _toast();
                            //             },
                            //             context: context,
                            //             type: QuickAlertType.info,
                            //             text:
                            //                 "We will sent a password reset link to your email. Click 'Ok' to continue.",
                            //             titleAlignment: TextAlign.center,
                            //             textAlignment: TextAlign.center,
                            //             confirmBtnText: 'Ok',
                            //             cancelBtnText: 'No',
                            //             confirmBtnColor: Colors.blue,
                            //             backgroundColor: Colors.white,
                            //             headerBackgroundColor: Colors.grey,
                            //             confirmBtnTextStyle: const TextStyle(
                            //               color: Colors.white,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //             titleColor: Colors.black,
                            //             textColor: Colors.black,
                            //           );
                            //         },
                            //         style: ElevatedButton.styleFrom(
                            //           backgroundColor:
                            //               Color.fromRGBO(26, 60, 105, 1.0),
                            //           // Custom background color
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(
                            //                 25), // Rounded corners
                            //           ),
                            //         ),
                            //         child: 'Change Password'
                            //             .text
                            //             .color(Colors.white)
                            //             .bold // Bold text
                            //             .make(),
                            //       ),
                            //     ),
                            //     SizedBox(width: 10),
                            //     SizedBox(
                            //       height: 40,
                            //       child: ElevatedButton(
                            //         onPressed: () async {
                            //           QuickAlert.show(
                            //             onCancelBtnTap: () {
                            //               Navigator.pop(context);
                            //             },
                            //             onConfirmBtnTap: () async {
                            //               await FirebaseAuth.instance.signOut();
                            //               setState(() {
                            //                 bUuId = null;
                            //                 ownerEmail = null;
                            //                 boardersEmail = null;
                            //               });
                            //               Navigator.pop(context);
                            //               Navigator.of(context)
                            //                   .pushAndRemoveUntil(
                            //                 MaterialPageRoute(
                            //                   builder: (context) =>
                            //                       AuthWrapper(),
                            //                 ),
                            //                 (Route<dynamic> route) =>
                            //                     false, // Removes all previous routes
                            //               );
                            //             },
                            //             context: context,
                            //             type: QuickAlertType.confirm,
                            //             text: 'Do you want to Log out?',
                            //             titleAlignment: TextAlign.center,
                            //             textAlignment: TextAlign.center,
                            //             confirmBtnText: 'Yes',
                            //             cancelBtnText: 'No',
                            //             confirmBtnColor: Colors.blue,
                            //             backgroundColor: Colors.white,
                            //             headerBackgroundColor: Colors.grey,
                            //             confirmBtnTextStyle: const TextStyle(
                            //               color: Colors.white,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //             titleColor: Colors.black,
                            //             textColor: Colors.black,
                            //           );
                            //         },
                            //         style: ElevatedButton.styleFrom(
                            //           backgroundColor: Colors.green,
                            //           // Custom background color
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(
                            //                 25), // Rounded corners
                            //           ),
                            //         ),
                            //         child: 'Log out'
                            //             .text
                            //             .color(Colors.white)
                            //             .bold // Bold text
                            //             .make(),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
                .height(MediaQuery.of(context).size.height)
                .width(MediaQuery.of(context).size.width)
                .white
                .make(),
          );
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
        displayTime: Duration(seconds: 1),
        useAnimation: true,
        maskColor: Colors.green,
        'Copied!');
  }
}
