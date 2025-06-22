import 'package:flutter/material.dart';
import 'package:rento/admin/approve_screen.dart';
import 'package:rento/admin/control_admin.dart';
import 'package:rento/admin/order_admin_screen.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/renter/details.dart';
import '../auth/login.dart';
import '../chatadmin/AdminChatList.dart';
import '../componants/card.dart';
import '../crud.dart';
import '../owner/add_prop.dart';
import '../renter/favorites.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];

  // متحكمات حقول البحث داخل الـ Dialog
  TextEditingController searchNameController = TextEditingController();
  TextEditingController searchFromPriceController = TextEditingController();
  TextEditingController searchToPriceController = TextEditingController();
  TextEditingController searchRoomCountController = TextEditingController();

  // متغيرات Dropdown لفلترة الأدوار
  String? selectedFloor;

  // قائمة الأدوار المتاحة
  final List<String> floorOptions = [
    'أرضي',
    'أول',
    'ثاني',
  ];

  // دالة لمطابقة ترتيب الأدوار (للفلترة)
  int _getFloorOrder(String floor) {
    switch (floor) {
      case 'أرضي':
        return 0;
      case 'أول':
        return 1;
      case 'ثاني':
        return 2;
      default:
        return -1; // لو قيمة غير معروفة
    }
  }

  Future<void> getRealstates() async {
    var response = await _crud.postRequest(linkView, {});
    if (response['status'] == 'success') {
      setState(() {
        allProperties = response['data'];
        filteredProperties = allProperties; // عرض الكل مبدئياً
      });
    }
    return response;
  }

  void loadFavorites() async {
    var response = await _crud.postRequest(linkGetFav, {
      "user_id": sharedPref.getString("id").toString(),
    });

    if (response["status"] == "success") {
      setState(() {
        favoriteProperties = List<int>.from(
          response["favorites"].map((id) => id),
        );
      });
    }
  }

  Future<void> load() async {
    // هذه الدالة تعمل ريفريش للصفحة وتجلب كل العقارات الأصلية
    await getRealstates();
    loadFavorites();
    // تأكد من مسح الفلاتر المعروضة في الـ Dialog عشان تبدأ من جديد
    searchNameController.clear();
    searchFromPriceController.clear();
    searchToPriceController.clear();
    searchRoomCountController.clear();
    selectedFloor = null;
    // لا نحتاج لـ setState() هنا لأن getRealstates() و loadFavorites() بيعملوها
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
    getRealstates();
  }

  // دالة لتطبيق جميع الفلاتر بناءً على المدخلات
  void applyFilters() {
    List tempFiltered = List.from(allProperties);

    String nameQuery = searchNameController.text.toLowerCase();
    String fromPrice = searchFromPriceController.text;
    String toPrice = searchToPriceController.text;
    String roomCountQuery = searchRoomCountController.text;

    // فلتر الاسم
    if (nameQuery.isNotEmpty) {
      tempFiltered = tempFiltered.where((property) {
        return property['address'] != null &&
            property['address'].toString().toLowerCase().contains(nameQuery);
      }).toList();
    }

    // فلتر السعر
    double? minP = double.tryParse(fromPrice);
    double? maxP = double.tryParse(toPrice);
    if (minP != null || maxP != null) {
      tempFiltered = tempFiltered.where((property) {
        double rentAmount =
            double.tryParse(property['rent_amount'].toString()) ?? 0;
        bool matchesMin = minP == null || rentAmount >= minP;
        bool matchesMax = maxP == null || rentAmount <= maxP;
        return matchesMin && matchesMax;
      }).toList();
    }

    // فلتر عدد الغرف (room_count) - رقمي
    int? targetRoomCount = int.tryParse(roomCountQuery);
    if (targetRoomCount != null) {
      tempFiltered = tempFiltered.where((property) {
        int propertyRoomCount = int.tryParse(property['room_count']?.toString() ?? '0') ?? 0;
        return propertyRoomCount == targetRoomCount;
      }).toList();
    }

    // فلتر الطابق (floor_number) - مطابقة نصية
    if (selectedFloor != null) {
      tempFiltered = tempFiltered.where((property) {
        String propertyFloor = property['floor_number']?.toString() ?? '';
        return propertyFloor == selectedFloor;
      }).toList();
    }

    setState(() {
      filteredProperties = tempFiltered;
    });
    Navigator.pop(context);
  }

  // دالة لمسح جميع مدخلات الفلاتر في الـ Dialog
  void _clearFiltersInDialog(Function setDialogState) {
    setDialogState(() {
      searchNameController.clear();
      searchFromPriceController.clear();
      searchToPriceController.clear();
      searchRoomCountController.clear();
      selectedFloor = null;
    });
  }

  // دالة لعرض الـ Search Dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.teal[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                "بحث وفلترة العقارات",
                style: TextStyle(
                  color: Colors.teal[900],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // حقل البحث بالاسم
                    TextField(
                      controller: searchNameController,
                      decoration: InputDecoration(
                        labelText: "ابحث بالاسم/العنوان",
                        labelStyle: TextStyle(color: Colors.teal[800]),
                        prefixIcon: Icon(Icons.location_on, color: Colors.teal[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.teal.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.teal.shade600),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.teal[900]),
                    ),
                    const SizedBox(height: 20),

                    // حقول البحث بالسعر
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "البحث حسب السعر",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchFromPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "من",
                              labelStyle: TextStyle(color: Colors.teal[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(color: Colors.teal[900]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchToPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "إلى",
                              labelStyle: TextStyle(color: Colors.teal[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(color: Colors.teal[900]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // دمج حقول الطابق وعدد الغرف
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الطابق وعدد الغرف",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // الطابق (Dropdown)
                    DropdownButtonFormField<String>(
                      value: selectedFloor,
                      hint: Text("اختر الطابق", style: TextStyle(color: Colors.teal[800])),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(" اختر الطابق", style: TextStyle(color: Colors.grey)),
                        ),
                        ...floorOptions.map((String floor) {
                          return DropdownMenuItem<String>(
                            value: floor,
                            child: Text(floor, style: TextStyle(color: Colors.teal[900])),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedFloor = newValue;
                        });
                      },
                      style: TextStyle(color: Colors.teal[900]),
                    ),
                    const SizedBox(height: 10),
                    // عدد الغرف (TextField)
                    TextField(
                      controller: searchRoomCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "عدد الغرف (بالضبط)",
                        labelStyle: TextStyle(color: Colors.teal[800]),
                        prefixIcon: Icon(Icons.meeting_room, color: Colors.teal[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.teal[900]),
                    ),
                    const SizedBox(height: 10),
                   
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    _clearFiltersInDialog(setDialogState);
                    Navigator.pop(context); // إغلاق الـ Dialog
                    await load(); // إعادة تحميل العقارات كلها
                  },
                  child: Text(
                    "إلغاء الفلاتر",
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الـ Dialog بدون مسح
                  },
                  child: Text(
                    "إلغاء",
                    style: TextStyle(color: Colors.teal[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("بحث"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      drawer: const _CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.teal[50]),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Row(
          children: [
            Text(
              "Rent",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal[50],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.search, color: Colors.teal[50]),
              onPressed: _showSearchDialog, // استدعاء الـ dialog عند الضغط
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              filteredProperties.isEmpty
                  ? const Center(child: Text("لا يوجد عقارات متاحة"))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.69,
                      ),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        var property = filteredProperties[index];
                        return InkWell(
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RealEstateDetailsPage(
                                      fav: false,
                                      favoriteProperties: favoriteProperties,
                                      images: List<String>.from(property['photos']),
                                      videos: List<String>.from(property['videos']),
                                      id: '${property['id']}',
                                      owner_id: '${property['id']}',
                                      title: '${property['address']}',
                                      price: '${property['rent_amount']}',
                                      location: '${property['address']}',
                                      description: '${property['description']}',
                                      phone: '${property['phone']}',
                                      state: '${property['property_state']}',
                                      latitude: '${property['latitude']}',
                                      longitude: '${property['longitude']}',
                                      floor_number: '${property['floor_number']}',
                                      room_count: '${property['room_count']}',
                                      property_direction: '${property['property_direction']}',
                                      rating:'${property['rate']}',
                                    ),
                              ),
                            );

                            if (result == true) {
                              await getRealstates();
                            }
                            loadFavorites();
                          },
                          child: RealEstateCard(
                            image: "$linkImageRoot/${property['photos'][0]}",
                            title: '${property['address']}',
                            price: '${property['rent_amount']}',
                            location: '${property['address']}',
                            description: '${property['description']}',
                            rate: '${property['rate']}',
                            status: '${property['property_state']}',
                            isFavorite: favoriteProperties.contains(
                              property['id'],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRealEstatePage()),
          );
        },
        backgroundColor: Colors.teal[800],
        child: Text(
          "اضافه",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.teal[50],
          ),
        ),
      ),
    );
  }
}

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal[900],
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
                    title: "الصفحه الرئيسية",
                    icon: Icons.home,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeAdmin()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "حساب",
                    icon: Icons.account_circle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ControlAdmin()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "الطلبات",
                    icon: Icons.list_alt,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderAdminScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "المفضلة",
                    icon: Icons.favorite,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Favorite()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "طلبات التاكيد",
                    icon: Icons.approval,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Approve()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "تواصل معنا",
                    icon: Icons.contact_support,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminChatList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 200),
                  _buildDrawerItem(
                    context,
                    title: "تسجيل الخروج",
                    icon: Icons.logout,
                    onTap: () {
                      sharedPref.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
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