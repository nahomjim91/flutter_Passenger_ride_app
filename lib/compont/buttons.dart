import 'package:flutter/material.dart';
import 'package:ride_app/auth_service.dart';

Widget ButtonsPrimary(isLoading, String label, onTap) {
  return ElevatedButton(
    onPressed: isLoading ? null : onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF0C3B2E),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: isLoading
        ? const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          )
        : Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
  );
}

Widget ButtonWitGoogle(isloading, toggleLoading) {
  return OutlinedButton.icon(
    onPressed: isloading
        ? null // Disable the button while loading
        : () async {
            toggleLoading(); // Start loading
            try {
              await AuthService().signInWithGoogle2();
              toggleLoading(); // Start loading
            } catch (e) {
              print("Error: $e");
            }
          },
    icon: !isloading ? const Icon(Icons.g_mobiledata, size: 24) : null,
    label: isloading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF0C3B2E),
              strokeWidth: 2,
            ),
          )
        : const Text('Sign up with Google'),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: const BorderSide(color: Color(0xFF0C3B2E)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
