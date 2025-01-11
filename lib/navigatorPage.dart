import 'package:flutter/material.dart';
import 'package:ride_app/Pages/Home.dart';
import 'package:ride_app/discount_screen.dart';
import 'package:ride_app/paymentScreen.dart';

import 'package:ride_app/passenger.dart';

class Home extends StatefulWidget {
  final Passenger passenger;

  const Home({Key? key, required this.passenger}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            key: GlobalKey<NavigatorState>(),
            initialRoute: 'home',
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case 'home':
                  return MaterialPageRoute(
                      builder: (_) => HomePage(passenger: widget.passenger));
                case 'paymentMethod':
                  return MaterialPageRoute(builder: (_) => PaymentMethod());
                case 'discounts':
                  return MaterialPageRoute(builder: (_) => DiscountScreen());

                default:
                  return MaterialPageRoute(
                    builder: (_) => const Center(child: Text('Page not found')),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
