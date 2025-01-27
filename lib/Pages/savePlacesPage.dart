import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:provider/provider.dart';
import 'package:ride_app/Auth/save_place_api.dart';
import 'package:ride_app/compont/Map/showSelectedMap.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/compont/showModalUtilities.dart';
import 'package:ride_app/passenger.dart';

class SavePlacesPage extends StatefulWidget {
  const SavePlacesPage({super.key});

  @override
  State<SavePlacesPage> createState() => _SavePlacesPageState();
}

class _SavePlacesPageState extends State<SavePlacesPage> {
  bool _isEditing = false;
  late TextEditingController _locationPickerInputController;
  List<SavePlace> _savedPlaces = [];
  late String passengerId;

  @override
  void initState() {
    super.initState();
    _locationPickerInputController = TextEditingController();
    passengerId = context.read<PassengerProvider>().passenger!.id;
    Future.microtask(() => _fetchSavedPlaces());
  }

  @override
  void dispose() {
    _locationPickerInputController.dispose();
    super.dispose();
  }

  // Fetch saved places from the API
  Future<void> _fetchSavedPlaces() async {
    try {
      final places = await SavePlaceApi.getSavedPlaces(passengerId);
      setState(() {
        _savedPlaces = places;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch saved places: $e')),
        );
      }
    }
  }

  // Save a new place
  Future<void> _savePlace(Place place) async {
    try {
      final savedPlace = await SavePlaceApi.savePlace(
        passengerId: passengerId,
        place: SavePlace(
            placename: place.displayName,
            latitude: place.latitude,
            longitude: place.longitude),
      );
      setState(() {
        _savedPlaces.add(savedPlace);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save place: $e')),
        );
      }
    }
  }

  // Update a saved place
  Future<void> _updatePlace(SavePlace place) async {
    try {
      final updatedPlace = await SavePlaceApi.updatePlace(place: place);
      setState(() {
        final index = _savedPlaces.indexWhere((p) => p.id == updatedPlace.id);
        if (index != -1) {
          _savedPlaces[index] = updatedPlace;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update place: $e')),
        );
      }
    }
  }

  // Delete a saved place
  Future<void> _deletePlace(String saveplaceId) async {
    try {
      await SavePlaceApi.deletePlace(saveplaceId);
      setState(() {
        _savedPlaces.removeWhere((place) => place.id == saveplaceId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete place: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(
                _isEditing ? 'Done' : 'Edit',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved places',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 31, 31),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "The driver will take you right where you're going",
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 31, 31),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _savedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _savedPlaces[index];
                      return _buildSavedPlaceTile(
                        place: place,
                        icon: Icons.place,
                        label: place.placename,
                        isSaved: true,
                        onEdit: () async {
                          final updatedPlace =
                              await _showEditPlaceDialog(place);
                          if (updatedPlace != null) {
                            await _updatePlace(updatedPlace);
                          }
                        },
                        onDelete: () => _deletePlace(place.id.toString()),
                      );
                    },
                  ),
                ),
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => showLocationPicker(
                          context,
                          TextEditingController(),
                          null,
                          (Place? newPlace) {
                            _savePlace(newPlace!);
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size(double.infinity, 100),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Add place',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceTile({
    required SavePlace place,
    required IconData icon,
    required String label,
    required bool isSaved,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: () {
        // Handle the tap event
        showSelectedPlace(Place(
            displayName: place.placename,
            latitude: place.latitude,
            longitude: place.longitude));
        print('Tapped on $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[500]),
                const SizedBox(width: 20),
                Text(label),
              ],
            ),
            if (_isEditing)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            if (!_isEditing)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  // Show a dialog to edit a saved place
  Future<SavePlace?> _showEditPlaceDialog(SavePlace place) async {
    final placenameController = TextEditingController(text: place.placename);
    return showDialog<SavePlace>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Place'),
          content: TextField(
            controller: placenameController,
            decoration: const InputDecoration(labelText: 'Place Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedPlace = SavePlace(
                  placename: placenameController.text,
                  latitude: place.latitude,
                  longitude: place.longitude,
                  id: place.id,
                );
                Navigator.pop(context, updatedPlace);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showSelectedPlace(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ShowSelectedMap(selectedPlace: place)),
    );
  }
}
