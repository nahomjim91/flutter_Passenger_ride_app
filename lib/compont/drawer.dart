import 'package:flutter/material.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/compont/uploadImage.dart';
import 'package:ride_app/passenger.dart';

class CustomDrawer extends StatefulWidget {
  final Passenger passenger;
  final VoidCallback onHistoryTap;

  CustomDrawer({
    Key? key,
    required this.passenger,
    required this.onHistoryTap,
  }) : super(key: key);
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Widget _buildDrawerHeader(context) {
    final imageUrl = widget.passenger.profile_photo!.contains("http")
        ? widget.passenger.profile_photo!
        : "http://127.0.0.1:8000${widget.passenger.profile_photo!}";
    print("Loading image from: $imageUrl");
    return GestureDetector(
      onTap: () => _navigateTo(context, 'profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: Colors.red,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Uploadimage().pickAndUploadImage(
                context,
                widget.passenger,
                (String newPhotoPath) {
                  setState(() {
                    widget.passenger.profile_photo = newPhotoPath;
                    Firebaseutillies()
                        .savePassengerToFirestore(widget.passenger);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    radius: 40,
                    child: widget.passenger.profile_photo != null
                        ? ClipOval(
                            child: Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              cacheWidth: 80 * 2,
                              cacheHeight: 80 * 2,
                              headers: {
                                'Accept': '*/*',
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading image: $error");
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: Icon(Icons.person, size: 40),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(Icons.person,
                            color: Colors.white, size: 40),
                  ),
                  // Add edit overlay
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color.fromARGB(255, 176, 174, 174),
                            width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
            ),
          ],
        ),
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

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerTile(
            title: 'History',
            onTap: () {
              Navigator.of(context).pop();
              widget.onHistoryTap();
            },
          ),
          _buildDrawerTile(
            title: 'Payment methods',
            subtitle: capitalize(widget.passenger.payment_method),
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
