// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:bh_finder/Auth/auth.wrapper.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Auth/wrapper.dart';
import '../Loading/loading.screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _password = TextEditingController();
  TextEditingController _emailPhonenumber = TextEditingController();
  bool _isPasswordVisible = false;
  bool loadingLogin = false;
  String? errors;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _password.dispose();
    _emailPhonenumber.dispose();
    super.dispose(); // Call the super dispose method
  }

  @override
  Widget build(BuildContext context) {
    return loadingLogin
        ? LoadingScreen()
        : WillPopScope(
            onWillPop: () async {
              Get.back();
              // Navigate back using GetX
              return false; // Prevent default back button behavior
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              scale: 3,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            'Discover your'
                                .text
                                .light
                                .color(Colors.grey)
                                .size(25)
                                .make(),
                          ],
                        ),
                        Row(
                          children: [
                            'perfect place to stay'
                                .text
                                .bold
                                .color(Colors.black)
                                .size(25)
                                .make(),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(curve: Curves.fastOutSlowIn)
                            .move(delay: 100.ms, duration: 1000.ms),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _emailPhonenumber,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Email',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _password,
                            obscureText: !_isPasswordVisible,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/ForgotPassScreen');
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Forgot your password?',
                                    ),
                                    Icon(Icons.arrow_forward,
                                        color: Color(0xFF31355C))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 20),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_password.text.isEmpty &&
                                    _emailPhonenumber.text.isEmpty) {
                                  setState(() {
                                    errors =
                                        'Please input your email and password';
                                  });
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error',
                                    text: '$errors',
                                  );
                                } else if (_emailPhonenumber.text.isEmpty) {
                                  setState(() {
                                    errors = 'Please input your email';
                                  });
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error',
                                    text: '$errors',
                                  );
                                } else if (_password.text.isEmpty) {
                                  setState(() {
                                    errors = 'Please input your password';
                                  });
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Error',
                                    text: '$errors',
                                  );
                                } else {
                                  QuickAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    type: QuickAlertType.loading,
                                    title: 'Signing in...',
                                    text: 'Please Wait',
                                  );
                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                      email: _emailPhonenumber.text.trim(),
                                      password: _password.text.trim(),
                                    );
                                    Navigator.pop(context);
                                    // Navigate to HomeScreen after closing pop-ups
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AuthWrapper()), // Replace with your HomeScreen
                                    );
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.success,
                                      title: 'Hello!',
                                      text: 'Welcome to BH Finder app!',
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    Navigator.pop(context);
                                    setState(() {
                                      errors = e
                                          .message; // Show a user-friendly error message
                                    });
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'Error',
                                      text: '$errors',
                                    );
                                    print('Error: $e');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(26, 60, 105, 1.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Log in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/SignUpScreen');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Don't have an account?  ".text.light.make(),
                              "Sign up".text.bold.make(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/TermsAndConditions');
                          },
                          child: 'Terms and Conditions'
                              .text
                              .light
                              .color(Colors.black)
                              .make(),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/OwnerSignupFirstScreen');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              'Boarding House Owner?'
                                  .text
                                  .light
                                  .size(16)
                                  .make(),
                              '  Sign up'.text.bold.size(16).make(),
                            ],
                          ),
                        ),
                        SizedBox(height: 30)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
        displayTime: Duration(seconds: 3),
        useAnimation: true,
        maskColor: Colors.green,
        '$errors');
  }
}
