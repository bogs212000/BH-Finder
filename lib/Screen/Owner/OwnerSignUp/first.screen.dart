// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../Loading/loading.screen.dart';
import 'owner.signup.data.dart';

File?_imageID;
File? _imageBldgPermit;

class OwnerSignupFirst extends StatefulWidget {
  const OwnerSignupFirst({super.key});

  @override
  State<OwnerSignupFirst> createState() => _OwnerSignupFirstState();
}

class _OwnerSignupFirstState extends State<OwnerSignupFirst> {
  TextEditingController _ownerFirstName = TextEditingController();
  TextEditingController _ownerMiddleName = TextEditingController();
  TextEditingController _ownerLastName = TextEditingController();
  TextEditingController _ownerContactNumber = TextEditingController();
  TextEditingController _ownerAddress = TextEditingController();
  String date = "";
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        date = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();

    //IDs
    Future<void> _openImagePicker() async {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _imageID = File(pickedImage.path);
        });
        // setState(() {
        //   loading = false;
        // });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: 'Sign up'.text.make(),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  'Please ensure all required details are filled out accurately. Double-check the information for correctness before submitting.'
                      .text
                      .make(),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: _ownerFirstName,
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
                        labelText: 'First name',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: _ownerMiddleName,
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
                        labelText: 'Middle name',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: _ownerLastName,
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
                        labelText: 'Last name',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: _ownerContactNumber,
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
                          labelText: 'Contact Number',
                          hintText: '091XXXXXX0'),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                    child: TextField(
                      controller: _ownerAddress,
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
                          labelText: 'Boarding House Address',
                          hintText: ''),
                    ),
                  ),
                  'Please take a clear photo of your valid ID. Ensure all details are visible and legible.'
                      .text
                      .make(),
                  SizedBox(height: 20),
                  Container(
                    height: 150,
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        _openImagePicker();
                      },
                      child: _imageID != null
                          ? Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(_imageID!),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.blue[300],
                                  size: 50,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            ownerFirstName = _ownerFirstName.text.toString();
                            ownerMiddleName = _ownerMiddleName.text.toString();
                            ownerLastName = _ownerLastName.text.toString();
                            ownerContactNumber =
                                _ownerContactNumber.text.toString();
                          });
                          print(
                              '$ownerFirstName $ownerMiddleName $ownerLastName - $ownerContactNumber');
                          Navigator.pushNamed(
                              context, '/OwnerSignupSecondScreen');
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
                              "Next",
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
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

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


//Second
class OwnerSignupSecond extends StatefulWidget {
  const OwnerSignupSecond({super.key});

  @override
  State<OwnerSignupSecond> createState() => _OwnerSignupSecondState();
}

class _OwnerSignupSecondState extends State<OwnerSignupSecond> {
  TextEditingController _boardingHouseName = TextEditingController();
  final _picker = ImagePicker();

  //IDs
  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _imageBldgPermit = File(pickedImage.path);
      });
      // setState(() {
      //   loading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: 'Supporting Documents'.text.make(),
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
                    controller: _boardingHouseName,
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
                      labelText: 'Boarding House Name',
                    ),
                  ),
                ),
                'Please take a clear photo of your building permit, ensuring that all information is visible and easy to read.'
                    .text
                    .make(),
                SizedBox(height: 20),
                Container(
                  height: 150,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      _openImagePicker();
                    },
                    child: _imageBldgPermit != null
                        ? Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_imageBldgPermit!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                        : Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.blue[300],
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                )
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
                          boardingHouseName =
                              _boardingHouseName.text.toString();
                        });
                        print(
                            '$ownerFirstName $ownerMiddleName $ownerLastName - $ownerContactNumber - $boardingHouseName');
                        Navigator.pushNamed(context, '/OwnerSignupThirdScreen');
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
                            "Next",
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


//Third
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
                          String url;
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('${_ownerEmail.text.trim()}/$ownerUId');
                          await ref.putFile(File(_imageID!.path));
                          url = await ref.getDownloadURL();

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