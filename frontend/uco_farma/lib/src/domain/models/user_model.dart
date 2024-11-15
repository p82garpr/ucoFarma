class User {
  final String email;
  final String fullname;
  final String? birthdate;
  
  User({
    required this.email,
    required this.fullname,
    this.birthdate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      birthdate: json['birthdate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullname': fullname,
      'birthdate': birthdate,
    };
  }
}