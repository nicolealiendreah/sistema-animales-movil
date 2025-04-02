import 'dart:convert';
import '../models/adoption_model.dart';
import 'api_service.dart';

class AdoptionService {
  final ApiService _api = ApiService();

  Future<List<Adoption>> getAll() async {
    final res = await _api.get('/adoptions');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Adoption.fromJson(e)).toList();
    }
    throw Exception('Error al obtener adopciones');
  }

  Future<bool> create(Adoption adoption) async {
    final res = await _api.post('/adoptions', adoption.toJson());
    return res.statusCode == 201;
  }
}
