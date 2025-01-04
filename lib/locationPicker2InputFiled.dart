import 'package:flutter/material.dart';
import 'package:ride_app/placeSearchWidget.dart';

class LocationSearchDoubleInput extends StatefulWidget {
  final TextEditingController locationDestinationInputController;
  final TextEditingController locationPickerInputController;
  final Function(Place?) onPickupPlaceChanged;
  final Function(Place?) onDestinationPlaceChanged;
  Place? pickupPlace;
  Place? destinationPlace;

  LocationSearchDoubleInput({
    Key? key,
    required this.locationDestinationInputController,
    required this.locationPickerInputController,
    required this.onPickupPlaceChanged,
    required this.onDestinationPlaceChanged,
    required this.pickupPlace,
    required this.destinationPlace,
  }) : super(key: key);

  @override
  _LocationSearchDoubleInputState createState() =>
      _LocationSearchDoubleInputState();
}

class _LocationSearchDoubleInputState extends State<LocationSearchDoubleInput> {
  bool pickerLocationFocused = false;
  bool destinationLocationFocused = true;
  final FocusNode pickerLocationFocusNode = FocusNode();
  final FocusNode destinationLocationFocusNode = FocusNode();
  List<Place> _places = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupFocusListeners();
  }

  void _initializeControllers() {
    widget.locationDestinationInputController.text =
        widget.destinationPlace?.displayName ?? '';
    widget.locationPickerInputController.text =
        widget.pickupPlace?.displayName ?? '';

    widget.locationDestinationInputController.addListener(() {
      setState(() {});
    });

    widget.locationPickerInputController.addListener(() {
      setState(() {});
    });
  }

  void _setupFocusListeners() {
    pickerLocationFocusNode.addListener(_updatePickerFocus);
    destinationLocationFocusNode.addListener(_updateDestinationFocus);
  }

  void _updatePickerFocus() {
    setState(() {
      pickerLocationFocused = pickerLocationFocusNode.hasFocus;
      destinationLocationFocused = !pickerLocationFocused;
    });
  }

  void _updateDestinationFocus() {
    setState(() {
      destinationLocationFocused = destinationLocationFocusNode.hasFocus;
      pickerLocationFocused = !destinationLocationFocused;
    });
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

  Widget _buildSearchResults() {
    return SizedBox(
      height: 300, // Fixed height for search results
      child: ListView.builder(
        itemCount: _places.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final place = _places[index];
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

  void _handlePlaceSelection(Place place) {
    setState(() {
      if (destinationLocationFocused) {
        widget.destinationPlace = place;
        widget.locationDestinationInputController.text = place.displayName;
        widget.onDestinationPlaceChanged(place);
      } else {
        widget.pickupPlace = place;
        widget.locationPickerInputController.text = place.displayName;
        widget.onPickupPlaceChanged(place);
      }

      FocusScope.of(context).unfocus();
      _places = [];

      debugPrint('Selected place: ${place.displayName}\n'
          'Coordinates: ${place.latitude.toStringAsFixed(4)}, '
          '${place.longitude.toStringAsFixed(4)}');
    });
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
    return Row(
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
        if ((isPickup && pickerLocationFocused) ||
            (!isPickup && destinationLocationFocused))
          _buildMapButton(),
      ],
    );
  }

  Widget _buildMapButton() {
    return ElevatedButton(
      onPressed: () {},
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 87, 104, 101),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 211, 208, 208),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            children: [
              _buildLocationInput(
                isPickup: true,
                controller: widget.locationPickerInputController,
                focusNode: pickerLocationFocusNode,
                label: 'Pick up',
                hint: 'General Wingate Street',
                icon: Icons.location_on,
                iconColor: Theme.of(context).primaryColor,
                iconBackgroundColor: const Color(0xFFFFCC00),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 5, 0, 5),
                child: const Divider(
                  color: Colors.grey,
                  height: 5,
                  thickness: 3,
                  indent: 20,
                ),
              ),
              _buildLocationInput(
                isPickup: false,
                controller: widget.locationDestinationInputController,
                focusNode: destinationLocationFocusNode,
                label: 'Destination',
                hint: 'Where to?',
                icon: Icons.flag,
                iconColor: const Color(0xFFFFCC00),
                iconBackgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _isSearching
            ? const Center(child: CircularProgressIndicator())
            : _buildSearchResults(),
      ],
    );
  }

  @override
  void dispose() {
    pickerLocationFocusNode.dispose();
    destinationLocationFocusNode.dispose();
    super.dispose();
  }
}
