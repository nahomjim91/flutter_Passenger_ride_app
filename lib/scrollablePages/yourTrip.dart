import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/routeMap.dart';
import 'package:ride_app/tripDetails.dart';

class Yourtrip extends StatefulWidget {
  Place? pickupPlace;
  Place? destinationPlace;

  Yourtrip({
    super.key,
    required this.destinationPlace,
    required this.pickupPlace,
  });

  @override
  State<Yourtrip> createState() => _YourtripState();
}

class _YourtripState extends State<Yourtrip> {
  double? distance;
  double? duration;
  List<LatLng>? routePoints;
  bool isLoading = false;

  // Key to force RouteMap rebuild when places change
  Key _mapKey = UniqueKey();

  void _updatePlaces(Place? newPickupPlace, Place? newDestinationPlace) {
    debugPrint("Updating places...");
    debugPrint("Old Pickup: ${widget.pickupPlace}");
    debugPrint("Old Destination: ${widget.destinationPlace}");

    setState(() {
      isLoading = true; // Show loading state
      widget.pickupPlace = newPickupPlace;
      widget.destinationPlace = newDestinationPlace;

      // Generate new key to force RouteMap rebuild
      _mapKey = UniqueKey();

      // Reset route calculations
      distance = null;
      duration = null;
      routePoints = null;

      isLoading = false; // Reset loading state
    });

    debugPrint("New Pickup: ${widget.pickupPlace}");
    debugPrint("New Destination: ${widget.destinationPlace}");
    debugPrint("RouteMap key updated: $_mapKey");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use key to force rebuild when places change
        if (widget.pickupPlace != null && widget.destinationPlace != null)
          RouteMap(
            key: _mapKey,
          startPlace: widget.pickupPlace!,
          endPlace: widget.destinationPlace!,
            onRouteCalculated: (dist, dur, points) {
              setState(() {
                distance = dist;
                duration = dur;
                routePoints = points;
              });
              debugPrint(
                  "Route calculated: Distance - $distance, Duration - $duration");
            },
          ),

        TripDetails(
          destinationPlace: widget.destinationPlace,
          pickupPlace: widget.pickupPlace,
          changePlaceValue: _updatePlaces,
        ),

        if (isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
