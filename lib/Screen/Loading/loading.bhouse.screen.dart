import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingBHouseScreen extends StatefulWidget {
  const LoadingBHouseScreen({super.key});

  @override
  State<LoadingBHouseScreen> createState() => _LoadingBHouseScreenState();
}

class _LoadingBHouseScreenState extends State<LoadingBHouseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Container(
                height: 450,
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
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
