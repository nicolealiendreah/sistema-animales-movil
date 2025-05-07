import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/user_model.dart';

class UserService {
  final String baseUrl = '$apiUrl/api/users';

  Future<bool> login(String email, String password) async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List users = body['postgres'];

      final user = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );

      if (user != null && user['password'] == password) {
        return true;
      }
    }
    return false;
  }

  Future<bool> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 500 &&
          (response.body.contains('validation failed') ||
              response.body.contains('_id'))) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
