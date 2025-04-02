import 'dart:convert';
import '../models/transfer_model.dart';
import 'api_service.dart';

class TransferService {
  final ApiService _api = ApiService();

  Future<List<Transfer>> getAll() async {
    final res = await _api.get('/transfers');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Transfer.fromJson(e)).toList();
    }
    throw Exception('Error al obtener traslados');
  }

  Future<bool> create(Transfer transfer) async {
    final res = await _api.post('/transfers', transfer.toJson());
    return res.statusCode == 201;
  }
}
