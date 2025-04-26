import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/utils/functions/get_location.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../main.dart';
import 'favorites.dart';

enum PaymentMethod { cashOnDelivery, online }

const String paymobApiKey =
    "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBeU56UTNNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5pVkxBTThQOGJpYzB5YVk0S2x6dkYxZWpCWTVMWkczel9oWTF6d1daYlFDZ0dVSGtuR2s1MmpfbG1kQlFPbXJ5dlFlQXk0UlNZYUJMQ19PN2Z0WXVqUQ==";
const String paymobIntegrationId = "5001272";

class RealEstateDetailsPage extends StatefulWidget {
  final List<String> images;
  final List<String> videos;
  List<int> favoriteProperties;
  final String id;
  final String owner_id;
  final bool fav;
  final String title;
  final String price;
  final String location;
  final String description;
  final String phone;
  late final String latitude;
  final String longitude;
  String state;
  final String floor_number;
  final String room_count;
  final String property_direction;
  final String rating;
  RealEstateDetailsPage({
    super.key,
    required this.id,
    required this.fav,
    required this.images,
    required this.videos,
    required this.favoriteProperties,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.phone,
    required this.rating,
    required this.state,
    required this.owner_id,
    required this.latitude,
    required this.longitude,
    required this.floor_number,
    required this.room_count,
    required this.property_direction,
  });

  @override
  State<RealEstateDetailsPage> createState() => _RealEstateDetailsPageState();
}

class _RealEstateDetailsPageState extends State<RealEstateDetailsPage> {
  String userBookingMessage = "";
  List<Map<String, dynamic>> userBookings = [];
  late ValueNotifier<String> stateNotifier;
  late List<VideoPlayerController> _videoControllers;
  late List<bool> _videoStatus; // Track whether video is playing or paused
  List<int> favoriteList = [];
  final Crud _crud = Crud();

  bool isOwnerOrAdmin(String userId, String propertyOwnerId) {
    // Check if the user is the owner of the property or an admin
    return userId == propertyOwnerId || sharedPref.getString("role") == "admin";
  }

  int calculateNumberOfDays(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  double calculateTotalPrice(int numberOfDays, double dailyPrice) {
    return numberOfDays * dailyPrice;
  }

  @override
  void initState() {
    super.initState();
    stateNotifier = ValueNotifier(widget.state);

    fetchPropertyState(); // جلب حالة العقار من الخادم
    checkUserBooking(); // جلب حجوزات المستخدم

    _videoControllers =
        widget.videos.map((videoUrl) {
          print("$linkVideoRoot/$videoUrl");
          final controller = VideoPlayerController.network(
              "$linkVideoRoot/$videoUrl",
            )
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(() {});
                  }
                })
                .catchError((error) {
                  print('Error initializing video: $error');
                });
          return controller;
        }).toList();
    _videoStatus = List.generate(widget.videos.length, (index) => false);
  }

  @override
  void dispose() {
    stateNotifier.dispose();

    super.dispose();
  }

  bool isFavorite(int propertyId) {
    return widget.favoriteProperties.contains(propertyId);
  }

  Future<void> toggleFavorite(int propertyId) async {
    var response = await _crud.postRequest(linkToggleFav, {
      "user_id": sharedPref.getString("id").toString(),
      "property_id": widget.id,
    });

    if (response['status'] == "success") {
      setState(() {
        if (response['action'] == "added") {
          widget.favoriteProperties.add(propertyId);
        } else {
          widget.favoriteProperties.remove(propertyId);
        }
      });
    }
  }

  Future<void> fetchPropertyState() async {
    var response = await _crud.postRequest(linkGetPropertyState, {
      'property_id': widget.id,
    });

    if (response['status'] == "success") {
      String newState = response['property_state'];
      String availableDate = response['available_date'] ?? "";

      // تحديث الحالة في واجهة المستخدم
      stateNotifier.value = newState;
    }
  }

  Future<void> checkUserBooking() async {
    var response = await _crud.postRequest(linkGetUserBooking, {
      'user_id': sharedPref.getString("id").toString(),
      'property_id': widget.id,
    });

    if (response['status'] == "success" && response['bookings'] != null) {
      setState(() {
        userBookings = List<Map<String, dynamic>>.from(response['bookings']);
      });
    } else {
      setState(() {
        userBookings = []; // تفريغ القائمة في حالة عدم وجود حجوزات
      });
    }
  }

  Widget buildUserBookings() {
    return userBookings.isNotEmpty
        ? Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children:
                userBookings.map((booking) {
                  return Card(
                    color: Colors.amber[100], // لون خلفية هادئ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.teal[900],
                        ),
                        title: Column(
                          children: [
                            Text(
                              " من ${booking['start_date']} ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                            ),
                            Text(
                              "إلى ${booking['end_date']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            // عرض مربع الحوار
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible:
                                  false, // لمنع الإغلاق بالضغط خارج الصندوق
                              builder:
                                  (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: Colors.teal[50],
                                    title: Text(
                                      'تأكيد',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.teal[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'هل أنت متأكد من الغاء حجز العقار؟',
                                      style: TextStyle(color: Colors.teal[900]),
                                      textAlign: TextAlign.center,
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: Text(
                                          'إلغاء',
                                          style: TextStyle(
                                            color: Colors.teal[900],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(ctx).pop(true);
                                        },
                                        child: Text(
                                          'متأكد',
                                          style: TextStyle(
                                            color: Colors.teal[50],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            // إذا اختار "متأكد" ننفذ الإضافة
                            if (confirmed == true) {
                              await cancelBooking(
                                booking['start_date'],
                                booking['end_date'],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        )
        : SizedBox.shrink(); // لا يعرض شيئًا إذا لم يكن هناك حجوزات
  }

  Future<void> cancelBooking(String startDate, String endDate) async {
    var response = await _crud.postRequest(linkCancelBooking, {
      'user_id': sharedPref.getString("id").toString(),
      'property_id': widget.id,
      'start_date': startDate,
      'end_date': endDate,
    });

    if (response['status'] == "success") {
      await checkUserBooking(); // تحديث قائمة الحجوزات
      await fetchPropertyState(); // تحديث حالة العقار

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ تم إلغاء الحجز بنجاح")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠ فشل في إلغاء الحجز")));
    }
  }

  Future<void> checkAvailability() async {
    try {
      var response = await _crud.postRequest(linkCheckAvailability, {
        'property_id': widget.id,
      });

      if (response['status'] == "unavailable") {
        List reservations = response['reservations'] ?? [];

        // ✅ عرض جميع التواريخ المحجوزة
        showDialog(
          context: context,
          builder: (context) => _showUnavailableDatesDialog(reservations),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This property is currently available.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking availability: ${e.toString()}")),
      );
    }
  }

  Widget _showUnavailableDatesDialog(List reservations) {
    return AlertDialog(
      backgroundColor: Colors.teal[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(
        child: Text(
          "تاريج حجز العقار",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal[50],
          ),
        ),
      ),
      content:
          reservations.isEmpty
              ? Text("No booked dates found.")
              : Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    reservations.map((res) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "📅 ${res['start_date']} → ${res['end_date']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[50],
                          ),
                        ),
                      );
                    }).toList(),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close", style: TextStyle(color: Colors.teal[50])),
        ),
      ],
    );
  }

  Widget _showBookingDialog() {
    DateTime minStartDate = DateTime.now();
    DateTime startDate = minStartDate;
    DateTime endDate = startDate.add(Duration(days: 1));
    int numberOfDays = calculateNumberOfDays(startDate, endDate);
    double totalPrice = calculateTotalPrice(
      numberOfDays,
      double.parse(widget.price),
    );

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: Colors.teal[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              "اختار تاريخ الحجز",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal[50],
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePickerButton(
                context,
                label: "تاريخ البدء",
                date: startDate,
                minDate: minStartDate,
                onDateSelected: (picked) {
                  setDialogState(() {
                    startDate = picked;
                    if (endDate.difference(startDate).inDays <= 0 ||
                        endDate.difference(startDate).inSeconds < 0) {
                      endDate = picked.add(Duration(days: 1));
                    }
                    numberOfDays = calculateNumberOfDays(startDate, endDate);
                    totalPrice = calculateTotalPrice(
                      numberOfDays,
                      double.parse(widget.price),
                    );
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildDatePickerButton(
                context,
                label: "تاريخ الانتهاء",
                date: endDate,
                minDate: startDate.add(Duration(days: 1)),
                onDateSelected: (picked) {
                  setDialogState(() {
                    endDate = picked;
                    if (startDate == minStartDate) {
                      numberOfDays =
                          calculateNumberOfDays(startDate, endDate) + 1;
                    } else {
                      numberOfDays = calculateNumberOfDays(startDate, endDate);
                    }
                    totalPrice = calculateTotalPrice(
                      numberOfDays,
                      double.parse(widget.price),
                    );
                  });
                },
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white54, height: 10),
              const SizedBox(height: 5),
              Text(
                "اجمالى التكلفه : ${totalPrice.toStringAsFixed(2)} ج.م",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "انهاء",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[50],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[50]),
              onPressed: () async {
                String userId = sharedPref.getString("id").toString();
                String propertyOwnerId =
                    widget.owner_id; // Replace with actual owner ID

                if (isOwnerOrAdmin(userId, propertyOwnerId)) {
                  // Allow booking without payment for owner or admin
                  await bookProperty(widget.id, startDate, endDate);
                } else {
                  // Show payment options for regular users
                  Navigator.pop(context); // Close the booking dialog
                  showDialog(
                    context: context,
                    builder:
                        (context) => _showPaymentOptionsDialog(
                          widget.id,
                          startDate,
                          endDate,
                          totalPrice,
                        ),
                  );
                }
              },
              child: Text(
                "تاكيد",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //  دالة مساعدة لإنشاء زر تحديد التاريخ بتصميم متناسق
  Widget _buildDatePickerButton(
    BuildContext context, {
    required String label,
    required DateTime date,
    required DateTime minDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal[50],
          ),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[50],
            foregroundColor: Colors.teal[900],
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Color.fromARGB(157, 42, 202, 181),
                width: 1.5,
              ),
            ),
          ),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: minDate,
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Text(
            "${date.toLocal()}".split(' ')[0],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> bookProperty(
    String propertyId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      var response = await _crud.postRequest(linkBookProperty, {
        'user_id': sharedPref.getString("id").toString(),
        'property_id': propertyId,
        'start_date': start.toIso8601String().split('T')[0],
        'end_date': end.toIso8601String().split('T')[0],
      });

      if (response['status'] == "success") {
        stateNotifier.value = "booked"; // تحديث حالة العق ر
        await checkUserBooking(); // تحديث قائمة الحجوزات

        // عرض رسالة نجاح الحجز
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ تم الحجز من ${start.toIso8601String().split('T')[0]} إلى ${end.toIso8601String().split('T')[0]}",
            ),
          ),
        );

        // تحديث واجهة المستخدم
        if (mounted) {
          setState(() {});
        }
      } else {
        // عرض رسالة فشل الحجز
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("⚠ فشل في الحجز")));
      }
    } catch (e) {
      // عرض رسالة خطأ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ حدث خطأ: ${e.toString()}")));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.teal[50],
          ), // أيقونة الرجوع للخلف
          onPressed: () {
            if (widget.fav) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Favorite()),
              );
            } else {
              Navigator.pop(context, true); // الرجوع للصفحة السابقة بشكل طبيعي
            }
          },
        ),
        backgroundColor: Colors.teal[800],
        title: Text(
          "العوده",
          style: TextStyle(color: Colors.teal[50], fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    widget.images.isNotEmpty
                        ? widget.images.asMap().entries.map((entry) {
                          int index = entry.key;
                          String file = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.zero,
                                      child: Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Colors.teal[800],
                                          automaticallyImplyLeading: false,
                                          actions: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                        body: Center(
                                          child: Hero(
                                            tag:
                                                'image_$index', // تأكد من أن ال tag فريد لكل صورة
                                            child: Image.network(
                                              "$linkImageRoot/$file",
                                              fit: BoxFit.contain,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Icon(Icons.error);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Hero(
                                tag:
                                    'image_$index', // نفس ال tag المستخدم في ال Dialog
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.teal.shade100,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      "$linkImageRoot/$file",
                                      width: 200,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                        : [const SizedBox.shrink()],
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.teal[800], height: 10),
            const SizedBox(height: 5),

            // Property Title, Price, and Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.teal[900],
                          size: 30,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'المكان',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          ' : ${widget.title}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.teal[900],
                          size: 28,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "السعر : ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "ج.م",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "(تكلفه اليوم الواحد)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  //الحاله
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "الحاله : ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: stateNotifier,
                          builder: (context, state, child) {
                            return Row(
                              children: [
                                Text(
                                  state == "available"
                                      ? "متاح"
                                      : "محجوز لفترات",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color:
                                        state == "available"
                                            ? Colors.teal[900]
                                            : Colors.red,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                state == "booked"
                                    ? TextButton(
                                      onPressed: () async {
                                        await checkAvailability();
                                      },
                                      child: Text(
                                        "عرض تاريح الحجز",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : Text(""),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "الطابق(الدور) :",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.floor_number,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "عدد الغرف :",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.room_count,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Rating
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "واجهه العقار :",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.property_direction,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          "التقييم :",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(width: 5),
                        widget.rating == "null"
                            ? Text(
                              "لا تقييم",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal[900],
                              ),
                            )
                            : Text(
                              widget.rating,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal[900],
                              ),
                            ),
                        SizedBox(width: 3),

                        Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "  الوصف :",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 16,

                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await OpenMap(location: widget.location);
                          },

                          label: Text(
                            'عرض على الخريطه',
                            style: TextStyle(
                              color: Colors.teal[50],
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.teal.shade900,
                          ),
                        ),
                      ),
                      SizedBox(width: 180),
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (child, animation) => ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                          child: Icon(
                            isFavorite(int.parse(widget.id))
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey<bool>(
                              isFavorite(int.parse(widget.id)),
                            ),
                            color:
                                isFavorite(int.parse(widget.id))
                                    ? Colors.red
                                    : Colors.teal[900],
                          ),
                        ),
                        onPressed: () async {
                          await toggleFavorite(int.parse(widget.id));
                          isFavorite(int.parse(widget.id));
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  buildUserBookings(), // ✅ عرض حجوزات المستخدم هنا
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.teal[50],
                        backgroundColor: Colors.teal[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 130,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _showBookingDialog(),
                        );
                      },
                      child: const Text(
                        "احجز الان",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
