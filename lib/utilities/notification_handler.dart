import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  // Instance of Flutternotification plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();


  static void initialize() {
    // Initialization  setting for android
    const InitializationSettings initializationSettingsAndroid =
    InitializationSettings(
        android: AndroidInitializationSettings("@drawable/ic_launcher"));
    _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      // to handle event when we receive notification
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {}
      },
    );
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (message.notification != null) {
        print(message.notification!.android!.sound);

        NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            message.notification!.android!.sound ?? "Channel Id",
            message.notification!.android!.sound ?? "Main Channel",
            groupKey: "gfg",
            color: Colors.green,
            importance: Importance.max,
            playSound: true,
            priority: Priority.high,
          ),
        );

        await _notificationsPlugin.show(
          id,
          message.notification?.title,
          message.notification?.body,
          notificationDetails,
          payload: message.data['route'],
        );
      } else {
        // Handle the case where the notification payload is null or doesn't contain the required properties
        // Display a default notification without any specific settings

        await _notificationsPlugin.show(
          id,
          'Default Title', // Replace with a default title
          'Default Body', // Replace with a default body
          null, // Set notificationDetails to null for default settings
          payload: message.data['route'],
        );
      }
    } catch (e) {
      print('error');
      debugPrint(e.toString());
    }
  }
}