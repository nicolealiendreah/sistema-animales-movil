import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/transfer_model.dart';

class TransferService {
  final String baseUrl = '$apiUrl/api/transfers';

  /// Obtener todos los traslados desde SQL
  Future<List<Transfer>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['postgres']; // SQL
      return data.map((e) => Transfer.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener traslados');
    }
  }

  /// Obtener un traslado por ID
  Future<Transfer> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Transfer.fromJson(body);
    } else {
      throw Exception('Error al obtener traslado');
    }
  }

  /// Crear un nuevo traslado
  Future<void> create(Transfer transfer) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transfer.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar traslado');
    }
  }

  /// Actualizar un traslado existente
  Future<void> update(String id, Transfer transfer) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transfer.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar traslado');
    }
  }

  /// Eliminar un traslado
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar traslado');
    }
  }
}
