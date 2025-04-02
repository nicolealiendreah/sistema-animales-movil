import 'dart:convert';
import '../models/evaluation_model.dart';
import 'api_service.dart';

class EvaluationService {
  final ApiService _api = ApiService();

  Future<List<Evaluation>> getAll() async {
    final res = await _api.get('/evaluations');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Evaluation.fromJson(e)).toList();
    }
    throw Exception('Error al obtener evaluaciones');
  }

  Future<bool> create(Evaluation evaluation) async {
    final res = await _api.post('/evaluations', evaluation.toJson());
    return res.statusCode == 201;
  }
}
