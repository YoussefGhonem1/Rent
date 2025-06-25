import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart'; // ✅ استيراد Flushbar

// ... (باقي كود _RealEstateDetailsPageState)

// دالة مساعدة لعرض رسائل احترافية
void showCustomMessage(BuildContext context, String message, {bool isSuccess = true}) {
  Flushbar(
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 16),
      textAlign: TextAlign.center,
    ),
    icon: Icon(
      isSuccess ? Icons.check_circle_outline : Icons.error_outline,
      size: 28.0,
      color: Colors.white,
    ),
    backgroundColor: isSuccess ? Colors.teal[700]! : Colors.red[700]!, // لون بناءً على النجاح/الفشل
    duration: Duration(seconds: 3), // مدة ظهور الرسالة
    borderRadius: BorderRadius.circular(8), // زوايا دائرية
    margin: EdgeInsets.all(8), // هامش من الحواف
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // حشو داخلي
    flushbarPosition: FlushbarPosition.TOP, // ظهور في الأعلى
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: Offset(0, 2),
        blurRadius: 4,
      )
    ],
  )..show(context);
}