import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Loading/loading.bhouse.screen.dart';

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
      body: VxBox(child: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2), () {}),
        // Simulate a delay
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While fetching the web page, display a loading screen
            return LoadingBHouseScreen();
          } else {
            return WebView(
              initialUrl:
              'https://sites.google.com/view/bh-finder/home',
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
