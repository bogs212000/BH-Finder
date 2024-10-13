import 'dart:io';

import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:uuid/v4.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../cons.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AddRooms extends StatefulWidget {
  const AddRooms({super.key});

  @override
  State<AddRooms> createState() => _AddRoomsState();
}

class _AddRoomsState extends State<AddRooms> {
  TextEditingController roomName = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController descriptions = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  bool verified = false;
  bool loading = false;
  String? error;
  File? _image;
  final _picker = ImagePicker();

  //IDs
  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      // setState(() {
      //   loading = false;
      // });
    }
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    requestStoragePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: 'Add Rooms'.text.make(),
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
                          child:
                              'Please provide accurate and valid information to ensure smooth account creation and service.'
                                  .text
                                  .make(),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 150,
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              _openImagePicker();
                            },
                            child: _image != null
                                ? Container(
                                    width: double.infinity,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(_image!),
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
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: roomName,
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
                              labelText: 'Room number/name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: price,
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
                              labelText: 'Price',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            '   Descriptions'.text.make(),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            maxLines: 3,
                            controller: descriptions,
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
                              labelText: '',
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
                                if (_image == null || roomName.text.isEmpty || price.text.isEmpty) {
                                  // Show a message if some required fields are missing
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all the required fields and select an image.')),
                                  );
                                } else {
                                  setState(() {
                                    loading = true;
                                  });

                                  try {
                                    String roomId = Uuid().v1();
                                    String url;

                                    // Get the application directory
                                    final appDocDir = await getApplicationDocumentsDirectory();
                                    final filePath = "${appDocDir.absolute}/path/to/${roomName.text}.jpg";
                                    final file = File(_image!.path);  // Use selected image path

                                    // Create metadata for the image
                                    final metadata = SettableMetadata(contentType: "image/jpeg");

                                    // Create a reference to Firebase Storage
                                    final storageRef = FirebaseStorage.instance.ref();

                                    // Upload file and metadata to Firebase Storage
                                    final uploadTask = storageRef
                                        .child("images/rooms/${DateTime.now().toString()}.jpg")
                                        .putFile(file, metadata);

                                    // Listen for state changes, errors, and completion of the upload.
                                    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
                                      switch (taskSnapshot.state) {
                                        case TaskState.running:
                                          final progress = 100.0 *
                                              (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
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
                                    url = await (await uploadTask).ref.getDownloadURL();

                                    // Add room details to Firestore
                                    await FirebaseFirestore.instance.collection('Rooms').doc(roomId).set({
                                      'roomDocId': roomId,
                                      'createdAt': DateTime.now(),
                                      'ownerUid': OwnerUuId,
                                      'bHouseName': bHouse,
                                      'address': '',
                                      'price': price.text,
                                      'roomImage': url,
                                      'totalToPay': '',
                                      'boardersName': '',
                                      'boardersConNumber': '',
                                      'boardersAddress': '',
                                      'boardersIn': '',
                                      'boardersOut': '',
                                      'roomNameNumber': roomName.text,
                                      'contactNumber': OwnerPhone,
                                      'roomStatus': 'available',
                                      'descriptions': descriptions.text,
                                      'rules': '',
                                      'rates': ''
                                    });

                                    setState(() {
                                      loading = false;
                                    });
                                    roomName.clear();
                                    descriptions.clear();
                                    price.clear();
                                    _image = null;
                                    QuickAlert.show(
                                      onCancelBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirmBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      context: context,
                                      type: QuickAlertType.success,
                                      text: 'Room added successfully!',
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
                                  } catch (e) {
                                    setState(() {
                                      loading = false;
                                    });

                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to add room: $e')),
                                    );
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
                                    "Add room",
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
              ],
            ),
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
