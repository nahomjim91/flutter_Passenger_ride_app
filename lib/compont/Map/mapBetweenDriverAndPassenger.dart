import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ride_app/compont/placeSearchWidget.dart';

class MapBetweenDriverAndPassenger extends StatefulWidget {
  final Place startLocation;
  final Place endLocation;
  final bool isRideRequestStarted;
  final Function(double distance, double duration, List<LatLng> routePoints)?
      onRouteCalculated;

  const MapBetweenDriverAndPassenger(
      {super.key,
      required this.startLocation,
      required this.endLocation,
      this.onRouteCalculated,
      required this.isRideRequestStarted});

  @override
  State<MapBetweenDriverAndPassenger> createState() =>
      _MapBetweenDriverAndPassengerState();
}

class _MapBetweenDriverAndPassengerState
    extends State<MapBetweenDriverAndPassenger> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _error = '';
  // Place? widget.endLocation; // You'll need to fetch this based on endLocationId

  @override
  void initState() {
    super.initState();
    _calculateRoute();
    debugPrint("Mapcurrent startLocation location: " +
        widget.startLocation.toJSON().toString());
    debugPrint("Mapcurrent endLocation location: " +
        widget.endLocation.toJSON().toString());
  }

  Future<void> _calculateRoute() async {
    try {
      const String apiKey =
          '5b3ce3597851110001cf624868b6674e349e493eaee5d64bd6e4c7db';
      const String baseUrl =
          'https://api.openrouteservice.org/v2/directions/driving-car';

      final response = await http.get(
        Uri.parse(
            '$baseUrl?api_key=$apiKey&start=${widget.endLocation.longitude},${widget.endLocation.latitude}&end=${widget.startLocation.longitude},${widget.startLocation.latitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;
        final properties = data['features'][0]['properties'];
        final segments = properties['segments'][0];

        setState(() {
          _routePoints = coordinates.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();
          _isLoading = false;
        });

        widget.onRouteCalculated?.call(
          segments['distance'],
          segments['duration'],
          _routePoints,
        );

        _fitBounds();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error calculating route: $e';
      });
      debugPrint('Error calculating route: $e');
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

  @override
  @override
  Widget build(BuildContext context) {
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    return Stack(
      children: [
        // Map Base Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(
              widget.startLocation.latitude,
              widget.startLocation.longitude,
            ),
            zoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue.shade700,
                  gradientColors: [
                    Colors.blue.shade500,
                    Colors.blue.shade900,
                  ],
                ),
              ],
            ),
            _markersPosition(),
          ],
        ),

        // Loading Indicator
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
      ],
    );
  }

  Widget _markersPosition() {
    return MarkerLayer(
      markers: [
        // Passenger Marker
        Marker(
          width: 100,
          height: 100,
          point: LatLng(
            widget.startLocation.latitude,
            widget.startLocation.longitude,
          ),
          builder: (context) => Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Passenger',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
        // Driver Marker
        Marker(
          width: 100,
          height: 100,
          point: LatLng(
            widget.endLocation.latitude,
            widget.endLocation.longitude,
          ),
          builder: (context) => Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 225, 90, 53)
                          .withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/car(1).png'),
                      fit: BoxFit.contain,
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
