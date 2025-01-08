import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:ride_app/compont/showModalUtilities.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/tripDetails.dart';

class RequestingRide extends StatefulWidget {
  RequestingRide({super.key, required this.rquestRide});

  RequestRide rquestRide;

  @override
  State<RequestingRide> createState() => _RequestingRideState();
}

class _RequestingRideState extends State<RequestingRide> {
  late SlidingPanelController _controller;
  late TextEditingController _locationPickerInputController;
  late TextEditingController _locationDestinationInputController;
  bool _shareLocation = false;
  int _counter = 0;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _locationPickerInputController = TextEditingController();
    _locationDestinationInputController = TextEditingController();
    _controller = SlidingPanelController();
  }

  @override
  void dispose() {
    _controller.removeListener;
    _locationPickerInputController.dispose();
    _locationDestinationInputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlidingPanel.scrollableContent(
          controller: _controller,
          config: SlidingPanelConfig(
            anchorPosition: 410,
            expandPosition: MediaQuery.of(context).size.height - 100,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          panelContentBuilder: (controller, physics) => Stack(children: [
            Container(
                alignment: Alignment.topCenter,
                // padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    // width: double.infinity,
                    height: MediaQuery.of(context).size.height - 50,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(31, 199, 19, 19)),
                    child: Column(
                      children: [
                        pendingRequest(),
                        const SizedBox(height: 5),
                        addressPoints(),
                        const SizedBox(height: 5),
                        priceEstimateCard(
                          price: '\$25.00',
                          shareLocation: _shareLocation,
                          onLocationShareChanged: (value) {
                            // Handle location sharing change
                            setState(() {
                              _shareLocation = value;
                            });
                          },
                          onCarrierDetailsTap: () {
                            // Handle carrier details tap
                          },
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: selectorButton(
                              subtitle: "Cancel ride",
                              title: null,
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              onTap: () {}),
                        )
                      ],
                    ),
                  ),
                )),
          ]),
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15, 0, 0, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(
                          0, 0), // Shadow position, 0,0 means all sides
                    ),
                  ],
                ),
                child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        'home', // Replace with your route name
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                      );
                    }),
              ),
              Center(
                child: Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget pendingRequest() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Driver responding...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatTime(_counter), //'00:06',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This usually takes a few seconds',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Driver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: const DecorationImage(
                      image: AssetImage('assets/images/driver(2).png'),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(15),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  'New request',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addressPoints() {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            selectorButton(
              title: "Pickup",
              subtitle: widget.rquestRide.pickupPlace!.displayName,
              icon: Container(
                width: 36,
                height: 38,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Icon(Icons.directions_run, color: Colors.white)),
              ),
              onTap: () {
                showLocationPicker(
                  context,
                  _locationPickerInputController,
                  widget.rquestRide.pickupPlace,
                  (Place? newPlace) {
                    setState(() {
                      widget.rquestRide.pickupPlace = newPlace!;
                    });
                  },
                );
              },
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: const Divider(height: 32)),
            selectorButton(
              title: null,
              subtitle: 'Add Stop',
              icon: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black, // Yellow pickup icon background
                  size: 32.0,
                ),
              ),
              onTap: () {
                showLocationPicker(
                  context,
                  _locationDestinationInputController,
                  widget.rquestRide.destinationPlace,
                  (Place? newPlace) {
                    setState(() {
                      widget.rquestRide.destinationPlace = newPlace!;
                    });
                  },
                );
              },
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: const Divider(height: 32)),
            selectorButton(
              title: "Destination",
              subtitle: widget.rquestRide.destinationPlace.displayName,
              icon: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.black, // Yellow pickup icon background
                  size: 32.0,
                ),
              ),
              onTap: () {
                showLocationPicker(
                  context,
                  _locationDestinationInputController,
                  widget.rquestRide.destinationPlace,
                  (Place? newPlace) {
                    setState(() {
                      widget.rquestRide.destinationPlace = newPlace!;
                    });
                  },
                );
              },
            ),
          ],
        ));
  }

  Widget priceEstimateCard({
    required String price,
    required bool shareLocation,
    required ValueChanged<bool> onLocationShareChanged,
    required VoidCallback onCarrierDetailsTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                    // border: Border.all(color: Colors.),
                    ),
                child: Image.asset(
                  'assets/images/telebirr_icon.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Money: $price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'This is an estimate. Exact price displayed after ride',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.black,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Share my location with driver',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: shareLocation,
                activeColor: Colors.blue,
                onChanged: onLocationShareChanged,
              ),
            ],
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: const Divider(height: 32)),
          selectorButton(
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.black,
              ),
              title: null,
              subtitle: 'Carrier Details',
              onTap: onCarrierDetailsTap),
        ],
      ),
    );
  }

  Widget selectorButton({
    required String? title,
    required String subtitle,
    required Widget icon,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            Colors.grey[600]), // Optional styling for the title
                  ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color:
                        subtitle == 'Cancel ride' ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
