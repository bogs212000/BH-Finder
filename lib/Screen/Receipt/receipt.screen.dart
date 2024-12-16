import 'package:bh_finder/cons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

import '../../fetch.dart';

class ReceiptScreen extends StatefulWidget {
  final String? roomId;

  const ReceiptScreen({super.key, this.roomId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late Future<DocumentSnapshot> receipt;

  @override
  void initState() {
    super.initState();
    fetchGcashNum(setState);
    receipt = FirebaseFirestore.instance
        .collection('Rooms')
        .doc(Get.arguments[0].toString())
        .get();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: receipt,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No Reservation found'));
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          DateTime dateTimeIn = data['boardersIn'].toDate();
          DateTime dateTimeOut = data['boardersOut'].toDate();
          String dateIn = DateFormat('yyyy-MM-dd').format(dateTimeIn);
          String dateOut = DateFormat('yyyy-MM-dd').format(dateTimeOut);
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  height: data['paid?'] == false ? 500 : 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 0.5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.png', scale: 7),
                          'BH Finder'.text.bold.size(25).make()
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          'Boarding House :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['bHouseName']}'.text.light.size(15).make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Room :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['roomNameNumber']}'
                              .text
                              .light
                              .size(15)
                              .make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Name :'.text.light.size(15).make(),
                          Spacer(),
                          '${data['boardersName']}'.text.light.size(15).make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Check-in :'.text.light.size(15).make(),
                          Spacer(),
                          '$dateIn'.text.light.size(15).make(),
                        ],
                      ),
                      Row(
                        children: [
                          'Check-out :'.text.light.size(15).make(),
                          Spacer(),
                          '$dateOut'.text.light.size(15).make(),
                        ],
                      ),
                      Row(
                        children: [
                          'To be paid :'.text.light.size(15).make(),
                          Spacer(),
                          'P'.text.light.size(15).make(),
                          ' ${data['price']}.00'.text.bold.size(15).make(),
                        ],
                      ),
                      Divider(),
                      data['paid?'] == true
                          ? 'Your already paid, Thank you!'.text.make()
                          : 'You can pay directly to the Boarding House owner in cash, or use GCash for your payment. Simply follow the provided instructions for a smooth transaction.'
                              .text
                              .light
                              .make(),
                      Divider(),
                      data['paid?'] == true
                          ? SizedBox(height: 1)
                          : 'After making your payment on GCash, please message the boarding house owner and send them the payment receipt reference number for confirmation.'
                              .text
                              .light
                              .make(),
                      Spacer(),
                      data['paid?'] == true
                          ? SizedBox()
                          : Row(
                              children: [
                                gcashNumber == null || gcashNumber == ''
                                    ? SizedBox()
                                    : 'Gcash #: $gcashNumber'.text.make(),
                                Spacer(),
                                gcashNumber == null || gcashNumber == ''
                                    ? SizedBox()
                                    : GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: '$gcashNumber'));
                                          _toast();
                                        },
                                        child: Icon(Icons.copy),
                                      ),
                              ],
                            ),
                      Divider(),
                      Row(
                        children: [
                          'Room ID-${data['roomDocId']}'
                              .text
                              .light
                              .size(8)
                              .make(),
                        ],
                      ),
                      Row(
                        children: [
                          'My ID-${data['boarderID']}'
                              .text
                              .light
                              .size(8)
                              .make(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                data['paid?'] == false
                    ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        gcashNumber == null || gcashNumber == ''
                            ? "The boarding house owner does not have a GCash account."
                                .text
                                .make()
                            : SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String gcashUrl = 'https://www.gcash.com/';
                                    if (await canLaunch(gcashUrl)) {
                                      await launch(gcashUrl);
                                    } else {
                                      throw 'Could not launch $gcashUrl';
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    // Custom background color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          25), // Rounded corners
                                    ),
                                  ),
                                  child: 'Pay with Gcash'
                                      .text
                                      .color(Colors.white)
                                      .bold // Bold text
                                      .make(),
                                ),
                              ),
                      ])
                    : SizedBox(),
              ],
            ),
          );
        },
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
        'Copied!');
  }
}
