import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';

class WaitEmailVerify extends StatefulWidget {
  const WaitEmailVerify({super.key});

  @override
  State<WaitEmailVerify> createState() => _WaitEmailVerifyState();
}

class _WaitEmailVerifyState extends State<WaitEmailVerify> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading ? LoadingScreen() : Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/112417-verify-your-email.json', height: 200),
            Row(
              children: [
                'Verify Email'.text.bold.make(),
              ],
            ),
            SizedBox(height: 10),
            "Please verify your email. We've sent a verification link to your inbox. Check your spam or junk folder if you don't see it"
                .text
                .make(),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null &&
                    !user.emailVerified) {
                  await user.sendEmailVerification();
                }
                setState(() {
                  loading = false;
                });

                await FirebaseAuth.instance.signOut();
              },
              child: Text('Verify email'),
            )

          ],
        ),
      ),
    );
  }
}
