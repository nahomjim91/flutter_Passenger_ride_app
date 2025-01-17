import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_app/compont/cameraScreen.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_app/passenger.dart';

class Uploadimage {
  Future<void> pickAndUploadImage(BuildContext context, Passenger passenger,
      Function(String) onPhotoUpdated) async {
    try {
      // Check both camera permission and availability in parallel
      final cameraStatusFuture = Permission.camera.status;
      final cameraAvailabilityFuture = availableCameras();

      final results =
          await Future.wait([cameraStatusFuture, cameraAvailabilityFuture]);
      final cameraStatus = results[0] as PermissionStatus;
      final cameras = results[1] as List<CameraDescription>;
      // ignore: unused_local_variable
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
                              passengerId: passenger.id,
                              onPhotoUpdated: onPhotoUpdated),
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
                    await handleImageSelection(ImageSource.gallery, context,
                        passenger, onPhotoUpdated);
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

  final ImagePicker picker = ImagePicker();
  Future<void> handleImageSelection(ImageSource source, BuildContext context,
      Passenger passenger, updatePassenger) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
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
              '${passenger.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Add passenger ID to request
      request.fields['passenger_id'] = passenger.id;

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse response data
        Map<String, dynamic> jsonResponse = jsonDecode(responseData);

        // Update the profile photo path
        String profilePhotoPath = jsonResponse['path'];
        updatePassenger(profilePhotoPath);
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
}
