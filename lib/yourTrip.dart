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
        // TripDetailsPage()
        // buildBottomContainer(),
        // SlidingBoxDemo()
      ],
    );
  }

  Widget buildBottomContainer() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back,
                                color: Colors.black),
                          ),
                          SizedBox(width: 16),
                          const Text(
                            'YOUR TRIP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.location_on, color: Colors.red),
                            title: Text('General Wingate Street'),
                            subtitle: Text('Estimated time: 8:55 AM'),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text('Dembel City Center'),
                            trailing: Text('Stops'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Icon(Icons.directions_bus),
                                SizedBox(width: 8),
                                Text('Economy - Br170'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
