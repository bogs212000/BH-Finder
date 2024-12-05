import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:uuid/v4.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Auth/auth.wrapper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  bool verified = false;
  bool loading = false;
  String? error;

  bool emailExists = false;
  bool isChecking = false;

  // Function to check if the email exists in Firestore
  Future<void> checkEmailExists(String email) async {
    if (email.isEmpty) {
      setState(() {
        emailExists = false;
      });
      return;
    }

    setState(() {
      isChecking = true; // Show loading while checking
    });

    try {
      // Reference the collection where the email is stored as document ID
      DocumentSnapshot emailDoc = await FirebaseFirestore.instance
          .collection('Users') // Replace with your collection name
          .doc(email)
          .get();

      setState(() {
        emailExists = emailDoc.exists;
      });
    } catch (e) {
      print("Error checking email existence: $e");
      setState(() {
        emailExists = false;
      });
    } finally {
      setState(() {
        isChecking = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: 'Create Account'.text.make(),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                  children: [
              Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: 'Please provide accurate and valid information during sign-up to ensure smooth account creation and service.'
                  .text.make(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 20),
              child: TextField(
                controller: firstName,
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
                  labelText: 'First Name',
                ),
                inputFormatters: [
                  // Formatter to convert input to uppercase
                  TextInputFormatter.withFunction(
                        (oldValue, newValue) =>
                        TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 20),
              child: TextField(
                controller: middleName,
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
                  labelText: 'Middle Name',
                ),
                inputFormatters: [
                  // Formatter to convert input to uppercase
                  TextInputFormatter.withFunction(
                        (oldValue, newValue) =>
                        TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 20),
              child: TextField(
                controller: lastName,
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
                  labelText: 'Last Name',
                ),
                inputFormatters: [
                  // Formatter to convert input to uppercase
                  TextInputFormatter.withFunction(
                        (oldValue, newValue) =>
                        TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 20),
              child: TextField(
                controller: address,
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
                  labelText: 'Address',
                ),
                inputFormatters: [
                  // Formatter to convert input to uppercase
                  TextInputFormatter.withFunction(
                        (oldValue, newValue) =>
                        TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 20),
              child: TextField(
                controller: contactNumber,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                  // Limit input to 11 characters
                  FilteringTextInputFormatter.digitsOnly,
                  // Only allow digits
                ],
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
                  labelText: 'Contact Number',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 5),
              child: TextField(
                controller: _email,
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
              onChanged: (email) {
                // Perform the check as the user types
                checkEmailExists(email.trim());
              },
            ),
          ),
          _email.text.isNotEmpty ? isChecking
              ? CircularProgressIndicator() // Show loading while checking
              : Text(
            emailExists
                ? 'This email address is already registered.'
                : '',
            style: TextStyle(
              color: emailExists ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ) : SizedBox(),
          Padding(
            padding: const EdgeInsets.only(
                left: 5, right: 5, bottom: 20, top: 15),
            child: TextField(
              controller: _password,
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
                labelText: 'Create Password',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 5, right: 5, bottom: 20),
            child: TextField(
              controller: _confirmPassword,
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
                labelText: 'Confirm Password',
              ),
            ),
          ),
          Padding(
            padding:
            EdgeInsets.only(left: 5, right: 5, bottom: 20),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.loading,
                    title: 'Loading...',
                    text: 'Please Wait',
                  );
                  if (firstName.text.isEmpty ||
                      middleName.text.isEmpty ||
                      lastName.text.isEmpty ||
                      address.text.isEmpty ||
                      contactNumber.text.isEmpty ||
                      _email.text.isEmpty ||
                      _password.text.isEmpty) {
                    setState(() {
                      error =
                      'Please complete the required details';
                    });
                    Navigator.pop(context);
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Error',
                      text: '$error',
                    );
                  } else if (_password.text !=
                      _confirmPassword.text) {
                    setState(() {
                      error = 'Password do not match';
                    });
                    Navigator.pop(context);
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Error',
                      text: '$error',
                    );
                  } else if (emailExists == true) {
                    setState(() {
                      error =
                      'This email is already associated with an account.';
                    });
                    Navigator.pop(context);
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Error',
                      text: '$error',
                    );
                  } else {
                    print('haha');
                    try {
                      // Generate a unique identifier for the user
                      String uuId = Uuid().v4();
                      print('Generated UUID: $uuId');

                      // Store user profile information in Firestore
                      await FirebaseFirestore.instance.collection('Users').doc(
                          _email.text.trim()).set({
                        'UuId': uuId,
                        'role': 'Boarder',
                        'createdAt': DateTime.now(),
                        'Email': _email.text.trim(),
                        'FirstName': firstName.text,
                        'MiddleName': middleName.text,
                        'LastName': lastName.text,
                        'Birthday': '',
                        'address': address.text,
                        'Image': '', // Placeholder for user image
                        'ImageID': '', // Placeholder for user image
                        'ImageIdPermit': '', // Placeholder for user image
                        'PhoneNumber': contactNumber.text,
                        'notification': 0,
                        'verified': true,
                        'token': '',
                      });
                      Navigator.of(context);
                      QuickAlert.show(
                        barrierDismissible: false,
                        onConfirmBtnTap: () {
                          print("Verification email sent.");
                          firstName.clear();
                          middleName.clear();
                          lastName.clear();
                          address.clear();
                          _email.clear();
                          _password.clear();
                          _confirmPassword.clear();
                          contactNumber.clear();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AuthWrapper()), // Change NextScreen() to your desired screen
                          );
                        },
                        context: context,
                        type: QuickAlertType.success,
                        title: 'Success!',
                        text: 'Please verify your email',
                      );
                      // Create user with email and password
                      await _auth.createUserWithEmailAndPassword(
                        email: _email.text.trim().toLowerCase(),
                        password: _password.text.trim(),
                      );
                    } on FirebaseAuthException catch (e) {
                      Navigator.pop(context);
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Error',
                        text: '$e',
                      );
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(26, 60, 105, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create Account",
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
    ),)
    ,
    ]
    ,
    )
    ,
    );
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
      displayTime: Duration(seconds: 3),
      maskColor: Colors.green,
      '$error',
      useAnimation: true,
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
