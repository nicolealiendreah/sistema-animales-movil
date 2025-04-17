import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/user_model.dart';

class UserService {
  final String baseUrl = '$apiUrl/api/users';

  /// Simula login buscando el usuario por email y comparando contraseña
  Future<bool> login(String email, String password) async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List users = body['postgres']; // Solo SQL

      // Buscar usuario por email
      final user = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );

      if (user != null && user['password'] == password) {
        // Login exitoso
        return true;
      }
    }
    // Si no se encontró o la contraseña es incorrecta
    return false;
  }

  /// Registrar nuevo usuario
  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }
}
