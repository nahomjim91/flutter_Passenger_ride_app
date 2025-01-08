import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_app/dataCustomize.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/navigatorPage.dart';
import 'package:ride_app/loginOrSignup.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/poeHome..dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          print('User is logged in');
          return FutureBuilder<Passenger?>(
            future: Firebaseutillies().getPassengerFromFirestore(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                final passenger = snapshot.data!;
                // Check if data requires customization
                if (passenger.first_name == 'Unknown' ||
                    passenger.last_name == 'Unknown') {
                  return DataCustomize(passenger: passenger);
                } else {
                  // return HomePage(); // for mapp showing 
                  return Home(passenger: passenger);
                }
              } else {
                return const Center(
                  child: Text('Error loading passenger data'),
                );
              }
            },
          );
        } else {
          return LoginOrSignup();
        }
      },
    ));
  }
}
