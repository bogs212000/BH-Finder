// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Screen/ForgotPass/forgotpass.screen.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/second.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/third.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:flutter/material.dart';

import 'Screen/BHouse/bh.screen.dart';
import 'Screen/BHouse/room.screen.dart';
import 'Screen/Owner/OwnerSignUp/first.screen.dart';
import 'Screen/Owner/owner.home.screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BH Finder',
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/HomeScreen': (context) => HomeScreen(),
        '/SignInScreen': (context) => SignInScreen(),
        '/BHScreen': (context) => BHouseScreen(),
        '/RoomScreen': (context) => RoomScreen(),
        '/ForgotPassScreen': (context) => ForgotPassScreen(),
        '/OwnerHomeScreen': (context) => OwnerHomeScreen(),
        '/OwnerSignupFirstScreen': (context) => OwnerSignupFirst(),
        '/OwnerSignupSecondScreen': (context) => OwnerSignupSecond(),
        '/OwnerSignupThirdScreen': (context) => OwnerSignupThird(),
      }
    );
  }
}
