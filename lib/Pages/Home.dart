import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/compont/drawer.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/map.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/routeMap.dart';
import 'package:ride_app/sliding_box.dart';
import 'package:ride_app/yourTrip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SlidingPanelController _historyController = SlidingPanelController();
  bool _isHistoryPanelVisible = false;
  @override
  void initState() {
    super.initState();
    _isHistoryPanelVisible = true;
    _historyController.addListener(_handlePanelStatusChange);
  }

  @override
  void dispose() {
    _historyController.removeListener(_handlePanelStatusChange);
    super.dispose();
  }

  void _handlePanelStatusChange() {
    if (_historyController.status == SlidingPanelStatus.anchored) {
      _toggleHistoryPanel();
    }
  }

  void _toggleHistoryPanel() {
    setState(() {
      _isHistoryPanelVisible = !_isHistoryPanelVisible;
    });
  }

  void handleLocationPicked(String address, LatLng coordinates) {
    print("Selected Address: $address");
    print("Coordinates: ${coordinates.latitude}, ${coordinates.longitude}");
    // Perform any additional actions with the received data
  }

  Widget _buildHistoryPanel() {
    return SlidingPanel.scrollableContent(
      controller: _historyController,
      config: SlidingPanelConfig(
        anchorPosition: MediaQuery.of(context).size.height - 300,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'No rides or orders to show',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleHistoryPanel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        future: Firebaseutillies().getPassengerFromFirestore("456"),
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
              child: Icon(
                Icons.add_box,
                size: 100,
              )),

          // sliding box
          SlidingBoxDemo(),
          // SlidingBoxDemo2()
          if (_isHistoryPanelVisible) _buildHistoryPanel(),
        ],
      ),
    );
  }
}
