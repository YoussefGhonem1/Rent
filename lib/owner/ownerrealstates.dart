
import 'package:flutter/material.dart';
import 'package:rento/chat/chat_screen.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/renter/details.dart';
import '../auth/login.dart';
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
class _OwnerRealstateState extends State<OwnerRealstate>  {
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
        filteredProperties =
            List.from(allProperties); // نسخ البيانات إلى filteredProperties
        favoriteProperties =
            List<int>.from(response["favorites"].map((id) => id));
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
      filteredProperties = allProperties.where((property) {
        print("🔍 Checking property: ${property['address']}"); // Debugging

        bool matchesSearch = query.isEmpty ||
            (property['address'] != null &&
                property['address']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()));

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
        favoriteProperties =
            List<int>.from(response["favorites"].map((id) => id));
      
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: allProperties.isEmpty
                  ? Center(
                      child:
                          Center(child:Text(
                              "لا يوجد عقارات متاحة") )) // عرض مؤشر تحميل أثناء جلب البيانات
                  : filteredProperties.isEmpty
                      ? Center(
                          child: Text(
                              "لا يوجد عقارات متاحة")) // عرض رسالة إذا لم يتم العثور على نتائج
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
                          itemCount: filteredProperties
                              .length, // استخدام filteredProperties
                          itemBuilder: (context, index) {
                            var property = filteredProperties[
                                index]; // استخدام filteredProperties
                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RealEstateDetailsPage(
                                      fav: false,
                                      favoriteProperties: favoriteProperties,
                                      images:
                                          List<String>.from(property['photos']),
                                      videos:
                                          List<String>.from(property['videos']),
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
                                loadFavorites();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                  
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5 ,vertical: 3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Property Image
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          child: Image.network(
                                            "$linkImageRoot/${property['photos'][0]}",
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                    
                                        // Property Details
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${property['address']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${property['rent_amount']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      157, 42, 202, 181),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 14,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      '${property['address']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    
                                        // Edit and Delete Buttons
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
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
                                                            builder: (context) =>
                                                                EditRealEstatePage(
                                                                    realdata:
                                                                        property)));
                                                  },
                                                  icon: const Icon(Icons.edit,
                                                      size: 16 , color: Colors.white),
                                                  label: const Text('Edit' , style: TextStyle(
                                                 
                                                    color: Colors.white,
                                                  ),),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            157, 42, 202, 181),
                                                    textStyle: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Flexible(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    var response =
                                                        await _crud.postRequest(
                                                            linkDelete, {
                                                      "id": property['id']
                                                          .toString(),
                                                    });
                                                    if (response['status'] ==
                                                        "success") {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OwnerRealstate()));
                                                    }
                                                  },
                                                  icon: const Icon(Icons.delete,
                                                      size: 14 , color: Colors.white),
                                                  label: const Text('Delete', style: TextStyle(
                                                 
                                                    color: Colors.white,
                                                  ),),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                    backgroundColor:
                                                        Colors.red.shade400,
                                                    textStyle: const TextStyle(
                                                        fontSize: 12),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddRealEstatePage()));
        },
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
        child: const Icon(Icons.add, color: Colors.white),
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
                    MaterialPageRoute(builder: (context) => HomeOwner()));
              },
            ),
            _buildDrawerItem(
              context,
              title: "Account",
              icon: Icons.account_balance_rounded,
              onTap: () {},
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
                              chatId: int.parse(response['chat_id'].toString()),
                              userId: int.parse(sharedPref.getString("id")!),
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
          fontSize: 18,
          color: Colors.white, // Neutral dark text for better readability
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.white, // Softer orange for icons
        size: 26,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded edges for items
      ),
      onTap: onTap,
    );
  }
}
