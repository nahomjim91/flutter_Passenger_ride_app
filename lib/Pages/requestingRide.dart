import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Pages/RideAccepted.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/compont/Map/routeMap.dart';
import 'package:ride_app/driver.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/request_ride.dart';
// import 'package:ride_app/scrollablePages/accptedRideDetails.dart';
import 'package:ride_app/scrollablePages/requestingRideDetail.dart';

class RequestingRide extends StatefulWidget {
  final RequestRide rquestRide;

  const RequestingRide({Key? key, required this.rquestRide}) : super(key: key);

  @override
  State<RequestingRide> createState() => _RequestingRideState();
}

class _RequestingRideState extends State<RequestingRide> {
  Timer? _timer;
  double? distance;
  double? duration;
  List<LatLng>? routePoints;
  List<Driver> drivers = [];
  late Passenger passenger;
  Driver? currentDriver;
  bool isDriverFound = false;
  int currentDriverIndex = 0;
  bool isLoading = false;
  bool isRequesting = false;
  bool shouldShareLocation = false;

  UniqueKey _mapKey = UniqueKey();

  // Server API endpoint
  final String serverUrl = 'http://127.0.0.1:8000/api';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    passenger = context.read<PassengerProvider>().passenger!;
    _loadDrivers();
  }

  @override
  void initState() {
    super.initState();
    //
  }

  /// Load nearby drivers from the API
  Future<void> _loadDrivers() async {
    setState(() => isLoading = true);
    try {
      final fetchedDrivers =
          await ApiService().getDriverAround(widget.rquestRide.pickupPlace);

      if (fetchedDrivers.isNotEmpty) {
        setState(() => drivers = fetchedDrivers);
        debugPrint("Drivers loaded: ${drivers.length}");
        _sendRideRequest();
      } else {
        debugPrint("No drivers found near the pickup location.");
      }
    } catch (e) {
      debugPrint("Error loading drivers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Send ride request to drivers with pooling logic
  Future<void> _sendRideRequest() async {
    setState(() => isRequesting = true);
    try {
      if (drivers.isEmpty) {
        debugPrint("No drivers available.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No drivers available. Please try again later.')),
        );
        return;
      }

      // Create a ride request and assign it to the first driver
      final rideRequestId =
          await _createRideRequest(passenger.id, drivers[0].id as int);
      if (rideRequestId == null) {
        throw Exception('Failed to create ride request');
      }

      for (int i = 0; i < drivers.length; i++) {
        final driver = drivers[i];
        debugPrint(
            'Sending request to driver ${driver.id} (${driver.first_name})');

        // Wait for driver response (5 seconds)
        final isAccepted = await _waitForDriverResponse(rideRequestId);
        if (isAccepted) {
          debugPrint(
              'Driver ${driver.id} (${driver.first_name}) accepted the request');
          setState(() {
            currentDriver = driver;
            isDriverFound = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Driver ${driver.first_name} accepted your request!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RideAccepted(
                rideRequestId: rideRequestId,
                requestRide: widget.rquestRide,
                driver: currentDriver!,
                shouldShareLocation: shouldShareLocation,
              ),
            ),
          );
          break; // Exit the loop if a driver accepts
        } else {
          debugPrint(
              'Driver ${driver.id} (${driver.first_name}) did not respond or rejected the request');

          // Reassign the ride request to the next driver (if available)
          if (i < drivers.length - 1) {
            final nextDriver = drivers[i + 1];
            await _reassignRideRequest(rideRequestId, nextDriver.id as int);
          } else {
            debugPrint('No more drivers available');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'No drivers accepted your request. Please try again.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _sendRideRequest: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to find a driver. Please try again.')),
      );
    } finally {
      setState(() => isRequesting = false);
    }
  }

  /// Create a ride request and assign it to a driver
  Future<int?> _createRideRequest(String passengerId, int driverId) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/ride-requests'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'passenger_id': passengerId,
          'driver_id': driverId,
          'request_data': widget.rquestRide.toJson(),
        }),
      );

      debugPrint(
          'Create Ride Request Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final rideRequest =
            responseData['rideRequest']; // Access the nested object
        if (rideRequest != null && rideRequest['id'] != null) {
          return rideRequest['id']; // Return the ride request ID
        } else {
          throw Exception('Ride request ID not found in response');
        }
      } else {
        throw Exception('Failed to create ride request: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in _createRideRequest: $e');
      return null;
    }
  }

  /// Reassign the ride request to the next driver
  Future<void> _reassignRideRequest(int rideRequestId, int nextDriverId) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/ride-requests/$rideRequestId/reassign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'driver_id': nextDriverId,
        }),
      );

      debugPrint(
          'Reassign Ride Request Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to reassign ride request: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in _reassignRideRequest: $e');
      rethrow;
    }
  }

  /// Wait for driver response (polling every second for 5 seconds)
  Future<bool> _waitForDriverResponse(int rideRequestId) async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 2)); // Wait for 1 second
      try {
        final response = await http.get(
          Uri.parse('$serverUrl/ride-requests/$rideRequestId'),
        );

        debugPrint(
            'Polling Ride Request Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final rideRequest = json.decode(response.body);
          if (rideRequest['status'] == 'accepted') {
            return true; // Driver accepted the request
          } else if (rideRequest['status'] == 'rejected') {
            return false; // Driver rejected the request
          }
        }
      } catch (e) {
        debugPrint('Error in _waitForDriverResponse: $e');
      }
    }
    return false; // No response within 5 seconds
  }

  /// Add a new stop to the ride and restart the request process
  void addingStops(Place newPlace) {
    setState(() {
      // Initialize stopsPlaces as an empty list if it is null
      widget.rquestRide.stopsPlaces ??= [];

      // Ensure the list is modifiable by creating a new list if necessary
      if (widget.rquestRide.stopsPlaces!.isEmpty) {
        widget.rquestRide.stopsPlaces = [newPlace];
      } else {
        widget.rquestRide.stopsPlaces!.add(newPlace);
      }

      _resetRouteData();
    });

    _sendRideRequest();
  }

  /// Remove a stop from the ride and restart the request process
  void _removeStops(Place placeToRemove) {
    setState(() {
      widget.rquestRide.stopsPlaces?.remove(placeToRemove);
      _resetRouteData();
    });
    _sendRideRequest();
  }

  /// Reset route-related data
  void _resetRouteData() {
    _mapKey = UniqueKey();
    distance = null;
    duration = null;
    routePoints = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isLoading)
          RouteMap(
            key:
                _mapKey, //ValueKey(drivers.length), // Update key when drivers change
            availableDriver: drivers,
            currentDriver: currentDriver,
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
          toggledShareLocation: () {
            setState(() {
              shouldShareLocation = !shouldShareLocation;
            });
          },
          shouldShareLocation: shouldShareLocation,
          rquestRide: widget.rquestRide,
          addingStops: addingStops,
          removedStops: _removeStops,
          sendRideRequest: _sendRideRequest,
        ),
      ],
    );
  }
}
