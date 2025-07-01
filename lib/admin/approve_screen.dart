import 'package:flutter/material.dart';
import 'package:rento/componants/custom_drawer.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/renter/details.dart';
import '../crud.dart';


class Approve extends StatefulWidget {
  const Approve({super.key});

  @override
  State<Approve> createState() => _ApproveState();
}

//with Crud
class _ApproveState extends State<Approve> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];

  getRealstates() async {
    var response = await _crud.postRequest(linkGetNotApprove, {});
    if (response['status'] == 'success') {
      setState(() {
        allProperties = response['data'];
        filteredProperties = List.from(
          allProperties,
        ); // نسخ البيانات إلى filteredProperties
      });
    } else {
      print("🔴 Failed to load properties: ${response['message']}");
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

  @override
  void initState() {
    super.initState();
    getRealstates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      /* drawer: _CustomDrawer(), */
       drawer: CustomDrawer(crud: _crud, userType: sharedPref.getString("type").toString()), 
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
              "RENT",
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
                onChanged: filterSearch, // تحديث البحث عند تغيير النص
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
                        child: Text(
                          "لا يوجد طلبات تاكيد",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                      )
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
                                          terms_and_conditions:
                                            '${property['terms_and_conditions']}',
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
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.teal[900],
                                                  size: 24,
                                                ),
                                                Text(
                                                    (property['address']?.isNotEmpty ==
                                                              true &&
                                                         property['address']!.length >
                                                              10)
                                                      ? '${property['address']!.substring(0, 10)}...'
                                                      : property['address'] ??
                                                          'لا يوجد عنوان',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.teal[900],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Row(
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
                                              onPressed: () async {
                                                var response = await _crud
                                                    .postRequest(linkApprove, {
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
                                                              Approve(),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.approval_outlined,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'موافق',
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
                                                    Colors.teal.shade900,
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
                                                              Approve(),
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
        onPressed: () async {
          var response = await _crud.postRequest(linkUpdateStatus, {});
          if (response['status'] == "success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Approve()),
            );
          }
        },
        backgroundColor: Colors.teal[800],
        child: Text("update" ,  style: TextStyle( fontSize: 14, color: Colors.teal[50],),)
      ),
    );
  }
}
/* 
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
                    onTap: () {      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => OrderAdminScreen()),
                      );},
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
 */