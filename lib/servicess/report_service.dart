import 'dart:convert';
import 'package:sistema_animales/servicess/api_service.dart';

class ReportService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> _getData(String endpoint) async {
    final res = await _api.get(endpoint);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded is Map && decoded.containsKey('postgres')) {
        return Map<String, dynamic>.from(decoded['postgres']);
      }
    }
    return {};
  }

  Future<Map<String, dynamic>> getBySpecies() =>
      _getData('/api/reportes/por-especie');

  Future<Map<String, dynamic>> getByType() =>
      _getData('/api/reportes/por-tipo');

  Future<Map<String, dynamic>> getLiberationsPerMonth() =>
      _getData('/api/reportes/liberaciones-por-mes');

  Future<Map<String, dynamic>> getEvaluationsPerAnimal() =>
      _getData('/api/reportes/evaluaciones-por-animal');

  Future<Map<String, dynamic>> getTransfersPerAnimal() =>
      _getData('/api/reportes/traslados-por-animal');
}
