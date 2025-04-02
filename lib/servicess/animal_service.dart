import 'dart:convert';
import '../models/animal_model.dart';
import 'api_service.dart';

class AnimalService {
  final ApiService _api = ApiService();

  Future<List<Animal>> getAll() async {
    final res = await _api.get('/animals');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Animal.fromJson(e)).toList();
    }
    throw Exception('Error al obtener animales');
  }

  Future<bool> create(Animal animal) async {
    final res = await _api.post('/animals', animal.toJson());
    return res.statusCode == 201;
  }

  Future<bool> update(String id, Animal animal) async {
    final res = await _api.put('/animals/$id', animal.toJson());
    return res.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/animals/$id');
    return res.statusCode == 200;
  }
}
