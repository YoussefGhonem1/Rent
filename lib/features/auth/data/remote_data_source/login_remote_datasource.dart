import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model_login.dart';

abstract class LoginRemoteDataSource {
  Future<UserModelLogin?> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements LoginRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModelLogin?> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('YOUR_API_ENDPOINT_HERE'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return UserModelLogin.fromJson(data['data']);
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to login');
    }
  }
}
