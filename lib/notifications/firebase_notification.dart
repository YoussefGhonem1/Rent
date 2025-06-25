import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // استيراد الحزمة الجديدة
import 'dart:convert'; // لإعادة استخدام jsonDecode
import 'package:rento/main.dart';
import 'package:rento/notifications/notification_screen.dart';

// تعريف كائن الـ notifications plugin على مستوى أعلى
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ********************************************************************
// دالة جديدة على مستوى أعلى لمعالجة النقر على الإشعارات في الخلفية
// يجب أن تكون هذه الدالة top-level أو static.
@pragma('vm:entry-point') // هام جداً لضمان وصول Flutter إليها في الخلفية
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification background tap received!');
  if (notificationResponse.payload != null) {
    try {
      final RemoteMessage message = RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
      // هنا يمكنك استدعاء handleMessage إذا كنت تريد نفس السلوك
      // ولكن تذكر أن navigatorKey قد لا يكون متاحًا بشكل موثوق في السياقات الخلفية
      // لذلك يفضل معالجة التوجيه أو البيانات بشكل مختلف هنا إذا كان التطبيق مغلقًا تمامًا.
      FirebaseNotifications().handleMessage(message); // سيحاول التوجيه
    } catch (e) {
      print("Error parsing background notification payload: $e");
    }
  }
}
// ********************************************************************

class FirebaseNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // دالة لتهيئة الإشعارات المحلية
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // هذه الدالة تعمل عندما يكون التطبيق في المقدمة أو الخلفية ويتم النقر على الإشعار
        if (response.payload != null) {
          final RemoteMessage message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // استخدام الدالة top-level هنا
    );
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Firebase Token: $token");
    } else {
      print("Failed to get Firebase token");
    }

    // هنا يتم الاستماع للرسائل الواردة عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      // عرض الإشعار المحلي
      if (message.notification != null) {
        showLocalNotification(message);
      }
    });

    handleBackgroundMessage();
  }

  // دالة لعرض الإشعار المحلي
  Future<void> showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // يجب أن تكون فريدة
      'Your Channel Name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // id الإشعار (يمكن أن يكون فريداً لكل إشعار)
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: jsonEncode(message.toMap()), // إرسال حمولة الرسالة كـ payload
    );
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // التأكد من أن navigatorKey جاهز للاستخدام
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(
        NotificationScreen.routeName,
        arguments: message,
      );
    } else {
      print("Navigator key is null, cannot navigate to NotificationScreen.");
      // يمكنك تخزين الرسالة مؤقتا هنا أو عرضها بطريقة أخرى
    }
  }

  void handleBackgroundMessage() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}