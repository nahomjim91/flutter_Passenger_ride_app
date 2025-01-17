import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ride_app/compont/placeSearchWidget.dart';

class RouteMap extends StatefulWidget {
  final Place startPlace;
  final Place endPlace;
  final List<Place>? stops;
  final Function(double distance, double duration, List<LatLng> routePoints)?
      onRouteCalculated;

  const RouteMap({
    Key? key,
    required this.startPlace,
    required this.endPlace,
    this.stops,
    this.onRouteCalculated,
  }) : super(key: key);

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _mapController = MapController();
  List<List<LatLng>> _routeSegments = [];
  List<double> _segmentDistances = [];
  List<double> _segmentDurations = [];
  double _totalDistance = 0;
  double _totalDuration = 0;
  bool _isLoading = true;
  String _error = '';

  final List<LatLng> _availableCars = [
    LatLng(8.989762498796392, 38.75107989156815),
    LatLng(8.99033892123591, 38.75052357070594),
    LatLng(8.990931503970192, 38.75076900638044),
  ];
  List<LatLng> _nearbyCars = [];

  @override
  void initState() {
    super.initState();
    _calculateFullRoute();
    _findNearbyCars();
  }

  LatLng _placeToLatLng(Place place) {
    return LatLng(place.latitude, place.longitude);
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
        'Current location: ${widget.startPlace.latitude}, ${widget.startPlace.longitude}');

    _nearbyCars = _availableCars.where((carPosition) {
      double distance = _calculateDistance(
          LatLng(
            widget.startPlace.latitude,
            widget.startPlace.longitude,
          ),
          carPosition);
      print(
          'Car at ${carPosition.latitude}, ${carPosition.longitude}: $distance meters');
      return distance <= searchRadius;
    }).toList();

    print('Found ${_nearbyCars.length} cars within $searchRadius meters');
  }

  Future<Map<String, dynamic>> _calculateRouteBetweenPoints(
      Place start, Place end) async {
    const String apiKey =
        '5b3ce3597851110001cf624860414528c2074446beab88e10450715a';
    final String baseUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car';

    final response = await http.get(
      Uri.parse(
          '$baseUrl?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates =
          data['features'][0]['geometry']['coordinates'] as List;
      final properties = data['features'][0]['properties'];
      final segments = properties['segments'][0];

      List<LatLng> routePoints = coordinates.map((coord) {
        return LatLng(coord[1] as double, coord[0] as double);
      }).toList();

      return {
        'points': routePoints,
        'distance': segments['distance'],
        'duration': segments['duration'],
      };
    } else {
      throw Exception('Failed to calculate route segment');
    }
  }

  Future<void> _calculateFullRoute() async {
    try {
      // Create ordered list of all points including start, stops, and end
      List<Place> orderedPoints = [widget.startPlace];
      if (widget.stops != null && widget.stops!.isNotEmpty) {
        orderedPoints.addAll(widget.stops!);
      }
      orderedPoints.add(widget.endPlace);

      // Reset lists
      _routeSegments = [];
      _segmentDistances = [];
      _segmentDurations = [];
      _totalDistance = 0;
      _totalDuration = 0;

      // Calculate route for each consecutive pair of points
      for (int i = 0; i < orderedPoints.length - 1; i++) {
        print('Calculating route from point $i to ${i + 1}');

        final routeData = await _calculateRouteBetweenPoints(
          orderedPoints[i],
          orderedPoints[i + 1],
        );

        _routeSegments.add(routeData['points']);
        _segmentDistances.add(routeData['distance']);
        _segmentDurations.add(routeData['duration']);

        _totalDistance += routeData['distance'];
        _totalDuration += routeData['duration'];
      }

      // Combine all route points for the callback
      final List<LatLng> allRoutePoints =
          _routeSegments.expand((segment) => segment).toList();

      setState(() {
        _isLoading = false;
      });

      widget.onRouteCalculated
          ?.call(_totalDistance, _totalDuration, allRoutePoints);
      _fitBounds();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error calculating route: $e';
      });
      print('Error calculating route: $e');
    }
  }

  void _fitBounds() {
    if (_routeSegments.isEmpty) return;

    final allPoints = _routeSegments.expand((segment) => segment).toList();
    final bounds = LatLngBounds.fromPoints(allPoints);
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  Widget _buildStopMarker(int stopNumber) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '$stopNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            center: _placeToLatLng(widget.startPlace),
            zoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            // Draw all route segments
            PolylineLayer(
              polylines: _routeSegments.map((segment) {
                return Polyline(
                  points: segment,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: [
                // Start marker
                Marker(
                  width: 68,
                  height: 68,
                  point: _placeToLatLng(widget.startPlace),
                  builder: (context) => Column(
                    children: [
                      const Text(
                        'Start',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.trip_origin,
                        color: Colors.green.shade700,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                // Stop markers
                if (widget.stops != null)
                  ...List.generate(
                    widget.stops!.length,
                    (index) => Marker(
                      width: 30,
                      height: 30,
                      point: _placeToLatLng(widget.stops![index]),
                      builder: (context) => _buildStopMarker(index + 1),
                    ),
                  ),
                // End marker
                Marker(
                  point: _placeToLatLng(widget.endPlace),
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
                // Car markers
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
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        // Cars counter
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarMarker() {
    return Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/car(1).png'), fit: BoxFit.fill),
        ));
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
