import 'package:flutter/material.dart';
import 'package:rento/chat/chat_screen.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/owner/owner_orders_screen.dart';
import 'package:rento/renter/details.dart';
import 'package:rento/renter/renter_orders_screen.dart';
import '../features/auth/presentation/views/login_screen.dart';
import '../crud.dart';
import '../renter/favorites.dart';
import 'add_prop.dart';
import 'edit_prop.dart';
import 'home_owner.dart';

class OwnerRealstate extends StatefulWidget {
  const OwnerRealstate({super.key});

  @override
  State<OwnerRealstate> createState() => _OwnerRealstateState();
}

//with Crud
class _OwnerRealstateState extends State<OwnerRealstate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];

  getRealstates() async {
    var response = await _crud.postRequest(linkViewOwnerRealstates, {
      "owner_id": sharedPref.getString("id").toString(),
    });
    if (response["status"] == "success") {
      setState(() {
        allProperties = response['data'];
        filteredProperties = List.from(
          allProperties,
        ); // نسخ البيانات إلى filteredProperties
        favoriteProperties = List<int>.from(
          response["favorites"].map((id) => id),
        );
      });
    }
    return response;
  }

  void filterSearch(String query) {
    if (allProperties.isEmpty) {
      print("🔴 No properties available to filter!");
      return;
    }

    setState(() {
      filteredProperties =
          allProperties.where((property) {
            print("🔍 Checking property: ${property['address']}"); // Debugging

            bool matchesSearch =
                query.isEmpty ||
                (property['address'] != null &&
                    property['address'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ));

            return matchesSearch;
          }).toList();
    });

    print("✅ Found ${filteredProperties.length} matching properties.");
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

  @override
  void initState() {
    super.initState();
    getRealstates();
    loadFavorites();
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
            SizedBox(width: 100),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "ابحث عن عقار",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: filterSearch,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  allProperties.isEmpty
                      ? Center(
                        child: Center(child: Text("لا يوجد عقارات متاحة")),
                      ) // عرض مؤشر تحميل أثناء جلب البيانات
                      : filteredProperties.isEmpty
                      ? Center(
                        child: Text("لا يوجد عقارات متاحة"),
                      ) // عرض رسالة إذا لم يتم العثور على نتائج
                      : GridView.builder(
                        shrinkWrap: true,
                        physics:
                            AlwaysScrollableScrollPhysics(), // تمكين التمرير
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                        itemCount:
                            filteredProperties
                                .length, // استخدام filteredProperties
                        itemBuilder: (context, index) {
                          var property =
                              filteredProperties[index]; // استخدام filteredProperties
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
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
                                        description:
                                            '${property['description']}',
                                        phone: '${property['phone']}',
                                        state: '${property['property_state']}',
                                        latitude: '${property['latitude']}',
                                        longitude: '${property['longitude']}',
                                        floor_number:
                                            '${property['floor_number']}',
                                        room_count: '${property['room_count']}',
                                        property_direction:
                                            '${property['property_direction']}',
                                        rating: '${property['rate']}',
                                      ),
                                ),
                              );
                              loadFavorites();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.teal[100],
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                                border: Border.all(
                                  // إضافة الحدود هنا
                                  color: Colors.teal.shade400,
                                  width: 1,
                                ),
                              ),

                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 3,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Property Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        "$linkImageRoot/${property['photos'][0]}",
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    // Property Details
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 10,
                                        left: 3,
                                        top: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.teal[900],
                                                size: 24,
                                              ),
                                              Text(
                                                '${property['address']}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                color: Colors.teal[900],
                                                size: 20,
                                              ),
                                              // السعر
                                              Text(
                                                " ${'${property['rent_amount']}'} L.E",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                        ],
                                      ),
                                    ),

                                    // Edit and Delete Buttons
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            EditRealEstatePage(
                                                              realdata:
                                                                  property,
                                                            ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.mode_edit_outlined,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'تعديل',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                backgroundColor:
                                                    Colors.teal[800],
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                var response = await _crud
                                                    .postRequest(linkDelete, {
                                                      "id":
                                                          property['id']
                                                              .toString(),
                                                    });
                                                if (response['status'] ==
                                                    "success") {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              OwnerRealstate(),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'حذف',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                backgroundColor:
                                                    Colors.red.shade400,
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
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
                            ),
                          );
                        },
                      ),
            ),
          ],
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
                        MaterialPageRoute(builder: (context) => HomeOwner()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "حساب", // "Account" in Arabic
                    icon: Icons.account_circle,
                    onTap: () {
                      if (sharedPref.getString("type").toString() == "owner") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OwnerRealstate(),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "الطلبات", // "Orders" in Arabic
                    icon: Icons.list_alt,
                    onTap: () {
                    
                        if (sharedPref.getString("type").toString() ==
                            "owner") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OwnerOrdersScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenterOrdersScreen(),
                            ),
                          );
                      }
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
                    title: "تواصل معنا", // "Contact Us" in Arabic
                    icon: Icons.contact_support,
                    onTap: () async {
                      try {
                        var response = await _crud.postRequest(linkCreateChat, {
                          "user_id": sharedPref.getString("id").toString(),
                        });

                        if (response['status'] == "success" &&
                            response.containsKey('chat_id')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(
                                    chatId: int.parse(
                                      response['chat_id'].toString(),
                                    ),
                                    userId: int.parse(
                                      sharedPref.getString("id")!,
                                    ),
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ?? "فشل إنشاء المحادثة",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("حدث خطأ: ${e.toString()}")),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 270),
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
