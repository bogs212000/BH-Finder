import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeLoadingScreen extends StatefulWidget {
  const HomeLoadingScreen({super.key});

  @override
  State<HomeLoadingScreen> createState() => _HomeLoadingScreenState();
}

class _HomeLoadingScreenState extends State<HomeLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Spacer(),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          
              SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
