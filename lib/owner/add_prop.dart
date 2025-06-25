import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../admin/home_admin.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../main.dart';
import 'home_owner.dart';

class AddRealEstatePage extends StatefulWidget {
  const AddRealEstatePage({super.key});

  @override
  _AddRealEstatePageState createState() => _AddRealEstatePageState();
}

class _AddRealEstatePageState extends State<AddRealEstatePage> {
  bool isLoading = false;
  final Crud _crud = Crud();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _saleAmountController = TextEditingController();
   final TextEditingController _termsAndConditionsController = TextEditingController();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<bool> _isPlaying = [];
  String? selectedFloor; // لتخزين القيمة المختارة
  int? selectedRooms; // لتخزين القيمة المختارة
  String? selectedDirection; // لتخزين القيمة المختارة

  // Pick multiple images
  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          pickedImages.map((pickedFile) => File(pickedFile.path)).toList(),
        );
      });
    }
  }

  // Pick video
  Future<void> _pickVideo() async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo != null) {
      File videoFile = File(pickedVideo.path);
      setState(() {
        _selectedVideos.add(videoFile);
        VideoPlayerController videoController = VideoPlayerController.file(
            videoFile,
          )
          ..initialize().then((_) {
            setState(() {});
          });
        _videoControllers.add(videoController);
        _isPlaying.add(false); // Video initially paused
      });
    }
  }

  // Toggle play/pause for a video
  void _togglePlayPause(int index) {
    setState(() {
      if (_isPlaying[index]) {
        _videoControllers[index].pause();
      } else {
        _videoControllers[index].play();
      }
      _isPlaying[index] = !_isPlaying[index];
    });
  }

  // Upload images and videos
  addRealEstate() async {
    isLoading = true;
    setState(() {});

    try {
      var response = await _crud.postRequestWithMultipleFiles(
        linkAdd,
        {
          "owner_id": sharedPref.getString("id").toString(),
          "address": _locationController.text,
          "description": _descriptionController.text,
          "phone": _phoneController.text,
          "rent_amount": _rentAmountController.text,
          "sale_amount": _saleAmountController.text,
          "floor_number": selectedFloor.toString(),
          "room_count": selectedRooms.toString(),
          "property_direction": selectedDirection.toString(),
           "terms_and_conditions": _termsAndConditionsController.text,
        },
        _selectedImages,
        _selectedVideos,
      );

      isLoading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
        sharedPref.getString("type") == "admin"
            ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeAdmin()),
            )
            : Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeOwner()),
            );
      } else {
        print("Adding real estate failed");
      }
    } catch (e) {
      isLoading = false;
      setState(() {});
      print("Exception occurred: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.teal[50],
          ), // أو أيقونة تانية تعجبك
          onPressed: () {
            Navigator.pop(context); // الرجوع للصفحة السابقة
          },
        ),
        title: Text(
          "العوده الى الرئيسيه",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal[50],
          ),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "اعرض عقارك وتواصل مع الالاف",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _pickImages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[800],
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 45,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "اضافه صور",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.teal[50],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ليس اجبارى و لكن ضروري لتساعد الآخرين على اتخاذ القرار",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal[50],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _selectedImages.isNotEmpty
                          ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  _selectedImages.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final file = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.teal.shade100,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                file,
                                                width: 200,
                                                height: 250,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // زر الحذف
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Material(
                                              color: Colors.redAccent,
                                              shape: CircleBorder(),
                                              elevation: 2,
                                              child: InkWell(
                                                customBorder: CircleBorder(),
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          )
                          : const SizedBox.shrink(),
                      /*   const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(157, 42, 202, 181),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 50),
                      ),
                      child: const Text("Select Video",
                          style: TextStyle(fontSize: 16 ,  color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    _selectedVideos.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _selectedVideos.map((file) {
                                int index = _selectedVideos.indexOf(file);
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 250,
                                        child: VideoPlayer(
                                            _videoControllers[index]),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isPlaying[index]
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.black,
                                        ),
                                        onPressed: () =>
                                            _togglePlayPause(index),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : const SizedBox.shrink(), */
                      const SizedBox(height: 10),
                      Form(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // حقل الموقع
                                TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    labelText: "الموقع",
                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.teal[900],
                                      fontSize: 14,
                                    ),
                                    hintText: "(مكان يسهل فتحه على الخريطه)",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء إدخال الموقع";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // قسم رقم الطابق
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'رقم الطابق',

                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  dropdownColor:
                                      Colors.teal[50], // لون الخلفية للقائمة
                                  iconEnabledColor: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(15),
                                  style: TextStyle(
                                    // ده لون القيمة المعروضة بعد الاختيار
                                    color: Colors.teal[900],
                                    fontSize: 16,
                                  ),
                                  value: selectedFloor,
                                  items:
                                      [
                                        'أرضي',
                                        'أول',
                                        'ثاني',
                                        'ثالث',
                                        'رابع',
                                        'خامس',
                                      ].map((floor) {
                                        return DropdownMenuItem(
                                          value: floor,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              floor,
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .teal[900], // ده لون العناصر داخل القائمة فقط
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFloor = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                // قسم عدد الغرف
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'عدد الغرف',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[900],
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      children:
                                          [1, 2, 3, 4, 5].map((room) {
                                            return ChoiceChip(
                                              label: Text('$room'),
                                              selected: selectedRooms == room,
                                              onSelected: (bool selected) {
                                                setState(() {
                                                  selectedRooms =
                                                      selected ? room : null;
                                                });
                                              },
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'واجهة العقار',
                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  dropdownColor:
                                      Colors.teal[50], // لون الخلفية للقائمة
                                  iconEnabledColor: Colors.teal[900],
                                  borderRadius: BorderRadius.circular(15),
                                  value: selectedDirection,
                                  style: TextStyle(
                                    // ده لون القيمة المعروضة بعد الاختيار
                                    color: Colors.teal[900],
                                    fontSize: 16,
                                  ),
                                  items:
                                      [
                                        'بحري',
                                        'قبلي',
                                        'غربي',
                                        'شرقي',
                                        'بحري غربي',
                                        'قبلي شرقي',
                                        'بحري شرقي',
                                        'قبلي غربي',
                                      ].map((dir) {
                                        return DropdownMenuItem(
                                          value: dir,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              dir,
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .teal[900], // ده لون العناصر داخل القائمة فقط
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDirection = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                // حقل الوصف
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    labelText: "الوصف",
                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    alignLabelWithHint: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء إدخال الوصف";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _termsAndConditionsController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    labelText: "الشروط التى يجب ان يتبعها المستأجر",
                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    alignLabelWithHint: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء إدخال الوصف";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // قسم معلومات الاتصال
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "رقم الهاتف",
                                    labelStyle: TextStyle(
                                      color: Colors.teal[900],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء إدخال رقم الهاتف";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _rentAmountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "تكلفة الإيجار",
                                    hintText:
                                        "يتم خصم 10% من قيمه الايجار رسوم",
                                    hintStyle: TextStyle(
                                      color: Colors.teal[900],
                                      fontSize: 14, // حجم مناسب للقراءة
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ), // أضف حدودًا خفيفة
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // حدود الحقل عند عدم التركيز
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // حدود الحقل عند التركيز
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.teal[900]!,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.attach_money,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء إدخال التكلفة";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 30),

                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // عرض مربع الحوار
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible:
                                            false, // لمنع الإغلاق بالضغط خارج الصندوق
                                        builder:
                                            (ctx) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              backgroundColor: Colors.teal[50],
                                              title: Text(
                                                'تأكيد',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.teal[900],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                'هل أنت متأكد من إضافة العقار؟',style: TextStyle(
                                                      color: Colors.teal[900],
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      ctx,
                                                    ).pop(false);
                                                  },
                                                  child: Text(
                                                    'إلغاء',
                                                    style: TextStyle(
                                                      color: Colors.teal[900],
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.teal[800],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop(true);
                                                  },
                                                  child: Text(
                                                    'متأكد',
                                                    style: TextStyle(
                                                      color: Colors.teal[50],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );

                                      // إذا اختار "متأكد" ننفذ الإضافة
                                      if (confirmed == true) {
                                        addRealEstate();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[800],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 125,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "إضافة العقار",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.teal[50],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
