import 'package:flutter/material.dart';
import 'package:ride_app/Auth/auth_service.dart';

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

Widget addressPointes(
    {required String? title,
    required String subtitle,
    required Widget icon,
    required bool enabledMapButton,
    required Function onTap,
    bool? enabledtrailing}) {
  return ListTile(
    onTap: () => onTap(),
    style: ListTileStyle.list,
    title: Row(
      children: [
        icon,
        SizedBox(width: 12),
        Expanded(
          // Ensures the text doesn't overflow beyond its allocated space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey[600]), // Optional styling for the title
                ),
              Text(
                subtitle,
                maxLines: 1, // Restrict to one line
                overflow:
                    TextOverflow.ellipsis, // Add ellipsis if text overflows
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[700] // Optional styling for subtitle
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        if (enabledMapButton)
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey[300],
            ),
            child: TextButton(
              child: Text('Stops'),
              onPressed: () {},
            ),
          ),
      ],
    ),
    trailing:
        (enabledtrailing ?? false) ? const Icon(Icons.arrow_forward_ios) : null,
  );
}
