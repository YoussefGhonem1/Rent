import 'package:flutter/material.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../auth/login.dart';
import '../crud.dart';
import '../owner/add_prop.dart';
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

  Future<void> getReservations() async {
    try {
      var response = await _crud.postRequest(linkOwnerOrder, {
        'owner_id': sharedPref.getString("id") ?? '',
      });
      if (response['status'] == 'success') {
        setState(() {
          allReservations = response['data'];
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
            // الصورة
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

            // التفاصيل
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 3, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
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

                  // السعر
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.teal[900],
                        size: 20,
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
                  const SizedBox(height: 3),

                  // تاريخ الحجز وحالة الدفع
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // تاريخ الحجز
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

                      // حالة الدفع
                      Chip(
                        label: Text(
                          _getStatusText(transaction['payment_status']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _getStatusColor(
                          transaction['payment_status'],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ],
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
        return 'في انتظار الدفع';
      case 'paid':
        return 'تم الدفع';
      default:
        return 'N/A';
    }
  }

  Color _getStatusColor(String? status) {
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
        title: Text(
          'الحجوزات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal[50],
          ),
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
