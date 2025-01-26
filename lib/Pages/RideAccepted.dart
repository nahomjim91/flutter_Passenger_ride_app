import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/compont/Map/mapBetweenDriverAndPassenger.dart';
import 'package:ride_app/compont/ongoingCard.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/driver.dart';
import 'package:ride_app/request_ride.dart';
import 'package:ride_app/scrollablePages/accptedRideDetails.dart';
import 'package:geolocator/geolocator.dart';

class RideAccepted extends StatefulWidget {
  RideAccepted(
      {super.key,
      required this.rideRequestId,
      required this.driver,
      required this.requestRide,
      required this.shouldShareLocation});
  final Driver driver;
  final int rideRequestId;
  RequestRide requestRide;
  bool shouldShareLocation = false;

  @override
  State<RideAccepted> createState() => _RideAcceptedState();
}

class _RideAcceptedState extends State<RideAccepted> {
  double? distance;
  double? duration;
  List<LatLng>? routePoints;

  late Place currentDriverCoordinates;
  late Place currentPassenger;
  late Timer _timer;
  bool isRideRequestStarted = false;
  UniqueKey _mapKey = new UniqueKey();
  UniqueKey _cardKey = new UniqueKey();
  final String serverUrl = 'http://127.0.0.1:8000/api';

  @override
  void initState() {
    super.initState();
    _fetchDriverCoordinates();
    currentDriverCoordinates = Place(
      displayName: widget.driver.first_name + " " + widget.driver.last_name,
      latitude: widget.driver.location['latitude']!,
      longitude: widget.driver.location['longitude']!,
    );
    if (widget.shouldShareLocation) _fetchPassengerLocation();

    _timer =
        Timer.periodic(Duration(seconds: 30), (Timer t) => _sequenceData());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _sequenceData() async {
    _mapKey = new UniqueKey();
    await _fetchDriverCoordinates();
    if (!isRideRequestStarted) {
      bool result = await _requestStatues(widget.rideRequestId);
      setState(() {
        isRideRequestStarted = result;
      });
    }
  }

  Future<void> _fetchDriverCoordinates() async {
    final driver = await ApiService().getDriverCoordinates(widget.driver.id);
    debugPrint("Driver location: " + driver!.toJSON().toString());
    _resetRouteData();
    if (driver != null) {
      setState(() {
        currentDriverCoordinates = driver;
      });
    }
  }

  Future<bool> _requestStatues(int rideRequestId) async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/ride-requests/$rideRequestId'),
      );

      debugPrint(
          'Polling Ride Request States Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final rideRequest = json.decode(response.body);
        if (rideRequest['status'] == 'started') {
          return true; // Driver starte the request
        }
        return false; // Driver ... the request
      }
    } catch (e) {
      debugPrint('Error in _waitForDriverResponse: $e');
    }

    return false;
  }

  /// Reset route-related data
  void _resetRouteData() {
    _mapKey = UniqueKey();
    _cardKey = UniqueKey();
    distance = null;
    duration = null;
    routePoints = null;
  }

  Future<void> _fetchPassengerLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle the case when location services are not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case when location permissions are denied
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPassenger = Place(
        displayName: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapBetweenDriverAndPassenger(
          key: _mapKey,
          startLocation: isRideRequestStarted
              ? currentDriverCoordinates
              : widget.shouldShareLocation
                  ? currentPassenger
                  : widget.requestRide.pickupPlace,
          endLocation: isRideRequestStarted
              ? widget.requestRide.destinationPlace
              : currentDriverCoordinates,
          isRideRequestStarted: isRideRequestStarted,
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
        if (isRideRequestStarted && distance != null && duration != null)
          OngoingCard(
              key: _cardKey,
              driverName:
                  widget.driver.first_name + " " + widget.driver.last_name,
              driverImage: widget.driver.profile_photo!,
              destination: widget.requestRide.destinationPlace.displayName,
              duration: duration!,
              distance: distance!,
              carType: widget.driver.vehicle_category,
              carNumber: widget.driver.license_plate)
        else if (!isRideRequestStarted)
          RideAccptedDetails(
            shouldShareLocation: widget.shouldShareLocation,
            toggledShareLocation: () {
              setState(() {
                widget.shouldShareLocation = !widget.shouldShareLocation;
              });
            },
            rquestRide: widget.requestRide,
            driverId: widget.driver.id,
            distance: distance,
            duration: duration,
          ),
      ],
    );
  }
}
