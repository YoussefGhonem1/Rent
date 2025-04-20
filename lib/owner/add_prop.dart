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
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<bool> _isPlaying = [];

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
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      File videoFile = File(pickedVideo.path);
      setState(() {
        _selectedVideos.add(videoFile);
        VideoPlayerController videoController =
            VideoPlayerController.file(videoFile)
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
        },
        _selectedImages,
        _selectedVideos,
      );

      isLoading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
        sharedPref.getString("type") == "admin"
            ? Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeAdmin()))
            : Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeOwner()));
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
      appBar: AppBar(
        leading: IconButton(
    icon: Icon(Icons.arrow_back , color: Colors.white), // أو أيقونة تانية تعجبك
    onPressed: () {
      Navigator.pop(context); // الرجوع للصفحة السابقة
    },
  ),
        title: const Text("Add Real Estate" , style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),),
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(157, 42, 202, 181),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 45),
                      ),
                      child: const Text("Select Photos",
                          style: TextStyle(fontSize: 16 ,  color: Colors.white) ),
                    ),
                    const SizedBox(height: 20),
                    _selectedImages.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _selectedImages.map((file) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Image.file(
                                    file,
                                    width: 200,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 20),
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
                        : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the location.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the description.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the phone number.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _rentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Rent Amount",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the Rent Amount.";
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: addRealEstate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(157, 42, 202, 181),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16 , color: Colors.white),
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
