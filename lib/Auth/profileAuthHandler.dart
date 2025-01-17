import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/passenger.dart';

class ProfileAuthHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> verifyPassword(String password) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check the user's providers directly from the user object
      final providerData = currentUser.providerData;

      // Find the provider ID the user is using
      final providerId =
          providerData.isNotEmpty ? providerData[0].providerId : null;

      if (providerId == 'google.com') {
        // For Google users, verify by attempting to reauthenticate with Google
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return false;

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await currentUser.reauthenticateWithCredential(credential);
          return true;
        } catch (e) {
          print('Error reauthenticating with Google: $e');
          return false;
        }
      } else if (providerId == 'password') {
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
          throw e;
        }
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
      // For Google users, require Google reauthentication
      else if (providerId == 'google.com') {
        bool isGoogleAuthValid = await verifyPassword(
            ''); // Password param is ignored for Google auth
        if (!isGoogleAuthValid) {
          throw Exception('Google authentication failed');
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
