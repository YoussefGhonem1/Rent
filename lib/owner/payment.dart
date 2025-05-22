/* 
 
 
  Future<void> initiatePaymobPayment(double amount) async {
    try {
      // 1️⃣ الحصول على `auth_token`
      var tokenResponse = await http.post(
        Uri.parse("https://accept.paymob.com/api/auth/tokens"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"api_key": paymobApiKey}),
      );

      var tokenData = jsonDecode(tokenResponse.body);
      String token = tokenData['token'];

      // 2️⃣ إنشاء الطلب `order_id`
      var orderResponse = await http.post(
        Uri.parse("https://accept.paymob.com/api/ecommerce/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "auth_token": token,
          "delivery_needed": false,
          "amount_cents": (amount * 100).toInt().toString(),
          "currency": "EGP",
          "items": [],
        }),
      );

      var orderData = jsonDecode(orderResponse.body);
      String orderId = orderData['id'].toString();

      // 3️⃣ إنشاء `payment_key`
      var paymentKeyResponse = await http.post(
        Uri.parse("https://accept.paymob.com/api/acceptance/payment_keys"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "auth_token": token,
          "amount_cents": (amount * 100).toInt().toString(),
          "expiration": 3600,
          "order_id": orderId,
          "currency": "EGP",
          "integration_id": paymobIntegrationId,
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

      var paymentKeyData = jsonDecode(paymentKeyResponse.body);
      String paymentToken = paymentKeyData['token'];

      // 4️⃣ فتح رابط الدفع في المتصفح
      String paymentUrl =
          "https://accept.paymob.com/api/acceptance/iframes/903674?payment_token=$paymentToken";
      launch(paymentUrl);
    } catch (e) {
      print("❌ خطأ أثناء الدفع: $e");
    }
  }

  Future<void> processPayment(PaymentMethod method, double totalAmount) async {
    double depositPercentage =
        method == PaymentMethod.cashOnDelivery ? 0.1 : 1.0;
    double depositAmount = totalAmount * depositPercentage;

    try {
      if (method == PaymentMethod.online) {
        await initiatePaymobPayment(depositAmount);
      } else {
        print("✅ الدفع عند الاستلام: تحويل $depositAmount L.E");
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ تمت عملية الدفع بنجاح")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشلت عملية الدفع: ${e.toString()}")),
      );
    }
  }

  Widget _showPaymentOptionsDialog(
    String propertyId,
    DateTime start,
    DateTime end,
    double totalPrice,
  ) {
    return AlertDialog(
      backgroundColor: Colors.teal[900],
      title: Center(
        child: Text(
          "اختر طريقة الدفع",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.teal[50],
          ),
        ),
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "الدفع الإلكتروني",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal[50],
                ),
              ),
              subtitle: Text(
                "المبلغ الإجمالي: ${totalPrice.toStringAsFixed(2)} ج.م",
                style: TextStyle(fontSize: 16, color: Colors.teal[50]),
              ),
              onTap: () async {
                Navigator.pop(context);
                await processPayment(PaymentMethod.online, totalPrice);
                await bookProperty(propertyId, start, end);
              },
            ),
            const Divider(color: Colors.white54, height: 10),
            ListTile(
              title: Text(
                "الدفع عند الاستلام",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal[50],
                ),
              ),
              subtitle: Text(
                "المبلغ المطلوب: ${(totalPrice * 0.1).toStringAsFixed(2)} ج.م",
                  style: TextStyle( fontSize: 16, color: Colors.teal[50],),
              ),
              onTap: () async {
                Navigator.pop(context);
                await processPayment(PaymentMethod.cashOnDelivery, totalPrice);
                await bookProperty(propertyId, start, end);
              },
            ),
          ],
        ),
      ),
    );
  }
 */

///////////////////////////////////////////////
/*  // ✅ التحقق من التداخل مع الحجوزات الحالية
$stmt = $con->prepare("SELECT COUNT(*) FROM `reservations` 
                      WHERE `property_id` = ? 
                      AND ((`start_date` BETWEEN ? AND ?) 
                      OR (`end_date` BETWEEN ? AND ?) 
                      OR (`start_date` <= ? AND `end_date` >= ?))");
$stmt->execute([$property_id, $start_date, $end_date, $start_date, $end_date, $start_date, $end_date]); */

/* // ✅ تحديث العقار ليكون محجوزًا حتى نهاية آخر حجز
$stmt = $con->prepare("UPDATE `properties` SET `property_state` = 'booked', `available_date` = ? WHERE `id` = ?");
$stmt->execute([$end_date, $property_id]); */