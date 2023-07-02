import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/dashboard.dart';
import 'package:foodshopapp/Screen/login_screen.dart';
import 'package:foodshopapp/Screen/resturant_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    checkAndRequestNotificationPermission();
    navigateToDashboard();
  }

  Future<void> checkAndRequestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      setState(() {
        isPermissionGranted = true;
      });
    } else {
      settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      setState(() {
        isPermissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      });
    }

    if (isPermissionGranted) {
      print('Permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Provisional permission granted');
    } else {
      print('Permission declined or has not been accepted');
    }
  }

  void navigateToDashboard() {
    Future.delayed(const Duration(milliseconds: 50), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      bool isRestaurant = prefs.getBool('isRestaurant') ?? false;

      if (isLoggedIn) {
        if (isRestaurant) {
          // Restaurant user is logged in, navigate to the restaurant dashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResturantDeshboard()));
        } else {
          // Regular user is logged in, navigate to the regular dashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      } else {
        // User is not logged in, navigate to the login screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const loginscreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/foodlogo.png',
                width: 200,
              ),
            ),
          ),
          const Column(
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Version 1.0',
                  style: TextStyle(
                    color: greyColor,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
