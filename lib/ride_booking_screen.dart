import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  bool isExpanded = false;
  final ScrollController _scrollController = ScrollController();
  bool _showContent = true;
  final List<Destination> destinations = [
    Destination('Addis Ababa Stadium', 'Addis Ababa'),
    Destination('Dember City Center', 'Bole, Addis Ababa'),
    Destination('Century Mall', 'Bole, Addis Ababa'),
    Destination('Bole International Airport', 'Bole, Addis Ababa'),
  ];

  final drawerItems = ListView(
    padding: EdgeInsets.zero,
    children: [
      ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: SizedBox(
          width: 58, // Width of the entire leading widget
          height: 58, // Height of the entire leading widget
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFCC00), // Background color
              shape: BoxShape.circle, // Makes the background circular
            ),
            child: IconButton(
              iconSize: 32,
              color: const Color(0xFF0C3B2E), // Icon color
              onPressed: () {
                // Add your camera button functionality here
              },
              icon: const Icon(Icons.camera_alt_sharp),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Doe',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFFFFCC00), // Yellow color for the name
              ),
            ),
            Text(
              '5.0⭐',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: Color(0xFFFFCC00), // Yellow color for the rating
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'History',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Payment methods',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
        subtitle: Text(
          'Telebirr',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
        trailing: Icon(Icons.payment_sharp),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Support',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Safety',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Save Places',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Descount',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
        subtitle: Text(
          'Enter promo code',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
        trailing: Icon(Icons.card_giftcard, color: Color(0xFFFFCC00)),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Settings',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
      const SizedBox(height: 10), // Spacer between ListTiles

      const ListTile(
        title: Text(
          'Info',
          style: TextStyle(color: Color(0xFFFFCC00)),
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();

    // Add a listener to the ScrollController
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scrolling up - show content
        print('Scrolling up - show content');
        setState(() {
          _showContent = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scrolling down - hide content
        print('Scrolling down - hide content');
        setState(() {
          _showContent = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(backgroundColor: Color(0xFF0C3B2E), child: drawerItems),
      body: Stack(
        children: [
          // Add your map widget here
          Positioned(
            bottom: -4,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showDestinationSheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3B2E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Where to?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pickupWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF003D33), // Dark green background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFCC00), // Yellow pickup icon background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 32.0,
                ),
              ),
              const SizedBox(width: 16.0),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'General Wingate Street',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30, 5, 0, 5),
            child: const Divider(
              color: Colors.grey,
              height: 10,
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
                  // color: Color(0xFFFFCC00), // Yellow pickup icon background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Color(0xFFFFCC00), // Yellow pickup icon background
                  size: 32.0,
                ),
              ),
              const SizedBox(width: 16.0),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextField(
                        decoration: InputDecoration.collapsed(
                      hintText: 'Where to?',
                    )),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFCC00), // Yellow button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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
    );
  }

  void _showDestinationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF0C3B2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_showContent) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: pickupWidget(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: destinations.length,
                  separatorBuilder: (context, index) => Container(
                    padding: const EdgeInsets.fromLTRB(30, 5, 0, 5),
                    child: const Divider(
                      color: Colors.white,
                      height: 10,
                      thickness: 1,
                      indent: 20,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        size: 24,
                        color: Color(0xFFFFCC00),
                      ),
                      title: Text(
                        destinations[index].name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        destinations[index].address,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Center(
                child: Text(
                  "adsjgf",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Destination {
  final String name;
  final String address;

  Destination(this.name, this.address);
}
