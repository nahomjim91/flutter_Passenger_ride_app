import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/passenger.dart';

class AuthService {
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
}
