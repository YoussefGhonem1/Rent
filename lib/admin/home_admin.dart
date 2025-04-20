
import 'package:flutter/material.dart';
import 'package:rento/admin/control_admin.dart';
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
class _HomeAdminState extends State<HomeAdmin>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];
  String selectedPriceFilter = "All"; // الفلتر الافتراضي

  getRealstates() async {
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
        favoriteProperties =
            List<int>.from(response["favorites"].map((id) => id));
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    loadFavorites();
    getRealstates();
  }

  void filterSearch(String query) {
    setState(() {
      filteredProperties = allProperties.where((property) {
        bool matchesSearch = query.isEmpty ||
            (property['address'] != null &&
                property['address']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()));

        // التأكد من أن rent_amount متاح وقابل للتحويل إلى رقم
        double rentAmount =
            double.tryParse(property['rent_amount'].toString()) ?? 0;

        bool matchesPrice = selectedPriceFilter == "All" ||
            (selectedPriceFilter == "<500" && rentAmount < 500) ||
            (selectedPriceFilter == "500-1000" &&
                rentAmount >= 500 &&
                rentAmount <= 1000) ||
            (selectedPriceFilter == ">1000" && rentAmount > 1000);

        return matchesSearch && matchesPrice;
      }).toList();
    });
  }

  void updatePriceFilter(String filter) {
    setState(() {
      selectedPriceFilter = filter;
      filterSearch(searchController.text); // تحديث القائمة بعد تغيير الفلتر
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: _CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(157, 37, 184, 164),
          leading: IconButton(
          icon: Icon(Icons.menu , color: Colors.white),
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
                color: Colors.white,
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
          child: ListView(
            children: [
              // 🔹 إضافة عنوان للفلترة
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "فلترة حسب السعر",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ]),
              ),

              // 🔹 الفلترة بالأسعار مع التمرير
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    _buildFilterButton("All", "الكل"),
                    SizedBox(width: 5),
                    _buildFilterButton("<500", "أقل من 500"),
                    SizedBox(width: 5),
                    _buildFilterButton("500-1000", "500 - 1000"),
                    SizedBox(width: 5),
                    _buildFilterButton(">1000", "أكثر من 1000"),
                    SizedBox(width: 10),
                  ],
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
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        var property = filteredProperties[index];
                        return InkWell(
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RealEstateDetailsPage(
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
                                  latitude:'${property['latitude']}' ,
                            longitude: '${property['longitude']}',
                                  rating: 0.0,
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
                            isFavorite: favoriteProperties.contains(property[
                                'id']), // ✅ تحديد إذا كان العقار في المفضل
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddRealEstatePage()));
          },
          backgroundColor: Color.fromARGB(157, 42, 202, 181),
          child: const Icon(Icons.add, color: Colors.white),
        ));
  }

  Widget _buildFilterButton(String value, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () => updatePriceFilter(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPriceFilter == value
              ? Color.fromARGB(157, 42, 202, 181)
              : Colors.grey[300],
          foregroundColor:
              selectedPriceFilter == value ? Colors.white : Colors.black,
          /*  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), */
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: selectedPriceFilter == value ? 3 : 1,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
      backgroundColor: Color.fromARGB(157, 42, 202, 181).withOpacity(0.5),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            // User Profile Section
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Image.asset(
                      "images/IMG_6965.PNG", // Add profile image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ListTile(
                    title: Text(
                      sharedPref.getString("username").toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white, // Slightly darker text
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Menu Items
            _buildDrawerItem(
              context,
              title: "Home Page",
              icon: Icons.home,
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeAdmin()));
              },
            ),
            _buildDrawerItem(
              context,
              title: "Control",
              icon: Icons.account_balance_rounded,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ControlAdmin()));
              },
            ),
            _buildDrawerItem(
              context,
              title: "Order",
              icon: Icons.check_box,
              onTap: () {},
            ),
            _buildDrawerItem(
              context,
              title: "Favourites",
              icon: Icons.favorite,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Favorite()));
              },
            ),
            _buildDrawerItem(
              context,
              title: "Contact Us",
              icon: Icons.phone_android_outlined,
              onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminChatList()));
              },
            ),
            _buildDrawerItem(
              context,
              title: "Sign Out",
              icon: Icons.exit_to_app,
              onTap: () {
                sharedPref.clear();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
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
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white, // Neutral dark text for better readability
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.white, // Softer orange for icons
        size: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded edges for items
      ),
      onTap: onTap,
    );
  }
}
