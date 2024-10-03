import 'package:firebase_auth/firebase_auth.dart';

String currentEmail = FirebaseAuth.instance.currentUser!.email.toString();
String? userRole;
String? OwnerUuId;
String? OwnerPhone;
String? BhouseName;
int? roomAvailable;
int? roomUnavailable;
int? allRooms;