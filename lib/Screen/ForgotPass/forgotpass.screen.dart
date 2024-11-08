// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:velocity_x/velocity_x.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  TextEditingController emailController = TextEditingController();
  String? msg;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              title: "Forgot Password".text.bold.size(16).make(),
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  "A link to reset your password will be sent to your email. Follow the instructions to update your password."
                      .text
                      .make(),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: emailController,
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
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            QuickAlert.show(
                                title: 'Loading',
                                text: 'Please wait...',
                                context: context,
                                type: QuickAlertType.loading);
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailController.text.trim());
                            Navigator.pop(context);
                            QuickAlert.show(
                                title: 'Success!',
                                text: 'Password reset email sent.',
                                onConfirmBtnTap: (){
                                  Navigator.pop(context);
                                },
                                context: context,
                                type: QuickAlertType.success);
                            print("Password reset email sent.");
                          } catch (e) {
                            print("Error sending password reset email: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF31355C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Change Password",
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
                ],
              ),
            ),
          );
  }

  Future<void> resetpassword() async {
    final _auth = FirebaseAuth.instance;
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      emailController.clear();
      setState(() {
        loading = false;
      });
      showAlertDialog(context);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == "invalid-email") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 5),
              Text("Please input a valid email."),
            ],
          ),
          duration: Duration(seconds: 2),
        ));
      } else if (e.code == "user-not-found") {
        msg = " User not found.";
      } else if (e.code == "network-request-failed") {
        msg = "Network request failed.";
      } else {
        msg = "Something went wrong.";
      }
      setState(() {
        loading = false;
      });
      // functions.NoticeErrorBox(context, msg);
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Icon(Icons.email),
      content: Text("Check you email for reset password link."),
      actions: [],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
