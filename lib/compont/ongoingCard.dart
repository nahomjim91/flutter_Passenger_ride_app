import 'package:flutter/material.dart';

class OngoingCard extends StatefulWidget {
  final String driverName;
  final String driverImage;
  final String destination;
  final double duration;
  final double distance;
  final String carType;
  final String carNumber;

  const OngoingCard({
    super.key,
    required this.driverName,
    required this.driverImage,
    required this.destination,
    required this.duration,
    required this.distance,
    required this.carType,
    required this.carNumber,
  });

  @override
  State<OngoingCard> createState() => _OngoingCardState();
}

class _OngoingCardState extends State<OngoingCard> {
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      // Convert to kilometers
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // Keep in meters
      return '${distanceInMeters.toStringAsFixed(1)} m';
    }
  }

  String formatDuration(double durationInSeconds) {
    if (durationInSeconds >= 3600) {
      // Convert to hours
      double durationInHours = durationInSeconds / 3600;
      return '${durationInHours.toStringAsFixed(1)} hr';
    } else if (durationInSeconds >= 60) {
      // Convert to minutes
      double durationInMinutes = durationInSeconds / 60;
      return '${durationInMinutes.toStringAsFixed(1)} min';
    } else {
      // Keep in seconds
      return '${durationInSeconds.toStringAsFixed(1)} sec';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.driverImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.carType} • ${widget.carNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(widget
                            .duration), // Use the helper function for duration
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.destination,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Distance',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDistance(widget
                          .distance), // Use the helper function for distance
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
