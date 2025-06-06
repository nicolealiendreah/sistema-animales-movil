import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
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

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (imageFile != null) {
      final extension = imageFile.path.split('.').last.toLowerCase();
      const allowed = ['jpg', 'jpeg', 'png', 'gif'];

      if (!allowed.contains(extension)) {
        throw Exception('Extensión de archivo no válida: .$extension');
      }

      final bytes = await imageFile.readAsBytes();

      request.files.add(http.MultipartFile.fromBytes(
        'imagen',
        bytes,
        filename: 'animal_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) return true;

    final error = await response.stream.bytesToString();
    print('Error al crear animal: $error');
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
