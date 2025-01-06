import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/ride_booking_screen.dart';
import 'package:ride_app/routeMap.dart';
import 'package:ride_app/sliding_box.dart';
import 'package:ride_app/test.dart';
import 'package:ride_app/tripDetails.dart';

class Yourtrip extends StatefulWidget {
  Place? pickupPlace;
  Place? destinationPlace;
  Yourtrip(
      {super.key, required this.destinationPlace, required this.pickupPlace});

  @override
  State<Yourtrip> createState() => _YourtripState();
}

class _YourtripState extends State<Yourtrip> {
  double? distance;
  double? duration;
  List<LatLng>? routePoints;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RouteMap(
          pointA: LatLng(
              widget.pickupPlace!.latitude, widget.pickupPlace!.longitude),
          pointB: LatLng(widget.destinationPlace!.latitude,
              widget.destinationPlace!.longitude),
          onRouteCalculated: (dist, dur, points) {
            setState(() {
              distance = dist;
              duration = dur;
              routePoints = points;
            });
          },
        ),
        TripDetails(
            destinationPlace: widget.destinationPlace,
            pickupPlace: widget.pickupPlace)

      ],
    );
  }

}
