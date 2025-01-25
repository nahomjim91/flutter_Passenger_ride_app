import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceSearchWidget extends StatefulWidget {
  final TextEditingController searchController;
  const PlaceSearchWidget({Key? key, required this.searchController})
      : super(key: key);

  @override
  _PlaceSearchWidgetState createState() => _PlaceSearchWidgetState();
}

class _PlaceSearchWidgetState extends State<PlaceSearchWidget> {
  final TextEditingController searchController = TextEditingController();
  List<Place> _places = [];
  bool _isLoading = false;

  @override
  void dispose() {
    widget.searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 2) {
      setState(() {
        _places = [];
      });
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _places = data.map((place) => Place.fromJson(place)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _places = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _places = [];
        _isLoading = false;
      });
      debugPrint('Error searching places: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              labelText: 'Search location',
              hintText: 'Enter a location',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        setState(() {
                          _places = [];
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  _places = [];
                });
              } else {
                _searchPlaces(value);
              }
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(place.displayName),
                      subtitle: Text(
                          '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}'),
                      onTap: () {
                        // Handle place selection
                        debugPrint('Selected place: ${place.displayName}');
                        // You can add a callback here to return the selected place
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Future<List<Place>?> searchPlaces(String query) async {
  if (query.length < 2) {
    return null;
  }
  try {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10',
      ),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((place) => Place.fromJson(place)).toList();
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('Error searching places: $e');
    return null;
  }
}

class Place {
  final String displayName;
  final double latitude;
  final double longitude;

  Place({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      displayName: json['display_name'] ?? '',
      latitude: double.parse(json['lat'] ?? '0'),
      longitude: double.parse(json['lon'] ?? '0'),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'display_name': displayName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
