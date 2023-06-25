import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/account.dart';
import 'package:foodshopapp/Screen/cart.dart';
import 'package:foodshopapp/Screen/cartitem.dart';
import 'package:foodshopapp/Screen/home.dart';
import 'package:foodshopapp/Screen/track.dart';
import 'package:get/get.dart';

import '../controller/bottom_bar_nav_controller.dart';
import '../utilities/app_colors.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final BottombarNavController _bottombarNavController =
  Get.put(BottombarNavController());

  List<Widget> _screens = [
    Home(),
    trackorder(),
    CartPage(),
    account(),
  ];

   // Keep track of cart items here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BottombarNavController>(
        builder: (controller) {
          return _screens[controller.selectedindex];
        },
      ),
      bottomNavigationBar: GetBuilder<BottombarNavController>(
        builder: (controller) {
          return BottomNavigationBar(
            onTap: (value) {
              controller.Changeindex(value);
            },
            currentIndex: controller.selectedindex,
            selectedItemColor: primaryColor,
            unselectedItemColor: greyColor,
            showUnselectedLabels: true,
            unselectedLabelStyle: TextStyle(color: softGreyColor),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.location_on), label: "Track"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart), label: "Cart"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
            ],
          );
        },
      ),
    );
  }
}
