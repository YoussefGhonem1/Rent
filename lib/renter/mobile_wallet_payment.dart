// 📦 import packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../crud.dart'; // تأكد أن هذا المسار صحيح
import 'package:rento/linkapi.dart'; // تأكد أن هذا المسار صحيح
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart'; 

class MobileWalletPaymentPage extends StatefulWidget {
  final double amount;
  final String reservationId; 
  final String propertyId;
  final VoidCallback onPaymentSuccess; 
  final VoidCallback onPaymentFailed;   

  const MobileWalletPaymentPage({
    super.key,
    required this.amount,
    required this.reservationId,   
    required this.propertyId, // إذا كنت تحتاجه في المستقبل
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<MobileWalletPaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<MobileWalletPaymentPage> {
  final String apiKey =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBeU56UTNNaXdpYm1GdFpTSTZJakUzTlRBMU5EVTVPVEV1T1RNek5UQXlJbjAuaE9XN1JhbzVDb2NSZjZ6SkRfQ3BBM1B3STBpV0Y2dVRqcDI3Ym92NTFBTmZJTmdjX092WTBUV1ZTY1hLdlNHRm1QSGFaSzZpYVV6dVk0dEYxdER5YUE="; 
  final String integrationId = "5148358"; 
  final String iframeId = "933499"; 

  final Crud _crud = Crud(); 

  bool _loading = true;
  String? _paymentUrl;
  late WebViewController _webViewController;

  String? _paymobOrderId; 
  String? _paymobIntegrationIdUsedForOrder; 

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
    initiatePayment(widget.amount);
  }
 Future<void> orderActivate() async {
    try {
      var response = await _crud.postRequest(linkCheckPaymentStatus, {
        'reservation_id':  widget.reservationId,
        'property_id':  widget.propertyId,
      });
    } catch (e) {
      print("Error fetching reservations: $e");
    
    }
  }
  
  Future<void> initiatePayment(double amount) async {
    try {
      print("DEBUG: Starting Paymob payment initiation for amount: $amount, Reservation ID: ${widget.reservationId}");

      // ✅ الخطوة 0: التحقق مما إذا كان هناك Paymob order ID موجود بالفعل للحجز ده
      var checkOrderIdResponse = await _crud.postRequest(linkGetPaymobOrderId, {
        "reservation_id": widget.reservationId,
      });

      print("DEBUG: Check Existing Paymob Order ID Status: ${checkOrderIdResponse['status']}");
      print("DEBUG: Check Existing Paymob Order ID Message: ${checkOrderIdResponse['message']}");

      // ✅ تعديل الشرط لجلب paymob_integration_id_usedForOrder أيضاً
      if (checkOrderIdResponse['status'] == "success" && 
          checkOrderIdResponse['paymob_order_id'] != null && 
          checkOrderIdResponse['paymob_integration_id_used'] != null) { // ✅ التأكد من وجود الـ integration_id_used
        _paymobOrderId = checkOrderIdResponse['paymob_order_id'];
        _paymobIntegrationIdUsedForOrder = checkOrderIdResponse['paymob_integration_id_used']; // ✅ تخزين الـ integration ID المستخدم
        print("DEBUG: Existing Paymob Order ID found: $_paymobOrderId with Integration ID: $_paymobIntegrationIdUsedForOrder. Reusing it.");
      } else {
        print("DEBUG: No existing Paymob Order ID or matching Integration ID found for reservation ${widget.reservationId}, will create a new one.");
        
        // 1️⃣ Get auth token
        var authRes = await http.post(
          Uri.parse("https://accept.paymob.com/api/auth/tokens"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"api_key": apiKey}),
        );
        
        print("DEBUG: Auth Token Request Status: ${authRes.statusCode}");
        print("DEBUG: Auth Token Request Body: ${authRes.body}");

        if (authRes.statusCode != 200 && authRes.statusCode != 201) {
          throw Exception("Failed to get auth token: ${authRes.body}");
        }
        final token = jsonDecode(authRes.body)['token'];
        if (token == null) {
          throw Exception("Auth token is null in response: ${authRes.body}");
        }
        print("DEBUG: Auth Token obtained: $token");

        var orderBody = jsonEncode({
          "auth_token": token,
          "delivery_needed": false,
          "amount_cents": (amount * 100).toInt().toString(),
          "currency": "EGP",
          "merchant_order_id":  "${widget.reservationId}_${DateTime.now().millisecondsSinceEpoch}", 
          "items": [
            {
              "name": "Reservation Payment",
              "amount_cents": (amount * 100).toInt().toString(),
              "description": "Payment for reservation ID: ${widget.reservationId}",
              "quantity": 1
            }
          ],
        });
        print("DEBUG: Order Creation Request Body: $orderBody");

        var orderRes = await http.post(
          Uri.parse("https://accept.paymob.com/api/ecommerce/orders"),
          headers: {"Content-Type": "application/json"},
          body: orderBody,
        );
        
        print("DEBUG: Order Creation Response Status: ${orderRes.statusCode}");
        print("DEBUG: Order Creation Response Body: ${orderRes.body}");

        if (orderRes.statusCode != 201) {
          throw Exception("Failed to create order: ${orderRes.body}");
        }
        _paymobOrderId = jsonDecode(orderRes.body)['id'].toString();
        if (_paymobOrderId == null) {
          throw Exception("Paymob Order ID is null in response: ${orderRes.body}");
        }
        print("DEBUG: New Paymob Order ID created: $_paymobOrderId");


        _paymobIntegrationIdUsedForOrder = integrationId; 
        
        var updateReservationPaymobOrderId = await _crud.postRequest(linkUpdatePaymobOrderId, {
          "reservation_id": widget.reservationId,
          "paymob_order_id": _paymobOrderId!,
          "paymob_integration_id_used": _paymobIntegrationIdUsedForOrder!, // ✅ تمرير الـ integration ID
        });
        print("DEBUG: Update Paymob Order ID in DB status: ${updateReservationPaymobOrderId['status']}");
        print("DEBUG: Update Paymob Order ID in DB message: ${updateReservationPaymobOrderId['message']}");
      }
      
      // 3️⃣ Get payment key
      var authResForPaymentKey = await http.post(
        Uri.parse("https://accept.paymob.com/api/auth/tokens"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"api_key": apiKey}),
      );
      if (authResForPaymentKey.statusCode != 200 && authResForPaymentKey.statusCode != 201) {
          throw Exception("Failed to get auth token for payment key: ${authResForPaymentKey.body}");
      }
      final currentAuthToken = jsonDecode(authResForPaymentKey.body)['token'];
      if (currentAuthToken == null) {
        throw Exception("Auth token is null before getting payment key.");
      }
      print("DEBUG: Auth Token re-obtained for payment key: $currentAuthToken");

      var paymentKeyBody = jsonEncode({
        "auth_token": currentAuthToken,
        "amount_cents": (amount * 100).toInt().toString(),
        "expiration": 3600,
        "order_id": int.parse(_paymobOrderId!), // استخدام الـ Paymob order ID المخزن
        "currency": "EGP",
        "integration_id": int.parse(_paymobIntegrationIdUsedForOrder!), // ✅ استخدام الـ integration ID المرتبط بالـ order
        "billing_data": {
          "first_name": "Test", // Replace with actual user data if available
          "last_name": "User",
          "email": "test@example.com", // Valid email is often required
          "phone_number": "01000000000", // Valid phone number
          "apartment": "NA", "floor": "NA", "street": "NA", "building": "NA",
          "shipping_method": "NA", "postal_code": "NA", "city": "Cairo",
          "state": "Cairo", "country": "EG",
        },
      });
      print("DEBUG: Payment Key Request Body: $paymentKeyBody");

      var keyRes = await http.post(
        Uri.parse("https://accept.paymob.com/api/acceptance/payment_keys"),
        headers: {"Content-Type": "application/json"},
        body: paymentKeyBody,
      );
      
      print("DEBUG: Payment Key Response Status: ${keyRes.statusCode}");
      print("DEBUG: Payment Key Response Body: ${keyRes.body}");
      
      if (keyRes.statusCode != 200 && keyRes.statusCode != 201) { 
        throw Exception("Failed to get payment key: ${keyRes.body}");
      }
      final paymentToken = jsonDecode(keyRes.body)['token'];
      if (paymentToken == null) {
        throw Exception("Payment Token is null in response: ${keyRes.body}");
      }
      print("DEBUG: Payment Token obtained: $paymentToken");

      // 4️⃣ Build payment URL
      // ✅ تم تعديل الـ URL هنا ليتناسب مع Iframe. تأكد من أن الجزء "accept.paymob.com" أو "paymob.com" صحيح لحسابك.
      final url =
          "https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentToken"; 
      print("DEBUG: Generated Payment URL: $url");

      setState(() {
        _paymentUrl = url;
        _loading = false;
      });

      // ✅ تهيئة الـ WebViewController وعرض الـ WebView
      _webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // يمكنك عرض مؤشر تحميل هنا
            },
            onPageStarted: (String url) {
              print('WebView Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('WebView Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView error: Code: ${error.errorCode}, Description: ${error.description}, U');
              widget.onPaymentFailed();
              Navigator.pop(context); // إغلاق الـ WebView عند الخطأ
            },
            onNavigationRequest: (request) {
              print('WebView Navigation request: ${request.url}');
              // Paymob redirects to specific URLs on success/failure
              // الـ webhook هو الذي سيحدث قاعدة البيانات. هنا فقط نخبر تطبيق Flutter.
              if (request.url.contains("success")) {
                print("Payment Success URL detected!");
                widget.onPaymentSuccess(); // إشعار للصفحة الأب بالنجاح
                orderActivate(); // ✅ استدعاء الدالة لتفعيل الطلب
                Navigator.pop(context); // إغلاق الـ WebView
                return NavigationDecision.prevent; // منع تحميل الصفحة
              } else if (request.url.contains("fail")) {
                print("Payment Failure URL detected!");
                widget.onPaymentFailed(); // إشعار للصفحة الأب بالفشل
                Navigator.pop(context); // إغلاق الـ WebView
                return NavigationDecision.prevent; // منع تحميل الصفحة
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_paymentUrl!));

    } catch (e) {
      print("ERROR: Caught error in initiatePayment: ${e.toString()}");
      widget.onPaymentFailed(); // إشعار بالفشل
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تهيئة الدفع: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text(
          "الدفع الإلكتروني",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[50]),
          onPressed: () {
            widget.onPaymentFailed(); // اعتبار العملية فاشلة إذا رجع المستخدم
            Navigator.pop(context);
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _paymentUrl != null
              ? WebViewWidget( // ✅ استخدام WebViewWidget هنا
                controller: _webViewController,
              )
              : const Center(child: Text("فشل إنشاء رابط الدفع")),
    );
  }
}