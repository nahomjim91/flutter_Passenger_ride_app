import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ride_app/passenger.dart';

class Firebaseutillies {
  Future<Passenger?> getPassengerFromFirestore(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('passengers')
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Passenger(
          id: data['id'],
          phone_number: data['phone_number'],
          first_name: data['first_name'],
          last_name: data['last_name'],
          profile_photo: data['profile_photo'],
          created_at: data['created_at'],
          email: data['email'],
        );
      } else {
        print("No such document!");
        return null;
      }
    } catch (e) {
      print("Failed to retrieve passenger: $e");
      return null;
    }
  }

  Future<void> savePassengerToFirestore(Passenger passenger) async {
    try {
      await FirebaseFirestore.instance
          .collection('passengers')
          .doc(passenger.id) // Use the user's UID as the document ID
          .set({
        'id': passenger.id,
        'phone_number': passenger.phone_number,
        'first_name': passenger.first_name,
        'last_name': passenger.last_name,
        'profile_photo': passenger.profile_photo,
        'created_at': passenger.created_at,
        'email': passenger.email,
      });

      print("Passenger data saved successfully.");
    } catch (e) {
      print("Failed to save passenger: $e");
    }
  }
}
