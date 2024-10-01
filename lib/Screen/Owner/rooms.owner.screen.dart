import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Home/home.screen.dart';
import 'owner.home.screen.dart';

class RoomsOwnerScreen extends StatefulWidget {
  const RoomsOwnerScreen({super.key});

  @override
  State<RoomsOwnerScreen> createState() => _RoomsOwnerScreenState();
}

class _RoomsOwnerScreenState extends State<RoomsOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    _toHomeScreen(),
                        (Route<dynamic> route) =>
                    false,
                  );
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
            'Rooms'.text.make(),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [],
        ),
      ),
    );
  }
  Route _toHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => OwnerHomeScreen(),
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
            child: OwnerHomeScreen());
      },
    );
  }
}
