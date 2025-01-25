import 'package:ride_app/compont/placeSearchWidget.dart';

class RequestRide {
  Place pickupPlace, destinationPlace;
  String instructions;
  String paymentMethod;
  String carType;
  List<Place>? stopsPlaces;

  RequestRide(
      {required this.pickupPlace,
      required this.destinationPlace,
      required this.paymentMethod,
      required this.carType,
      required this.instructions,
      List<Place>? stopsPlaces})
      : this.stopsPlaces = stopsPlaces ?? const [];

  Map<String, dynamic> toJson() {
    return {
      'pickup_place': pickupPlace.toJSON(),
      'destination_place': destinationPlace.toJSON(),
      'instructions': instructions,
      'payment_method': paymentMethod,
      'car_type': carType,
      'stops_places': stopsPlaces?.map((place) => place.toJSON()).toList(),
    };
  }
}
