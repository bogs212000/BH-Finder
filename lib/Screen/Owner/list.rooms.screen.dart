import 'dart:io';

import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/Owner/owner.home.screen.dart';
import 'package:bh_finder/Screen/Owner/owner.nav.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';
import 'Rooms/view.room.dart';

class ListRoomsScreen extends StatefulWidget {
  const ListRoomsScreen({super.key});

  @override
  State<ListRoomsScreen> createState() => _ListRoomsScreenState();
}

class _ListRoomsScreenState extends State<ListRoomsScreen> {
  bool loading = false;
  final _picker = ImagePicker();
  File? _image;
  TextEditingController _roomName = TextEditingController();
  TextEditingController _roomPrice = TextEditingController();

  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 40);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              leading: GestureDetector(onTap: (){
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        OwnerNav(),
                  ),
                      (Route<dynamic> route) =>
                  false, // Removes all previous routes
                );
              }, child: Icon(Icons.arrow_back),),
              backgroundColor: Colors.white,
              elevation: 0,
              title: 'Rooms'.text.make(),
            ),
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Rooms")
                        .where('ownerUid', isEqualTo: OwnerUuId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Check if the snapshot has an error
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Something went wrong!",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }

                      // Show loading spinner while waiting for data
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        );
                      }

                      // Show message if no data is found
                      if (snapshot.data?.size == 0) {
                        return Center(
                          child: Text('Nothing to fetch here.'),
                        );
                      }

                      // Data is available, display it
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        // Use the length of the fetched data
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = snapshot.data!.docs[index]
                              .data()! as Map<String, dynamic>;
                          String docId = snapshot.data!.docs[index].id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewRoom(viewRoomId: data['roomDocId'], boarderToken: data['boarderToken']),
                                  ),
                                  (Route<dynamic> route) =>
                                      false, // Removes all previous routes
                                );
                              },
                              child: Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            data['roomImage'] ??
                                                'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${data['roomNameNumber']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              data['roomStatus'],
                                              style: TextStyle(
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 110,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₱ ${data['price'] ?? '---'} per month',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  QuickAlert.show(
                                                    onCancelBtnTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    onConfirmBtnTap: () async {
                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('Rooms')
                                                            .doc(docId)
                                                            .delete();
                                                        Navigator.pop(context);
                                                        QuickAlert.show(
                                                          onCancelBtnTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                          onConfirmBtnTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                          context: context,
                                                          type: QuickAlertType.success,
                                                          text: 'Room deleted successfully!',
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
                                                        print(e);
                                                      }
                                                    },
                                                    context: context,
                                                    type:
                                                        QuickAlertType.confirm,
                                                    text:
                                                        "Are you sure you want to delete this room?",
                                                    titleAlignment:
                                                        TextAlign.center,
                                                    textAlignment:
                                                        TextAlign.center,
                                                    confirmBtnText: 'Yes',
                                                    cancelBtnText: 'No',
                                                    confirmBtnColor:
                                                        Colors.blue,
                                                    backgroundColor:
                                                        Colors.white,
                                                    headerBackgroundColor:
                                                        Colors.grey,
                                                    confirmBtnTextStyle:
                                                        const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    titleColor: Colors.black,
                                                    textColor: Colors.black,
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.delete_forever_outlined,
                                                  color: Colors.grey,
                                                  size: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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
                              print(OwnerUuId);
                              Navigator.pushNamed(context, '/AddRooms');
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
                                  "Add Rooms",
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
