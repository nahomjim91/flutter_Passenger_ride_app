import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Auth/save_place_api.dart';
import 'package:ride_app/compont/Map/showSelectedMap.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/driver.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/request_ride.dart';

// ignore: must_be_immutable
class RideAccptedDetails extends StatefulWidget {
  RideAccptedDetails(
      {super.key,
      required this.rquestRide,
      this.distance,
      this.duration,
      this.routePoints,
      required this.driverId,
      required this.toggledShareLocation,
      required this.shouldShareLocation});

  RequestRide rquestRide;
  double? distance;
  double? duration;
  List<LatLng>? routePoints;
  bool shouldShareLocation;
  int driverId;
  void Function() toggledShareLocation;

  @override
  State<RideAccptedDetails> createState() => _RideAccptedDetailsState();
}

class _RideAccptedDetailsState extends State<RideAccptedDetails> {
  late SlidingPanelController _controller;
  bool _isLoading = false;
  // bool widget.shouldShareLocation = false;
  // ignore: unused_field
  int _counter = 0;
  late Passenger passenger;
  Driver? driver;

  Future<void> _loadDriver() async {
    _isLoading = true;
    Driver? driver = await ApiService().getDriverById(2);
    setState(() {
      this.driver = driver;
    });
    _isLoading = false;
  }

  // ignore: unused_field
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    passenger = context.read<PassengerProvider>().passenger!;
    _loadDriver();
    _controller = SlidingPanelController();
  }

  @override
  void dispose() {
    _controller.removeListener;
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingPanel.scrollableContent(
      controller: _controller,
      config: SlidingPanelConfig(
        anchorPosition: 410,
        expandPosition: MediaQuery.of(context).size.height - 100,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      panelContentBuilder: (controller, physics) => _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                driverDetails(
                    durationInSeconds: (widget.duration ?? 0)
                        .toInt(), // 51 minutes in seconds use duration
                    driverName: (driver?.first_name ?? '') +
                        ' ' +
                        (driver?.last_name ?? ''),
                    rating: 5.0,
                    carColor: Colors.grey, // driver.vehicle_color
                    carModel: driver!.vehicle_model,
                    carPlateNumber: driver!.license_plate,
                    personImageUrl: driver!.profile_photo!),
                const SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    physics: physics,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3.0),
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
                                  title: "Save your pickup location",
                                  subtitle: 'For Fast access on feature rides',
                                  icon: Container(
                                    width: 36,
                                    height: 38,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                        child: Icon(Icons.bookmark,
                                            color: Colors.black)),
                                  ),
                                  onTap: () async {
                                    SavePlace savedPlace =
                                        await SavePlaceApi.savePlace(
                                      passengerId: passenger.id,
                                      place: SavePlace(
                                          placename: widget.rquestRide
                                              .pickupPlace.displayName,
                                          latitude: widget
                                              .rquestRide.pickupPlace.latitude,
                                          longitude: widget.rquestRide
                                              .pickupPlace.longitude),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        addressPoints(),
                        const SizedBox(height: 5),
                        priceEstimateCard(
                          price: '\$25.00',
                          shareLocation: widget.shouldShareLocation,
                          onLocationShareChanged: (value) {
                            setState(() {
                              widget.shouldShareLocation = value;
                            });
                            widget.toggledShareLocation;
                          },
                          onCarrierDetailsTap: () {
                            // Handle carrier details tap
                          },
                        ),
                        const SizedBox(height: 5),
                        _buildCancelButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      leading: _buildLeadingWidget(context),
    );
  }

  Widget _buildCancelButton() {
    double bottomGap = widget.rquestRide.stopsPlaces != null ? 100 : 10;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.fromLTRB(0, 0, 0, bottomGap),
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
        onTap: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            'home',
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 0, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                'home',
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        const Center(child: SizedBox()),
      ],
    );
  }

  Widget driverDetails({
    required int durationInSeconds,
    required String driverName,
    required double rating,
    required Color carColor,
    required String carModel,
    required String carPlateNumber,
    required String personImageUrl,
  }) {
    int durationInMinutes = (durationInSeconds / 60).ceil();

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver image
            CircleAvatar(
              backgroundImage: NetworkImage(personImageUrl),
              radius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time left
                  Text(
                    '~$durationInMinutes min left',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Driver name and rating
                  Text(
                    '$driverName ★ $rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Car model and color
                  Text(
                    'carMode - $carModel - $carColor ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Car plate number
                  Text(
                    'Plate: $carPlateNumber',
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
              subtitle: widget.rquestRide.pickupPlace.displayName,
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
                showSelectedPlace(widget.rquestRide.pickupPlace);
              },
            ),
            if (widget.rquestRide.stopsPlaces != null)
              for (int i = 0; i < widget.rquestRide.stopsPlaces!.length; i++)
                Column(children: [
                  selectorButton(
                    title: "Stop ${i + 1}",
                    subtitle: widget.rquestRide.stopsPlaces![i].displayName,
                    icon: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.black, // Yellow pickup icon background
                        size: 32.0,
                      ),
                    ),
                    onTap: () {
                      showSelectedPlace(widget.rquestRide.stopsPlaces![i]);
                    },
                  ),
                ]),
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
                showSelectedPlace(
                  widget.rquestRide.destinationPlace,
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
    List<String> images = [
      'assets/images/telebirr_icon.png',
      'assets/images/awash_icon.png',
      'assets/images/cash_icon.png',
    ];
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
                  passenger.payment_method.toLowerCase() == 'telebirr'
                      ? images[0]
                      : passenger.payment_method == 'awash'
                          ? images[1]
                          : images[2],
                  // 'assets/images/telebirr_icon.png',
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
                      passenger.payment_method == 'cash'
                          ? 'Cash: $price'
                          : 'Mobile Money: $price',
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

  void showSelectedPlace(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ShowSelectedMap(selectedPlace: place)),
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 0, 15),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Colors.grey[200]!,
          )),
        ),
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
                          color: Colors
                              .grey[600]), // Optional styling for the title
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
      ),
    );
  }
}
