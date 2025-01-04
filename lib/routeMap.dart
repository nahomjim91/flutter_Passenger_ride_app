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

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    const String apiKey =
        '5b3ce3597851110001cf624860414528c2074446beab88e10450715a'; // Replace with your API key
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

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

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
                Marker(
                  point: widget.pointA,
                  width: 80,
                  height: 80,
                  builder: (context) => const Column(
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
          ],
        ),
      ],
    );
  }
}
