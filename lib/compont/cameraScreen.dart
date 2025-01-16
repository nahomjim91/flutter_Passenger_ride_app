import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
import 'dart:html' as html; // Add this for Flutter Web support

class CameraScreen extends StatefulWidget {
  final String passengerId;
  final Function(String) onPhotoUpdated;

  const CameraScreen({
    Key? key,
    required this.passengerId,
    required this.onPhotoUpdated,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      _showError('Camera permission is required');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No cameras available');
        return;
      }

      final camera = cameras.first;
      final cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController.initialize();

      if (!mounted) return;

      setState(() {
        _controller = cameraController;
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showError('Error initializing camera: $e');
    }
  }

  Future<void> _captureAndUpload() async {
    if (!_isCameraInitialized || _isCapturing || _controller == null) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      final bytes = await photo.readAsBytes();

      // Create a Blob and FormData for Flutter Web
      final blob = html.Blob([bytes]);
      final fileName =
          '${widget.passengerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final formData = html.FormData();
      formData.appendBlob('image', blob, fileName);
      formData.append('passenger_id', widget.passengerId);

      // Make an HTTP request using html.HttpRequest
      final request = await html.HttpRequest.request(
        'http://127.0.0.1:8000/api/upload-profile-photo',
        method: 'POST',
        sendData: formData,
      );

      if (request.status == 200) {
        final jsonResponse = jsonDecode(request.responseText!);
        widget.onPhotoUpdated(jsonResponse['path']);
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw Exception('Upload failed: ${request.status}');
      }
    } catch (e) {
      _showError('Error capturing/uploading photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),

            // Top Controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Capture Button
                  Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _captureAndUpload,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Center(
                                child: Icon(
                                  Icons.camera,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                      ),
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
}
