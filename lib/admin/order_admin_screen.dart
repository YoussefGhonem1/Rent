import 'package:flutter/material.dart';
import 'package:rento/admin/approve_screen.dart';
import 'package:rento/admin/control_admin.dart';
import 'package:rento/chatadmin/AdminChatList.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/renter/favorites.dart';
import '../auth/login.dart';
import '../crud.dart';
import 'home_admin.dart';

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
            print("🔍 Checking property: ${order['property']['address']}"); // Debugging

            bool matchesSearch =
                query.isEmpty ||
                (order['property']['address'] != null &&
                   order['property']['address'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ));

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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final transaction = order['transaction'];
    final property = order['property'];
    final renter = order['renter'];
    final owner = order['owner'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: Colors.teal[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Info
            Row(
              children: [
                Icon(Icons.home, color: Colors.teal[800], size: 20),
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

            // Rental Info
            _buildInfoRow('المبلغ:', '${property['rent_amount']} L.E'),
            _buildInfoRow(
              'التاريخ:',
              '${transaction['start_date']} - ${transaction['end_date']}',
            ),

            const Divider(color: Colors.teal, height: 20),

            // Users Info
            _buildUserSection('المستأجر:', renter),
            const SizedBox(height: 8),
            _buildUserSection('المالك:', owner),

            // Status & Actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    transaction['payment_status'] ?? 'N/A',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(
                    transaction['payment_status'],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[700]),
                      onPressed: () => _deleteOrder(transaction['id']),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal[800]),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      drawer: _CustomDrawer(),
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
                      (context, index) => _buildOrderCard(filteredOrders[index]),
                ),
              ),
    );
  }
}

Crud _crud = Crud();

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal[900], // Changed to solid teal color
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.asset("images/Capture.PNG", fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  sharedPref.getString("username").toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.teal.shade50,
                  ),
                ),
              ],
            ),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    title: "الصفحه الرئيسية", // "Home Page" in Arabic
                    icon: Icons.home,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeAdmin()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "حساب", // "Account" in Arabic
                    icon: Icons.account_circle,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ControlAdmin()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "الطلبات", // "Orders" in Arabic
                    icon: Icons.list_alt,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderAdminScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "المفضلة", // "Favorites" in Arabic
                    icon: Icons.favorite,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Favorite()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "طلبات التاكيد", // "Favorites" in Arabic
                    icon: Icons.approval,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Approve()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "تواصل معنا", // "Contact Us" in Arabic
                    icon: Icons.contact_support,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminChatList(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 200),
                  _buildDrawerItem(
                    context,
                    title: "تسجيل الخروج", // "Sign Out" in Arabic
                    icon: Icons.logout,
                    onTap: () {
                      sharedPref.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.teal.shade50),
      ),
      leading: Icon(icon, color: Colors.teal.shade50, size: 26),
      minLeadingWidth: 30,
      onTap: onTap,
    );
  }
}
