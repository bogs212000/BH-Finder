import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/owner.signup.data.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../cons.dart';

class AddRoomsScreen extends StatefulWidget {
  const AddRoomsScreen({super.key});

  @override
  State<AddRoomsScreen> createState() => _AddRoomsScreenState();
}

class _AddRoomsScreenState extends State<AddRoomsScreen> {
  bool loading = false;
  TextEditingController _boardingHouseName = TextEditingController();

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
                // Container(
                //   padding: EdgeInsets.all(20),
                //   color: Colors.white,
                //   width: double.infinity,
                //   height: double.infinity,
                //   child: Column(
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                //         child: TextField(
                //           controller: _boardingHouseName,
                //           keyboardType: TextInputType.name,
                //           textAlign: TextAlign.left,
                //           style: const TextStyle(
                //             fontSize: 15,
                //             fontWeight: FontWeight.bold,
                //           ),
                //           decoration: InputDecoration(
                //             filled: true,
                //             fillColor: Colors.grey.withOpacity(0.1),
                //             focusedBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(20),
                //               borderSide: BorderSide(color: Colors.white),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.white),
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             labelText: 'Boarding House Name',
                //           ),
                //         ),
                //       ),
                //       Container(
                //         height: 150,
                //         width: double.infinity,
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: Padding(
                //                 padding: const EdgeInsets.all(10.0),
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     color: Colors.blue[100],
                //                     borderRadius: BorderRadius.circular(10),
                //                   ),
                //                   child: Center(
                //                     child: Icon(
                //                       Icons.camera_alt_rounded,
                //                       color: Colors.blue[300],
                //                       size: 50,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(10.0),
                //               child: Container(
                //                 width: 100,
                //                 decoration: BoxDecoration(
                //                   color: Colors.blue[50],
                //                   borderRadius: BorderRadius.circular(10),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                // ),
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
                              setState(() {
                                loading = true;
                              });
                              try {
                                String? roomId = Uuid().v1();
                                FirebaseFirestore.instance
                                    .collection('Rooms')
                                    .doc(roomId)
                                    .set({
                                  'roomDocId': roomId,
                                  'createdAt': DateTime.now(),
                                  'ownerUid': OwnerUuId,
                                  'bHouseName': BhouseName,
                                  'price': '',
                                  'roomImage': '',
                                  'totalToPay': '',
                                  'boardersName': '',
                                  'boardersConNumber': '',
                                  'boardersIn': '',
                                  'boardersOut': '',
                                  'roomNameNumber': 'Room name',
                                  'contactNumber': OwnerPhone,
                                  'roomStatus': 'available',
                                  'descriptions': '',
                                  'rules': '',
                                  'rates': ''
                                });
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
                                  "Add",
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
