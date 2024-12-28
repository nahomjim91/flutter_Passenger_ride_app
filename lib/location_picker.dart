import 'package:flutter/material.dart';

class Destination {
  final String name;
  final String location;

  Destination(this.name, this.location);
}

final List<Destination> destinations = [
  Destination('Your Location', 'Pick at your GPS location'),
  Destination('Addis Ababa Stadium', 'Addis Ababa'),
  Destination('Dember City Center', 'Bole, Addis Ababa'),
  Destination('Century Mall', 'Bole, Addis Ababa'),
  Destination('Bole International Airport', 'Bole, Addis Ababa'),
];

class LocationSearch extends StatefulWidget {
  final TextEditingController locationDestinationInputController;
  final TextEditingController locationPickerInputController;
  const LocationSearch(
      {Key? key,
      required this.locationDestinationInputController,
      required this.locationPickerInputController})
      : super(key: key);
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  late bool pickerLocationFocused = false;
  late bool destinationLocationFocused = true;
  FocusNode pickerLocationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(destinations[index].name),
                  subtitle: Text(destinations[index].location),
                  onTap: () {
                    // Handle destination selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
