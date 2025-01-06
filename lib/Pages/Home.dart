import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ride_app/Pages/requestingRide.dart';
import 'package:ride_app/compont/drawer.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/compont/showModalUtilities.dart';
import 'package:ride_app/map.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/routeMap.dart';
import 'package:ride_app/sliding_box.dart';
import 'package:ride_app/yourTrip.dart';

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
    print("Selected Address: $address");
    print("Coordinates: ${coordinates.latitude}, ${coordinates.longitude}");
    // Perform any additional actions with the received data
  }

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
            Firebaseutillies().getPassengerFromFirestore(widget.passenger.id),
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
          ),
          // RouteMap(
          //     pointA: LatLng(9.00427798077372, 38.7679495460327),
          //     pointB: LatLng(9.012797563606085, 38.77155443494872)),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      Yourtrip(destinationPlace: pointB, pickupPlace: pointA),
                ));
              },
              // onPressed: () {
              //   Navigator.of(context)
              //       .push(MaterialPageRoute(builder: (_) => RequestingRide(destinationPlace: pointB, pickupPlace: pointA)));
              // },
              child: Icon(
                Icons.add_box,
                size: 100,
              )),

          // sliding box
          SlidingBoxDemo(),
          // SlidingBoxDemo2()
        ],
      ),
    );
  }
}
