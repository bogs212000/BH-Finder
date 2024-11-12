import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class WaitEmailVerify extends StatefulWidget {
  const WaitEmailVerify({super.key});

  @override
  State<WaitEmailVerify> createState() => _WaitEmailVerifyState();
}

class _WaitEmailVerifyState extends State<WaitEmailVerify> {
  bool loading = false;
  String? message;

  @override
  void initState() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Container(
              padding: EdgeInsets.all(25),
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/112417-verify-your-email.json',
                      height: 200),
                  'Verify Email'.text.bold.make(),
                  SizedBox(height: 10),
                  "Please verify your email by clicking the verification link we've sent to your inbox. If you don’t see it, please check your spam or junk folder. Once verified, you can log in to your account."
                      .text
                      .make(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.loading,
                        title: 'Loading...',
                        text: 'Sending verification email.',
                      );
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && !user.emailVerified) {
                        await user.sendEmailVerification();
                      }
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        title: 'Verification',
                        text: 'Email Verification sent!',
                      );
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Text('Verify email'),
                  )
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
        '$message');
  }
}
