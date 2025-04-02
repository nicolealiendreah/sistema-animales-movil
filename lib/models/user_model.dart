class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
  });

  // Factory para crear un usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      password: '', // Nunca deserializamos la contraseña desde backend
    );
  }

  // Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
