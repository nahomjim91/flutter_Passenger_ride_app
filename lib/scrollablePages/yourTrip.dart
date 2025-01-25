import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/compont/Map/routeMap.dart';
import 'package:ride_app/compont/tripDetails.dart';
import 'package:ride_app/driver.dart';

// ignore: must_be_immutable
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
  late List<Driver> drivers;

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
  void initState() {
    super.initState();
    // Use a Future method inside initState
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    isLoading = true;
    final fetchedDrivers =
        await ApiService().getDriverAround(widget.pickupPlace!);
    setState(() {
      drivers = fetchedDrivers;
      debugPrint("drivers: ${drivers.length}");
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use key to force rebuild when places change

        if (widget.pickupPlace != null &&
            widget.destinationPlace != null &&
            !isLoading)
          RouteMap(
            key: _mapKey,
            availableDriver: drivers,
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
