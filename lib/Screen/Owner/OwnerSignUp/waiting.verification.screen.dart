// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../Auth/auth.wrapper.dart';

class WaitingVerificationScreen extends StatefulWidget {
  const WaitingVerificationScreen({super.key});

  @override
  State<WaitingVerificationScreen> createState() => _WaitingVerificationScreenState();
}

class _WaitingVerificationScreenState extends State<WaitingVerificationScreen> {

  @override
  void initState() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/119400-waiting.json', height: 100),
                'We are currently reviewing your data, which may take 1 to 3 hours. Please check back later.'
                    .text.size(16)
                    .make()
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => AuthWrapper(),
                          ),
                              (Route<dynamic> route) =>
                          false, // Removes all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF31355C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Back to Log In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Route _toSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => SignInScreen(),
      transitionDuration: Duration(milliseconds: 1000),
      reverseTransitionDuration: Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
            parent: animation,
            reverseCurve: Curves.fastOutSlowIn,
            curve: Curves.fastLinearToSlowEaseIn);

        return SlideTransition(
            position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                .animate(animation),
            textDirection: TextDirection.rtl,
            child: SignInScreen());
      },
    );
  }
}
