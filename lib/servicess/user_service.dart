import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<bool> login(String username, String password) async {
    final res = await _api.post('/login', {
      'username': username,
      'password': password,
    });
    return res.statusCode == 200;
  }

  Future<bool> register(User user) async {
    final res = await _api.post('/users', user.toJson());
    return res.statusCode == 201;
  }
}
