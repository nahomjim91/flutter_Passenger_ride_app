import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Pages/EditProfilePage.dart';
import 'package:ride_app/compont/drawer.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/compont/showModalUtilities.dart';
import 'package:ride_app/compont/map.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/scrollablePages/sliding_box.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  Passenger passenger;
  HomePage({super.key, required this.passenger});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHistoryPanelVisible = false;
  @override
  void initState() {
    super.initState();
  }

  void _toggleHistoryPanel() {
    if (!_isHistoryPanelVisible) {
      showHistorySheet(
          context,
          () => {
                setState(() {
                  _isHistoryPanelVisible = false;
                }),
                Navigator.pop(context)
              });
    }
    setState(() {
      _isHistoryPanelVisible = !_isHistoryPanelVisible;
    });
  }

  void handleLocationPicked(String address, LatLng coordinates) {
    debugPrint("Selected Address: $address");
    debugPrint(
        "Coordinates: ${coordinates.latitude}, ${coordinates.longitude}");
    // Perform any additional actions with the received data
  }

  Place pointA = Place(
    displayName: 'Point A',
    latitude: 8.990125936297181,
    longitude: 38.7512341241246,
  );

  Place pointB = Place(
    displayName: 'Point B',
    latitude: 9.0079232,
    longitude: 38.7678208,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout, color: Colors.grey),
            ),
          ],
        ),
      ),
      drawer: FutureBuilder<Passenger?>(
        future:
            // Firebaseutillies().getPassengerFromFirestore(widget.passenger.id),
            ApiService().getPassenger(widget.passenger.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // or any other loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('No passenger data');
          } else {
            return CustomDrawer(
              passenger: snapshot.data!,
              onHistoryTap: _toggleHistoryPanel,
            );
          }
        },
      ),
      body: Stack(
        children: [
          MapCustome(
            onLocationPicked: handleLocationPicked,
            isDisplayOnly: false,
          ),

          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      // Yourtrip(destinationPlace: pointB, pickupPlace: pointA)
                      EditProfilePage(
                          passenger: widget.passenger,
                          setPassenger: (Passenger passenger) => setState(() {
                                widget.passenger = passenger;
                              })),
                ));
              },
              child: const Icon(
                Icons.add_box,
                size: 100,
              )),

          // sliding box
          const SlidingBoxDemo(),
          // SlidingBoxDemo2()
        ],
      ),
    );
  }
}

//8.989762498796392, 38.75107989156815
//8.99033892123591, 38.75052357070594
//8.990931503970192, 38.750769006380445

// current location
//8.9904215, 38.7512067