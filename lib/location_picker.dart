import 'package:flutter/material.dart';
import 'package:ride_app/placeSearchWidget.dart';

class LocationSearchDoubleInput extends StatefulWidget {
  final TextEditingController locationDestinationInputController;
  final TextEditingController locationPickerInputController;
  final Function(Place?) onPickupPlaceChanged; // Callback for pickup place
  final Function(Place?)
      onDestinationPlaceChanged; // Callback for destination place

  Place? pickupPlace;
  Place? destinationPlace;
  LocationSearchDoubleInput(
      {Key? key,
      required this.locationDestinationInputController,
      required this.locationPickerInputController,
      required this.onPickupPlaceChanged,
      required this.onDestinationPlaceChanged,
      required this.pickupPlace,
      required this.destinationPlace})
      : super(key: key);
  @override
  _LocationSearchDoubleInputState createState() =>
      _LocationSearchDoubleInputState();
}

class _LocationSearchDoubleInputState extends State<LocationSearchDoubleInput> {
  late bool pickerLocationFocused = false;
  late bool destinationLocationFocused = true;
  FocusNode pickerLocationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();
  List<Place> _places = [];

  @override
  void initState() {
    super.initState();

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
    pickerLocationFocusNode.addListener(() {
      setState(() {
        pickerLocationFocused = pickerLocationFocusNode.hasFocus;
        destinationLocationFocused = !pickerLocationFocused;
      });
    });
    destinationLocationFocusNode.addListener(() {
      setState(() {
        destinationLocationFocused = destinationLocationFocusNode.hasFocus;
        pickerLocationFocused = !destinationLocationFocused;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 87, 104, 101), // Dark green background
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
                Row(
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFFFCC00), // Yellow pickup icon background
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                        size: 32.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pick up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextField(
                            focusNode: pickerLocationFocusNode,
                            controller: widget.locationPickerInputController,
                            decoration: InputDecoration(
                              hintText: 'General Wingate Street',
                              suffixIcon: widget.locationPickerInputController
                                      .text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        widget.locationPickerInputController
                                            .clear();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) async {
                              if (value.isEmpty) {
                                setState(() {
                                  _places = [];
                                });
                              } else {
                                _places = (await searchPlaces(value)) ?? [];
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (pickerLocationFocused)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFFFFCC00), // Yellow button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 17),
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
                  ],
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
                Row(
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color:
                            Color(0xFFFFCC00), // Yellow pickup icon background
                        size: 32.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destination',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextField(
                            controller:
                                widget.locationDestinationInputController,
                            decoration: InputDecoration(
                              hintText: 'Where to?',
                              suffixIcon: widget
                                      .locationDestinationInputController
                                      .text
                                      .isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        widget
                                            .locationDestinationInputController
                                            .clear();
                                      },
                                    )
                                  : null,
                            ),
                            focusNode: destinationLocationFocusNode,
                            onChanged: (value) async {
                              if (value.isEmpty) {
                                setState(() {
                                  _places = [];
                                });
                              } else {
                                _places = (await searchPlaces(value)) ?? [];
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (destinationLocationFocused)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFFFFCC00), // Yellow button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 17),
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
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 400, // Set a fixed height for the list
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(place.displayName),
                    subtitle: Text(
                        '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}'),
                    onTap: () {
                      setState(() {
                        if (!destinationLocationFocused) {
                          debugPrint('Destination location focused');
                          widget.destinationPlace = place;
                          widget.locationDestinationInputController.text =
                              place.displayName;
                          widget.onDestinationPlaceChanged(
                              place); // Notify the parent

                          FocusScope.of(context).unfocus();
                          destinationLocationFocused = false;
                          _places = [];
                        } else if (!pickerLocationFocused) {
                          debugPrint('Picker location focused');
                          widget.pickupPlace = place;
                          widget.locationPickerInputController.text =
                              place.displayName;
                          widget
                              .onPickupPlaceChanged(place); // Notify the parent

                          FocusScope.of(context).unfocus();
                          pickerLocationFocused = false;
                        }
                        debugPrint(
                            'Selected place: ${place.displayName}\nCoordinates: ${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}');
                      });
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
