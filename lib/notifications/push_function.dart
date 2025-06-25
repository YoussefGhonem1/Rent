import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // لاستيراد rootBundle
import 'package:rento/crud.dart';
import 'package:rento/linkapi.dart'; // تأكد أن linkGetFcmToken معرف هنا
import 'package:googleapis_auth/auth_io.dart';


final Crud _crud = Crud(); // قم بإنشاء كائن Crud إذا لزم الأمر

const String _firebaseProjectId = 'makanak-c9d5f';



Future<String?> _getAccessToken() async {
  try {
   
    final String serviceAccountJsonString = await rootBundle.loadString('assets/makanak-c9d5f-firebase-adminsdk-fbsvc-6237763e22.json');

    // 2. فك تشفير السلسلة إلى Map
    final Map<String, dynamic> serviceAccountJson = jsonDecode(serviceAccountJsonString);

    // 3. إنشاء بيانات الاعتماد
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    // النطاق المطلوب لإرسال رسائل FCM
    final List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      serviceAccountCredentials,
      scopes,
    );
    return client.credentials.accessToken.data;
  } catch (e) {
    print("Error getting access token: $e");
    return null;
  }
}

Future<void> sendNotificationToUserV1(
  String targetUserId,
  String title,
  String body,
) async {
  try {
    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print("Failed to get OAuth 2.0 Access Token.");
      return;
    }
    print("Access Token obtained successfully.");

    var response = await _crud.postRequest(
      linkGetFcmToken, // يجب أن يكون هذا الرابط لنقطة نهاية PHP التي تجلب توكن المستخدم
      {"user_id": targetUserId},
    );

    if (response != null &&
        response['status'] == 'success' &&
        response['fcm_token'] != null) {
      String targetFcmToken = response['fcm_token'];
      print("Target FCM Token retrieved: $targetFcmToken");

      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$_firebaseProjectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': targetFcmToken,
          'notification': {'title': title, 'body': body},
          'data': {
            // تم تغيير أسماء المفاتيح لتجنب أي تعارضات محتملة
            // القيم يجب أن تكون strings
            'custom_message_type': 'custom_alert',
            'target_user_id': targetUserId,
            'event_timestamp': DateTime.now().toIso8601String(),
          },
        },
      };

      final http.Response fcmResponse = await http.post(
        Uri.parse(fcmEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (fcmResponse.statusCode == 200) {
        print("Notification sent successfully to user $targetUserId!");
        print("FCM Response: ${fcmResponse.body}");
      } else {
        print(
          "Failed to send notification. Status Code: ${fcmResponse.statusCode}",
        );
        print("FCM Response Body: ${fcmResponse.body}");
      }
    } else {
      print(
        "Failed to retrieve FCM token for user $targetUserId: ${response?['message'] ?? 'Unknown error'}",
      );
    }
  } catch (e) {
    print("Exception occurred while sending notification: $e");
  }
}