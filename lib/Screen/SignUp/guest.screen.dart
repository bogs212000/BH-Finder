import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {

  @override
  void initState() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: TabBar(
            padding: EdgeInsets.all(5),
            dividerHeight: .1,
            tabs: [
              'Boarding Houses'.text.bold.make(),
              'Sign in'.text.bold.make(),
            ],
          ),
          body: TabBarView(
            children: [
              HomeScreen(),
              SignInScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
