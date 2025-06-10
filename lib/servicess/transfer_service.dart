import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/transfer_model.dart';

class TransferService {
  final String baseUrl = '$apiUrl/api/transfers';

  Future<List<Transfer>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['postgres'];
      return data.map((e) => Transfer.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener traslados');
    }
  }

  Future<Transfer> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Transfer.fromJson(body);
    } else {
      throw Exception('Error al obtener traslado');
    }
  }

  Future<void> create(Transfer transfer) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(transfer.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return;
  }

  if (response.statusCode == 500 &&
      (response.body.contains('not found') ||
       response.body.contains('MongoDB') ||
       response.body.contains('llave duplicada') || 
       response.body.contains('pkey'))) {
    return;
  }

  throw Exception('Error al registrar traslado: ${response.body}');
}
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
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar traslado');
    }
  }
}
