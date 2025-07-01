import 'package:flutter/material.dart';
import 'package:rento/componants/card.dart';
import 'package:rento/componants/custom_drawer.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import '../crud.dart';
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
  bool _loading = true;

  bool _showTitle = true;
  void loadFavorites() async {
    var response = await _crud.postRequest(linkGetFav, {
      "user_id": sharedPref.getString("id").toString(),
    });

    if (response["status"] == "success") {
      setState(() {
        _loading = false; // تم تحميل البيانات
        favoriteProperties = List<int>.from(
          response["favorites"].map((id) => int.parse(id.toString())),
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
      drawer: CustomDrawer(
        crud: _crud,
        userType: sharedPref.getString("type").toString(),
      ),
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
            _loading
                ? const Center(child: CircularProgressIndicator())
                : filteredProperties.isEmpty
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
                                  int.parse(property['id']),
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
