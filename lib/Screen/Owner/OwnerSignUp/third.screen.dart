import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:uuid/v4.dart';
import 'package:velocity_x/velocity_x.dart';

class OwnerSignupThird extends StatefulWidget {
  const OwnerSignupThird({super.key});

  @override
  State<OwnerSignupThird> createState() => _OwnerSignupThirdState();
}

class _OwnerSignupThirdState extends State<OwnerSignupThird> {
  TextEditingController _ownerEmail = TextEditingController();
  TextEditingController _ownerPassword = TextEditingController();
  TextEditingController _ownerConfirmPassword = TextEditingController();
  bool verified = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? LoadingScreen() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: 'Finalizing'.text.make(),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                  child: TextField(
                    controller: _ownerEmail,
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
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                  child: TextField(
                    controller: _ownerPassword,
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
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                  child: TextField(
                    controller: _ownerConfirmPassword,
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
                        setState(() {
                          loading = true;
                        });
                        String ownerUId = Uuid().v4();
                        print('Uuid : $ownerUId');
                        try {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(_ownerEmail.text.trim())
                              .set({
                            'OwnerUId': ownerUId,
                            'role': 'Owner',
                            'createdAt': DateTime.now(),
                            'BoardingHouseName': boardingHouseName,
                            'Email': _ownerEmail.text.trim(),
                            'FirstName': ownerFirstName,
                            'MiddleName': ownerMiddleName,
                            'LastName': ownerLastName,
                            'Birthday': '',
                            'Image': '',
                            'Rules': '',
                            'PhoneNumber': ownerContactNumber,
                            'verified': verified,
                          });
                          await FirebaseFirestore.instance
                              .collection('BoardingHouses')
                              .doc(_ownerEmail.text.trim())
                              .set({
                            'OwnerUId': ownerUId,
                            'BoardingHouseName': boardingHouseName,
                            'PhoneNumber': ownerContactNumber,
                            'lat': '',
                            'long': '',
                            'createdAt': DateTime.now(),
                            'Email': _ownerEmail.text.trim(),
                            'FirstName': ownerFirstName,
                            'MiddleName': ownerMiddleName,
                            'LastName': ownerLastName,
                            'BuildingPermitImage': '',
                            'Rules': '',
                            'verified': verified,
                          });
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                              email: _ownerEmail.text.trim(),
                              password: _ownerPassword.text.trim());
                          setState(() {
                            loading = false;
                          });
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            loading = false;
                          });
                          print(e);
                        }
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
                            "Request Account",
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
