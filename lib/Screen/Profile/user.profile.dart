import 'package:bh_finder/Auth/auth.wrapper.dart';
import 'package:bh_finder/Screen/Loading/loading.bhouse.screen.dart';
import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Profile/user.edit.profile.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

import '../Home/home.screen.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<DocumentSnapshot> profile;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  bool loading = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    profile = FirebaseFirestore.instance.collection('Users').doc('$userEmail').get();
  }

  @override
  void dispose() {
    _refreshController.dispose(); // Dispose of the controller
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Refresh your profile data
    setState(() {
      profile = FirebaseFirestore.instance.collection('Users').doc('$userEmail').get();
    });
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                // Your action here
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
          )
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false, // Assuming no pull-up loading is needed
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: 	WaterDropMaterialHeader(
          distance: 30,
        ), // Custom loading header
        child: FutureBuilder<DocumentSnapshot>(
          future: profile,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingBHouseScreen();
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No Reservation found'));
            }
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.account_circle_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
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
                        Row(children: ['Profile'.text.bold.size(25).make()]),
                        Divider(),
                        Row(
                          children: [
                            'Name :'.text.light.size(15).make(),
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
                            '${data['PhoneNumber']}'.text.light.size(15).make(),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserEditProfile(
                                  first: data['FirstName'],
                                  middle: data['MiddleName'],
                                  last: data['LastName'],
                                  address: data['address'],
                                  email: data['Email'],
                                  phoneNum: data['PhoneNumber'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: 'Edit Profile'.text.color(Colors.white).bold.make(),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            QuickAlert.show(
                              onCancelBtnTap: () {
                                Navigator.pop(context);
                              },
                              onConfirmBtnTap: () async {
                                await FirebaseAuth.instance.signOut();
                                setState(() {
                                  bUuId = null;
                                  ownerEmail = null;
                                  boardersEmail = null;
                                });
                                Navigator.pop(context);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => AuthWrapper(),
                                  ),
                                      (Route<dynamic> route) =>
                                  false, // Removes all previous routes
                                );
                              },
                              context: context,
                              type: QuickAlertType.confirm,
                              text: 'Do you want to Log out?',
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: 'Log out'.text.color(Colors.white).bold.make(),
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
                        child: 'Terms And Conditions'.text.light.make(),
                      ),
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
      'Copied!',
    );
  }
}
