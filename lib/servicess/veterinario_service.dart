import 'dart:convert';
import 'package:sistema_animales/models/veterinarian_model.dart';
import 'api_service.dart';

class VeterinarioService {
  final ApiService _api = ApiService();
  final String endpoint = '/api/veterinarios';

  Future<List<Veterinario>> getAll() async {
    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['postgres'];
      return list.map((e) => Veterinario.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar veterinarios');
    }
  }

  Future<bool> create(Veterinario v) async {
    final response = await _api.post(endpoint, v.toJson());
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(String id, Veterinario v) async {
    final response = await _api.put('$endpoint/$id', v.toJson());
    return response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final response = await _api.delete('$endpoint/$id');
    return response.statusCode == 200;
  }
}
