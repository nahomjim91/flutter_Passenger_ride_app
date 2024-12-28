import 'package:flutter/material.dart';
import 'package:ride_app/home_screen.dart';
import 'package:ride_app/ride_booking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0C3B2E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C3B2E)),
        fontFamily: 'Poppins',
      ),
      home: Home(),
      // home: MyHome(),
    );
  }
}
