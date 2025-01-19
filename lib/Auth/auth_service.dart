import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Pages/resetEmailSentPage.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/passenger.dart';

class AuthService {
  final ApiService apiService = ApiService();

  Future<User> signInWithGoogle2() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      // If the user is already signed in, return the user
      if (currentUser != null) {
        print("User already signed in: ${currentUser.email}");
        return currentUser;
      }

      // Trigger Google Sign-In
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Set custom scopes if needed
      googleProvider
        ..addScope('email')
        ..addScope('profile');

      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithPopup(googleProvider);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create a Passenger object
        // Check if the user exists in Firestore
        final existingPassenger =
            await Firebaseutillies().getPassengerFromFirestore(user.uid);

        if (existingPassenger != null) {
          // User already exists, redirect to home
          print("User already exists in Firestore. Redirecting to home.");
          return user;
        } else {
          final passenger = Passenger(
            id: user.uid,
            phone_number:
                user.phoneNumber ?? 'Unknown', // Default if no phone number
            first_name: user.displayName?.split(' ').first ??
                'Unknown', // Extract first name
            last_name: 'Unknown', // Extract last name
            profile_photo: user.photoURL ??
                "https://lh3.googleusercontent.com/a/AEdFTp4wIcFvcdLSRoBqJsF4Y-lzb_hHL8k7jqnCYBs0=s96-c", // Default profile photo
            created_at: user.metadata.creationTime?.toIso8601String() ??
                'Unknown', // Creation time
            email: user.email ?? 'Unknown', // Default email if null
            payment_method: 'cash'
          );
          await Firebaseutillies().savePassengerToFirestore(passenger);

          print("User signed up: ${user.email},");
        }
      }
      return user!;
    } catch (e) {
      print("Error signing in with Google: $e");
      throw Exception("Error signing in with Google");
    }
  }

  Future<void> signUpWithEmail(
      email, password, firstName, lastName, phone, toggle) async {
    try {
      toggle();
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Access the signed-up user
      User? user = userCredential.user;

      if (user != null) {
        // Update the user's display name
        await user.updateDisplayName(firstName + " " + lastName);
        await user.reload(); // Refresh the user to apply updates
        // Create a Passenger object
        final passenger = Passenger(
          id: user.uid,
          phone_number: phone ?? 'Unknown',
          first_name: firstName,
          last_name: lastName,
          profile_photo: user.photoURL ??
              "https://lh3.googleusercontent.com/a/AEdFTp4wIcFvcdLSRoBqJsF4Y-lzb_hHL8k7jqnCYBs0=s96-c",
          created_at:
              user.metadata.creationTime?.toIso8601String() ?? 'Unknown',
          email: user.email ?? 'Unknown',
          payment_method: 'cash'
        );
        await Firebaseutillies().savePassengerToFirestore(passenger);

        print("User signed up: ${user.email},");
        toggle();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Error: $e');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print("User signed in: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      } else {
        print('Error: $e');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> resetPassword(
      String email, BuildContext context, Function(bool) loadingUpdater,
      {isForgotPassword = false}) async {
    try {
      loadingUpdater(true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      loadingUpdater(false);
      // Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Password reset email sent!")),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetEmailSentPage(
                email: email,
                title:
                    !isForgotPassword ? "Reset Password" : "Forgot Password")),
      );
    } on FirebaseAuthException catch (e) {
      loadingUpdater(false);
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      loadingUpdater(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  Future<void> resendEmailRestPassword(
    String email,
    BuildContext context,
    Function(bool) loadingUpdater,
  ) async {
    try {
      loadingUpdater(true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      loadingUpdater(false);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } on FirebaseAuthException catch (e) {
      loadingUpdater(false);
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      loadingUpdater(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  Future<void> signUpWithEmailLaravel(String email, String password,
      String firstName, String lastName, String phone, Function toggle) async {
    try {
      toggle();
      // Firebase sign-up
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Access the signed-up user
      User? user = userCredential.user;

      if (user != null) {
        // Update the user's display name
        await user.updateDisplayName('$firstName $lastName');
        await user.reload();

        // Save Passenger in Laravel
        final passenger = Passenger(
          id: user.uid,
          phone_number: phone,
          first_name: firstName,
          last_name: lastName,
          profile_photo: user.photoURL ??
              "https://lh3.googleusercontent.com/a/AEdFTp4wIcFvcdLSRoBqJsF4Y-lzb_hHL8k7jqnCYBs0=s96-c",
          created_at:
              user.metadata.creationTime?.toIso8601String() ?? 'Unknown',
          email: user.email ?? 'Unknown',
          payment_method: 'cash'
        );
        await apiService.createPassenger(passenger);

        print("User signed up and data saved to Laravel: ${user.email}");
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      toggle();
    }
  }

  Future<User> signInWithGoogle2Laravel() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      // If the user is already signed in, return the user
      if (currentUser != null) {
        debugPrint("User already signed in: ${currentUser.email}");
        return currentUser;
      }

      // Trigger Google Sign-In
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider
        ..addScope('email')
        ..addScope('profile');

      // Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user != null) {
        // Try to get existing passenger
        try {
          final existingPassenger = await apiService.getPassenger(user.uid);

          if (existingPassenger != null) {
            debugPrint("User already exists in database. Redirecting to home.");
            return user;
          } else {
            debugPrint(
                'User does not exist in database. Creating new passenger.');

            // Split display name into first and last name
            final nameParts = user.displayName?.split(' ') ?? ['Unknown'];
            final firstName = nameParts.first;
            final lastName = nameParts.length > 1 ? nameParts.last : 'Unknown';

            final passenger = Passenger(
              id: user.uid,
              phone_number: user.phoneNumber ??
                  'Unknown Number', // Empty string instead of 'Unknown'
              first_name: firstName,
              last_name: lastName,
              profile_photo: user.photoURL ??
                  "https://ui-avatars.com/api/?name=${Uri.encodeComponent(firstName)}+${Uri.encodeComponent(lastName)}", // Generate avatar if no photo
              created_at: DateTime.now().toIso8601String(), // Current timestamp
              email: user.email ?? '', // Empty string instead of 'Unknown'
              payment_method: 'cash',
            );

            debugPrint(
                'Attempting to create passenger with data: ${passenger.toJson()}');
            final createdPassenger =
                await apiService.createPassenger(passenger);
            debugPrint(
                'Successfully created passenger: ${createdPassenger.toJson()}');
            return user;
          }
        } catch (e) {
          debugPrint('Error in passenger operations: $e');
          // If there's an error with the passenger operations, still return the authenticated user
          // but log the error for debugging
          return user;
        }
      }
      throw Exception('Failed to sign in with Google - user is null');
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      throw Exception('Sign in failed: $e');
    }
  }
}
