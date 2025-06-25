import 'package:flutter/material.dart';
import 'package:rento/core/utils/functions/theme.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/notifications/push_function.dart';
import '../crud.dart';
import '../renter/details.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List allReservations = [];
  bool isLoading = true;
  String messageTitle = "تم الموافقه على عرضك";
  String messageBody = "تم الموافقه على عرضك من قبل المالك انتقل للدفع الان";
   String balance = "0.00";

  Future<void> getReservations() async {
    try {
      var response = await _crud.postRequest(linkOwnerOrder, {
        'owner_id': sharedPref.getString("id") ?? '',
      });
      if (response['status'] == 'success') {
        setState(() {
          allReservations = response['data'];
          balance= (response['data'][0]['owner']['balance'] ?? "0.00").toString();
          isLoading = false;
        });
      } else {
        print("Failed to load reservations: ${response['message']}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching reservations: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getReservations();
    
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    final transaction = reservation['transaction'];
    final property = reservation['property'];
    
    final images = property['images'] ?? [];
  
    final firstImage =
        images.isNotEmpty ? "$linkImageRoot/${images[0]}" : "images/fig.webp";

    // Extract reservation details
    final userId = transaction['user_id'].toString();
    final int numberOfPeople = transaction['number_of_people'] ?? 0;
    final String reservationType = transaction['reservation_type'] ?? 'N/A';
    final String startDate = transaction['start_date'] ?? '';
    final String endDate = transaction['end_date'] ?? '';
    final double dailyPrice =
        double.tryParse(property['rent_amount'] ?? '0') ?? 0;

    // Calculate number of days and total price
    final DateTime start = DateTime.parse(startDate);
    final DateTime end = DateTime.parse(endDate);
    final int numberOfDays = end.difference(start).inDays + 1;
    final double totalPrice = numberOfDays * dailyPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                    owner_id: sharedPref.getString("id") ?? "",
                    title: property['address'] ?? "",
                    price: property['rent_amount'] ?? "",
                    location: property['address'] ?? "",
                     terms_and_conditions:
                                            '${property['terms_and_conditions']}',
                    description: "",
                    phone: "",
                    state: "",
                    latitude: "",
                    longitude: "",
                    floor_number: "",
                    room_count: "",
                    property_direction: property['property_direction'] ?? "",
                    rating: "",
                  ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
              child: SizedBox(
                height: 110,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    firstImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Image.asset(
                          "images/fig.webp",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              ),
            ),

            // Details
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 3, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.teal[900],
                          size: 24,
                        ),
                        Expanded(
                          child: Text(
                            property['address'] ?? 'No Address',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Price
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.teal[900],
                          size: 20,
                        ),
                        Text(
                          " ${property['rent_amount']}  ج.م / تكلفه اليوم" ,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Reservation Details
                    _buildInfoRow("عدد الأشخاص:", "$numberOfPeople"),
                    _buildInfoRow("نوع الحجز:", reservationType),
                    _buildInfoRow("تاريخ البدء:", startDate),
                    _buildInfoRow("تاريخ الانتهاء:", endDate),
                    _buildInfoRow("عدد الأيام:", "$numberOfDays"),
                    _buildInfoRow(
                      "التكلفة الإجمالية:",
                      "${totalPrice.toStringAsFixed(2)} ج.م",
                    ),

                    const SizedBox(height: 3),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Payment Status Chip
                        Flexible(
                          child: Chip(
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        transaction['status'] == 'pending'
                            ?
                            // Elevated Button
                            Flexible(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.teal[50],
                                  backgroundColor: Colors.teal[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal:
                                        15, // Adjusted padding to prevent overflow
                                  ),
                                ),
                                onPressed: () async {
                                  // عرض مربع الحوار
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible:
                                        false, // لمنع الإغلاق بالضغط خارج الصندوق
                                    builder:
                                        (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
                                            'هل انت متاكد من الموفقه على العرض؟',
                                            style: TextStyle(
                                              color: Colors.teal[900],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                              },
                                              child: Text(
                                                'الغاء الحجز',
                                                style: TextStyle(
                                                  color: Colors.teal[900],
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.teal[800],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              },
                                              child: Text(
                                                'تاكيد الحجز',
                                                style: TextStyle(
                                                  color: Colors.teal[50],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirmed == true) {
                                    var response = await _crud.postRequest(
                                      linkUpdateOrderStatus,
                                      {'id': transaction['id'].toString()},
                                    );
                                    await sendNotificationToUserV1(
                                      userId,
                                      messageTitle,
                                      messageBody,
                                    );
                                    showCustomMessage(
                                      context,
                                      "تم قبول العرض",
                                      isSuccess: true,
                                    );
                                  } else if (confirmed == false) {
                                    await _crud.postRequest(linkDeleteOrder, {
                                      'id': transaction['id'].toString(),
                                    });
                                  }
                                  getReservations();
                                },
                                child: const Text(
                                  "موافقه على العرض",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ), // Adjusted font size to fit
                                ),
                              ),
                            )
                            : Flexible(
                              child: Chip(
                                label: Text(
                                  _getStatusText(transaction['status']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(
                                  transaction['status'],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'بانتظار التاكيد';
      case 'confirmed':
        return 'تم التاكيد';
      default:
        return 'غير ماكد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'بانتظار الدفع';
      case 'paid':
        return 'تم الدفع';
      default:
        return 'غير مدفوع';
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.teal[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: Row(
          // ✅ استخدام Row لعرض العنوان والرصيد معاً
          children: [
            Text(
              'الحجوزات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal[50],
              ),
            ),
            const SizedBox(width: 120),
            Text(
              'الرصيد: ${balance}', // جلب الرصيد من sharedPref
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // حجم خط أصغر للرصيد
                color: Colors.amber[300], // لون مميز للرصيد
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),

                    itemCount: allReservations.length,
                    itemBuilder:
                        (context, index) =>
                            _buildReservationCard(allReservations[index]),
                  ),
                ),
              ),
    );
  }
}
