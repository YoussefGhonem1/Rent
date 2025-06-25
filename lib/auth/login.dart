import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rento/admin/home_admin.dart';
import 'package:rento/auth/register.dart';
import 'package:rento/crud.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart'; // تأكد إن ده فيه الـ sharedPref
import '../owner/home_owner.dart';
import '../valid.dart'; // ملف الـ validation functions

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Crud _crud = Crud(); // تم تصحيح الاسم من _curd إلى _crud
  GlobalKey<FormState> formstate = GlobalKey(); // إضافة GlobalKey للفورم

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isloading = false;
  String? _errorMessage; // لإضافة رسائل الخطأ

  // هذا السطر لم يعد ضروريا هنا ويمكن حذفه
  // late final String? Function(String?) val;

  login() async {
    // التحقق من صحة المدخلات قبل إرسال الطلب
    if (formstate.currentState!.validate()) {
      _errorMessage = null; // إزالة أي رسائل خطأ سابقة
      isloading = true;
      setState(() {});

      try {
        var response = await _crud.postRequest(linkLogin, {
          "email": emailController.text,
          "password": passwordController.text,
        });

        isloading = false;
        setState(() {});

        if (response != null && response['status'] == "success") {
          // حفظ بيانات المستخدم في Shared Preferences
          sharedPref.setString("id", response['data']['id'].toString());
          sharedPref.setString("username", response['data']['username']);
          sharedPref.setString("email", response['data']['email']);
          sharedPref.setString("type", response['data']['type'].toString());
          sharedPref.setString("balance", response['data']['balance']);
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && sharedPref.getString("id") != null) {
            await _crud.postRequest(linkUpdateUserFcmToken, {
              "user_id": sharedPref.getString("id")!,
              "fcm_token": fcmToken,
            });
            print("FCM Token sent to backend: $fcmToken");
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "تم تسجيل الدخول بنجاح!"),
            ),
          );

          // التوجيه بناءً على نوع المستخدم
          if (sharedPref.getString("type") == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeAdmin(),
              ), // استخدام const مع الـ Widget
            );
          } else if (sharedPref.getString("type") == "owner" ||
              sharedPref.getString("type") == "renter") {
            // ممكن تضيف هنا تحقق لو فيه أنواع تانية غير owner عشان يروح على home_owner
            // أو تعمل HomeRenter لو ليها شاشة مختلفة
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeOwner(),
              ), // استخدام const مع الـ Widget
            );
          } else {
            // لو نوع المستخدم غير معروف أو لم يتم إرجاعه بشكل صحيح
            setState(() {
              _errorMessage =
                  "نوع المستخدم غير معروف. يرجى الاتصال بالدعم الفني.";
            });
          }
        } else {
          // لو الـ status مش "success" يبقى فيه خطأ
          String message =
              "فشل تسجيل الدخول. يرجى التأكد من البريد وكلمة المرور.";
          if (response != null && response['message'] != null) {
            message =
                response['message']; // استخدام الرسالة اللي جاية من الباك إند
          }
          setState(() {
            _errorMessage = message;
          });
          print("Login failed: $message");
          print(
            "Response Body: $response",
          ); // طباعة الـ response بالكامل للمراجعة
        }
      } catch (e) {
        isloading = false;
        setState(() {});
        setState(() {
          _errorMessage = "حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.";
        });
        print("Exception occurred: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child:
            isloading == true
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // استخدام const هنا
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    // إضافة Form Widget
                    key: formstate, // ربط الـ GlobalKey
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
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.teal[900],
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: emailController,
                          validator: (val) {
                            // تحسين الـ validation للبريد الإلكتروني
                            if (val == null || val.isEmpty) {
                              return "البريد الإلكتروني مطلوب";
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return "صيغة بريد إلكتروني غير صحيحة";
                            }
                            return validInput(val, 3, 50); // استخدم valid.dart
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
                          obscureText: true,
                          validator: (val) {
                            return validInput(
                              val!,
                              6,
                              30,
                            ); // يفضل 6 أحرف على الأقل للباسورد
                          },
                          decoration: InputDecoration(
                            labelText: "كلمة المرور",
                            labelStyle: TextStyle(color: Colors.teal[900]),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.teal[900],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // عرض رسالة الخطأ هنا لو فيه
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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
                            // استدعاء دالة login بعد التحقق من الفورم
                            await login();
                          },
                          child: const Text(
                            // استخدام const
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
                                builder:
                                    (context) =>
                                        RegisterScreen(), // استخدام const
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
      ),
    );
  }
}
