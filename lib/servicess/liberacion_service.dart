import 'dart:convert';
import '../models/liberacion_model.dart';
import 'api_service.dart';

class LiberacionService {
  final ApiService _api = ApiService();
  final String endpoint = '/api/liberaciones';

  Future<List<Liberacion>> getAll() async {
    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['postgres'];
      return list.map((e) => Liberacion.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar liberaciones');
    }
  }

  Future<bool> create(Liberacion l) async {
    final response = await _api.post(endpoint, l.toJson());
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(String id, Liberacion l) async {
    final response = await _api.put('$endpoint/$id', l.toJson());
    return response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final response = await _api.delete('$endpoint/$id');
    return response.statusCode == 200;
  }
}
