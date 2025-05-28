import 'package:rento/crud.dart';
import 'package:rento/features/auth/data/models/user_model_register.dart';
import 'package:rento/linkapi.dart';

class RegisterRemoteDataSource {
  final Crud crud;

  RegisterRemoteDataSource(this.crud);

  Future<Map<String, dynamic>?> register(UserModelRegister user) async {
    try {
      // تحويل القيم إلى String لتطابق النوع المطلوب
      final data = user.toJson().map((key, value) => MapEntry(key, value.toString()));
      
      // إرسال الطلب
      final response = await crud.postRequest(linkRegister, data);
      
      return response;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }
}
