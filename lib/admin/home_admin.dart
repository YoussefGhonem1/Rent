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

//with Crud
class _HomeAdminState extends State<HomeAdmin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];
  String selectedPriceFilter = "All"; // الفلتر الافتراضي
  bool showNameSearch = false;
  bool showPriceSearch = false;
  double? minPrice;
  double? maxPrice;
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController fromPriceController = TextEditingController();
  TextEditingController toPriceController = TextEditingController();

  Future<void> getRealstates() async {
    var response = await _crud.postRequest(linkView, {});
    if (response['status'] == 'success') {
      setState(() {
        allProperties = response['data'];
        filteredProperties = allProperties;
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeAdmin()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
    getRealstates();
  }

  void filterByName(String query) {
    setState(() {
      filteredProperties =
          allProperties.where((property) {
            return query.isEmpty ||
                (property['address'] != null &&
                    property['address'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ));
          }).toList();
    });
  }

  void filterByPrice(String from, String to) {
    setState(() {
      double? min = double.tryParse(from);
      double? max = double.tryParse(to);

      filteredProperties =
          allProperties.where((property) {
            double rentAmount =
                double.tryParse(property['rent_amount'].toString()) ?? 0;

            bool matchesMin = min == null || rentAmount >= min;
            bool matchesMax = max == null || rentAmount <= max;

            return matchesMin && matchesMax;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      drawer: _CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.teal[50]),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // كده تفتحه بسهولة
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
            Spacer(),
            IconButton(
              icon: Icon(Icons.search, color: Colors.teal[50]),
              onPressed: () {
                setState(() {
                  showNameSearch = !showNameSearch;
                  showPriceSearch = false;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_alt, color: Colors.teal[50]),
              onPressed: () {
                setState(() {
                  showPriceSearch = !showPriceSearch;
                  showNameSearch = false;
                });
              },
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
              if (showNameSearch)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[700], // لون الخلفية
                    borderRadius: BorderRadius.circular(6), // زوايا مدورة
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // ظل خفيف
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: nameSearchController,
                      decoration: InputDecoration(
                        hintText: "ابحث عن عقار بالاسم",
                        hintStyle: TextStyle(color: Colors.teal[900]),
                        prefixIcon: Icon(Icons.search, color: Colors.teal[900]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600),
                        ),
                        filled: true,
                        fillColor: Colors.teal[50],
                      ),
                      style: TextStyle(color: Colors.teal[900]),
                      onChanged: (value) {
                        filterByName(value);
                      },
                    ),
                  ),
                ),

              // حقل البحث بالسعر
              if (showPriceSearch)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[700], // الخلفية البيضاء للبوكس
                    borderRadius: BorderRadius.circular(6), // زوايا مدورة
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // ظل خفيف
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "البحث حسب السعر  (متاح اضافه سعر واحد)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[50],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: fromPriceController,
                                decoration: InputDecoration(
                                  labelText: "من",
                                  labelStyle: TextStyle(
                                    color: Colors.teal[900],
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.teal[50],
                                ),
                                style: TextStyle(color: Colors.teal[900]),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: toPriceController,
                                decoration: InputDecoration(
                                  labelText: "إلى",
                                  labelStyle: TextStyle(
                                    color: Colors.teal[900],
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.teal[50],
                                ),
                                style: TextStyle(color: Colors.teal[900]),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                filterByPrice(
                                  fromPriceController.text,
                                  toPriceController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[50],
                                foregroundColor: Colors.teal[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text("بحث"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 10), // مسافة قبل عرض العقارات
              // 🔹 عرض العقارات بعد الفلترة
              filteredProperties.isEmpty
                  ? Center(child: Text("لا يوجد عقارات متاحة"))
                  : GridView.builder(
                    shrinkWrap: true, // يجعل GridView يعمل داخل ListView
                    physics:
                        NeverScrollableScrollPhysics(), // تعطيل التمرير داخل GridView
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    images: List<String>.from(
                                      property['photos'],
                                    ),
                                    videos: List<String>.from(
                                      property['videos'],
                                    ),
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
                                    property_direction:
                                        '${property['property_direction']}',
                                    rating: '${property['rate']}',
                                  ),
                            ),
                          );

                          // ✅ إذا تم التحديث، نقوم بجلب البيانات من جديد
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
                          ), // ✅ تحديد إذا كان العقار في المفضل
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
                      Navigator.push(
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
                      Navigator.push(
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
                      Navigator.push(
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
                      Navigator.push(
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
                      Navigator.push(
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
