import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_app/Pages/EditProfilePage.dart';
import 'package:ride_app/Pages/Home.dart';
import 'package:ride_app/Pages/profilePage.dart';
import 'package:ride_app/Pages/discountPage.dart';
import 'package:ride_app/Pages/paymentPage.dart';
import 'package:ride_app/passenger.dart';

class NavigatorPage extends StatelessWidget {
  NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PassengerProvider>(
        builder: (context, passengerProvider, _) {
          return Stack(
            children: [
              Navigator(
                key: GlobalKey<NavigatorState>(),
                initialRoute: 'home',
                onGenerateRoute: (RouteSettings settings) {
                  switch (settings.name) {
                    case 'home':
                      return MaterialPageRoute(
                        builder: (_) => HomePage(),
                      );
                    case 'paymentMethod':
                      return MaterialPageRoute(
                        builder: (_) => const PaymentMethod(),
                      );
                    case 'discounts':
                      return MaterialPageRoute(
                        builder: (_) => DiscountPage(),
                      );
                    case 'profile':
                      return MaterialPageRoute(
                        builder: (_) => ProfilePage(),
                      );
                    case 'editProfile':
                      return MaterialPageRoute(
                        builder: (_) => EditProfilePage(),
                      );
                    default:
                      return MaterialPageRoute(
                        builder: (_) => const Center(
                          child: Text('Page not found'),
                        ),
                      );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
