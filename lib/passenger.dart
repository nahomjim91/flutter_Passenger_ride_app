class Passenger {
  String id;
  String phone_number;
  String first_name;
  String last_name;
  String? profile_photo;
  String created_at;
  String email;
  String payment_method;

  Passenger({
    required this.id,
    required this.phone_number,
    required this.first_name,
    required this.last_name,
    this.profile_photo,
    required this.created_at,
    required this.email,
    required this.payment_method,
  });

  // CopyWith method
  Passenger copyWith({
    String? first_name,
    String? last_name,
    String? phone_number,
    String? profile_photo,
    String? email,
    String? payment_method,
  }) {
    return Passenger(
      id: id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      phone_number: phone_number ?? this.phone_number,
      profile_photo: profile_photo ?? this.profile_photo,
      email: email ?? this.email,
      created_at: created_at,
      payment_method:payment_method ?? this.payment_method,
    );
  }

  // From JSON
  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone_number: json['phone_number'],
      profile_photo: json['profile_photo'],
      email: json['email'],
      created_at: json['created_at'],
      payment_method: json['payment_method'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'phone_number': phone_number,
      'profile_photo': profile_photo,
      'email': email,
      'created_at': created_at,
      'payment_method': payment_method
    };
  }
}
