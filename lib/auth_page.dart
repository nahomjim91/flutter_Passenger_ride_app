import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_app/Auth/api_service.dart';
// import 'package:ride_app/Auth/apiService.dart';
import 'package:ride_app/dataCustomize.dart';
import 'package:ride_app/navigatorPage.dart';
import 'package:ride_app/loginOrSignup.dart';
import 'package:ride_app/passenger.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final ApiService _apiService = ApiService();
  bool _isInitialLoad = true;

  // Helper method to check if passenger data is complete
  bool isPassengerDataComplete(Passenger passenger) {
    return passenger.first_name.isNotEmpty &&
        passenger.last_name.isNotEmpty &&
        passenger.first_name != '' &&
        passenger.last_name != '' &&
        passenger.phone_number.isNotEmpty &&
        passenger.phone_number != '' &&
        passenger.phone_number != 'Unknown Number';
  }

  Future<Passenger?> _fetchPassengerData(String uid) async {
    try {
      debugPrint('Fetching passenger data for UID: $uid');
      if (_isInitialLoad) {
        await Future.delayed(const Duration(seconds: 2));
        _isInitialLoad = false;
      }

      final passenger = await _apiService.getPassenger(uid);
      debugPrint('Passenger data received: ${passenger.toString()}');
      return passenger;
    } catch (e) {
      debugPrint('Error fetching passenger data: $e');
      return null;
    }
  }

  Future<Passenger?> _retryWithBackoff(String uid,
      {int maxAttempts = 3}) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final passenger = await _apiService.getPassenger(uid);
        if (passenger != null) {
          return passenger;
        }
      } catch (e) {
        debugPrint('Attempt ${attempt + 1} failed: $e');
      }
      await Future.delayed(Duration(seconds: attempt + 2));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.hasData && authSnapshot.data != null) {
            final user = authSnapshot.data!;
            debugPrint('User authenticated with UID: ${user.uid}');

            return FutureBuilder<Passenger?>(
              future: _retryWithBackoff(user.uid),
              builder: (context, passengerSnapshot) {
                if (passengerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading your profile...'),
                      ],
                    ),
                  );
                }

                if (passengerSnapshot.hasData &&
                    passengerSnapshot.data != null) {
                  final passenger = passengerSnapshot.data!;
                  debugPrint('Passenger data loaded successfully');

                  // Check if passenger data is complete
                  if (!isPassengerDataComplete(passenger)) {
                    debugPrint(
                        'Incomplete passenger data detected. Redirecting to DataCustomize.');
                    return DataCustomize(passenger: passenger);
                  } else {
                    debugPrint(
                        'Complete passenger data. Redirecting to NavigatorPage.');
                    return NavigatorPage(passenger: passenger);
                  }
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unable to load your profile'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isInitialLoad = true;
                          });
                        },
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const LoginOrSignup();
        },
      ),
    );
  }
}
