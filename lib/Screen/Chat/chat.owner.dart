import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import '../../api.dart';
import '../../cons.dart';
import '../Owner/list.rooms.screen.dart';

final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

class ChatOwner extends StatefulWidget {
  final String? ownerNumber;
  final String? emailOwner;
  final String? token;

  ChatOwner({Key? key, this.ownerNumber, this.emailOwner, this.token})
      : super(key: key);

  @override
  State<ChatOwner> createState() => _ChatOwnerState();
}

class _ChatOwnerState extends State<ChatOwner> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void sendPushMessage(String body, String title) async {
    try {
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle.loadString(
            'assets/firebase/${Api.notifications}'),
      );

      final client =
          await clientViaServiceAccount(serviceAccountCredentials, _scopes);
      final accessToken = client.credentials.accessToken.data;

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/bh-finder-50ccf/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': btoken,
            // Send notification to all users subscribed to this topic
            'notification': {
              'body': body,
              'title': title,
              'image': 'https://firebasestorage.googleapis.com/v0/b/bh-finder-50ccf.appspot.com/o/App%2Fic_launcher.png?alt=media&token=68ac0062-7cd4-4e43-a39f-0e40d612ad01',
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'body': body, // Include additional data if needed
              'title': title,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully to all users');
      } else {
        print(
            'Failed to send push notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    double screenWidth = MediaQuery.of(context).size.width;

    _callNumber() async {
      QuickAlert.show(
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
        onConfirmBtnTap: () async {
          String number = '${widget.ownerNumber}'; //set the number here
          bool? res = await FlutterPhoneDirectCaller.callNumber(number);
          Navigator.pop(context);
        },
        context: context,
        type: QuickAlertType.confirm,
        text: 'Do you want to continue?',
        titleAlignment: TextAlign.center,
        textAlignment: TextAlign.center,
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: Colors.blue,
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.grey,
        confirmBtnTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleColor: Colors.black,
        textColor: Colors.black,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 30,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Chat",
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                brightness == Brightness.light
                    ? Colors.blue.shade500
                    : Colors.blue.shade900,
                brightness == Brightness.light
                    ? Colors.green.shade300
                    : Colors.green.shade800,
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                _callNumber();
              },
              child: Icon(
                Icons.call,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            child: StreamBuilder(
              stream: _firestore
                  .collection('Chats')
                  .doc('$email+${widget.emailOwner}')
                  .collection('Chats')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Container(
                                height: 40,
                                width: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30)
                    ],
                  );
                }

                var messages = snapshot.data?.docs.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages!) {
                  final messageText = message['text'];
                  final messageSender = message['sender'].toString();
                  final time = message['date'].toString();

                  final messageBubble = MessageBubble(
                    sender: time,
                    text: messageText,
                    isMe: _auth.currentUser?.email == messageSender,
                    onLongPress: () {
                      if (messageSender !=
                          FirebaseAuth.instance.currentUser?.email.toString()) {
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Message'),
                              content: Text(
                                  'Are you sure you want to delete this message?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _firestore
                                        .collection('Chats')
                                        .doc('$email+${widget.emailOwner}')
                                        .collection('Chats')
                                        .doc(message.id)
                                        .delete();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                  messageBubbles.add(messageBubble);
                }
                return Container(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messageBubbles.length,
                    itemBuilder: (context, index) {
                      return messageBubbles[index];
                    },
                  ),
                );
              },
            ),
          )),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 50,
                width: screenWidth * 0.78,
                // Adjust the factor based on your design
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Message....',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    DateTime nowChat = DateTime.now();
                    String formattedDate =
                        DateFormat('EEEE, yyyy-MM-dd').format(nowChat);
                    String formattedTime = DateFormat('h:mm a').format(nowChat);
                    String date = "$formattedDate, $formattedTime";
                    _sendMessage(date.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Icon(Icons.send),
                ),
              ),
            ],
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }

  void _sendMessage(String date) async {
    if (_messageController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc('$email+${widget.emailOwner}')
          .set({
        'ownerEmail': '${widget.emailOwner}',
        'email': email,
        'bHouse': bHouse,
        'name': '$fName $mName $lName',
        'role': 'boarder',
        'createdAt': DateTime.now(),
        'seenBorder?': false,
        'seenOwner?': true,
        'count': FieldValue.increment(1),
        'ownerNumber': '${widget.ownerNumber.toString()}',
        'ownerToken': widget.token.toString(),
        'myToken': myToken,
        'boarderNumber': bPhoneNumber,
      });
      await FirebaseFirestore.instance
          .collection('BoardingHouses')
          .doc(ownerEmail)
          .update({
        'chat': FieldValue.increment(1),
      });
      await _firestore
          .collection('Chats')
          .doc('$email+$ownerEmail')
          .collection('Chats')
          .add({
        'date': date,
        'role': 'boarder',
        'text': _messageController.text,
        'sender': _auth.currentUser?.email?.toString(),
        'createdAt': DateTime.now(),
      });
      String body = _messageController.text;
      String title = "$fName $mName $lName";
      _messageController.clear();
      sendPushMessage(body, title);
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final VoidCallback? onLongPress;

  MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Material(
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
              elevation: 5,
              color: isMe ? Colors.blue : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMe ? Colors.white : Colors.black,
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
