import 'package:flutter/material.dart';
import 'package:ride_app/auth_page.dart';

import 'package:firebase_core/firebase_core.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0C3B2E),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C3B2E)),
          fontFamily: 'Poppins',
        ),
        // home: Home(),
        // home: MyHome(),
        // home: SignupPage(),
        home: AuthPage() // from poe
        );
  }
}
