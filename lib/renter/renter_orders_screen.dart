import 'package:flutter/material.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../auth/login.dart';
import '../crud.dart';
import '../renter/details.dart';

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
    final firstImage = images.isNotEmpty ? "$linkImageRoot/${images[0]}" : "images/fig.webp";

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
        border: Border.all(
          color: Colors.teal.shade400,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RealEstateDetailsPage(
                fav: false,
                favoriteProperties: [],
                images: List<String>.from(images),
                videos: [],
                id: property['id'].toString(),
                owner_id: transaction['user_id'].toString(),
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
                errorBuilder: (context, error, stackTrace) => Image.asset(
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
              color: transaction['status'] == 'confirmed'
                  ? Colors.teal[800]
                  : Colors.orange,
              child: Center(
                child: Text(
                  transaction['status'] == 'confirmed'
                      ? 'تم تأكيد الحجز'
                      : 'في انتظار التأكيد',
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
                      Icon(Icons.location_on, color: Colors.teal[900], size: 20),
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
                          Icon(Icons.attach_money, color: Colors.teal[900], size: 18),
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
                          Icon(Icons.calendar_today, color: Colors.teal[900], size: 16),
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

                  // Payment Status
                  Row(
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
                          _getPaymentStatusText(transaction['payment_status']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _getPaymentStatusColor(transaction['payment_status']),
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

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'في انتظار الدفع';
      case 'paid':
        return 'تم الدفع';
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
        title:  Text('حجوزاتي' ,   style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color:  Colors.teal[50],
              ),),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Colors.teal[50]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allReservations.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد حجوزات حالية',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.teal[800],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: getReservations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: allReservations.length,
                    itemBuilder: (context, index) => 
                      _buildReservationCard(allReservations[index]),
                  ),
                ),
    );
  }
}