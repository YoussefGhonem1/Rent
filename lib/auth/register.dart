import 'package:flutter/material.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../valid.dart';
import 'login.dart';

// (باقي الكود زي ما هو)

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Crud _crud = Crud();
  GlobalKey<FormState> formstate = GlobalKey(); // نحتاجها للتحقق من الـ validators
  bool isloading = false;
  // late final String? Function(String?) val; // هذا السطر لم يعد ضروريا هنا ويمكن حذفه
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String? selectedRole;

  // هنا هنضيف متغير عشان نعرض رسائل الخطأ
  String? _errorMessage;

  register() async {
    // التحقق من صحة المدخلات باستخدام الـ GlobalKey
    if (formstate.currentState!.validate() && selectedRole != null) {
      _errorMessage = null; // إعادة تعيين رسالة الخطأ قبل البدء
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
          // هنا ممكن تعرض رسالة نجاح بسيطة للمستخدم قبل الانتقال
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "تم التسجيل بنجاح!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // لو الـ status مش "success" يبقى فيه خطأ
          String message = "فشل التسجيل. حاول مرة أخرى.";
          if (response != null && response['message'] != null) {
            message = response['message']; // استخدم الرسالة اللي جاية من الباك إند
          }
          setState(() {
            _errorMessage = message;
          });
          print("Registration failed: $message");
          print("Response Body: $response"); // طباعة الـ response بالكامل للمراجعة
        }
      } catch (e) {
        isloading = false;
        setState(() {});
        setState(() {
          _errorMessage = "حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.";
        });
        print("Exception occurred: $e");
      }
    } else if (selectedRole == null) {
      setState(() {
        _errorMessage = "الرجاء اختيار نوع الحساب (مالك أو مستأجر).";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: isloading == true
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Form( // نضيف الـ Form Widget هنا عشان نستخدم الـ GlobalKey
                  key: formstate, // ربط الـ GlobalKey بالـ Form
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
                        // إضافة validator للبريد الإلكتروني للتحقق من الفورمات
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "البريد الإلكتروني مطلوب";
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return "صيغة بريد إلكتروني غير صحيحة";
                          }
                          return validInput(val, 3, 50); // ممكن تعدل الطول الأقصى للبريد
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
                          return validInput(val!, 6, 30); // يفضل كلمة المرور تكون 6 أحرف على الأقل
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
                      // إضافة حقل تأكيد كلمة المرور
                      TextFormField(
                        controller: confirmController,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "تأكيد كلمة المرور مطلوب";
                          }
                          if (val != passwordController.text) {
                            return "كلمة المرور غير متطابقة";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "تأكيد كلمة المرور",
                          labelStyle: TextStyle(color: Colors.teal[900]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock_reset, color: Colors.teal[900]),
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
                              Text('مالك', style: TextStyle(color: Colors.teal[900])),
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
                              Text('مستأجر', style: TextStyle(color: Colors.teal[900])),
                            ],
                          ),
                        ],
                      ),
                      // عرض رسالة الخطأ هنا لو فيه
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
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
                          // تأكد إن الفورم كله valid قبل ما تبعت الداتا
                          if (formstate.currentState!.validate()) {
                            await register();
                          } else if (selectedRole == null) {
                            setState(() {
                              _errorMessage = "الرجاء اختيار نوع الحساب (مالك أو مستأجر).";
                            });
                          }
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
            ),
    );
  }
}