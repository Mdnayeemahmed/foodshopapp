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

  @override
  void initState() {
    super.initState();
    navigateToDashboard();
  }

  void navigateToDashboard() {
    Future.delayed(Duration(milliseconds: 50), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      bool isRestaurant = prefs.getBool('isRestaurant') ?? false;

      if (isLoggedIn) {
        if (isRestaurant) {
          // Restaurant user is logged in, navigate to the restaurant dashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResturantDeshboard()));
        } else {
          // Regular user is logged in, navigate to the regular dashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
        }
      } else {
        // User is not logged in, navigate to the login screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginscreen()));
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
          Column(
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
