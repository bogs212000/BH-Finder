import 'dart:async';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ReservationSuccess extends StatefulWidget {
  const ReservationSuccess({super.key});

  @override
  State<ReservationSuccess> createState() => _ReservationSuccessState();
}

class _ReservationSuccessState extends State<ReservationSuccess> {
  @override
  void initState() {
    super.initState();

    // Automatically navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            'Reservation Successful'.text.size(20).bold.make(),
          ],
        ),
      ),
    );
  }
}