class User {
  final String correo;
  final String? nombre;
  
  User({
    required this.correo,
    this.nombre,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      correo: json['correo'] ?? '',
      nombre: json['nombre'],
    );
  }
}