import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/animal_model.dart';

class AnimalService {
  final String baseUrl = '$apiUrl/api/animales';

  /// GET ALL: Obtener todos los animales (de SQL)
  Future<List<Animal>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['sql']; //  SQL
      return data.map((e) => Animal.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener animales');
    }
  }

  /// GET ONE: Obtener un animal por ID
  Future<Animal> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Animal.fromJson(body);
    } else {
      throw Exception('Error al obtener animal');
    }
  }

  /// POST: Crear nuevo animal
  Future<bool> create(Animal animal) async {
  final res = await http.post(
    Uri.parse('$baseUrl'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(animal.toJson()),
  );

  return res.statusCode == 201 || res.statusCode == 200;
}


  /// PUT: Editar animal existente
  Future<void> update(String id, Animal animal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(animal.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar animal');
    }
  }

  /// DELETE: Eliminar animal
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar animal');
    }
  }
}
