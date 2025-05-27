import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/evaluation_model.dart';

class EvaluationService {
  final String baseUrl = '$apiUrl/api/evaluations';

  Future<List<Evaluation>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['postgres'];
      return data.map((e) => Evaluation.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener evaluaciones');
    }
  }

  Future<Evaluation> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Evaluation.fromJson(body);
    } else {
      throw Exception('Error al obtener evaluación');
    }
  }

  Future<void> create(Evaluation evaluation) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(evaluation.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return;
  }

  if (response.statusCode == 500 &&
      (response.body.contains('validation failed') ||
       response.body.contains('_id') ||
       response.body.contains('MongoDB'))) {
    return;
  }

  throw Exception('Error al registrar evaluación: ${response.body}');
}

  Future<void> update(String id, Evaluation evaluation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evaluation.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar evaluación');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar evaluación');
    }
  }
}
