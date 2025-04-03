class User {
  final int? id;
  final String name;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "lastName": lastName,
      "username": username,
      "email": email,
      "password": password,
    };
  }
}
