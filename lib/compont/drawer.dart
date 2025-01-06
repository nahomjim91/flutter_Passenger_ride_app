import 'package:flutter/material.dart';
import 'package:ride_app/passenger.dart';

class CustomDrawer extends StatelessWidget {
  final Passenger passenger;
  final VoidCallback onHistoryTap;

  const CustomDrawer({
    Key? key,
    required this.passenger,
    required this.onHistoryTap,
  }) : super(key: key);

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: const Color(0xFF0C3B2E),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            radius: 40,
            child: passenger.profile_photo != null
                ? ClipOval(
                    child: Image.network(
                      passenger.profile_photo!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.camera_alt, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passenger.first_name,
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
    );
  }

  Widget _buildDrawerTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[750]),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null ? Icon(icon) : null,
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pop(); // Close the drawer
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerTile(
            title: 'History',
            onTap: () {
              Navigator.of(context).pop();
              onHistoryTap();
            },
          ),
          _buildDrawerTile(
            title: 'Payment methods',
            subtitle: 'Telebirr',
            icon: Icons.payment_sharp,
            onTap: () => _navigateTo(context, 'paymentMethod'),
          ),
          _buildDrawerTile(
            title: 'Earn as a driver',
            onTap: () {},
          ),
          _buildDrawerTile(
            title: 'Support',
            onTap: () => _navigateTo(context, 'support'),
          ),
          _buildDrawerTile(
            title: 'Safety',
            onTap: () {},
          ),
          _buildDrawerTile(
            title: 'Saved places',
            onTap: () => _navigateTo(context, 'savedPlaces'),
          ),
          _buildDrawerTile(
            title: 'Discounts',
            subtitle: 'Enter promo code',
            icon: Icons.card_giftcard,
            onTap: () => _navigateTo(context, 'discounts'),
          ),
          _buildDrawerTile(
            title: 'Settings',
            onTap: () {},
          ),
          _buildDrawerTile(
            title: 'Info',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
