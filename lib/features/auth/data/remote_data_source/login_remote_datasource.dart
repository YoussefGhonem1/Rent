
import 'package:rento/crud.dart';
import 'package:rento/linkapi.dart';

import '../models/user_model_login.dart';
// تأكد من المسار الصحيح

 
class LoginRemoteDataSource   {
  final Crud crud;

  LoginRemoteDataSource(this.crud);

  @override
  Future<UserModelLogin?> login(String email, String password) async {
    try {
      final response = await crud.postRequest(
        linkLogin,
        {
          'email': email,
          'password': password,
        },
      );

      if (response != null && response['status'] == 'success') {
        return UserModelLogin.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Login Exception: $e');
      return null;
    }
  }
}
