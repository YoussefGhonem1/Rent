import 'package:flutter/material.dart';
import 'package:rento/admin/approve_screen.dart';
import 'package:rento/admin/order_admin_screen.dart';
import 'package:rento/chat/chat_screen.dart';
import 'package:rento/componants/card.dart';
import 'package:rento/componants/custom_drawer.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/owner/owner_orders_screen.dart';
import 'package:rento/renter/renter_orders_screen.dart';
import '../auth/login.dart';
import '../crud.dart';
import '../owner/home_owner.dart';
import '../owner/ownerrealstates.dart';
import '../renter/details.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

//with Crud
class _FavoriteState extends State<Favorite> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List<dynamic> filteredProperties = [];
  TextEditingController searchController = TextEditingController();
  List allProperties = [];

  bool _showTitle = true;
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

  Future<void> loadallFavorites() async {
    var response = await _crud.postRequest(linkGetAllFav, {
      "user_id": sharedPref.getString("id").toString(),
    });

    if (response["status"] == "success") {
      setState(() {
        allProperties = response['data'];
        filteredProperties = List.from(
          allProperties,
        ); // نسخ البيانات إلى filteredProperties
        filteredProperties = response["data"];
      });
    }
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
    loadFavorites();
    loadallFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      /* drawer: _CustomDrawer(), */
       drawer: CustomDrawer(crud: _crud, userType: sharedPref.getString("type").toString()), 
      appBar: AppBar(
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
        backgroundColor: Colors.teal[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child:
            filteredProperties.isEmpty
                ? Center(
                  child: Text(
                    "لا توجد عقارات مفضله",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                )
                : Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _showTitle ? 50 : 0,
                      child: Center(
                        child: Text(
                          "العقارات المفضله",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification) {
                            setState(() {
                              _showTitle = notification.metrics.pixels < 50;
                            });
                          }
                          return true;
                        },
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                              AlwaysScrollableScrollPhysics(), // تمكين التمرير
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.69,
                              ),
                          itemCount:
                              filteredProperties
                                  .length, // استخدام filteredProperties
                          itemBuilder: (context, index) {
                            var property =
                                filteredProperties[index]; // استخدام filteredProperties
                            return InkWell(
                              onTap: () async {
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RealEstateDetailsPage(
                                          fav: true,
                                          favoriteProperties:
                                              favoriteProperties,
                                          images: List<String>.from(
                                            property['photos'],
                                          ),
                                          videos: List<String>.from(
                                            property['videos'],
                                          ),
                                          id: '${property['id']}',
                                          owner_id: '${property['owner_id']}',
                                             terms_and_conditions:
                                            '${property['terms_and_conditions']}',
                                          title: '${property['address']}',
                                          price: '${property['rent_amount']}',
                                          location: '${property['address']}',
                                          description:
                                              '${property['description']}',
                                          phone: '${property['phone']}',
                                          state:
                                              '${property['property_state']}',
                                          latitude: '${property['latitude']}',
                                          longitude: '${property['longitude']}',
                                          floor_number:
                                              '${property['floor_number']}',
                                          room_count:
                                              '${property['room_count']}',
                                          property_direction:
                                              '${property['property_direction']}',
                                          rating: '${property['rate']}',
                                        ),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    setState(
                                      () {},
                                    ); // إعادة بناء الصفحة لتحديث القائمة
                                  }
                                });
                              },
                              child: RealEstateCard(
                                image:
                                    "$linkImageRoot/${property['photos'][0]}",
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
                      ),
                    ),
                  ],
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
                            "admin") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderAdminScreen(),
                            ),
                          );
                        } else if (sharedPref.getString("type").toString() ==
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
                  (sharedPref.getString("type").toString() == "admin")
                      ? const Divider(color: Colors.white54, height: 10)
                      : Spacer(),

                  (sharedPref.getString("type").toString() == "admin")
                      ? _buildDrawerItem(
                        context,
                        title: "طلبات التاكيد", // "Favorites" in Arabic
                        icon: Icons.approval,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Approve()),
                          );
                        },
                      )
                      : SizedBox(),
                  const Divider(color: Colors.white54, height: 10),
                  _buildDrawerItem(
                    context,
                    title: "تواصل معنا", // "Contact Us" in Arabic
                    icon: Icons.contact_support,
                    onTap: () async {
                      try {
                        var response = await Crud().postRequest(
                          linkCreateChat,
                          {"user_id": sharedPref.getString("id").toString()},
                        );

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
                  (sharedPref.getString("type").toString() == "admin")
                      ? SizedBox(height: 200)
                      : SizedBox(height: 270),
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
