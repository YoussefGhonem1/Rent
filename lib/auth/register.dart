import 'package:flutter/material.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../valid.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Crud _crud = Crud();
  GlobalKey<FormState> formstate = GlobalKey();
  bool isloading = false;
  late final String? Function(String?) val;
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String? selectedRole;

  register() async {
    isloading = true;
    setState(() {});

    try {
      var response = await _crud.postRequest(linkRegister, {
        "username": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "type": selectedRole!,
      });

      isloading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print("Registration failed");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      isloading = false;
      setState(() {});
      print("Exception occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body:
          isloading == true
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "إنشاء حسابك",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "انضم إلينا لتجربة صيفية لا نهاية لها",
                        style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: nameController,
                        validator: (val) {
                          return validInput(val!, 3, 30);
                        },

                        decoration: InputDecoration(
                          labelText: "الاسم الكامل",
                          labelStyle: TextStyle(color: Colors.teal[900]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: emailController,
                        validator: (val) {
                          return validInput(val!, 3, 30);
                        },
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
                        controller: passwordController,
                        validator: (val) {
                          return validInput(val!, 3, 30);
                        },
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
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'owner',
                                groupValue: selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRole = value!;
                                  });
                                },
                                activeColor: Colors.teal[900],
                              ),
                              Text('مالك' , style: TextStyle( color: Colors.teal[900])),
                              SizedBox(width: 20),
                              Radio<String>(
                                value: 'renter',
                                groupValue: selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRole = value!;
                                  });
                                },
                                activeColor: Colors.teal[900],
                              ),
                              Text('مستأجر' , style: TextStyle( color: Colors.teal[900])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                            horizontal: 150,
                          ),
                        ),
                        onPressed: () async {
                          await register();
                        },
                        child: Text(
                          "سجل",
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
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "هل لديك حساب بالفعل؟ تسجيل الدخول",
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
