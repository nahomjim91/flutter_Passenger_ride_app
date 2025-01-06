import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapCustome extends StatefulWidget {
  final Function(String address, LatLng coordinates) onLocationPicked;

  const MapCustome({
    Key? key,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  _MapCustomeState createState() => _MapCustomeState();
}

class _MapCustomeState extends State<MapCustome> {
  final Location _location = Location();
  late LatLng _currentPosition;
  late LatLng _selectedPosition;
  bool _isLoading = true;
  final MapController _mapController = MapController();
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('Location data is null');
      }

      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _selectedPosition = _currentPosition;
        _isLoading = false;
      });
      await _getAddressFromLatLng(_selectedPosition);
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() {
        _isLoading = false;
        _selectedAddress = "Error getting location. Please try again.";
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;

    setState(() {
      _selectedAddress = "Fetching address...";
    });

    try {
      debugPrint(
          "Fetching address for: ${position.latitude}, ${position.longitude}");

      if (!_isValidLatLng(position.latitude, position.longitude)) {
        throw Exception('Invalid coordinates');
      }

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        debugPrint("Placemark found: $place");

        // Create a list of address components, filtering out null or empty values
        List<String> addressComponents = [
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.administrativeArea ?? '',
          place.country ?? '',
        ].where((component) => component.isNotEmpty).toList();

        // Join the non-empty components with commas
        String formattedAddress = addressComponents.isEmpty
            ? "No detailed address available"
            : addressComponents.join(", ");

        setState(() {
          _selectedAddress = formattedAddress;
        });

        widget.onLocationPicked(_selectedAddress, position);
      } else {
        debugPrint("No placemarks found for the given coordinates.");
        setState(() {
          _selectedAddress = "No address available for these coordinates.";
        });
        widget.onLocationPicked(_selectedAddress, position);
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching placemark: $e");
      debugPrint("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _selectedAddress = "Location found, but address details unavailable.";
        });
        widget.onLocationPicked(_selectedAddress, position);
      }
    }
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              _getAddressFromLatLng(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                if (_selectedPosition == _currentPosition)
                  Marker(
                    point: _currentPosition,
                    width: 80,
                    height: 80,
                    builder: (context) => const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.overline),
                        ),
                        Icon(
                          Icons.location_on_sharp,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ],
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
      ],
    );
  }
}
