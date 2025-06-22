import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rento/main.dart';
import 'package:rento/notifications/notification_screen.dart';

class FirebaseNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Firebase Token: $token");
    } else {
      print("Failed to get Firebase token");
    }
    handleBackgroundMessage();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState!.pushNamed(
      NotificationScreen.routeName,
      arguments: message,
    );
  }

  void handleBackgroundMessage() async{
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
