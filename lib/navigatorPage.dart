import 'package:flutter/material.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Pages/EditProfilePage.dart';
import 'package:ride_app/Pages/Home.dart';
import 'package:ride_app/Pages/profilePage.dart';
import 'package:ride_app/Pages/discountPage.dart';
import 'package:ride_app/Pages/paymentPage.dart';

import 'package:ride_app/passenger.dart';

// ignore: must_be_immutable
class NavigatorPage extends StatefulWidget {
  Passenger passenger;

  NavigatorPage({super.key, required this.passenger});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  void updatingPassenger(Passenger passenger) async {
    try {
      Passenger updatedPassenger =
          await ApiService().updatePassenger(passenger.id, passenger);
      setState(() {
        widget.passenger = updatedPassenger;
      });
    } catch (e) {
      print('Error updating passenger: $e');
    }
  }

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
                  return MaterialPageRoute(
                      builder: (_) => PaymentMethod(
                          passenger: widget.passenger,
                          updater: updatingPassenger));
                case 'discounts':
                  return MaterialPageRoute(builder: (_) => DiscountPage());
                case 'profile':
                  return MaterialPageRoute(
                      builder: (_) => ProfilePage(passenger: widget.passenger));
                case 'editProfile':
                  return MaterialPageRoute(
                      builder: (_) => EditProfilePage(
                          passenger: widget.passenger,
                          setPassenger: (Passenger passenger) => setState(() {
                                widget.passenger = passenger;
                              })));

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
