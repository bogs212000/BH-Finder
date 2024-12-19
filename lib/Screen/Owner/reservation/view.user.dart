import 'package:bh_finder/Auth/auth.wrapper.dart';
import 'package:bh_finder/Screen/Loading/loading.bhouse.screen.dart';
import 'package:bh_finder/Screen/Loading/loading.screen.dart';
import 'package:bh_finder/Screen/Profile/user.edit.profile.dart';
import 'package:bh_finder/Screen/TermsAndConditons/terms.conditions.dart';
import 'package:bh_finder/Screen/about/about.screen.dart';
import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';


class ViewUser extends StatefulWidget {
  const ViewUser({super.key});

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  late Future<DocumentSnapshot> profile;
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  bool loading = false;
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    profile =
        FirebaseFirestore.instance.collection('Users').doc('$userEmail').get();
  }

  @override
  void dispose() {
    _refreshController.dispose(); // Dispose of the controller
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Refresh your profile data
    setState(() {
      profile = FirebaseFirestore.instance
          .collection('Users')
          .doc('${Get.arguments[0].toString()}')
          .get();
    });
    await Future.delayed(
        Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        // Assuming no pull-up loading is needed
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: WaterDropMaterialHeader(
          distance: 30,
        ),
        // Custom loading header
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc('${Get.arguments[0].toString()}')
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingBHouseScreen();
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No Reservation found'));
            }
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      data['Image'] != ''
                          ? CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(
                            '${data['Image']}'), // Path to your image
                      )
                          : const CircleAvatar(
                        radius: 50,
                        child: Center(
                          child: Icon(
                            size: 50,
                            Icons.account_circle_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  '${data['FirstName']} ${data['MiddleName']} ${data['LastName']}'
                                      .text
                                      .size(15)
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  '${data['Email']}'
                                      .text
                                      .light
                                      .size(12)
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  '${data['PhoneNumber']}'
                                      .text
                                      .light
                                      .size(12)
                                      .make(),
                                ],
                              ),
                              Row(
                                children: [
                                  '${data['address']}'
                                      .text
                                      .light
                                      .size(12)
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // SizedBox(height: 20),
                  // Image.network(data['Image'].toString()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
      displayTime: Duration(seconds: 1),
      useAnimation: true,
      maskColor: Colors.green,
      'Copied!',
    );
  }
}
