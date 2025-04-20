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
          "type": selectedRole!
        });

        isloading = false;
        setState(() {});

        if (response != null && response['status'] == "success") {
         
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          print("Registration failed");
          print("Response Body: ${response.body}");
        }
      } catch (e) {
        isloading = false;
        setState(() {});
        print("Exception occurred: $e" );
      }
   

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: isloading == true
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Join us for an endless summer experience!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: nameController,
                      validator: (val) {
                        return validInput(val!, 3, 30);
                      },
                      
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      validator: (val) {
                        return validInput(val!, 3, 30);
                      },
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
                      controller: passwordController,
                      validator: (val) {
                        return validInput(val!, 3, 30);
                      },
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'type',
                        labelStyle: TextStyle(
                          color: Colors.blue, // Label color
                          fontWeight: FontWeight.bold,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16), // Padding inside the dropdown
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                          borderSide: BorderSide(
                            color: Colors.blue, // Border color
                            width: 2, // Border width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green, // Border color when focused
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16, // Text size in the dropdown
                        color: Colors.black, // Text color
                      ),
                      dropdownColor:
                          Colors.white, // Background color of dropdown options
                      items: [
                        DropdownMenuItem(
                          value: 'owner',
                          child: Text(
                            'Owner',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'renter',
                          child: Text(
                            'Renter',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
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
                        await register();
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        "Already have an account? Login",
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
