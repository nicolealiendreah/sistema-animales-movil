import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistema_animales/models/veterinarian_model.dart';
import 'package:sistema_animales/core/env.dart';

class VeterinarioService {
  final String baseUrl = '$apiUrl/api/veterinarios';

  Future<List<Veterinario>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['postgres'];
      return data.map((e) => Veterinario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener veterinarios');
    }
  }

  Future<void> create(Veterinario veterinario, {XFile? imageFile}) async {
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    final Map<String, dynamic> data = veterinario.toJson();
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
        filename: 'veterinario_${DateTime.now().millisecondsSinceEpoch}.$extension',
        contentType: MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
      ));
    }

    final response = await request.send();

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = await response.stream.bytesToString();
      throw Exception('Error al registrar veterinario: $error');
    }
  }

  Future<void> update(String id, Veterinario v) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(v.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar veterinario');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar veterinario');
    }
  }
}
