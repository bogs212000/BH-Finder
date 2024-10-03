// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/waiting.verification.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Screen/Owner/owner.home.screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

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
          return Center(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie.asset('assets/Lottie/119400-waiting.json',
                  //     height: 50),
                  const Text("Loading please wait...",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.blueGrey,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        } else if (userData.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie.asset('assets/Lottie/119400-waiting.json',
                  //     height: 50),
                  SizedBox(width: 5),
                  const Text("Loading please wait...",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.blueGrey,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
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
              if ((userData.data!['verified'] == true) &
                  (userData.data!['role'] == "Owner")) {
                return OwnerHomeScreen();
              } else if ((userData.data!['verified'] == false) &
                  (userData.data!['role'] == "Owner")) {
                return WaitingVerificationScreen();
              } else if ((userData.data!['role'] == "Client")) {
                return HomeScreen();
              } else {
                return SignInScreen();
              }
            },
          );
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
