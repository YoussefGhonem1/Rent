import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../admin/control_admin.dart';
import '../crud.dart';
import '../linkapi.dart';
import '../main.dart';
import 'ownerrealstates.dart';

class EditRealEstatePage extends StatefulWidget {
  final realdata;
  const EditRealEstatePage({super.key, this.realdata});

  @override
  _EditRealEstatePageState createState() => _EditRealEstatePageState();
}

class _EditRealEstatePageState extends State<EditRealEstatePage> {
  bool isloading = false;
  final Crud _crud = Crud();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _saleAmountController = TextEditingController();
  String? selectedFloor;
  int? selectedRooms;
  String? selectedDirection;
  List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<bool> _isPlaying = [];

  Future<void> _requestPermissions() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب منح صلاحيات الوصول لتحديد الصور/الفيديوهات'),
        ),
      );
    }
  }

  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages =
            pickedImages.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

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
        _isPlaying.add(false);
      });
    }
  }

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

  editRealstate() async {
    isloading = true;
    setState(() {});

    try {
      var response = await _crud.postRequestWithMultipleFiles(
        linkEdit,
        {
          "id": widget.realdata['id'].toString(),
          "address": _locationController.text,
          "description": _descriptionController.text,
          "phone": _phoneController.text,
          "rent_amount": _rentAmountController.text,
          "imagename": widget.realdata['images'].toString(),
          "floor_number": selectedFloor.toString(),
          "room_count": selectedRooms.toString(),
          "property_direction": selectedDirection.toString(),
        },
        _selectedImages,
        _selectedVideos,
      );

      isloading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
        sharedPref.getString("type") == "admin"
            ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ControlAdmin()),
            )
            : Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerRealstate()),
            );
      }
    } catch (e) {
      isloading = false;
      setState(() {});
      print("Exception occurred: $e");
    }
  }

  @override
  void initState() {
    _descriptionController.text = widget.realdata['description'];
    _phoneController.text = widget.realdata['phone'];
    _locationController.text = widget.realdata['address'];
    _rentAmountController.text = widget.realdata['rent_amount'];
    selectedFloor = widget.realdata['floor_number']?.toString();
    selectedRooms =
        widget.realdata['room_count'] != null
            ? int.tryParse(widget.realdata['room_count'].toString())
            : null;
    selectedDirection =
        widget.realdata['property_direction']?.toString();
        
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[50]),
          onPressed: () => Navigator.pop(context),
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
          isloading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "تعديل بيانات العقار",
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
                                "تعديل الصور",
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
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Material(
                                              color: Colors.redAccent,
                                              shape: const CircleBorder(),
                                              elevation: 2,
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap:
                                                    () => setState(
                                                      () => _selectedImages
                                                          .removeAt(index),
                                                    ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: "الموقع",
                                labelStyle: TextStyle(color: Colors.teal[900]),
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
                                if (value?.isEmpty ?? true) {
                                  return "الرجاء إدخال الموقع";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'رقم الطابق',
                                labelStyle: TextStyle(color: Colors.teal[900]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownColor: Colors.teal[50],
                              iconEnabledColor: Colors.teal[900],
                              borderRadius: BorderRadius.circular(15),
                              style: TextStyle(
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
                                      ]
                                      .map(
                                        (floor) => DropdownMenuItem(
                                          value: floor,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              floor,
                                              style: TextStyle(
                                                color: Colors.teal[900],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (value) =>
                                      setState(() => selectedFloor = value),
                            ),
                            const SizedBox(height: 20),
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
                                      [1, 2, 3, 4, 5]
                                          .map(
                                            (room) => ChoiceChip(
                                              label: Text('$room'),
                                              selected: selectedRooms == room,
                                              onSelected:
                                                  (selected) => setState(
                                                    () =>
                                                        selectedRooms =
                                                            selected
                                                                ? room
                                                                : null,
                                                  ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'واجهة العقار',
                                labelStyle: TextStyle(color: Colors.teal[900]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownColor: Colors.teal[50],
                              iconEnabledColor: Colors.teal[900],
                              borderRadius: BorderRadius.circular(15),
                              style: TextStyle(
                                color: Colors.teal[900],
                                fontSize: 16,
                              ),
                              value: selectedDirection,
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
                                      ]
                                      .map(
                                        (dir) => DropdownMenuItem(
                                          value: dir,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              dir,
                                              style: TextStyle(
                                                color: Colors.teal[900],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (value) =>
                                      setState(() => selectedDirection = value),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: "الوصف",
                                labelStyle: TextStyle(color: Colors.teal[900]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return "الرجاء إدخال الوصف";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "رقم الهاتف",
                                labelStyle: TextStyle(color: Colors.teal[900]),
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
                                if (value?.isEmpty ?? true) {
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
                                hintText: "يتم خصم 10% من قيمه الايجار رسوم",
                                hintStyle: TextStyle(
                                  color: Colors.teal[900],
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
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
                                if (value?.isEmpty ?? true) {
                                  return "الرجاء إدخال التكلفة";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          backgroundColor: Colors.teal[50],
                                          title: Text(
                                            'تأكيد',
                                            style: TextStyle(
                                              color: Colors.teal[900],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'هل أنت متأكد من تعديل العقار؟',
                                            style: TextStyle(
                                              color: Colors.teal[900],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
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
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
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
                                  if (confirmed == true) await editRealstate();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[800],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 120,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "حفظ التعديلات",
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
                    ],
                  ),
                ),
              ),
    );
  }
}
