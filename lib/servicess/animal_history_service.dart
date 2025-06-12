import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/animal_historial_model.dart';

class AnimalHistoryService {
  final String baseUrl = '$apiUrl/api/historico';

  Future<AnimalHistorial> getHistorialPorNombre(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/por-nombre/$nombre'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['postgres'] != null) {
        return AnimalHistorial.fromJson(body['postgres']);
      } else {
        throw Exception('La respuesta no contiene datos válidos.');
      }
    } else {
      throw Exception('Error al obtener historial del animal');
    }
  }
}
