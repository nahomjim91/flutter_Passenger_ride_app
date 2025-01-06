import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ride_app/Pages/requestingRide.dart';
import 'package:ride_app/compont/buttons.dart';
import 'package:ride_app/compont/car.dart';
import 'package:ride_app/compont/paymentMethod.dart';
import 'package:ride_app/compont/showModalUtilities.dart';
import 'package:ride_app/locationPicker.dart';
import 'package:ride_app/placeSearchWidget.dart';

class TripDetails extends StatefulWidget {
  Place? destinationPlace;
  Place? pickupPlace;
  TripDetails(
      {super.key, required this.destinationPlace, required this.pickupPlace});

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  late SlidingPanelController _controller;
  late TextEditingController _locationPickerInputController;
  late TextEditingController _locationDestinationInputController;
  late Widget opensearchField;
  bool isExpanded = false;
  bool isUp = false;

  Place pointA = Place(
    displayName: 'Point A',
    latitude: 9.00427798077372,
    longitude: 38.7679495460327,
  );

  Place pointB = Place(
    displayName: 'Point B',
    latitude: 9.0079232,
    longitude: 38.7678208,
  );

  @override
  void initState() {
    super.initState();
    _locationPickerInputController = TextEditingController();
    _locationDestinationInputController = TextEditingController();
    _controller = SlidingPanelController();
    _controller.addListener(() {
      setState(() {
        if (_controller.value.position >=
            _controller.value.anchorPosition + 20) {
          isExpanded = true;
          // isUp = false;
        } else {
          isExpanded = false;
          // isUp = true;
        }
      });
    });
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
            expandPosition: MediaQuery.of(context).size.height - 50,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: isExpanded ? _Details() : _smallDetails()),
          ]),
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
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
                      Navigator.pop(context);
                    }),
              ),
              Center(
                child: Container(
                  width: 50,
                  height: 8,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: ElevatedButton(onPressed: () {}, child: Container()),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, -3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Navigator.of(context).pushNamed("paymentMethod");
                      showPaymentMethod(context, paymentOption: 'cash');
                    },
                    icon: Icon(Icons.add_card_outlined, color: Colors.black54),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4533),
                      padding: EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RequestingRide(
                              destinationPlace: pointB, pickupPlace: pointA)));
                    },
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (_controller.status == SlidingPanelStatus.anchored) {
                        _controller.expand();
                      } else {
                        _controller.anchor();
                      }
                    },
                    icon: Icon(Icons.tune, color: Colors.black54),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _smallDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: const Text(
              "Your Trip",
              style: TextStyle(
                  fontFamily: ' sans-serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          addressPointes(
            title: "Pickup",
            subtitle: widget.pickupPlace!.displayName,
            icon: Container(
              width: 48,
              height: 48,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_run, color: Colors.white),
            ),
            enabledMapButton: false,
            onTap: () {
              showLocationPicker(
                context,
                _locationPickerInputController,
                widget.pickupPlace,
                (Place? newPlace) {
                  setState(() {
                    widget.pickupPlace = newPlace;
                  });
                },
              );
            },
          ),
          Container(
              padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: const Divider()),
          addressPointes(
              title: "~ 14 min",
              subtitle: widget.destinationPlace!.displayName,
              icon: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.black, // Yellow pickup icon background
                  size: 32.0,
                ),
              ),
              enabledMapButton: true,
              onTap: () {
                showLocationPicker(
                  context,
                  _locationDestinationInputController,
                  widget.destinationPlace,
                  (Place? newPlace) {
                    setState(() {
                      widget.destinationPlace = newPlace;
                    });
                  },
                );
              }),
          Container(
              padding: EdgeInsets.fromLTRB(2, 0, 0, 0), child: const Divider()),
          CarSelectionWidget()
        ],
      ),
    );
  }

  Widget _Details() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.pickupPlace != null)
                  addressPointes(
                    title: "Pickup",
                    subtitle: widget.pickupPlace!.displayName,
                    icon: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.directions_run, color: Colors.white),
                    ),
                    enabledMapButton: false,
                    onTap: () => _showPickupPicker(),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Divider(height: 1),
                ),
                if (widget.destinationPlace != null)
                  addressPointes(
                    title: "~ 14 min",
                    subtitle: widget.destinationPlace!.displayName,
                    icon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    enabledMapButton: true,
                    onTap: () => _showDestinationPicker(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          CarSelectionWidget(isDetails: true),
          const SizedBox(height: 5),
          _buildPaymentSection(),
          const SizedBox(height: 5),
          _buildInstructionsSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed("paymentMethod");
        showPaymentMethod(context);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 15, 0, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change payment method",
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Cash",
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  const Icon(Icons.money),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right_sharp))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 0, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () => showInstructionForDriver(context),
              child: Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      "Leave instructions for driver",
                      style: TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right_sharp))
              ])),
          // showAvatarModalBottomSheet(),
          const Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
            child: const Divider(height: 1),
          ),
          GestureDetector(
            onTap: () => showContact(context),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                "Request for someone else",
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickupPicker() {
    showLocationPicker(
      context,
      _locationPickerInputController,
      widget.pickupPlace,
      (Place? newPlace) {
        if (mounted) {
          setState(() => widget.pickupPlace = newPlace);
        }
      },
    );
  }

  void _showDestinationPicker() {
    showLocationPicker(
      context,
      _locationDestinationInputController,
      widget.destinationPlace,
      (Place? newPlace) {
        if (mounted) {
          setState(() => widget.destinationPlace = newPlace);
        }
      },
    );
  }
}
