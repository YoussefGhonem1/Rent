import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

 String _basicAuth = 'Basic ${base64Encode(utf8.encode('youssef:2028142003'))}';

Map<String, String> myheaders = {'authorization': _basicAuth}; 

class Crud {
  getRequest(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        return responsebody;
      } else {
        print("Error ${response.statusCode}");
      }
    } catch (e) {
      print("Error Catch $e");
    }
  }

  /*  postRequest(String url, Map data) async {
    try {
      var response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        return responsebody;
      } else {
        print("Error ${response.statusCode}");
      }
    } catch (e) {
      print("Error Catch $e");
    }
  } */

  postRequest(String url, Map<String, String> data) async {
    try {
      var response =
          await http.post(Uri.parse(url), body: data , headers: myheaders );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

   postRequestWithFile(String url, Map<String, String> data, File file) async {
    var request = http.MultipartRequest("post", Uri.parse(url));
    var length = await file.length();
    var stream = http.ByteStream(file.openRead());
    var multipartFile = http.MultipartFile("file", stream, length,
        filename: basename(file.path));
     request.headers.addAll(myheaders); 
    request.files.add(multipartFile);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    var myrequest = await request.send();

    var response = await http.Response.fromStream(myrequest);
    if (myrequest.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("error");
    }
  }
  


postRequestWithMultipleFiles(
  String url,
  Map<String, String> data,
  List<File> photos,
  List<File> videos,
) async {
  try {
    var request = http.MultipartRequest("POST", Uri.parse(url));

    // Add headers if needed
    request.headers.addAll(myheaders); 

    // Add text data
    data.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add photo files
    for (File photo in photos) {
      var stream = http.ByteStream(photo.openRead());
      var length = await photo.length();
      var multipartFile = http.MultipartFile(
        "photos[]", // Naming the input to handle multiple photos
        stream,
        length,
        filename: basename(photo.path),
      );
      request.files.add(multipartFile);
    }

    // Add video files
    for (File video in videos) {
      var stream = http.ByteStream(video.openRead());
      var length = await video.length();
      var multipartFile = http.MultipartFile(
        "videos[]", // Naming the input to handle multiple videos
        stream,
        length,
        filename: basename(video.path),
      );
      request.files.add(multipartFile);
    }

    // Send the request
    var myRequest = await request.send();
    var response = await http.Response.fromStream(myRequest);

    if (myRequest.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.body}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}


}
  
 