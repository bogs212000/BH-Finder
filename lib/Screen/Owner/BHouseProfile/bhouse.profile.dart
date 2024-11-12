import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Profile/user.edit.profile.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

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
    profile =
        FirebaseFirestore.instance.collection('BoardingHouses').doc('$userEmail').get();
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
      appBar: AppBar(actions: [Padding(
        padding: EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).pushAndRemoveUntil(
            //   _toNotificationScreen(),
            //       (Route<dynamic> route) => false,
            // );
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 0.3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.settings,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ),
        ),
      )],),
      body: FutureBuilder<DocumentSnapshot>(
        future: profile,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No Reservation found'));
          }
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [

                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
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
                  child: Column(
                    children: [
                      Row(
                        children: ['Boarding House Profile'.text.bold.size(20).make()],
                      ),
                      Divider(),
                      Row(
                        children: [
                          'Boarding House :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['BoardingHouseName']}'
                              .text
                              .light
                              .size(15)
                              .make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Owner :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['FirstName']} ${data['MiddleName']} ${data['LastName']}'
                              .text
                              .light
                              .size(15)
                              .make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Email :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['Email']}'.text.light.size(15).make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Contact Number :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['PhoneNumber']}'
                              .text
                              .light
                              .size(15)
                              .make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Address :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['address']}'.text.light.size(15).make(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          QuickAlert.show(
                            onCancelBtnTap: () {
                              Navigator.pop(context);
                            },
                            onConfirmBtnTap: () async {
                              Navigator.pop(context);
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                    email: data['Email'].toString());
                                message = "Password reset email sent.";
                              } catch (e) {
                                message =
                                "Error sending password reset email";
                              }
                              _toast();
                            },
                            context: context,
                            type: QuickAlertType.info,
                            text:
                            "We will sent a password reset link to your email. Click 'Ok' to continue.",
                            titleAlignment: TextAlign.center,
                            textAlignment: TextAlign.center,
                            confirmBtnText: 'Ok',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(26, 60, 105, 1.0),
                          // Custom background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(25), // Rounded corners
                          ),
                        ),
                        child: 'Change Password'
                            .text
                            .color(Colors.white)
                            .bold // Bold text
                            .make(),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
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
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          // Custom background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25), // Rounded corners
                          ),
                        ),
                        child: 'Edit Profile'
                            .text
                            .color(Colors.white)
                            .bold // Bold text
                            .make(),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/TermsAndConditions');
                        },
                        child: 'Terms And Conditions'.text.light.make()),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    'Users Guide'.text.light.make(),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
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
