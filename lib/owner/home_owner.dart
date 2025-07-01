import 'package:flutter/material.dart';
import 'package:rento/componants/custom_drawer.dart';
import 'package:rento/linkapi.dart';
import 'package:rento/main.dart';
import 'package:rento/renter/details.dart';
import '../componants/card.dart';
import '../crud.dart';
import 'add_prop.dart';


class HomeOwner extends StatefulWidget {
  const HomeOwner({super.key});

  @override
  State<HomeOwner> createState() => _HomeOwnerState();
}

class _HomeOwnerState extends State<HomeOwner> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Crud _crud = Crud();
  List<int> favoriteProperties = [];
  List allProperties = [];
  List filteredProperties = [];
  bool _loading = true;
  // متحكمات حقول البحث داخل الـ Dialog
  TextEditingController searchNameController = TextEditingController();
  TextEditingController searchFromPriceController = TextEditingController();
  TextEditingController searchToPriceController = TextEditingController();
  // متحكمات لعدد الغرف (مبقوش في RoomCountSection منفصلة)
  TextEditingController searchRoomCountController =
      TextEditingController(); // هنخليه حقل واحد لعدد الغرف بالضبط

  // متغيرات Dropdown لفلترة الأدوار
  String? selectedFloor; // هيكون لاختيار دور واحد فقط

  // قائمة الأدوار المتاحة (تم تعديلها)
  final List<String> floorOptions = ['أرضي', 'أول', 'ثاني'];


  getRealstates() async {
    var response = await _crud.postRequest(linkView, {});
    if (response['status'] == 'success') {
      setState(() {
        _loading = false; // تم تحميل البيانات
        allProperties = response['data'];
        filteredProperties = allProperties; // عرض الكل مبدئياً
      });
    }
    return response;
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

 void loadFavorites() async {
  var response = await _crud.postRequest(linkGetFav, {
    "user_id": sharedPref.getString("id").toString(),
  });

  if (response["status"] == "success") {
    setState(() {
      favoriteProperties = List<int>.from(
        response["favorites"].map((id) => int.parse(id.toString())),
      );    });
  } else {
    print("Failed to load favorites: ${response['message']}"); // طباعة عند الفشل
  }
}

  @override
  void initState() {
    super.initState();
    loadFavorites();
    getRealstates();
  }

  // دالة لتطبيق جميع الفلاتر بناءً على المدخلات
  void applyFilters() {
    List tempFiltered = List.from(allProperties); // ابدأ بكل العقارات

    String nameQuery = searchNameController.text.toLowerCase();
    String fromPrice = searchFromPriceController.text;
    String toPrice = searchToPriceController.text;
    String roomCountQuery = searchRoomCountController.text; // قيمة عدد الغرف

    // فلتر الاسم
    if (nameQuery.isNotEmpty) {
      tempFiltered =
          tempFiltered.where((property) {
            return property['address'] != null &&
                property['address'].toString().toLowerCase().contains(
                  nameQuery,
                );
          }).toList();
    }

    // فلتر السعر
    double? minP = double.tryParse(fromPrice);
    double? maxP = double.tryParse(toPrice);
    if (minP != null || maxP != null) {
      tempFiltered =
          tempFiltered.where((property) {
            double rentAmount =
                double.tryParse(property['rent_amount'].toString()) ?? 0;
            bool matchesMin = minP == null || rentAmount >= minP;
            bool matchesMax = maxP == null || rentAmount <= maxP;
            return matchesMin && matchesMax;
          }).toList();
    }

    // جديد: فلتر عدد الغرف (room_count) - رقمي
    int? targetRoomCount = int.tryParse(roomCountQuery);
    if (targetRoomCount != null) {
      tempFiltered =
          tempFiltered.where((property) {
            int propertyRoomCount =
                int.tryParse(property['room_count']?.toString() ?? '0') ?? 0;
            return propertyRoomCount == targetRoomCount; // مطابقة العدد بالضبط
          }).toList();
    }

    // تعديل: فلتر الطابق (floor_number) - مطابقة نصية
    if (selectedFloor != null) {
      tempFiltered =
          tempFiltered.where((property) {
            String propertyFloor = property['floor_number']?.toString() ?? '';
            return propertyFloor == selectedFloor; // مطابقة الطابق بالضبط
          }).toList();
    }

    setState(() {
      filteredProperties = tempFiltered;
    });
    Navigator.pop(context); // إغلاق الـ Dialog بعد تطبيق الفلاتر
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
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.teal[700],
                        ),
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

                    // جديد: دمج حقول الطابق وعدد الغرف
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
                      hint: Text(
                        "اختر الطابق",
                        style: TextStyle(color: Colors.teal[800]),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        // خيار "مسح الاختيار" للطابق
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            " اختر الطابق",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ...floorOptions.map((String floor) {
                          return DropdownMenuItem<String>(
                            value: floor,
                            child: Text(
                              floor,
                              style: TextStyle(color: Colors.teal[900]),
                            ),
                          );
                        }),
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
                        prefixIcon: Icon(
                          Icons.meeting_room,
                          color: Colors.teal[700],
                        ),
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
                    // مسح الفلاتر وإعادة تحميل العقارات الأصلية
                    _clearFiltersInDialog(
                      setDialogState,
                    ); // مسح حقول الـ Dialog
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

  // جديد: دالة لمسح جميع مدخلات الفلاتر داخل الـ Dialog State
  void _clearFiltersInDialog(Function setDialogState) {
    setDialogState(() {
      searchNameController.clear();
      searchFromPriceController.clear();
      searchToPriceController.clear();
      searchRoomCountController.clear();
      selectedFloor = null; // مسح اختيار الطابق
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      key: _scaffoldKey,
      drawer: CustomDrawer(
        crud: _crud,
        userType: sharedPref.getString("type").toString(),
      ),
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
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProperties.isEmpty
                  ? const Center(child: Text("لا يوجد عقارات متاحة"))
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                    owner_id: '${property['owner_id']}',
                                    title: '${property['address']}',
                                    price: '${property['rent_amount']}',
                                    location: '${property['address']}',
                                    description: '${property['description']}',
                                    terms_and_conditions:
                                        '${property['terms_and_conditions']}',
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
                           int.parse(property['id']),
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          sharedPref.getString("type").toString() == "owner"
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRealEstatePage(),
                    ),
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
              )
              : Container(),
    );
  }
}
