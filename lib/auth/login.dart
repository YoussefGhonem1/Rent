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
    var response = await _curd.postRequest(linkLogin,
        {"email": emailController.text, "password": passwordController.text});
    isloading = false;
    setState(() {});
    if (response['status'] == "success") {
      sharedPref.setString("id", response['data']['id'].toString());
      sharedPref.setString("username", response['data']['username']);
      sharedPref.setString("email", response['data']['email']);
      sharedPref.setString("type", response['data']['type'].toString());
      sharedPref.getString("type") == "admin"
          ? Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeAdmin()))
          : Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeOwner()));
    } else {
      print("****fail***");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: isloading == true
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Login to continue your summer journey.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      validator: (val) {
                        return validInput(val!, 3, 30);
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.orange),
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
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 50),
                      ),
                      onPressed: () async {
                        await login();
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
