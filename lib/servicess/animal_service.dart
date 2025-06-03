import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../core/env.dart';
import '../models/animal_rescatista_model.dart';

class AnimalService {
  final String baseUrl = '$apiUrl/api/animales';

  Future<List<AnimalRescatista>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final postgres = body['postgres'];

      if (postgres is List) {
        return postgres
            .map((registro) =>
                AnimalRescatista.fromJson(registro as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Formato inesperado en la respuesta');
      }
    } else {
      throw Exception(
          'Error al obtener animales - Status: ${response.statusCode}');
    }
  }

  Future<AnimalRescatista> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return AnimalRescatista.fromJson(body['postgres']);
    } else {
      throw Exception('Error al obtener animal');
    }
  }

  Future<bool> create(Map<String, dynamic> data, {XFile? imageFile}) async {
  final uri = Uri.parse(baseUrl);
  final request = http.MultipartRequest('POST', uri);

  print('Enviando campos:');
  data.forEach((key, value) {
    if (value != null) {
      print('$key: $value');
      request.fields[key] = value.toString();
    }
  });

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'imagen',
      imageFile.path,
      filename: basename(imageFile.path),
    ));
  }

  final response = await request.send();

  if (response.statusCode == 201) return true;

  final error = await response.stream.bytesToString();
  print('❌ Error al crear animal: $error');
  return false;
}


  Future<void> update(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar animal');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar animal');
    }
  }
}
