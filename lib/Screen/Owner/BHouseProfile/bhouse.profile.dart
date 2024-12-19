import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Profile/user.edit.profile.dart';
import 'package:bh_finder/Screen/about/about.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('BoardingHouses').doc(FirebaseAuth.instance.currentUser!.email.toString()).snapshots(),
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
                        children: [Flexible(child: data['BoardingHouseName'].toString().text.overflow(TextOverflow.ellipsis).bold.size(16).make())],
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
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
                        },
                        child: Row(
                          children: [
                            Icon(Icons.house_rounded, size: 15),
                            ' Manage info'.text.light.size(15).make(),
                            Spacer(),
                            Icon(Icons.navigate_next, size: 15),
                          ],
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){

                        },
                        child: Row(
                          children: [
                            Icon(Icons.pan_tool_alt, size: 12),
                            ' Guide'.text.light.size(15).make(),
                            Spacer(),
                            Icon(Icons.navigate_next, size: 15),
                          ],
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(
                              context, '/TermsAndConditions');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.book, size: 12),
                            ' Terms and Conditions'.text.light.size(15).make(),
                            Spacer(),
                            Icon(Icons.navigate_next, size: 15),
                          ],
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          Get.to(()=>AboutScreen());
                        },
                        child: Row(
                          children: [
                            Icon(Icons.apps, size: 12),
                            ' About'.text.light.size(15).make(),
                            Spacer(),
                            Icon(Icons.navigate_next, size: 15),
                          ],
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: () {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.confirm,
                            text: "Are you sure you want to delete this account?",
                            titleAlignment: TextAlign.center,
                            textAlignment: TextAlign.center,
                            confirmBtnText: 'No',
                            cancelBtnText: 'Yes',
                            confirmBtnColor: Colors.red,
                            backgroundColor: Colors.white,
                            headerBackgroundColor: Colors.grey,
                            confirmBtnTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            titleColor: Colors.black,
                            textColor: Colors.black,
                            onConfirmBtnTap: () {
                              Navigator.pop(context); // Close dialog on "No"
                            },
                            onCancelBtnTap: () async {
                              Navigator.pop(context); // Close dialog on "Yes"

                              // Show loading dialog
                              QuickAlert.show(
                                barrierDismissible: false,
                                context: context,
                                type: QuickAlertType.loading,
                                title: 'Deleting account',
                                text: 'Please wait...',
                              );

                              try {
                                // Backup current user info
                                final user = FirebaseAuth.instance.currentUser;
                                final userEmail = user?.email ?? "";

                                // Delete Firestore documents
                                if (userEmail.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('BoardingHouses')
                                      .doc(userEmail)
                                      .delete();
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(userEmail)
                                      .delete();
                                }

                                // Delete Firebase Authentication account
                                await user?.delete();

                                // Navigate to AuthWrapper
                                Get.offAll(() => AuthWrapper());
                              } on FirebaseAuthException catch (e) {
                                Navigator.pop(context); // Close loading dialog
                                if (e.code == 'requires-recent-login') {
                                  // Re-authentication required
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Re-authentication needed',
                                    text: 'Please log in again to delete your account.',
                                  );
                                } else {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error',
                                    text: e.message ?? "An unknown error occurred.",
                                  );
                                }
                              } catch (e) {
                                Navigator.pop(context); // Close loading dialog
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Error',
                                  text: "Failed to delete the account. Try again later.",
                                );
                              } finally {
                                _toast(); // Custom toast notification
                              }
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 12),
                            ' Delete account'.text.light.red600.size(15).make(),
                            Spacer(),
                            Icon(Icons.delete_outline, color: Colors.red, size: 15),
                          ],
                        ),
                      ),

                      Divider(),


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
                          backgroundColor: Colors.green,
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
                ),
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
