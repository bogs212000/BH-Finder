import 'package:bh_finder/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ScreenDeleted extends StatefulWidget {
  const ScreenDeleted({super.key});

  @override
  State<ScreenDeleted> createState() => _ScreenDeletedState();
}

class _ScreenDeletedState extends State<ScreenDeleted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VxBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.lost),
            'Your Boarding House has been removed by the admin'.text.make()
          ],
        ),
      )
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
