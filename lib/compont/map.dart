import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapCustome extends StatefulWidget {
  final Function(String address, LatLng coordinates) onLocationPicked;
  final bool isDisplayOnly;

  const MapCustome({
    Key? key,
    required this.onLocationPicked,
    this.isDisplayOnly = true,
  }) : super(key: key);

  @override
  _MapCustomeState createState() => _MapCustomeState();
}

class _MapCustomeState extends State<MapCustome> {
  final Location _location = Location();
  late LatLng _currentPosition;
  late LatLng _selectedPosition;
  bool _isLoading = true;
  bool _isAddressLoading = false;
  final MapController _mapController = MapController();
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
          _selectedAddress = "Location permission denied";
          // Set a default location (e.g., city center) if permission denied
          _currentPosition = LatLng(9.0222, 38.7468); // Default to Addis Ababa
          _selectedPosition = _currentPosition;
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
        _selectedPosition = _currentPosition;
        _isLoading = false;
      });

      // Add a small delay to ensure the map is properly initialized
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      _mapController.move(_currentPosition, 15);
      await _getAddressFromLatLng(_selectedPosition, false);
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _selectedAddress = "Error getting location. Please try again.";
        // Set a default location here as well
        _currentPosition = LatLng(9.0222, 38.7468); // Default to Addis Ababa
        _selectedPosition = _currentPosition;
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

  Future<void> _getAddressFromLatLng(
      LatLng position, bool isLocationPicked) async {
    if (!mounted) return;

    setState(() {
      _isAddressLoading = true;
      _selectedAddress = "Fetching address...";
    });

    try {
      if (!_isValidLatLng(position.latitude, position.longitude)) {
        throw Exception('Invalid coordinates');
      }

      // Create a fallback address using coordinates
      String fallbackAddress =
          'Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

      try {
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (!mounted) return;

        if (placemarks.isNotEmpty) {
          geo.Placemark place = placemarks[0];

          // Create a map of address components with custom fallbacks
          Map<String, String> addressParts = {
            'street': place.street ??
                'Street ${position.latitude.toStringAsFixed(4)}',
            'subLocality': place.subLocality ?? '',
            'locality': place.locality ??
                'Area ${position.longitude.toStringAsFixed(4)}',
            'administrativeArea': place.administrativeArea ?? '',
            'country': place.country ?? '',
          };

          // Filter out empty components and join them
          List<String> addressComponents = addressParts.entries
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => entry.value)
              .toList();

          String formattedAddress = addressComponents.isEmpty
              ? fallbackAddress
              : addressComponents.join(", ");

          setState(() {
            _selectedAddress = formattedAddress;
            _isAddressLoading = false;
          });
        } else {
          // Use fallback address if no placemark found
          setState(() {
            _selectedAddress = fallbackAddress;
            _isAddressLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching placemark details: $e");
        // Use fallback address on error
        setState(() {
          _selectedAddress = fallbackAddress;
          _isAddressLoading = false;
        });
      }

      // Only call onLocationPicked if this was triggered by user selection
      if (isLocationPicked) {
        widget.onLocationPicked(_selectedAddress, position);
      }
    } catch (e) {
      debugPrint("Critical error in _getAddressFromLatLng: $e");
      if (mounted) {
        setState(() {
          _selectedAddress = "Unable to determine location. Please try again.";
          _isAddressLoading = false;
        });
      }
    }
  }

// Add this helper method to format coordinates into a readable string
  String formatCoordinates(LatLng position) {
    return '${position.latitude.toStringAsFixed(4)}°${position.latitude >= 0 ? 'N' : 'S'}, '
        '${position.longitude.toStringAsFixed(4)}°${position.longitude >= 0 ? 'E' : 'W'}';
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  void _moveToCurrentLocation() {
    _mapController.move(_currentPosition, 15);
    setState(() {
      _selectedPosition = _currentPosition;
    });
    _getAddressFromLatLng(_currentPosition, false);
  }

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
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentPosition,
            zoom: 15,
            onTap: (tapPosition, point) {
              setState(() {
                _selectedPosition = point;
              });
              _getAddressFromLatLng(point, false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition,
                  width: 80,
                  height: 80,
                  builder: (context) => const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                if (_selectedPosition != _currentPosition)
                  Marker(
                    point: _selectedPosition,
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'currentLocation',
                onPressed: _moveToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoomIn',
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_mapController.center, currentZoom + 1);
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoomOut',
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_mapController.center, currentZoom - 1);
                },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        if (widget.isDisplayOnly)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected Location:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_isAddressLoading)
                    const LinearProgressIndicator()
                  else
                    Text(
                      _selectedAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onLocationPicked(
                            _selectedAddress, _selectedPosition);
                        // Navigator.of(context).pop();
                      },
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
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
