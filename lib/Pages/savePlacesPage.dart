import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:ride_app/compont/Map/location_search.dart';

class SavePlaces extends StatefulWidget {
  const SavePlaces({super.key});

  @override
  State<SavePlaces> createState() => _SavePlacesState();
}

class _SavePlacesState extends State<SavePlaces> {
  bool _isEditing = false;
  bool _isHomeSaved = false;
  bool _isWorkingSaved = true;
  late SlidingPanelController _controller;
  late TextEditingController _locationPickerInputController;

  @override
  void initState() {
    super.initState();
    _locationPickerInputController = TextEditingController();
    _controller = SlidingPanelController();

    // Only update UI when necessary
    // _controller.addListener(() {
    //   if (_controller.value.position <= 4) {
    //     // Avoid recursive updates
    //     // _controller.anchor();
    //   }
    // });
  }

  @override
  void dispose() {
    _locationPickerInputController.dispose();
    // _controller.dispose();
    super.dispose();
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
                  child: Column(
                    children: [
                      _buildSavedPlaceTile(
                        icon: Icons.home,
                        label: 'Add home',
                        isSaved: _isHomeSaved,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(43, 0, 20, 0),
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      _buildSavedPlaceTile(
                        icon: Icons.work_outline_rounded,
                        label: _isWorkingSaved ? 'Work' : 'Add work',
                        isSaved: _isWorkingSaved,
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => _controller.expand(),
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size(double.infinity, 100),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                        child: const Text('Add place'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SlidingPanel.scrollableContent(
            controller: _controller,
            config: SlidingPanelConfig(
              anchorPosition: 0,
              expandPosition: MediaQuery.of(context).size.height - 100,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            panelContentBuilder: (controller, physics) => Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: LocationSearch(
                locationPickerInputController: _locationPickerInputController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceTile({
    required IconData icon,
    required String label,
    required bool isSaved,
  }) {
    return InkWell(
      onTap: () {
        // Handle the tap event
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
            Icon(
              isSaved
                  ? _isEditing
                      ? Icons.edit
                      : Icons.arrow_forward_ios
                  : Icons.add,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}

class SavedPlace {
  String name;
  String address;

  SavedPlace({required this.name, required this.address});
}
