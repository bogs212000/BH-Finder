// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:velocity_x/velocity_x.dart';

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
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              if (_password.text.isEmpty ||
                                  _emailPhonenumber.text.isEmpty) {
                                setState(() {});
                              } else {
                                try {
                                  setState(() {
                                    loading = true;
                                  });
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: _emailPhonenumber.text.trim(),
                                          password: _password.text.trim());
                                  setState(() {
                                    loading = false;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    loading = false;
                                  });
                                  print(e);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF31355C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign in",
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
                        child: Text(
                          "Don't have an account?",
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/OwnerSignupFirstScreen');
                        },
                        child: 'Boarding House Owner'.text.bold.size(16).make(),
                      ),
                      SizedBox(height: 40)
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
