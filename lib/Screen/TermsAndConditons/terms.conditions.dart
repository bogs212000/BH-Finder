import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: 'Terms and Conditions'.text.black.make(),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 2), () {}),
          // Simulate a delay
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While fetching the web page, display a loading screen
              return Center(
                child: Lottie.asset('assets/lottie/loading.json',
                    height: 100),
              );
            } else {
              return WebView(
                initialUrl: 'https://www.freeprivacypolicy.com/live/f6705f2c-e10e-4b0a-be43-93e479d708e8',
                // Set the URL you want to display
                javascriptMode: JavascriptMode.unrestricted,
                onWebResourceError:
                    (WebResourceError webResourceError) {
                  // Handle the error here, e.g., display an error message.
                  print('Web Error: ${webResourceError.description}');
                }, // Enable JavaScript
              );
            }
          },
        ),
      ),
    );
  }
}
