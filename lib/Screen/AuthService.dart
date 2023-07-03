import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';




class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('Users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String fullName, bool isResturant,String address,String Phonenumber) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save additional user data to Firestore
      await _usersCollection.doc(userCredential.user!.uid).set({
        'Email': email,
        'FullName': fullName,
        'IsRestaurant': isResturant,
        'Address':address,
        'Phonenumber':Phonenumber
      });

      return userCredential;
    } catch (e) {
      // Handle sign-up errors
      print('Sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot snapshot = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      bool isRestaurant =
          (snapshot.data() as Map<String, dynamic>)['IsRestaurant'] as bool? ?? false;

      // Save user login status and user type
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('isRestaurant', isRestaurant);
      print(isRestaurant);

      return userCredential;
    } catch (e) {
      // Handle sign-in errors
      print('Sign in error: $e');
      return null;
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user login status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);

      await _auth.signOut();
    } catch (e) {
      // Handle sign-out errors
      print('Sign out error: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }



  Future getDeviceToken() async{
    FirebaseMessaging _firebasemessage=FirebaseMessaging.instance;
    String? deviceToken=await _firebasemessage.getToken();
    return (deviceToken==null) ? '' : deviceToken ;
  }

  Future<void> sendPushMessage(String token, String body, String title) async {
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final String serverKey = 'AAAAvqpQ2g8:APA91bGoV6xWidZFuKQB0fT5rd7wA-FS-gOCC36L56iBA13bgo7NX5MuFvStZmq0_mJcJa4NKzAcAr2fe6-h1pfApnnCtiG0WtHjuddISHMsfrQ_q1EWte-gDKkAk4Ty8RHnZ2JhLET8'; // Replace with your FCM server key

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final Map<String, dynamic> data = {
      'priority': 'high',
      'data': {
        'click_action': 'done',
        'status': 'done',
        'body': body,
        'title': title,
      },
      'notification': {
        'title': title,
        'body': body,
      },
      'to': token,
    };

    try {
      final http.Response response = await http.post(url, headers: headers, body: jsonEncode(data));

      if (response.statusCode == 200) {
        print('Push notification sent successfully!');
        //showNotification(title, body);
        print('ep');
      } else {
        print('Failed to send push notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending push notification: $e');
      }
    }
  }

  Future<void> showNotification(String title, String body) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
}
