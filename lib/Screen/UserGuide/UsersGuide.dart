import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class UsersGuideScreen extends StatefulWidget {
  const UsersGuideScreen({super.key});

  @override
  State<UsersGuideScreen> createState() => _UsersGuideScreenState();
}

class _UsersGuideScreenState extends State<UsersGuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Users guide'.text.bold.make(),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: VxBox()
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
