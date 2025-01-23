import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:ride_app/compont/Map/map.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';

class CurrentLocationPlace extends Place {
  CurrentLocationPlace({
    required super.displayName,
    required super.latitude,
    required super.longitude,
  });

  @override
  String toString() => 'Current Location: $displayName';
}

class LocationSearchDoubleInput extends StatefulWidget {
  final TextEditingController locationDestinationInputController;
  final TextEditingController locationPickerInputController;
  final Function(Place?) onPickupPlaceChanged;
  final Function(Place?) onDestinationPlaceChanged;
  final Place? pickupPlace;
  final Place? destinationPlace;

  const LocationSearchDoubleInput({
    super.key,
    required this.locationDestinationInputController,
    required this.locationPickerInputController,
    required this.onPickupPlaceChanged,
    required this.onDestinationPlaceChanged,
    required this.pickupPlace,
    required this.destinationPlace,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LocationSearchDoubleInputState createState() =>
      _LocationSearchDoubleInputState();
}

class _LocationSearchDoubleInputState extends State<LocationSearchDoubleInput> {
  late final FocusNode _pickerLocationFocusNode;
  late final FocusNode _destinationLocationFocusNode;
  final Location _location = Location();

  List<Place> _places = [];
  bool _isSearching = false;
  bool _isPickupSearchActive = false;
  CurrentLocationPlace? _currentLocation;

  @override
  void initState() {
    super.initState();
    _pickerLocationFocusNode = FocusNode();
    _destinationLocationFocusNode = FocusNode();
    _initializeControllers();
    _setupFocusListeners();
    _initializeCurrentLocation();
  }

  void _initializeControllers() {
    if (widget.destinationPlace?.displayName != null) {
      widget.locationDestinationInputController.text =
          widget.destinationPlace!.displayName;
    }
    if (widget.pickupPlace?.displayName != null) {
      widget.locationPickerInputController.text =
          widget.pickupPlace!.displayName;
    }
  }

  void _setupFocusListeners() {
    _pickerLocationFocusNode.addListener(() {
      if (_pickerLocationFocusNode.hasFocus) {
        setState(() => _isPickupSearchActive = true);
      }
    });

    _destinationLocationFocusNode.addListener(() {
      if (_destinationLocationFocusNode.hasFocus) {
        setState(() => _isPickupSearchActive = false);
      }
    });
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('Location data is null');
      }

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String address = [
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
        ].where((component) => component.isNotEmpty).join(", ");

        setState(() {
          _currentLocation = CurrentLocationPlace(
            displayName: address,
            latitude: locationData.latitude!,
            longitude: locationData.longitude!,
          );
        });
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _places = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await searchPlaces(value);
      if (mounted) {
        setState(() {
          _places = results ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _places = [];
          _isSearching = false;
        });
      }
    }
  }

  void _handlePlaceSelection(Place place) {
    if (_isPickupSearchActive) {
      widget.locationPickerInputController.text = place.displayName;
      widget.onPickupPlaceChanged(place);
    } else {
      widget.locationDestinationInputController.text = place.displayName;
      widget.onDestinationPlaceChanged(place);
    }

    setState(() => _places = []);
    FocusScope.of(context).unfocus();
  }

  Future<void> _showMapPicker(BuildContext context) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapCustome(
            onLocationPicked: (address, coordinates) {
              // Create a fallback address if the geocoding fails
              String fallbackAddress =
                  'Location (${coordinates.latitude.toStringAsFixed(4)}°, '
                  '${coordinates.longitude.toStringAsFixed(4)}°)';

              Navigator.pop(
                context,
                Place(
                  displayName: address.isEmpty ? fallbackAddress : address,
                  latitude: coordinates.latitude,
                  longitude: coordinates.longitude,
                ),
              );
            },
          ),
        ),
      );
      if (result != null && result is Place) {
        _handlePlaceSelection(result);
      }
    } catch (Exception) {}
  }

  Widget _buildSearchResults() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _places.isEmpty && _currentLocation == null ? 0 : 300,
      child: ListView.builder(
        itemCount: (_currentLocation != null ? 1 : 0) + _places.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == 0 && _currentLocation != null) {
            return ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text('Current Location'),
              subtitle: Text(_currentLocation!.displayName),
              onTap: () => _handlePlaceSelection(_currentLocation!),
            );
          }

          final actualIndex = _currentLocation != null ? index - 1 : index;
          final place = _places[actualIndex];

          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(place.displayName),
            subtitle: Text(
              '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
            ),
            onTap: () => _handlePlaceSelection(place),
          );
        },
      ),
    );
  }

  Widget _buildLocationInput({
    required bool isPickup,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    final bool isActive =
        isPickup ? _isPickupSearchActive : !_isPickupSearchActive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor, size: 32.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              setState(() => _places = []);
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),
          if (isActive) _buildMapButton(),
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ElevatedButton(
        onPressed: () => _showMapPicker(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        ),
        child: Text(
          'Map',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 87, 104, 101),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 211, 208, 208),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              _buildLocationInput(
                isPickup: true,
                controller: widget.locationPickerInputController,
                focusNode: _pickerLocationFocusNode,
                label: 'Pick up',
                hint: 'General Wingate Street',
                icon: Icons.location_on,
                iconColor: Theme.of(context).primaryColor,
                iconBackgroundColor: const Color(0xFFFFCC00),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: const Divider(
                  color: Colors.grey,
                  height: 5,
                  thickness: 3,
                ),
              ),
              _buildLocationInput(
                isPickup: false,
                controller: widget.locationDestinationInputController,
                focusNode: _destinationLocationFocusNode,
                label: 'Destination',
                hint: 'Where to?',
                icon: Icons.flag,
                iconColor: const Color(0xFFFFCC00),
                iconBackgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildSearchResults(),
      ],
    );
  }

  @override
  void dispose() {
    _pickerLocationFocusNode.dispose();
    _destinationLocationFocusNode.dispose();
    super.dispose();
  }
}
