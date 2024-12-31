class Passenger {
  String id;
  String phone_number;
  String first_name;
  String last_name;
  String? profile_photo;
  String created_at;
  String email;

  Passenger({
    required this.id,
    required this.phone_number,
    required this.first_name,
    required this.last_name,
    this.profile_photo,
    required this.created_at,
    required this.email,
  });

  // CopyWith method
  Passenger copyWith({
    String? first_name,
    String? last_name,
    String? phone_number,
    String? profile_photo,
    String? email,
  }) {
    return Passenger(
      id: id,
      phone_number: phone_number ?? this.phone_number,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      profile_photo: profile_photo ?? this.profile_photo,
      created_at: created_at,
      email: email ?? this.email,
    );
  }
}
