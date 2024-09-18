// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:flutter/material.dart';

import 'Screen/BHouse/bh.screen.dart';
import 'Screen/BHouse/room.screen.dart';

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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/HomeScreen': (context) => HomeScreen(),
        '/SignInScreen': (context) => SignInScreen(),
        '/BHScreen': (context) => BHouseScreen(),
        '/RoomScreen': (context) => RoomScreen(),
      }
    );
  }
}
