import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:ride_app/location_picker.dart';
import 'package:ride_app/placeSearchWidget.dart';

class SlidingBoxDemo extends StatefulWidget {
  const SlidingBoxDemo({super.key});

  @override
  _SlidingBoxDemoState createState() => _SlidingBoxDemoState();
}

class _SlidingBoxDemoState extends State<SlidingBoxDemo> {
  late SlidingPanelController _controller;
  late TextEditingController _locationPickerInputController;
  late TextEditingController _locationDestinationInputController;
  late String currentFlow = 'Your Trip';
  Place? pickupPlace;
  Place? destinationPlace;
  bool isExpanded = false;
  bool isUp = false;

  @override
  void initState() {
    super.initState();
    _locationPickerInputController = TextEditingController();
    _locationDestinationInputController = TextEditingController();
    _controller = SlidingPanelController();
    _controller.addListener(() {
      setState(() {
        if (_controller.status == SlidingPanelStatus.anchored) {
          isExpanded = false;
          isUp = false;
        } else {
          // isExpanded = true;
          isUp = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _locationPickerInputController.dispose();
    _locationDestinationInputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (currentFlow == 'Start')
          SlidingPanel.scrollableContent(
            controller: _controller,
            config: SlidingPanelConfig(
              anchorPosition: 70,
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
              child: isExpanded
                  ? LocationSearchDoubleInput(
                      locationDestinationInputController:
                          _locationDestinationInputController,
                      locationPickerInputController:
                          _locationPickerInputController,
                      pickupPlace: pickupPlace,
                      destinationPlace: destinationPlace,
                      onPickupPlaceChanged: (place) {
                        setState(() {
                          pickupPlace = place; // Update the parent state
                        });
                        if (pickupPlace != null && destinationPlace != null) {
                          _controller.anchor();
                          currentFlow = "Your Trip";
                        }
                        ;
                      },
                      onDestinationPlaceChanged: (place) {
                        setState(() {
                          destinationPlace = place; // Update the parent state
                        });
                        if (pickupPlace != null && destinationPlace != null) {
                          _controller.anchor();
                          currentFlow = "Your Trip";
                        }
                      },
                    )
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isExpanded = true;
                            });
                            _controller.expand();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[350],
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                          ),
                          child: isUp
                              ? const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car),
                                        SizedBox(width: 20),
                                        Text(
                                          'Where to?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                  ],
                                )
                              : const Row(
                                  children: [
                                    SizedBox(width: 20),
                                    Text(
                                      'Where to?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        // const Spacer(),
                        LocationGrid(),
                      ],
                    ),
            ),
            leading: Container(
              width: 50,
              height: 8,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ElevatedButton(onPressed: () {}, child: Container()),
            ),
          )
        else if (currentFlow == 'Your Trip')
          buildBottomContainer(),
      ],
    );
  }

  Widget buildBottomContainer() {
    return Stack(
  children: [
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'YOUR TRIP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.location_on, color: Colors.red),
                        title: Text('General Wingate Street'),
                        subtitle: Text('Estimated time: 8:55 AM'),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('Dembel City Center'),
                        trailing: Text('Stops'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(Icons.directions_bus),
                            SizedBox(width: 8),
                            Text('Economy - Br170'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
);  }
}

class LocationGrid extends StatefulWidget {
  @override
  State<LocationGrid> createState() => _LocationGridState();
}

class _LocationGridState extends State<LocationGrid> {
  final List<String> locations = [
    "Bole International Airport",
    "Century Mall",
    "Dember City Center",
    "Addis Ababa Stadium",
    // "Addis Ababa Stadium",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        LocationBox(
          name: locations[0],
          isSmall: false,
        ),
        LocationBox(
          name: locations[1],
          isSmall: true,
        ),
      ]),
      Row(children: [
        LocationBox(
          name: locations[2],
          isSmall: true,
        ),
        LocationBox(
          name: locations[3],
          isSmall: false,
        ),
      ])
    ]);
  }
}

class LocationBox extends StatefulWidget {
  final String name;

  final bool isSmall;

  const LocationBox({Key? key, required this.name, required this.isSmall})
      : super(key: key);

  @override
  State<LocationBox> createState() => _LocationBoxState();
}

class _LocationBoxState extends State<LocationBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 120,
        maxWidth: widget.isSmall
            ? 180
            : 200, // Increased maxWidth to allow for longer names
        maxHeight: 120,
      ),
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.directions_car, size: 20),
              Icon(Icons.park, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
