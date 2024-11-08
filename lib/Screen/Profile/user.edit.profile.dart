import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

File? _profilePic;

class UserEditProfile extends StatefulWidget {
  final String? first;
  final String? middle;
  final String? last;
  final String? email;
  final String? address;
  final String? phoneNum;
  final String? profilePic;

  const UserEditProfile(
      {super.key,
      this.first,
      this.middle,
      this.last,
      this.address,
      this.email,
      this.profilePic,
      this.phoneNum});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  late TextEditingController _fname;
  late TextEditingController _mname;
  late TextEditingController _lname;
  late TextEditingController _address;
  late TextEditingController _pnumber;
  String? message;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with the passed values
    _fname = TextEditingController(text: widget.first);
    _mname = TextEditingController(text: widget.middle);
    _lname = TextEditingController(text: widget.last);
    _address = TextEditingController(text: widget.address);
    _pnumber = TextEditingController(text: widget.phoneNum);

    // Add listeners to detect changes
    _fname.addListener(_checkIfChanged);
    _mname.addListener(_checkIfChanged);
    _lname.addListener(_checkIfChanged);
    _address.addListener(_checkIfChanged);
    _pnumber.addListener(_checkIfChanged);
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed
    _fname.dispose();
    _mname.dispose();
    _lname.dispose();
    _address.dispose();
    _pnumber.dispose();
    super.dispose();
  }

  void _checkIfChanged() {
    // Check if any text field value differs from the initial values
    if (_fname.text != (widget.first ?? "") ||
        _mname.text != (widget.middle ?? "") ||
        _lname.text != (widget.last ?? "") ||
        _address.text != (widget.address ?? "") ||
        _pnumber.text != (widget.phoneNum ?? "")) {
      setState(() {
        _isChanged = true;
      });
    } else {
      setState(() {
        _isChanged = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();

    //IDs
    Future<void> _openImagePicker() async {
      final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _profilePic = File(pickedImage.path);
        });
        // setState(() {
        //   loading = false;
        // });
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    widget.profilePic != ''
                        ? StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.email.toString()).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 50,
                            child: Center(
                              child: Icon(
                                size: 50,
                                Icons.account_circle_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error fetching data'));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('No Reservation found'));
                        }
                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                              '${data['Image']}'), // Path to your image
                        );
                      },
                    )
                        : const CircleAvatar(
                            radius: 50,
                            child: Center(
                              child: Icon(
                                size: 50,
                                Icons.account_circle_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    Container(
                      height: 100,
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _openImagePicker();
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                if (_profilePic != null)
                  Row(
                    children: [
                      Flexible(
                          child: '${_profilePic?.path}'
                              .text
                              .overflow(TextOverflow.ellipsis)
                              .make()),
                      Spacer(),
                      ElevatedButton(
                          onPressed: () async {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.loading,
                              title: 'Uploading',
                              text: 'Please Wait...',
                            );
                            try {
                              // Get the application documents directory
                              final appDocDir =
                              await getApplicationDocumentsDirectory();

                              // Construct the file path for saving the image locally (optional)
                              final filePath =
                                  "${appDocDir.path}/path/to/${widget.email}.jpg";

                              // Get the selected image file (use the path from the selected image)
                              final file = File(_profilePic!.path);

                              // Create metadata for the image
                              final metadata = SettableMetadata(
                                  contentType: "image/jpeg");

                              // Create a reference to Firebase Storage
                              final storageRef = FirebaseStorage.instance.ref();
                              final imageRef = storageRef.child("profilePic/${widget.email.toString()}/${DateTime.now().toString()}.jpg");

                              // Upload file and metadata to Firebase Storage
                              final uploadTask = imageRef.putFile(file, metadata);
                              // Listen for state changes, errors, and completion of the upload.
                              uploadTask.snapshotEvents
                                  .listen((TaskSnapshot taskSnapshot) async {
                                switch (taskSnapshot.state) {
                                  case TaskState.running:
                                    final progress = 100.0 *
                                        (taskSnapshot.bytesTransferred /
                                            taskSnapshot.totalBytes);
                                    print(
                                        "Upload is $progress% complete.");
                                    break;
                                  case TaskState.paused:
                                    print("Upload is paused.");
                                    break;
                                  case TaskState.canceled:
                                    print("Upload was canceled.");
                                    break;
                                  case TaskState.error:
                                    print("Upload encountered an error.");
                                    break;
                                  case TaskState.success:
                                    print("Upload successful!");
                                    final downloadURL = await imageRef.getDownloadURL();
                                    print("Download URL: $downloadURL");

                                    // Add the URL to Firestore
                                    await FirebaseFirestore.instance.collection('Users').doc(widget.email).update({
                                      'Image': downloadURL,
                                    });
                                    setState(() {
                                      _profilePic = null;
                                    });
                                }
                              });

                              _profilePic = null;
                              Navigator.pop(context);

                              // Show a success dialog
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Success!',
                                text: 'Images has been Uploaded',
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                },
                              );
                            } catch (e) {
                              print("Error uploading image: $e");
                            }
                          },
                          child: 'Upload'.text.make()),
                    ],
                  ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 0.5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: ['Edit Profile'.text.bold.size(25).make()],
                      ),
                      Divider(),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        child: TextField(
                          controller: _fname,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        child: TextField(
                          controller: _mname,
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
                            labelText: 'Middle',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        child: TextField(
                          controller: _lname,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        child: TextField(
                          controller: _address,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 20),
                        child: TextField(
                          controller: _pnumber,
                          keyboardType: TextInputType.number,
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
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            QuickAlert.show(
                              onCancelBtnTap: () {
                                Navigator.pop(context);
                              },
                              onConfirmBtnTap: () async {
                                Navigator.pop(context);
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: widget.email.toString());
                                  message = "Password reset email sent.";
                                } catch (e) {
                                  message =
                                      "Error sending password reset email";
                                }
                                _toast();
                              },
                              context: context,
                              type: QuickAlertType.info,
                              text:
                                  "We will sent a password reset link to your email. Click 'Ok' to continue.",
                              titleAlignment: TextAlign.center,
                              textAlignment: TextAlign.center,
                              confirmBtnText: 'Ok',
                              cancelBtnText: 'No',
                              confirmBtnColor: Colors.blue,
                              backgroundColor: Colors.white,
                              headerBackgroundColor: Colors.grey,
                              confirmBtnTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              titleColor: Colors.black,
                              textColor: Colors.black,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(26, 60, 105, 1.0),
                            // Custom background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(25), // Rounded corners
                            ),
                          ),
                          child: 'Change Password'
                              .text
                              .color(Colors.white)
                              .bold // Bold text
                              .make(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (_isChanged)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            QuickAlert.show(
                              onCancelBtnTap: () {
                                Navigator.pop(context);
                              },
                              onConfirmBtnTap: () async {
                                Navigator.pop(context);
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.email
                                        .toString()) // Assuming the document is based on user email
                                    .update({
                                  'FirstName': _fname.text,
                                  // Use `.text` to update the actual text
                                  'MiddleName': _mname.text,
                                  'LastName': _lname.text,
                                  'address': _address.text,
                                  'PhoneNumber': _pnumber.text,
                                });
                                setState(() {
                                  message = 'Save Changes!';
                                });
                                _toast();
                              },
                              context: context,
                              type: QuickAlertType.confirm,
                              text: 'Save Changes.',
                              titleAlignment: TextAlign.center,
                              textAlignment: TextAlign.center,
                              confirmBtnText: 'Yes',
                              cancelBtnText: 'No',
                              confirmBtnColor: Colors.blue,
                              backgroundColor: Colors.white,
                              headerBackgroundColor: Colors.grey,
                              confirmBtnTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              titleColor: Colors.black,
                              textColor: Colors.black,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            // Custom background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(25), // Rounded corners
                            ),
                          ),
                          child: 'Save Changes'
                              .text
                              .color(Colors.white)
                              .bold // Bold text
                              .make(),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ));
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
      displayTime: Duration(seconds: 3),
      maskColor: Colors.green,
      '$message',
      useAnimation: true,
    );
  }
}
