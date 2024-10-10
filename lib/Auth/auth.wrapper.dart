// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Auth/wrapper.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screen/SignUp/waiting.screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

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
              return SignInScreen();
            }
          }),
    );
  }
}