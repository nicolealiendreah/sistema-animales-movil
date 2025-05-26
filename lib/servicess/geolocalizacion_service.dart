import 'dart:convert';
import 'package:sistema_animales/models/geolocalizacion_model.dart';
import 'package:sistema_animales/servicess/api_service.dart';

class GeolocalizacionService {
  final ApiService _apiService = ApiService();
  final String endpoint = '/geolocalizaciones'; 

  Future<List<Geolocalizacion>> getAll() async {
    final response = await _apiService.get(endpoint);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Geolocalizacion.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener geolocalizaciones');
    }
  }

  Future<bool> create(Geolocalizacion geo) async {
    final response = await _apiService.post(endpoint, geo.toJson());
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> delete(String id) async {
    final response = await _apiService.delete('$endpoint/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> update(String id, Geolocalizacion geo) async {
    final response = await _apiService.put('$endpoint/$id', geo.toJson());
    return response.statusCode == 200;
  }

  Future<Geolocalizacion> getById(String id) async {
    final response = await _apiService.get('$endpoint/$id');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Geolocalizacion.fromJson(data);
    } else {
      throw Exception('No se encontró la geolocalización');
    }
  }
}
