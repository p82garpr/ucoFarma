import '../models/medicine_model.dart';

class User {
  final String id;
  final String email;
  final String fullname;
  final String? birthdate;
  final List<Medicine>? medicines;

  User({
    required this.id,
    required this.email,
    required this.fullname,
    this.birthdate,
    this.medicines,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      birthdate: json['birthdate'],
      medicines: (json['medicines'] as List<dynamic>?)
          ?.map((med) => Medicine.fromJson(med))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullname': fullname,
      'birthdate': birthdate,
      'medicines': medicines?.map((med) => med.toJson()).toList(),
    };
  }
}
