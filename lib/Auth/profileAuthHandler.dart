import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/passenger.dart';

class ProfileAuthHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

// final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getSignInMethod() {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Get the provider data
      final providerData = currentUser.providerData;

      // Check if the user has any providers
      if (providerData.isEmpty) return null;

      // Get the first provider ID
      final providerId = providerData[0].providerId;

      // Return the sign-in method
      switch (providerId) {
        case 'google.com':
          return 'google';
        case 'password':
          return 'email';
        default:
          return null;
      }
    } catch (e) {
      print('Error checking sign-in method: $e');
      return null;
    }
  }

  Future<bool> verifyPassword(String password) async {
    String? signInMethod = ProfileAuthHandler().getSignInMethod();
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Find the provider ID the user is using
      if (signInMethod == 'email') {
        // For email/password users, verify the password
        try {
          final credential = EmailAuthProvider.credential(
            email: currentUser.email!,
            password: password,
          );
          await currentUser.reauthenticateWithCredential(credential);
          return true;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            return false;
          }
        }
      }else if (signInMethod == 'google') {
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying authentication: $e');
      return false;
    }
  }

  Future<bool> updateProfile(
      Passenger updatedPassenger, String? password) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final providerId = currentUser.providerData.isNotEmpty
          ? currentUser.providerData[0].providerId
          : null;

      // For email/password users, require password verification
      if (providerId == 'password') {
        if (password == null || password.isEmpty) {
          throw Exception('Password is required for verification');
        }
        bool isPasswordValid = await verifyPassword(password);
        if (!isPasswordValid) {
          throw Exception('Invalid password');
        }
      }
      // Update display name if changed
      if (currentUser.displayName !=
          '${updatedPassenger.first_name} ${updatedPassenger.last_name}') {
        await currentUser.updateDisplayName(
            '${updatedPassenger.first_name} ${updatedPassenger.last_name}');
      }

      // Save updated passenger data to Firestore
      await Firebaseutillies().savePassengerToFirestore(updatedPassenger);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      throw e; // Rethrow to handle in UI
    }
  }
}
