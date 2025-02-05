// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:bh_finder/Admin/admin.home.dart';
import 'package:bh_finder/Screen/Deleted/deleted.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Loading/home.loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/waiting.verification.screen.dart';
import 'package:bh_finder/Screen/Owner/owner.nav.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:bh_finder/Screen/SignUp/waiting.screen.dart';
import 'package:bh_finder/Screen/guest/home.guest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screen/BHouse/room.cache.dart';
import '../Screen/Home/nav.home.dart';
import '../Screen/Owner/new/new.nav.owner.dart';
import '../Screen/Owner/owner.home.screen.dart';
import '../Screen/SignUp/guest.screen.dart';
import '../cons.dart';

class Wrapper extends StatefulWidget {
  final String datas;
  const Wrapper({Key? key, required this.datas}) : super(key: key,);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = FirebaseAuth.instance.currentUser?.email;
    print(email);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc('$email')
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> userData) {
        if (!userData.hasData) {
          return HomeLoadingScreen();
        } else if (userData.connectionState == ConnectionState.waiting) {
          return HomeLoadingScreen();
        } else if (userData.hasError) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Something went wrong!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 231, 25, 25),
                ),
              )
            ],
          );
        } else if (userData.hasData) {
          return Builder(
            builder: (
              context,
            ) {
              if ((userData.data!['verified'] == true) &&
                  (userData.data!['role'] == "Owner")) {
                return NewOwnerNav();
              } else if ((userData.data!['role'] == "Owner") &&
                  (userData.data!['deleted'] == true)) {
                return ScreenDeleted();
              } else if ((userData.data!['verified'] == true) &&
                  (userData.data!['role'] == "Boarder") &&
                  (user != null && !user.emailVerified)) {
                return WaitEmailVerify();
              } else if ((userData.data!['verified'] == true) &&
                  (userData.data!['role'] == "Boarder") &&
                  (user != null && user.emailVerified) &&
                  widget.datas != '') {
                return RoomCache();
              }else if ((userData.data!['verified'] == true) &&
                  (userData.data!['role'] == "Boarder") &&
                  (user != null && user.emailVerified) &&
                  widget.datas == '') {
                bUuId = userData.data!['UuId'];
                fName = userData.data!['FirstName'];
                mName = userData.data!['MiddleName'];
                lName = userData.data!['LastName'];
                bPhoneNumber = userData.data!['PhoneNumber'];
                return NavHome();
              } else if ((userData.data!['verified'] == true) &&
                  (userData.data!['role'] == "Admin") &&
                  (user != null && user.emailVerified)) {
                return AdminHomeScreen();
              } else if ((userData.data!['verified'] == false) &&
                  (userData.data!['role'] == "Owner")) {
                return WaitingVerificationScreen();
              } else if ((userData.data!['role'] == "Client")) {
                return NavHome();
              } else {
                return HomeGuest();
              }
            },
          );
        } else {
          return HomeGuest();
        }
      },
    );
  }
}
