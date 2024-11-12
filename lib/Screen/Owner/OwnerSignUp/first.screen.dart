// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../Auth/auth.wrapper.dart';
import '../../Loading/loading.screen.dart';
import 'owner.signup.data.dart';

File? _imageID;
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
  TextEditingController _homeAddress = TextEditingController();
  String date = "";
  DateTime selectedDate = DateTime.now();
  String? errors;

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
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
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
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                        // Limit input to 11 characters
                        FilteringTextInputFormatter.digitsOnly,
                        // Only allow digits
                      ],
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
                      controller: _homeAddress,
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
                          labelText: 'Home Address',
                          hintText: ''),
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
                          if (_ownerFirstName.text.isEmpty ||
                              _ownerMiddleName.text.isEmpty ||
                              _ownerLastName.text.isEmpty ||
                              _ownerAddress.text.isEmpty ||
                              _ownerContactNumber.text.isEmpty ||
                              _imageID == null) {
                            setState(() {
                              errors = 'Please complete the required details';
                            });
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Error',
                              text: '$errors',
                            );
                          } else {
                            setState(() {
                              ownerFirstName = _ownerFirstName.text.toString();
                              ownerMiddleName =
                                  _ownerMiddleName.text.toString();
                              ownerLastName = _ownerLastName.text.toString();
                              ownerContactNumber =
                                  _ownerContactNumber.text.toString();
                              boardingHouseAddress =
                                  _ownerAddress.text.toString();
                            });
                            print(
                                '$ownerFirstName $ownerMiddleName $ownerLastName - $ownerContactNumber');
                            Navigator.pushNamed(
                                context, '/OwnerSignupSecondScreen');
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
              children: [],
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
  String? errors;

  //IDs
  Future<void> _openImagePicker() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
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
                        if (_boardingHouseName.text.isEmpty ||
                            _imageBldgPermit == null) {
                          setState(() {
                            errors = 'Please complete the required details';
                          });
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'Error',
                            text: '$errors',
                          );
                        } else {
                          setState(() {
                            boardingHouseName =
                                _boardingHouseName.text.toString();
                          });
                          print(
                              '$ownerFirstName $ownerMiddleName $ownerLastName - $ownerContactNumber - $boardingHouseName - $boardingHouseAddress');
                          Navigator.pushNamed(
                              context, '/OwnerSignupThirdScreen');
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
  bool emailExists = false;
  bool isChecking = false;
  String? error;

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
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, bottom: 5),
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
                          onChanged: (email) {
                            // Perform the check as the user types
                            checkEmailExists(email.trim());
                          },
                        ),
                      ),
                      _ownerEmail.text.isNotEmpty
                          ? isChecking
                              ? CircularProgressIndicator() // Show loading while checking
                              : Text(
                                  emailExists
                                      ? 'This email address is already registered.'
                                      : '',
                                  style: TextStyle(
                                    color:
                                        emailExists ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : SizedBox(),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
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
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
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
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 20),
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_ownerEmail.text.isEmpty ||
                                  _ownerPassword.text.isEmpty ||
                                  _ownerConfirmPassword.text.isEmpty) {
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
                              } else if (_ownerPassword.text !=
                                  _ownerConfirmPassword.text) {
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
                              } else {
                                String ownerUId = Uuid().v4();
                                print('Uuid : $ownerUId');
                                QuickAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  type: QuickAlertType.loading,
                                  title: 'Loading...',
                                  text: 'Please Wait',
                                );
                                try {
                                  String url;
                                  String url2;
                                  // Get the application directory
                                  final appDocDir =
                                      await getApplicationDocumentsDirectory();
                                  final filePath =
                                      "${appDocDir.absolute}/path/to/${_ownerEmail.text}.jpg";
                                  final file = File(_imageID!
                                      .path); // Use selected image path

                                  final appDocDir2 =
                                      await getApplicationDocumentsDirectory();
                                  final filePath2 =
                                      "${appDocDir.absolute}/path/to/${_ownerEmail.text}.jpg";
                                  final file2 = File(_imageBldgPermit!.path);

                                  // Create metadata for the image
                                  final metadata = SettableMetadata(
                                      contentType: "image/jpeg");

                                  // Create a reference to Firebase Storage
                                  final storageRef =
                                      FirebaseStorage.instance.ref();

                                  // Upload file and metadata to Firebase Storage
                                  final uploadTask = storageRef
                                      .child(
                                          "OwnersImages/${DateTime.now().toString()}.jpg")
                                      .putFile(file, metadata);

                                  // Upload file and metadata to Firebase Storage
                                  final uploadTask2 = storageRef
                                      .child(
                                          "OwnersImages/${DateTime.now().toString()}.jpg")
                                      .putFile(file2, metadata);

                                  // Listen for state changes, errors, and completion of the upload.
                                  uploadTask.snapshotEvents
                                      .listen((TaskSnapshot taskSnapshot) {
                                    switch (taskSnapshot.state) {
                                      case TaskState.running:
                                        final progress = 100.0 *
                                            (taskSnapshot.bytesTransferred /
                                                taskSnapshot.totalBytes);
                                        print("Upload is $progress% complete.");
                                        break;
                                      case TaskState.paused:
                                        print("Upload is paused.");
                                        break;
                                      case TaskState.canceled:
                                        print("Upload was canceled");
                                        break;
                                      case TaskState.error:
                                        print("Upload encountered an error.");
                                        break;
                                      case TaskState.success:
                                        print("Upload successful!");
                                        break;
                                    }
                                  });

                                  uploadTask2.snapshotEvents
                                      .listen((TaskSnapshot taskSnapshot) {
                                    switch (taskSnapshot.state) {
                                      case TaskState.running:
                                        final progress = 100.0 *
                                            (taskSnapshot.bytesTransferred /
                                                taskSnapshot.totalBytes);
                                        print("Upload is $progress% complete.");
                                        break;
                                      case TaskState.paused:
                                        print("Upload is paused.");
                                        break;
                                      case TaskState.canceled:
                                        print("Upload was canceled");
                                        break;
                                      case TaskState.error:
                                        print("Upload encountered an error.");
                                        break;
                                      case TaskState.success:
                                        print("Upload successful!");
                                        break;
                                    }
                                  });

                                  // Get download URL after successful upload
                                  url = await (await uploadTask)
                                      .ref
                                      .getDownloadURL();
                                  url2 = await (await uploadTask2)
                                      .ref
                                      .getDownloadURL();
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
                                    'ImageID': url,
                                    'Image': '',
                                    'ImageIdPermit': url2,
                                    'Rules': '',
                                    'PhoneNumber': ownerContactNumber,
                                    'verified': false,
                                    'address': boardingHouseAddress,
                                    'token': '',
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('BoardingHouses')
                                      .doc(_ownerEmail.text.trim())
                                      .set({
                                    'address': boardingHouseAddress,
                                    'OwnerUId': ownerUId,
                                    'BoardingHouseName': boardingHouseName,
                                    'PhoneNumber': ownerContactNumber,
                                    'Lat': 9.2690275,
                                    'Long': 118.4058032,
                                    'chat': 0,
                                    'createdAt': DateTime.now(),
                                    'Email': _ownerEmail.text.trim(),
                                    'FirstName': ownerFirstName,
                                    'MiddleName': ownerMiddleName,
                                    'LastName': ownerLastName,
                                    'BuildingPermitImage': '',
                                    'Rules': '',
                                    'verified': verified,
                                    'Image': '',
                                    'ratings': [0],
                                    'gCashNum': '',
                                    'token': '',
                                    'notification': 0,
                                  });
                                  Navigator.pop(context);
                                  QuickAlert.show(
                                    confirmBtnText: 'Confirm',
                                    barrierDismissible: false,
                                    onConfirmBtnTap: () async {
                                      Navigator.pop(context);
                                        Future.delayed(Duration(seconds: 2), () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => AuthWrapper(),
                                          ),
                                        );
                                      });
                                    },
                                    context: context,
                                    type: QuickAlertType.success,
                                    title: 'Success!',
                                    text:
                                        'Thank you for registering! Please Click Confirm and allow some time for your account to be verified by the admin. We appreciate your patience.',
                                  );
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                      email: _ownerEmail.text.trim(),
                                      password: _ownerPassword.text.trim());
                                  _ownerEmail.clear();
                                  _ownerConfirmPassword.clear();
                                  _ownerPassword.clear();
                                  _imageBldgPermit = null;
                                  _imageID = null;
                                } on FirebaseAuthException catch (e) {
                                  print(e);
                                }
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
