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
  bool isRideAccepted = false;
  bool _isDisposed = false; // Track disposal

  UniqueKey _mapKey = UniqueKey();

  final String serverUrl = 'http://127.0.0.1:8000/api';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    passenger = context.read<PassengerProvider>().passenger!;
    _loadDrivers();
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    _timer?.cancel();
    super.dispose();
  }

  /// Load nearby drivers from the API

  Future<void> _loadDrivers() async {
    if (_isDisposed) return;
    if (mounted) setState(() => isLoading = true);
    try {
      final fetchedDrivers =
          await ApiService().getDriverAround(widget.rquestRide.pickupPlace);

      if (!_isDisposed && fetchedDrivers.isNotEmpty) {
        if (mounted) setState(() => drivers = fetchedDrivers);
        _sendRideRequest();
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading drivers')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _sendRideRequest() async {
    if (_isDisposed) return;
    if (mounted) setState(() => isRequesting = true);
    try {
      if (drivers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No drivers available')),
          );
        }
        return;
      }

      final rideRequestId =
          await _createRideRequest(passenger.id, drivers[0].id as int);
      if (rideRequestId == null || _isDisposed) return;

      for (int i = 0; i < drivers.length; i++) {
        if (_isDisposed || isRideAccepted) break;

        final driver = drivers[i];
        final isAccepted = await _waitForDriverResponse(rideRequestId);
        if (_isDisposed) break;

        if (isAccepted) {
          if (mounted) {
            setState(() {
              currentDriver = driver;
              isDriverFound = true;
              isRideAccepted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Driver ${driver.first_name} accepted!')),
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
          }
          break;
        } else if (i < drivers.length - 1) {
          await _reassignRideRequest(rideRequestId, drivers[i + 1].id as int);
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to find a driver')),
        );
      }
    } finally {
      if (mounted) setState(() => isRequesting = false);
    }
  }

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

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['rideRequest']?['id'];
      }
    } catch (e) {
      debugPrint('Error creating ride request: $e');
    }
    return null;
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
      await Future.delayed(const Duration(seconds: 2));
      if (_isDisposed) return false;

      try {
        final response = await http.get(
          Uri.parse('$serverUrl/ride-requests/$rideRequestId'),
        );
        if (response.statusCode == 200) {
          final rideRequest = json.decode(response.body);
          if (rideRequest['status'] == 'accepted') return true;
          if (rideRequest['status'] == 'rejected') return false;
        }
      } catch (e) {
        debugPrint('Error polling response: $e');
      }
    }
    return false;
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
        ),
      ],
    );
  }
}
