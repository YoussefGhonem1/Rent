// 📦 import packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../crud.dart';
import 'package:rento/linkapi.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart'; 

class PaymentPage extends StatefulWidget {
  final double amount;
  final String reservationId; 
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentFailed;

  const PaymentPage({
    super.key,
    required this.amount,
     required this.reservationId,   
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // 🔐 Paymob credentials
  final String apiKey =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBeU56UTNNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5pVkxBTThQOGJpYzB5YVk0S2x6dkYxZWpCWTVMWkczel9oWTF6d1daYlFDZ0dVSGtuR2s1MmpfbG1kQlFPbXJ5dlFlQXk0UlNZYUJMQ19PN2Z0WXVqUQ==";
  final String integrationId = "5001272";
  final String iframeId = "903674";
  final Crud _crud = Crud();
  String order_id = "";

  bool _loading = true;
  String? _paymentUrl;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    initiatePayment(widget.amount);
  }

  Future<void> checkPaymentStatus(String id) async {
    var response = await _crud.postRequest(linkCheckPaymentStatus, {
      'order_id': id,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['paid']) {
        widget.onPaymentSuccess();
      } else {
        widget.onPaymentFailed();
      }
    }
  }

  Future<void> initiatePayment(double amount) async {
    try {
      // 1️⃣ Get auth token
      var authRes = await http.post(
        Uri.parse("https://accept.paymob.com/api/auth/tokens"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"api_key": apiKey}),
      );
      final token = jsonDecode(authRes.body)['token'];

      // 2️⃣ Create order
      var orderRes = await http.post(
        Uri.parse("https://accept.paymob.com/api/ecommerce/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "auth_token": token,
          "delivery_needed": false,
          "amount_cents": (amount * 100).toInt().toString(),
          "currency": "EGP",
           "merchant_order_id": widget.reservationId,
          "items": [],
        }),
      );
      final orderId = jsonDecode(orderRes.body)['id'];
      order_id = orderId.toString();

      // 3️⃣ Get payment key
      var keyRes = await http.post(
        Uri.parse("https://accept.paymob.com/api/acceptance/payment_keys"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "auth_token": token,
          "amount_cents": (amount * 100).toInt().toString(),
          "expiration": 3600,
          "order_id": orderId,
          "currency": "EGP",
          "integration_id": integrationId,
          "billing_data": {
            "first_name": "Test",
            "last_name": "User",
            "email": "test@example.com",
            "phone_number": "01000000000",
            "apartment": "NA",
            "floor": "NA",
            "street": "NA",
            "building": "NA",
            "shipping_method": "NA",
            "postal_code": "NA",
            "city": "Cairo",
            "state": "Cairo",
            "country": "EG",
          },
        }),
      );

      final paymentToken = jsonDecode(keyRes.body)['token'];

      // 4️⃣ Build payment URL
      final url =
          "https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentToken";

      setState(() {
        _paymentUrl = url;
        _loading = false;
      });
    } catch (e) {
      widget.onPaymentFailed();
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: Text(
          "الدفع الإلكتروني",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal[50],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[50]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _paymentUrl != null
              ? WebViewWidget(
                controller:
                    WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onNavigationRequest: (request) {
                            if (request.url.contains("success")) {
                              checkPaymentStatus(order_id);
                              return NavigationDecision
                                  .prevent; // منع تحميل الصفحة لتجنب إغلاق الويب في
                            } else if (request.url.contains("fail")) {
                              widget.onPaymentFailed();
                              Navigator.pop(context);
                            }
                            return NavigationDecision.navigate;
                          },
                        ),
                      )
                      ..loadRequest(Uri.parse(_paymentUrl!)),
              )
              : const Center(child: Text("فشل إنشاء رابط الدفع")),
    );
  }
}
