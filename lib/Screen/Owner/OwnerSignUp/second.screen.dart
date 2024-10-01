import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class OwnerSignupSecond extends StatefulWidget {
  const OwnerSignupSecond({super.key});

  @override
  State<OwnerSignupSecond> createState() => _OwnerSignupSecondState();
}

class _OwnerSignupSecondState extends State<OwnerSignupSecond> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: 'Building Info'.text.make(),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
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
                        Navigator.pushNamed(context, '/OwnerSignupThirdScreen');
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
