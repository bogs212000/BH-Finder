import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Loading/loading.bhouse.screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Privacy Policy'.text.bold.make(),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: VxBox(
              child: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2), () {}),
        // Simulate a delay
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While fetching the web page, display a loading screen
            return LoadingBHouseScreen();
          } else {
            return WebView(
              initialUrl:
                  'https://www.freeprivacypolicy.com/live/89140d5e-ce43-4a45-bcef-91f0b1c45964',
              // Set the URL you want to display
              javascriptMode: JavascriptMode.unrestricted,
              onWebResourceError: (WebResourceError webResourceError) {
                // Handle the error here, e.g., display an error message.
                print('Web Error: ${webResourceError.description}');
              }, // Enable JavaScript
            );
          }
        },
      ))
          .height(MediaQuery.of(context).size.height)
          .width(MediaQuery.of(context).size.width)
          .white
          .make(),
    );
  }
}
