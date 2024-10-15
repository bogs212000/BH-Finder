import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart'; // Make sure this package is added

class MyTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: TabBar(
            padding: EdgeInsets.all(5),
            indicatorColor: Colors.blue, // Optional: Customize indicator color
            tabs: [
              'Boarding Houses'.text.bold.make(),
              'Reservations'.text.bold.make(),
            ],
          ),
          body: TabBarView(
            children: [
              'haha'.text.make(),
              'hehe'.text.make(),
            ],
          ),
        ),
      ),
    );
  }
}
