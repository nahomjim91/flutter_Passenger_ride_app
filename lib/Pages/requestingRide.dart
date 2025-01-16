import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/routeMap.dart';
import 'package:ride_app/scrollablePages/requestingRideDetail.dart';
import 'package:ride_app/tripDetails.dart';

class RequestingRide extends StatefulWidget {
  RequestingRide({super.key, required this.rquestRide});

  RequestRide rquestRide;

  @override
  State<RequestingRide> createState() => _RequestingRideState();
}

class _RequestingRideState extends State<RequestingRide> {
  Timer? _timer;
  double? distance;
  double? duration;
  List<LatLng>? routePoints;
  Key _mapKey = UniqueKey();

  void _updatePlaces(Place newPlace, int index) {
    debugPrint("Updating places...");
    debugPrint("Old Pickup: ${widget.rquestRide.stopsPlaces![index]}");

    setState(() {
      // Generate new key to force RouteMap rebuild
      _mapKey = UniqueKey();

      widget.rquestRide.stopsPlaces![index] = newPlace;
      // Reset route calculations
      distance = null;
      duration = null;
      routePoints = null;
    });

    debugPrint("New Pickup: ${widget.rquestRide.stopsPlaces![index]}");
    debugPrint("RouteMap key updated: $_mapKey");
  }

  void _addingStops(Place newPlace) {
    setState(() {
      // Generate new key to force RouteMap rebuild
      _mapKey = UniqueKey();

      // Create a new list based on the existing list and add the new place
      final updatedStops =
          List<Place>.from(widget.rquestRide.stopsPlaces ?? []);
      updatedStops.add(newPlace);

      // Update the state with the new list
      widget.rquestRide.stopsPlaces = updatedStops;

      // widget.rquestRide.stopsPlaces!.add(newPlace);
      // Reset route calculations
      distance = null;
      duration = null;
      routePoints = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RouteMap(
          key: _mapKey,
          startPlace: widget.rquestRide.pickupPlace,
          endPlace: widget.rquestRide.destinationPlace,
          stops: widget.rquestRide.stopsPlaces,
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
        RequestingRideDetails(
            rquestRide: widget.rquestRide,
            addingStops: _addingStops,
            updatePlaces: _updatePlaces)
      ],
    );
  }
}
