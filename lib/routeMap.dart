import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteMap extends StatefulWidget {
  final LatLng pointA;
  final LatLng pointB;
  final Function(double distance, double duration, List<LatLng> routePoints)?
      onRouteCalculated;

  const RouteMap({
    Key? key,
    required this.pointA,
    required this.pointB,
    this.onRouteCalculated,
  }) : super(key: key);

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  double _distance = 0;
  double _duration = 0;
  bool _isLoading = true;
  String _error = '';

  final List<LatLng> _availableCars = [
    LatLng(8.989762498796392, 38.75107989156815), // Car 1
    LatLng(8.99033892123591, 38.75052357070594), // Car 2
    LatLng(8.990931503970192, 38.75076900638044), // Car 3
  ];

  // List to store nearby cars
  List<LatLng> _nearbyCars = [];

  @override
  void initState() {
    super.initState();
    _calculateRoute();
    _findNearbyCars();
  }

  // Haversine formula for more accurate distance calculation
  double _calculateDistance(LatLng point1, LatLng point2) {
    var lat1 = point1.latitude;
    var lon1 = point1.longitude;
    var lat2 = point2.latitude;
    var lon2 = point2.longitude;

    var R = 6371e3; // Earth's radius in meters
    var phi1 = lat1 * pi / 180;
    var phi2 = lat2 * pi / 180;
    var deltaPhi = (lat2 - lat1) * pi / 180;
    var deltaLambda = (lon2 - lon1) * pi / 180;

    var a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  void _findNearbyCars() {
    final searchRadius = 2000.0; // 2000 meters radius

    print(
        'Current location: ${widget.pointA.latitude}, ${widget.pointA.longitude}');

    _nearbyCars = _availableCars.where((carPosition) {
      double distance = _calculateDistance(widget.pointA, carPosition);
      print(
          'Car at ${carPosition.latitude}, ${carPosition.longitude}: $distance meters');
      return distance <= searchRadius;
    }).toList();

    print('Found ${_nearbyCars.length} cars within $searchRadius meters');
  }

  Future<void> _calculateRoute() async {
    const String apiKey =
        '5b3ce3597851110001cf624860414528c2074446beab88e10450715a';
    final String baseUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car';

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl?api_key=$apiKey&start=${widget.pointA.longitude},${widget.pointA.latitude}&end=${widget.pointB.longitude},${widget.pointB.latitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;
        final properties = data['features'][0]['properties'];

        setState(() {
          _routePoints = coordinates.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();

          _distance = properties['segments'][0]['distance'];
          _duration = properties['segments'][0]['duration'];
          _isLoading = false;
        });

        widget.onRouteCalculated?.call(_distance, _duration, _routePoints);
        _fitBounds();
      } else {
        throw Exception('Failed to calculate route');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error calculating route: $e';
      });
    }
  }

  void _fitBounds() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  // Build car marker widget
  Widget _buildCarMarker() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        image:  DecorationImage(
            image: AssetImage('assets/images/car(1).png'), fit: BoxFit.fill),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     spreadRadius: 1,
        //     blurRadius: 2,
        //     offset: const Offset(0, 1),
        //   ),
        // ],
      ),
      // child: Image.asset('assets/images/car(1).png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _routePoints.isNotEmpty
                ? _routePoints[_routePoints.length ~/ 2]
                : widget.pointA,
            zoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Start point marker
                Marker(
                  width: 48,
                  height: 48,
                  point: widget.pointA,
                  builder: (context) => buildTimeCard(minutes: '2'),
                ),
                // End point marker
                Marker(
                  point: widget.pointB,
                  width: 80,
                  height: 80,
                  builder: (context) => const Column(
                    children: [
                      Text(
                        'End',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ],
                  ),
                ),
                // Nearby cars markers
                ..._nearbyCars.map(
                  (carPosition) => Marker(
                    width: 40,
                    height: 40,
                    point: carPosition,
                    builder: (context) => _buildCarMarker(),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Optional: Add a counter for nearby cars
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Text(
              '${_nearbyCars.length} cars nearby',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTimeCard({
    required String minutes,
    Color backgroundColor = const Color.fromARGB(255, 0, 0, 0),
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            minutes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'min',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
