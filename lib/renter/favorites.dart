import 'package:flutter/material.dart';
import 'package:rento/chat/chat_screen.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../admin/control_admin.dart';
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
class _FavoriteState extends State<Favorite>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List<dynamic> filteredProperties = [];

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

  
  Future<void> loadallFavorites() async {
    var response = await _crud.postRequest(linkGetAllFav, {
      "user_id": sharedPref.getString("id").toString(),
    });

    if (response["status"] == "success") {
      setState(() {
        filteredProperties = response["data"];
      });
    }
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
      drawer: _CustomDrawer(),
      appBar: AppBar(
          
          leading: IconButton(
          icon: Icon(Icons.menu , color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // كده تفتحه بسهولة
          },
        ),
        title: Text("Favorite Properties" ,  style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),),
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: filteredProperties.isEmpty
            ? Center(child: Text("No favorite properties yet."))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RealEstateDetailsPage(
                            fav: true,
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
                      ).then((value) {
                        if (value == true) {
                          setState(() {}); // إعادة بناء الصفحة لتحديث القائمة
                        }
                      });
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${property['address']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${property['rent_amount']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(157, 42, 202, 181),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '${property['address']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                },
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

            sharedPref.getString("type").toString() == "admin"
                ? _buildDrawerItem(
                    context,
                    title: "Control",
                    icon: Icons.account_balance_rounded,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ControlAdmin()));
                    },
                  )
                : sharedPref.getString("type").toString() == "owner"
                    ? _buildDrawerItem(
                        context,
                        title: "Acount",
                        icon: Icons.account_balance_rounded,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OwnerRealstate()));
                        },
                      )
                    : _buildDrawerItem(
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
                Navigator.pushReplacement(context,
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
