import 'package:firebase_auth/firebase_auth.dart';

String currentEmail = FirebaseAuth.instance.currentUser!.email.toString();
String? userRole;
String? ownerToken;
String? OwnerUuId;
String? OwnerPhone;
String? BhouseName;
String? bhName;
int? roomAvailable;
int? roomUnavailable;
int? allRooms;

//Boarder
String? myToken;

//bHouse data
String? bHouseRules;
String? bHouseDescriptions;

//BHouse Address
double? addressLat;
double? addressLong;


//user Current Location
double? userLat;
double? userLong;
//rooms
String? roomId;
String? roomNumber;
String? roomDescriptions;
String? roomPrice;

DateTime selectedDateCheckIn = DateTime.now();
DateTime? selectedDateCheckInRerent;

//Boarders
String? fName;
String? mName;
String? lName;
String? bPhoneNumber;
String? bUuId;
String? bAddress;
String? ownerID;

//currently boarding data
String? cBHouseName;
String? cRoom;
bool? cPaid;
String? cDocId;

//reservation view
String? rBHouse;
String? rRoomsDocId;
String? rBHouseDocId;
bool? status;
DateTime? rCheckIn;
DateTime? rCheckOut;

//Chat BHouse Owner
String? ownerEmail;
String? bHouse;

//Chat Boarders
String? boardersEmail;

double? bHouseLat;
double? bHouseLong;

//chat
String? chatName;
String? chatEmail;

bool? reserved = false;

//nav
int selectedIndex = 0;

//gcash
String? gcashNumber;
String? fetchGcashEmail;

//
String? rerentOwnerId;

//
String? roomCache;
String? roomCaches;