import 'dart:convert';
import '../models/rescuer_model.dart';
import 'api_service.dart';

class RescuerService {
  final ApiService _api = ApiService();

  Future<List<Rescuer>> getAll() async {
    final res = await _api.get('/rescatistas');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Rescuer.fromJson(e)).toList();
    }
    throw Exception('Error al obtener rescatistas');
  }

  Future<bool> create(Rescuer rescuer) async {
    final res = await _api.post('/rescatistas', rescuer.toJson());
    return res.statusCode == 201;
  }

  Future<bool> delete(String id) async {
    final res = await _api.delete('/rescatistas/$id');
    return res.statusCode == 200;
  }
}
