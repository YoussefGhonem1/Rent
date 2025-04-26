import 'package:flutter/material.dart';
import 'package:rento/admin/home_admin.dart';
import 'package:rento/auth/register.dart';
import 'package:rento/crud.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../owner/home_owner.dart';
import '../valid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Crud _curd = Crud();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool isloading = false;
  late final String? Function(String?) val;

  login() async {
    isloading = true;
    setState(() {});
    var response = await _curd.postRequest(linkLogin, {
      "email": emailController.text,
      "password": passwordController.text,
    });
    isloading = false;
    setState(() {});
    if (response['status'] == "success") {
      sharedPref.setString("id", response['data']['id'].toString());
      sharedPref.setString("username", response['data']['username']);
      sharedPref.setString("email", response['data']['email']);
      sharedPref.setString("type", response['data']['type'].toString());
      sharedPref.getString("type") == "admin"
          ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeAdmin()),
          )
          : Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeOwner()),
          );
    } else {
      print("****fail***");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child:
            isloading == true
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "مرحبًا بعودتك",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "قم بتسجيل الدخول لمواصلة رحلتك الصيفية",
                        style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        validator: (val) {
                          return validInput(val!, 3, 30);
                        },
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "بريد إلكتروني",
                          labelStyle: TextStyle(color: Colors.teal[900]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (val) {
                          return validInput(val!, 3, 30);
                        },
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "كلمة المرور",
                          labelStyle: TextStyle(color: Colors.teal[900]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.teal[900]),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 120,
                          ),
                        ),
                        onPressed: () async {
                          await login();
                        },
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "ليس لديك حساب؟ سجل الآن",
                          style: TextStyle(
                            color: Colors.teal[900],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
