// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Auth/wrapper.dart';
import 'package:bh_finder/Screen/BHouse/room.cache.dart';
import 'package:bh_finder/Screen/Home/guest.home.screen.dart';
import 'package:bh_finder/Screen/SignUp/guest.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:bh_finder/Screen/guest/home.guest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screen/Home/home.screen.dart';
import '../Screen/SignUp/waiting.screen.dart';
import '../cons.dart';

class AuthWrapper extends StatefulWidget {
  final String? roomCaches;
  const AuthWrapper({super.key, this.roomCaches});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  initState() {
    setState(() {
      roomCaches = widget.roomCaches;
    });
    print('#### room cache - ${widget.roomCaches} Auth Wrapper ####');
    super.initState();
  }
  // Future<void> loadSharedPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     roomCache = prefs.getString('roomCache') ?? ''; // Handle null case
  //   });
  //
  // }

  // @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Something went wrong."),
              );
            } else if (snapshot.hasData) {
              return Wrapper();
            } else {
              return HomeGuest();
            }
          }),
    );
  }
}
