import 'dart:convert';
import '../models/tratamiento_model.dart';
import 'api_service.dart';

class TratamientoService {
  final ApiService _api = ApiService();
  final String endpoint = '/api/tratamientos';

  Future<List<Tratamiento>> getAll() async {
    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['postgres'];
      return list.map((e) => Tratamiento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar tratamientos');
    }
  }

  Future<bool> create(Tratamiento t) async {
    final response = await _api.post(endpoint, t.toJson());
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(String id, Tratamiento t) async {
    final response = await _api.put('$endpoint/$id', t.toJson());
    return response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final response = await _api.delete('$endpoint/$id');
    return response.statusCode == 200;
  }
}
