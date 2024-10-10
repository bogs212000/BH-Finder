import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../cons.dart';

class ChatOwner extends StatefulWidget {
  ChatOwner({Key? key}) : super(key: key);

  @override
  State<ChatOwner> createState() => _ChatOwnerState();
}

class _ChatOwnerState extends State<ChatOwner> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    double screenWidth = MediaQuery.of(context).size.width;

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
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            child: StreamBuilder(
              stream: _firestore
                  .collection('Chats')
                  .doc('$email+$ownerEmail')
                  .collection('Chats')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Lottie.asset('assets/lottie/animation_loading.json',
                        width: 100, height: 100),
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
          .doc('$email+$ownerEmail')
          .set({
        'ownerEmail': ownerEmail,
        'email': email,
        'bHouse': bHouse,
        'name': 'name',
        'role': 'boarder',
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
      _messageController.clear();
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
