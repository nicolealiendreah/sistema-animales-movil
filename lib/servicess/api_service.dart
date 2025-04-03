import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';

class ApiService {
  final String baseUrl = apiUrl;


  /// GET: Obtener datos desde la API
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url);
  }

  /// POST: Enviar datos para crear un recurso
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  /// PUT: Actualizar un recurso existente
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  /// DELETE: Eliminar un recurso
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url);
  }
}
