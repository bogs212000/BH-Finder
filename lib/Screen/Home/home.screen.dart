// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.only(left: 5, right: 5),
          height: 35,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                // Shadow color with opacity
                spreadRadius: 1,
                // Spread radius
                blurRadius: 1,
                // Blur radius
                offset: Offset(
                    0, 1), // Position of the shadow (horizontal, vertical)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pin_drop_outlined,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                  SizedBox(width: 5),
                  'Street'
                      .text
                      .color(Colors.grey.withOpacity(0.8))
                      .size(12)
                      .bold
                      .make()
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
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
                  Icons.notifications_active_outlined,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        'Discover your'
                            .text
                            .light
                            .color(Colors.grey)
                            .size(25)
                            .make(),
                      ],
                    ),
                    Row(
                      children: [
                        'perfect place to stay'
                            .text
                            .bold
                            .color(Colors.black)
                            .size(25)
                            .make(),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextField(
                        // controller: _emailPhonenumber,
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Center(
                                  child: Icon(
                                    Icons.filter_list,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
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
                            labelText: 'Search',
                            labelStyle:
                                TextStyle(color: Colors.grey.withOpacity(0.8))),
                      ),
                    ),
                  ],
                ),
              ),
          
              //List BH
              Container(
                padding: EdgeInsets.only(right: 20, left: 20),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 150,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF31355C),
                          ),
                          child: 'Boarding Houses'
                              .text
                              .lg
                              .size(11)
                              .center
                              .color(Colors.white)
                              .make(),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 280,
                              height: 230,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://images.adsttc.com/media/images/53a3/b4b4/c07a/80d6/3400/02d2/slideshow/HastingSt_Exterior_048.jpg?1403237534',
                                  ), // Replace with your own image URL
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [],
                              ),
                              child: Stack(
                                children: [
                                  // Positioned Text: Title and Subtitle
                                  Positioned(
                                    left: 12,
                                    bottom: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sample', // Title
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Sandoval, Narra, Palawan', // Subtitle
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Positioned Rating and Star Icon
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Row(
                                      children: [
                                        Text(
                                          '4.8', // Rating
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    //find nearby
                    Row(
                      children: [
                        Container(
                          width: 130,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF31355C),
                          ),
                          child: 'Find Nearby'
                              .text
                              .lg
                              .size(11)
                              .center
                              .color(Colors.white)
                              .make(),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [],
                              ),
                              child: Stack(
                                children: [
                                  // Positioned Text: Title and Subtitle
                                  Positioned(
                                    left: 12,
                                    bottom: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sample', // Title
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Sandoval, Narra, Palawan', // Subtitle
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Positioned Rating and Star Icon
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Row(
                                      children: [
                                        Text(
                                          '4.8', // Rating
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
