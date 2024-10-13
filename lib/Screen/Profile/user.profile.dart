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

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<DocumentSnapshot> profile;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    profile =
        FirebaseFirestore.instance.collection('Users').doc('$userEmail').get();
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
            appBar: AppBar(),
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
                  child: SingleChildScrollView(
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
                              Row(
                                children: ['Profile'.text.bold.size(25).make()],
                              ),
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
                                  '${data['Address']}'
                                      .text
                                      .light
                                      .size(15)
                                      .make(),
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
                                        address: data['Address'],
                                        email: data['Email'],
                                        phoneNum: data['PhoneNumber'],
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
                                      Navigator.pop(context);
                                      setState(() {
                                        loading = true;
                                      });
                                      await FirebaseAuth.instance.signOut();
                                      setState(() {
                                        loading = false;
                                      });
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
                                  // Custom background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        25), // Rounded corners
                                  ),
                                ),
                                child: 'Log out'
                                    .text
                                    .color(Colors.white)
                                    .bold // Bold text
                                    .make(),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
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
