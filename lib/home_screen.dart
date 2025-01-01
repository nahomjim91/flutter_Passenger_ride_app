import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:flutter_sliding_panel/flutter_sliding_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_app/discount_screen.dart';
import 'package:ride_app/map.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/paymentMethod.dart';
import 'package:ride_app/placeSearchWidget.dart';
import 'package:ride_app/save_places_secreen.dart';
import 'package:ride_app/sliding_box.dart';
import 'package:ride_app/support_sreen.dart';

class Home extends StatefulWidget {
  Passenger passenger;
  Home({super.key, required this.passenger});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SlidingPanelController _historyController = SlidingPanelController();
  bool _isHistoryPanelVisible = false; // To control panel visibility
  Place? pickupPlace;
  Place? destinationPlace;

  @override
  initState() {
    super.initState();
    _isHistoryPanelVisible = true;
    _historyController.addListener(() {
      setState(() {
        if (_historyController.status == SlidingPanelStatus.anchored) {
          _toggleHistoryPanel();
        }
      });
    });
  }

  SlidingPanel _historyWidget() => SlidingPanel.scrollableContent(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    _toggleHistoryPanel();
                  },
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
      );

  void _toggleHistoryPanel() {
    setState(() {
      _isHistoryPanelVisible = !_isHistoryPanelVisible;
    });
  }

  ListView drawerItems() => ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0C3B2E),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  radius: 40,
                  child: widget.passenger.profile_photo != null
                      ? ClipOval(
                          child: Image.network(
                            widget.passenger.profile_photo!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.camera_alt, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.passenger.first_name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '5.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'History',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              _toggleHistoryPanel(); // Toggle panel visibility
            },
          ),
          ListTile(
            title: Text(
              'Payment methods',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            subtitle: Text('Telebirr'),
            trailing: Icon(Icons.payment_sharp),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to payment method screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PaymentMethod(),
              ));
            },
          ),
          ListTile(
            title: Text(
              'Earn as a driver',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Support',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to support screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SupportServicePage(),
              ));
            },
          ),
          ListTile(
            title: Text(
              'Safety',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Saved places',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to saved places screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SavePlaces(),
              ));
            },
          ),
          ListTile(
            title: Text(
              'Discounts',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            subtitle: Text('Enter promo code'),
            trailing: Icon(Icons.card_giftcard),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to discount screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DiscountScreen(),
                // builder: (context) => MyHomePage(),
              ));
            },
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Info',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[750]),
            ),
            onTap: () {},
          ),
        ],
      );

  void handleLocationPicked(String address, LatLng coordinates) {
    print("Selected Address: $address");
    print("Coordinates: ${coordinates.latitude}, ${coordinates.longitude}");
    // Perform any additional actions with the received data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.logout, color: Colors.grey)),
          ],
        ),
      ),
      drawer: Drawer(
        child: drawerItems(),
      ),
      body: Stack(
        children: [
          // Map here
          MapCustome(
            onLocationPicked: handleLocationPicked,
          ),
          // sliding box
          SlidingBoxDemo(
              
          ),
          _isHistoryPanelVisible ? _historyWidget() : const SizedBox(),
          // SlidingBoxDemo2()
        ],
      ),
    );
  }
}
