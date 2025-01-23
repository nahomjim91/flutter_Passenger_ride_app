import 'package:flutter/material.dart';
import 'package:ride_app/compont/Map/map.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';

class LocationPicker extends StatefulWidget {
  final TextEditingController inputController;
  final Function(Place?) saveSearchPlace;
  final Place? searchPlace;

  const LocationPicker({
    Key? key,
    required this.inputController,
    required this.searchPlace,
    required this.saveSearchPlace,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final FocusNode _focusNode = FocusNode();
  List<Place> _places = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.inputController.text = widget.searchPlace?.displayName ?? '';
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePlaceSelection(Place place) {
    widget.inputController.text = place.displayName;
    widget.saveSearchPlace(place);

    setState(() => _places = []);
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
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

  void _onSearchChanged(String value) async {
    setState(() => _isSearching = true);

    if (value.isEmpty) {
      setState(() {
        _places = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final results = await searchPlaces(value) ?? [];
      setState(() {
        _places = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _places = [];
        _isSearching = false;
      });
    }
  }

  void _onPlaceSelected(Place place) {
    setState(() {
      widget.inputController.text = place.displayName;
      widget.saveSearchPlace(place);
    });

    _focusNode.unfocus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildSearchBar(),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lighter grey background
        borderRadius: BorderRadius.circular(30), // More rounded corners
        boxShadow: [
          // Add subtle shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.inputController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Location\nDestination address', // Multi-line hint
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  height: 1.2,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: widget.inputController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.inputController.clear();
                          setState(() => _places = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          _buildMapButton()
        ],
      ),
    );
  }

  Widget _buildMapButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => _showMapPicker(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100], // Light grey button
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          'Map',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _places.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final place = _places[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(place.displayName),
          subtitle: Text(
              '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}'),
          onTap: () => _onPlaceSelected(place),
        );
      },
    );
  }
}
