import 'package:flutter/material.dart';
import 'package:rento/componants/custom_drawer.dart';
import 'package:rento/core/utils/functions/theme.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../crud.dart';

class OrderAdminScreen extends StatefulWidget {
  const OrderAdminScreen({super.key});

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  final Crud _crud = Crud();
  List allOrders = [];
  bool isLoading = true;
  List filteredOrders = [];
  Map<int, bool> isCardExpanded = {};

  int calculateNumberOfDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  double calculateTotalPrice(int numberOfDays, double dailyPrice) {
    return numberOfDays * dailyPrice;
  }

  Future<void> getOrders() async {
    try {
      var response = await _crud.postRequest(linkAdminOrder, {});
      if (response['status'] == 'success') {
        setState(() {
          allOrders = response['data'];
          filteredOrders = List.from(allOrders);
          isLoading = false;
        });
      } else {
        print("Failed to load orders: ${response['message']}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> load() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderAdminScreen()),
    );
  }

  void filterSearch(String query) {
    if (allOrders.isEmpty) {
      print("🔴 No properties available to filter!");
      return;
    }

    setState(() {
      filteredOrders =
          allOrders.where((order) {
            print(
              "🔍 Checking property: ${order['property']['address']}",
            ); // Debugging

            bool matchesSearch =
                query.isEmpty ||
                (order['property']['address'] != null &&
                    order['property']['address']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()));

            return matchesSearch;
          }).toList();
    });

    print("✅ Found ${filteredOrders.length} matching properties.");
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final transaction = order['transaction'];
    final property = order['property'];
    final renter = order['renter'];
    final owner = order['owner'];
    double totalPrice = calculateTotalPrice(
      calculateNumberOfDays(
        DateTime.parse(transaction['start_date']),
        DateTime.parse(transaction['end_date']),
      ),
      double.parse(property['rent_amount']),
    );
    double amountPaid = double.parse(transaction['amount_paid']) / 2;
    bool expanded = isCardExpanded[index] ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: Colors.teal[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            ListTile(
              title: Text(
                property['address'] ?? 'No Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.teal[900],
                ),
                onPressed: () {
                  setState(() {
                    isCardExpanded[index] = !expanded;
                  });
                },
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'الايجار اليومى:',
                      '${property['rent_amount']} ج.م',
                    ),
                    _buildInfoRow(
                      'التاريخ:',
                      '${transaction['start_date']} - ${transaction['end_date']}',
                    ),
                    _buildInfoRow('المبلغ الكلى:', '$totalPrice ج.م'),
                    _buildInfoRow(
                      'رقم الهاتف المضاف مع العقار:',
                      '${property['phone'] ?? 'N/A'}',
                    ),
                    _buildInfoRow(
                      'رقم الفيزا او المحفظه:',
                      '${property['wallet_number'] ?? 'N/A'}',
                    ),
                    const Divider(color: Colors.teal, height: 20),
                    _buildUserSection('المستأجر:', renter),
                    const SizedBox(height: 8),
                    _buildUserSection('المالك:', owner),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'موافقة صاحب العقار',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        Chip(
                          label: Text(
                            _getStatusText(transaction['status']),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: _getStatusColor(
                            transaction['status'],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ],
                      
                    ),
                    const SizedBox(height: 12),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            _getPaymentStatusText(
                              transaction['payment_status'],
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getPaymentStatusColor(
                            transaction['payment_status'],
                          ),
                        ),
                        transaction['transfer_status'] == 'transferred'
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                "تم التحويل",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ElevatedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
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
                                      'هل أنت متأكد من تأكيد تحويل المبلغ؟',
                                      style: TextStyle(color: Colors.teal[900]),
                                      textAlign: TextAlign.center,
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(false),
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
                                        onPressed:
                                            () => Navigator.of(ctx).pop(true),
                                        child: Text(
                                          'تأكيد',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed == true) {
                              var response = await _crud.postRequest(
                                linkConfirmTransfer,
                                {
                                  'reservation_id':
                                      transaction['id'].toString(),
                                },
                              );
                              if (response['status'] == "success") {
                                showCustomMessage(
                                  context,
                                  "تم تأكيد التحويل بنجاح",
                                  isSuccess: true,
                                );
                                getOrders(); // يتم التحديث وهيتغير الزر تلقائي لأن البيانات رجعت جديدة
                              } else {
                                showCustomMessage(
                                  context,
                                  "حدث خطأ أثناء تأكيد التحويل",
                                  isSuccess: false,
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.attach_money,
                            color: Colors.white,
                          ),
                          label: Text(
                            "تأكيد تحويل ${amountPaid} ج.م",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[700]),
                          onPressed: () => _deleteOrder(transaction['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState:
                  expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
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

  Widget _buildUserSection(String title, Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text('الاسم: ${user['username'] ?? 'N/A'}'),
        Text('البريد: ${user['email'] ?? 'N/A'}'),
        Text('رقم الهاتف: ${user['phone_number'] ?? 'N/A'}'),
      ],
    );
  }

  Future<void> _deleteOrder(int orderId) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من حذف هذا الطلب؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  var response = await _crud.postRequest(linkDeleteOrder, {
                    'id': '$orderId',
                  });
                  if (response['status'] == 'success') {
                    getOrders(); // Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف الطلب بنجاح')),
                    );
                  }
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
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
          children: [
            Text(
              'إدارة الطلبات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal[50],
              ),
            ),
            SizedBox(width: 50),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "ابحث عن طلب",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: filterSearch, // تحديث البحث عند تغيير النص
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.teal[50]),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: CustomDrawer(
        crud: _crud,
        userType: sharedPref.getString("type").toString(),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredOrders.isEmpty
              ? Center(
                child: Text(
                  'لا توجد طلبات حالية',
                  style: TextStyle(fontSize: 20, color: Colors.teal[800]),
                ),
              )
              : RefreshIndicator(
                onRefresh: load,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredOrders.length,
                  itemBuilder:
                      (context, index) =>
                          _buildOrderCard(filteredOrders[index], index),
                ),
              ),
    );
  }
}
