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
  const EditRealEstatePage({
    super.key,
    this.realdata,
  });

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

  // Lists to store selected images and videos
  List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<bool> _isPlaying = [];

  // Request permission to manage external storage
  Future<void> _requestPermissions() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      // Permissions granted, continue with media picking
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Storage permission is required to select images/videos')),
      );
    }
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages =
            pickedImages.map((pickedFile) => File(pickedFile.path)).toList();
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

  // Handle form submission
  /* void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      final location = _locationController.text;
      final description = _descriptionController.text;
      final phone = _phoneController.text;
      final rentAmount = _rentAmountController.text;
      final saleAmount = _saleAmountController.text;

      /* // Handle form submission (e.g., send to server or database)
      print("Location: $location");
      print("Description: $description");
      print("Phone: $phone");
      print("Rent Amount: $rentAmount");
      print("Sale Amount: $saleAmount");
 */
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );

      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedImages = [];
        _selectedVideos = [];
        _videoControllers.forEach((controller) => controller.dispose());
        _videoControllers.clear();
        _isPlaying.clear();
      });
    }
  } */

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

  @override
  void dispose() {
    super.dispose();
    // Dispose video controllers to avoid memory leaks
    for (var controller in _videoControllers) {
      controller.dispose();
    }
  }

  editRealstate() async {
    isloading = true;
    setState(() {});

    try {
      var response;

      response = await _crud.postRequestWithMultipleFiles(
          linkEdit,
          {
            "id": widget.realdata['id'].toString(),
            "address": _locationController.text,
            "description": _descriptionController.text,
            "phone": _phoneController.text,
            "rent_amount": _rentAmountController.text,
            "imagename": widget.realdata['images'].toString(),
          },
          _selectedImages,
          _selectedVideos);

      isloading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
       sharedPref.getString("type") == "admin"
          ? Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ControlAdmin()))
          : Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OwnerRealstate()));
      } else {
        print("Registration failed");
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
    
    /* _selectedImages = List<String>.from(widget.realdata['photos']).map((uri) => File('$linkImageRoot/$uri')).toList(); */

  /*   _selectedVideos = List<String>.from(widget.realdata['videos']).map((uri) => File('$linkVideoRoot/$uri')).toList(); */
    super.initState();
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
        title: const Text("Edit Real Estate"  , style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),),
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
      ),
      body: isloading == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Photos Button
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(157, 42, 202, 181),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 45),
                      ),
                      child: const Text("Select Photos",
                          style: TextStyle(fontSize: 16 , color: Colors.white)),
                    ),
                    const SizedBox(height: 20),

                    // Display selected images
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

                    // Select Video Button
                    ElevatedButton(
                      onPressed: _pickVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(157, 42, 202, 181),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 50),
                      ),
                      child: const Text("Select Video",
                          style: TextStyle(fontSize: 16 , color: Colors.white)),
                    ),
                    const SizedBox(height: 20),

                    // Display selected videos
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

                    // Address Field
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

                    // Description Field
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

                    // Phone Number Field
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
                    // Rent Amount Field
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
                    const SizedBox(height: 20),

                    // Sale Amount (Optional) Field
                    TextFormField(
                      controller: _saleAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Sale Amount (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await editRealstate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(157, 42, 202, 181),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                        ),
                        child: const Text(
                          "Edit",
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
