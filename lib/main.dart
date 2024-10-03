// ignore_for_file: prefer_const_constructors

import 'package:bh_finder/Screen/ForgotPass/forgotpass.screen.dart';
import 'package:bh_finder/Screen/Home/home.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/second.screen.dart';
import 'package:bh_finder/Screen/Owner/OwnerSignUp/third.screen.dart';
import 'package:bh_finder/Screen/SignUp/signin.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Auth/auth.wrapper.dart';
import 'Screen/BHouse/bh.screen.dart';
import 'Screen/BHouse/room.screen.dart';
import 'Screen/Loading/loading.screen.dart';
import 'Screen/Owner/OwnerSignUp/first.screen.dart';
import 'Screen/Owner/add.rooms.screen.dart';
import 'Screen/Owner/owner.home.screen.dart';
import 'Screen/Owner/reservation/reservation.view.screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      debugShowCheckedModeBanner: false,
      routes: {
        '/HomeScreen': (context) => HomeScreen(),
        '/LoadingScreen': (context) => LoadingScreen(),
        '/SignInScreen': (context) => SignInScreen(),
        '/BHScreen': (context) => BHouseScreen(),
        '/RoomScreen': (context) => RoomScreen(),
        '/ForgotPassScreen': (context) => ForgotPassScreen(),
        '/OwnerHomeScreen': (context) => OwnerHomeScreen(),
        '/OwnerSignupFirstScreen': (context) => OwnerSignupFirst(),
        '/OwnerSignupSecondScreen': (context) => OwnerSignupSecond(),
        '/OwnerSignupThirdScreen': (context) => OwnerSignupThird(),
        '/AddRoomsScreen': (context) => AddRoomsScreen(),
        '/ViewReservationScreen': (context) => ViewReservationScreen(),
      }
    );
  }
}
