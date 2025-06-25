import 'package:flutter/material.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/notifications/push_function.dart';
import 'package:rento/renter/payment.dart'; // تأكد من المسار الصحيح لـ PaymentPage
import 'package:rento/renter/mobile_wallet_payment.dart'; // ✅ جديد: استيراد MobileWalletPaymentPage
import '../crud.dart';
import '../renter/details.dart'; // تأكد من المسار الصحيح

class RenterOrdersScreen extends StatefulWidget {
  const RenterOrdersScreen({super.key});

  @override
  State<RenterOrdersScreen> createState() => _RenterOrdersScreenState();
}

class _RenterOrdersScreenState extends State<RenterOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List allReservations = [];
  bool isLoading = true;

  Future<void> getReservations() async {
    try {
      var response = await _crud.postRequest(linkRenterOrder, {
        'user_id': sharedPref.getString("id") ?? '',
      });
      if (response['status'] == 'success') {
        setState(() {
          allReservations = response['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getReservations();
  }

  // دالة لحساب عدد الأيام (مكررة، ممكن تبقى دالة عامة)
  int _calculateNumberOfDays(DateTime start, DateTime end) {
    return end.difference(start).inDays; // +1 لحساب اليوم الأخير
  }

  // ✅ دالة جديدة لعرض خيارات الدفع (كـ AlertDialog)
  void _showPaymentOptions(
    BuildContext context,
    double amount,
    String reservationId,
    String propertyId,
    String ownerId,
    String propertyAddress,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // استخدام dialogContext لتجنب الالتباس
        return AlertDialog(
          backgroundColor: Colors.teal[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "اختر طريقة الدفع",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.teal[900],
            ),
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // لجعل الـ Dialog لا يأخذ مساحة كبيرة
            children: [
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.teal[800]),
                title: Text(
                  "بطاقة ائتمان(فيزا/ماستركارد)",
                  style: TextStyle(color: Colors.teal[900], fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(dialogContext); // إغلاق الـ Dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentPage(
                            // توجيه لصفحة الدفع بالبطاقة
                            amount: amount,
                            reservationId: reservationId,
                            propertyId: propertyId,
                            onPaymentSuccess: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم الدفع ببطاقة بنجاح!'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                              await sendNotificationToUserV1(
                                ownerId,
                                "تم تاكيد الحجز لعقارك ",
                                "تم تاكيد حجز عقارك في $propertyAddress من قبل المستأجر. يرجى التحقق من التطبيق لمزيد من التفاصيل.",
                              );
                              getReservations(); // تحديث قائمة الحجوزات
                              setState(() {
                                isLoading = true; // إعادة تحميل البيانات
                              }); // تحديث قائمة الحجوزات
                            },
                            onPaymentFailed: () {
                              // نفذ الإجراء عند فشل الدفع
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('فشل الدفع بالبطاقة.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              getReservations(); // تحديث قائمة الحجوزات حتى لو فشل
                            },
                          ),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.teal, height: 10), // فاصل
              ListTile(
                leading: Icon(Icons.wallet, color: Colors.teal[800]),
                title: Text(
                  "المحفظة الإلكترونية",
                  style: TextStyle(color: Colors.teal[900], fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(dialogContext); // إغلاق الـ Dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MobileWalletPaymentPage(
                            // توجيه لصفحة الدفع بالمحفظة
                            amount: amount,
                            reservationId: reservationId,
                            propertyId: propertyId,
                            onPaymentSuccess: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم الدفع بالمحفظة بنجاح!'),
                                ),
                              );
                              await sendNotificationToUserV1(
                                ownerId,
                                "تم تاكيد الحجز لعقارك ",
                                "تم تاكيد حجز عقارك في $propertyAddress من قبل المستأجر. يرجى التحقق من التطبيق لمزيد من التفاصيل.",
                              );
                              getReservations(); // تحديث قائمة الحجوزات
                              setState(() {
                                isLoading = true; // إعادة تحميل البيانات
                              }); // تحديث قائمة الح
                            },
                            onPaymentFailed: () {
                              // نفذ الإجراء عند فشل الدفع
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('فشل الدفع بالمحفظة.'),
                                ),
                              );
                              getReservations(); // تحديث قائمة الحجوزات حتى لو فشل
                            },
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // إغلاق الـ Dialog
              child: Text("إلغاء", style: TextStyle(color: Colors.teal[700])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    final transaction = reservation['transaction'];
    final property = reservation['property'];
    final images =
        property['images'] ??
        property['photos'] ??
        []; // استخدام 'photos' لو 'images' غير موجودة
    final firstImage =
        images.isNotEmpty ? "$linkImageRoot/${images[0]}" : "images/fig.webp";

    // حساب المبلغ الإجمالي
    final String startDateStr = transaction['start_date'] ?? '';
    final String endDateStr = transaction['end_date'] ?? '';
    final double dailyPrice =
        double.tryParse(property['rent_amount'] ?? '0') ?? 0;

    DateTime startDate;
    DateTime endDate;
    int numberOfDays = 0;
    double totalPrice = 0.0;

    try {
      startDate = DateTime.parse(startDateStr);
      endDate = DateTime.parse(endDateStr);
      numberOfDays = _calculateNumberOfDays(startDate, endDate) + 1;
      totalPrice = numberOfDays * dailyPrice;
    } catch (e) {
      print("Error parsing dates or prices: $e");
      // Handle error, e.g., set default values or show an error message
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(color: Colors.teal.shade400, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RealEstateDetailsPage(
                    fav: false,
                    favoriteProperties: [],
                    images: List<String>.from(images),
                    videos: [],
                    id: property['id'].toString(),
                    owner_id:
                        property['owner_id']
                            .toString(), // تأكد من الحصول على owner_id الصحيح
                    title: property['address'] ?? "",
                    price: property['rent_amount'] ?? "",
                    location: property['address'] ?? "",
                    description: property['description'] ?? "",
                    terms_and_conditions: '${property['terms_and_conditions']}',
                    phone: property['phone'] ?? "",
                    state: property['property_state'] ?? "",
                    latitude: property['latitude'] ?? "",
                    longitude: property['longitude'] ?? "",
                    floor_number: property['floor_number'] ?? "",
                    room_count: property['room_count'] ?? "",
                    property_direction: property['property_direction'] ?? "",
                    rating: property['rate'] ?? "",
                  ),
            ),
          );
        },
        child: Column(
          children: [
            // Property Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                firstImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Image.asset(
                      "images/fig.webp",
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              ),
            ),

            // Reservation Status
            Container(
              height: 30,
              color:
                  transaction['status'] == 'confirmed'
                      ? Colors.teal[800]
                      : Colors.orange,
              child: Center(
                child: Text(
                  _getStatusText(transaction['status']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.teal[900],
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          property['address'] ?? 'No Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price and Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.teal[900],
                            size: 18,
                          ),
                          Text(
                            " ${property['rent_amount']} L.E",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.teal[900],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${transaction['start_date']}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal[900],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // End Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.teal[900],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${transaction['end_date']}",
                        style: TextStyle(fontSize: 14, color: Colors.teal[900]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total Price
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التكلفة الإجمالية:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(2)} L.E',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.teal[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment Status Chip
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'حالة الدفع:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            _getPaymentStatusText(
                              transaction['payment_status'],
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: _getPaymentStatusColor(
                            transaction['payment_status'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (transaction['status'] == 'confirmed' &&
                      transaction['payment_status'] == 'pending')
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.teal[50],
                          backgroundColor: Colors.teal[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 50,
                          ),
                        ),
                        onPressed: () {
                          _showPaymentOptions(
                            context,
                            totalPrice,
                            transaction['id'].toString(),
                            property['id'].toString(),
                            property['owner_id'].toString(),
                            property['address'],
                          );
                        },
                        child: const Text(
                          "ادفع الان",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  else if (transaction['payment_status'] == 'paid')
                    Container(
                      height: 30,
                      color: Colors.teal[800],
                      child: const Center(
                        child: Text(
                          "تم تاكيد الحجز و يمكنك الاستمتاع بالرحله الان",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  // هذا الجزء يعرض رسالة "تم رفض الطلب" لو الـ status هو 'rejected'
                  else if (transaction['status'] == 'rejected')
                    Container(
                      height: 30,
                      color: Colors.red[800],
                      child: const Center(
                        child: Text(
                          "تم رفض طلب الحجز",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Owner Approval Status Text and Color (for Owner perspective)
  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'فى انتظار موافقه صاحب العقار';
      case 'confirmed':
        return 'تم موافقه صاحب العقار يمكنك الدفع';
      case 'rejected':
        return 'تم رفض الطلب';
      default:
        return 'غير معروف';
    }
  }

  // Payment Status Text and Color (general for all users)
  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'في انتظار الدفع';
      case 'paid':
        return 'تم الدفع';
      case 'failed': // لو أضفت حالة 'failed' في الباك إند
        return 'فشل الدفع';
      default:
        return 'غير معروف';
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: Text(
          'حجوزاتي',
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : allReservations.isEmpty
              ? Center(
                child: Text(
                  'لا توجد حجوزات حالية',
                  style: TextStyle(fontSize: 20, color: Colors.teal[800]),
                ),
              )
              : RefreshIndicator(
                onRefresh: getReservations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: allReservations.length,
                  itemBuilder:
                      (context, index) =>
                          _buildReservationCard(allReservations[index]),
                ),
              ),
    );
  }
}
