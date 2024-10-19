// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Screen/ForgotPass/forgotpass.screen.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Owner/BHouseProfile/bhouse.profile.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/second.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/third.screen.dart';
import 'package:bh_finder/Screen/Profile/user.profile.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'Auth/auth.wrapper.dart';
import 'Screen/BHouse/bh.screen.dart';
import 'Screen/BHouse/room.screen.dart';
import 'Screen/BordersReservation/boarder.reservation.screen.dart';
import 'Screen/Chat/chat.boarders.dart';
import 'Screen/Chat/chat.list.dart';
import 'Screen/Chat/chat.owner.dart';
import 'Screen/Chat/owner.chat.list.dart';
import 'Screen/Home/guest.home.screen.dart';
import 'Screen/Loading/loading.screen.dart';
import 'Screen/Owner/Map/location.dart';
import 'Screen/Owner/OwnerSignUp/first.screen.dart';
import 'Screen/Owner/Rooms/view.room.dart';
import 'Screen/Owner/add.rooms.dart';
import 'Screen/Owner/list.rooms.screen.dart';
import 'Screen/Owner/owner.home.screen.dart';
import 'Screen/Owner/owner.notification.dart';
import 'Screen/Owner/reservation/reservation.view.screen.dart';
import 'Screen/Receipt/receipt.screen.dart';
import 'Screen/Review/review.section.dart';
import 'Screen/SignUp/signup.screen.dart';
import 'Screen/TermsAndConditons/terms.conditions.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseStorage storage = FirebaseStorage.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BH Finder',
      home: const AuthWrapper(),
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/HomeScreen': (context) => HomeScreen(),
        '/UserProfile': (context) => UserProfile(),
        '/ViewRoom': (context) => ViewRoom(),
        '/BHouseProfile': (context) => BHouseProfile(),
        '/GuestHomeScreen': (context) => GuestHomeScreen(),
        '/LoadingScreen': (context) => LoadingScreen(),
        '/SignInScreen': (context) => SignInScreen(),
        '/BHScreen': (context) => BHouseScreen(),
        '/RoomScreen': (context) => RoomScreen(),
        '/ForgotPassScreen': (context) => ForgotPassScreen(),
        '/OwnerHomeScreen': (context) => OwnerHomeScreen(),
        '/OwnerSignupFirstScreen': (context) => OwnerSignupFirst(),
        '/OwnerSignupSecondScreen': (context) => OwnerSignupSecond(),
        '/OwnerSignupThirdScreen': (context) => OwnerSignupThird(),
        '/ListRoomsScreen': (context) => ListRoomsScreen(),
        '/ViewReservationScreen': (context) => ViewReservationScreen(),
        '/SignUpScreen': (context) => SignUpScreen(),
        '/ChatOwner': (context) => ChatOwner(),
        '/ChatList': (context) => ChatList(),
        '/AddRooms': (context) => AddRooms(),
        '/OwnerChatList': (context) => OwnerChatList(),
        '/ChatBoarders': (context) => ChatBoarders(),
        '/BoarderReservationScreen': (context) => BoarderReservationScreen(),
        '/TermsAndConditions': (context) => TermsAndConditionsScreen(),
        '/ReceiptScreen': (context) => ReceiptScreen(),
        '/ReviewSectionScreen': (context) => ReviewSectionScreen(),
        '/BHouseAddress': (context) => BHouseAddress(),
        '/OwnerNotificationScreen': (context) => OwnerNotificationScreen(),
      }
    );
  }
}
