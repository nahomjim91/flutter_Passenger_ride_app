import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:ride_app/compont/buttons.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';

class ShowSelectedMap extends StatefulWidget {
  final Place selectedPlace;

  const ShowSelectedMap({
    Key? key,
    required this.selectedPlace,
  }) : super(key: key);

  @override
  _ShowSelectedMapState createState() => _ShowSelectedMapState();
}

class _ShowSelectedMapState extends State<ShowSelectedMap> {
  final Location _location = Location();
  late LatLng _currentPosition;
  late LatLng _selectedPosition;
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(
      widget.selectedPlace.latitude,
      widget.selectedPlace.longitude,
    );
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
          _currentPosition = LatLng(9.0222, 38.7468); // Default to Addis Ababa
        });
        return;
      }

      LocationData locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('Location data is null');
      }

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _isLoading = false;
      });

      // Add a small delay to ensure the map is properly initialized
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Center the map to show both points
      _centerMapOnBothPoints();
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _currentPosition = LatLng(9.0222, 38.7468); // Default to Addis Ababa
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  void _centerMapOnBothPoints() {
    // Calculate the bounds that include both points
    final bounds =
        LatLngBounds.fromPoints([_currentPosition, _selectedPosition]);

    // Fit the map to these bounds with some padding
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  void _moveToCurrentLocation() {
    _mapController.move(_currentPosition, 15);
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Map Base Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _selectedPosition,
            zoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                // Current location marker with custom design
                Marker(
                  point: _currentPosition,
                  width: 50,
                  height: 50,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Selected place marker with custom design
                Marker(
                  point: _selectedPosition,
                  width: 50,
                  height: 50,
                  builder: (context) => Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Back Button
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ),

        // Map Controls
        Positioned(
          right: 16,
          bottom: 220,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MapButton(
                      icon: Icons.my_location,
                      onPressed: _moveToCurrentLocation,
                      topRadius: true,
                    ),
                    const Divider(height: 1),
                    MapButton(
                      icon: Icons.add,
                      onPressed: () {
                        final currentZoom = _mapController.zoom;
                        _mapController.move(
                            _mapController.center, currentZoom + 1);
                      },
                    ),
                    const Divider(height: 1),
                    MapButton(
                      icon: Icons.remove,
                      onPressed: () {
                        final currentZoom = _mapController.zoom;
                        _mapController.move(
                            _mapController.center, currentZoom - 1);
                      },
                      bottomRadius: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Location Details Card
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Selected Location',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.selectedPlace.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coordinates: ${widget.selectedPlace.latitude.toStringAsFixed(6)}, ${widget.selectedPlace.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// Custom Map Button Widget
