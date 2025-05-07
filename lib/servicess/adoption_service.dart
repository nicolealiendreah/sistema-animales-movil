import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/adoption_model.dart';

class AdoptionService {
  final String baseUrl = '$apiUrl/api/adoptions';

  Future<List<Adoption>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['postgres']; // SQL
      return data.map((e) => Adoption.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener adopciones');
    }
  }

  Future<Adoption> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Adoption.fromJson(body);
    } else {
      throw Exception('Error al obtener adopción');
    }
  }

  Future<void> create(Adoption adoption) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(adoption.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 500 &&
        (response.body.contains('MongoDB') ||
            response.body.contains('not found') ||
            response.body.contains('llave duplicada') ||
            response.body.contains('pkey'))) {
      return;
    }

    throw Exception('Error al registrar adopción: ${response.body}');
  }

  Future<void> update(String id, Adoption adoption) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(adoption.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar adopción');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar adopción');
    }
  }
}
