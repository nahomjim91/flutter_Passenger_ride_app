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
}
