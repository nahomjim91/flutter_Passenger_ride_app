
class Driver {
  int id;
  String phone_number;
  String first_name;
  String last_name;
  String? profile_photo;
  String vehicle_make;
  String vehicle_category;
  String vehicle_model;
  String vehicle_color;
  String license_plate;
  Map<String, double> location; // Added location property

  Driver({
    required this.id,
    required this.phone_number,
    required this.first_name,
    required this.last_name,
    this.profile_photo,
    required this.vehicle_make,
    required this.vehicle_category,
    required this.vehicle_model,
    required this.vehicle_color,
    required this.license_plate,
    required this.location, // Added location to the constructor
  });

  // CopyWith method
  Driver copyWith({
    String? first_name,
    String? last_name,
    String? phone_number,
    String? profile_photo,
    String? email,
    String? vehicle_make,
    String? vehicle_category,
    String? vehicle_model,
    String? vehicle_color,
    String? license_plate,
    Map<String, double>? location, // Allow updating location
  }) {
    return Driver(
      id: id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      phone_number: phone_number ?? this.phone_number,
      profile_photo: profile_photo ?? this.profile_photo,
      vehicle_make: vehicle_make ?? this.vehicle_make,
      vehicle_category: vehicle_category ?? this.vehicle_category,
      vehicle_model: vehicle_model ?? this.vehicle_model,
      vehicle_color: vehicle_color ?? this.vehicle_color,
      license_plate: license_plate ?? this.license_plate,
      location: location ?? this.location, // Update location if provided
    );
  }

  // From JSON
  factory Driver.fromJson(Map json) {
    return Driver(
      id: json['driver_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone_number: json['phone_number'],
      profile_photo: json['profile_photo'],
      vehicle_make: json['vehicle_make'],
      vehicle_category: json['vehicle_category'],
      vehicle_model: json['vehicle_model'],
      vehicle_color: json['vehicle_color'],
      license_plate: json['license_plate'],
      location: {
        'latitude': double.tryParse(json['location']['latitude']) ?? 0.0,
        'longitude': double.tryParse(json['location']['longitude']) ?? 0.0
      },
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'driver_id': id,
      'first_name': first_name,
      'last_name': last_name,
      'phone_number': phone_number,
      'profile_photo': profile_photo,
      'vehicle_make': vehicle_make,
      'vehicle_category': vehicle_category,
      'vehicle_model': vehicle_model,
      'vehicle_color': vehicle_color,
      'license_plate': license_plate,
      'location': location, // Include location in JSON
    };
  }
}
