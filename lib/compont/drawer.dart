import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_app/compont/cameraScreen.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/passenger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      // Check both camera permission and availability in parallel
      final cameraStatusFuture = Permission.camera.status;
      final cameraAvailabilityFuture = availableCameras();

      final results =
          await Future.wait([cameraStatusFuture, cameraAvailabilityFuture]);
      final cameraStatus = results[0] as PermissionStatus;
      final cameras = results[1] as List<CameraDescription>;
      final hasCamera = cameras.isNotEmpty;

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    if (cameraStatus.isGranted) {
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(
                            passengerId: widget.passenger.id,
                            onPhotoUpdated: (String newPhotoPath) {
                              setState(() {
                                widget.passenger.profile_photo = newPhotoPath;
                                Firebaseutillies()
                                    .savePassengerToFirestore(widget.passenger);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Profile photo updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handleImageSelection(ImageSource.gallery, context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error in _pickAndUploadImage: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleImageSelection(
      ImageSource source, BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image == null) return;

      // Read image bytes
      final bytes = await image.readAsBytes();

      // Create URI for the API endpoint
      var uri = Uri.parse('http://127.0.0.1:8000/api/upload-profile-photo');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add the file as bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename:
              '${widget.passenger.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Add passenger ID to request
      request.fields['passenger_id'] = widget.passenger.id;

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse response data
        Map<String, dynamic> jsonResponse = jsonDecode(responseData);

        // Update the profile photo path
        setState(() {
          widget.passenger.profile_photo = jsonResponse['path'];
          Firebaseutillies().savePassengerToFirestore(widget.passenger);
        });

        // Show success message
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDrawerHeader(context) {
    final imageUrl = "http://127.0.0.1:8000${widget.passenger.profile_photo!}";
    print("Loading image from: $imageUrl");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: const Color(0xFF0C3B2E),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadImage(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  radius: 40,
                  child: widget.passenger.profile_photo != null
                      ? ClipOval(
                          child: Image.network(
                            "http://127.0.0.1:8000${widget.passenger.profile_photo!}",
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                // Add edit overlay
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
          Column(
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
