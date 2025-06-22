import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  static const String routeName = '/notification';
  final RemoteMessage message;
  const NotificationScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Title: ${message.notification?.title ?? "No Title"}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Body: ${message.notification?.body ?? "No Body"}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (message.data.isNotEmpty)
            Text(
              'Data: ${message.data.toString()}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}