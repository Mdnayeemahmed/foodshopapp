import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/account.dart';
import 'package:foodshopapp/Screen/cart.dart';
import 'package:foodshopapp/Screen/home.dart';
import 'package:foodshopapp/Screen/track.dart';
import 'package:get/get.dart';

import '../controller/bottom_bar_nav_controller.dart';
import '../utilities/app_colors.dart';

class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  final BottombarNavController _bottombarNavController =
  Get.put(BottombarNavController());

  List<Widget> _screens = [
    Home(),
    trackorder(),
    cart(),
    account()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BottombarNavController>(
          builder: (controller) {
            return _screens[controller.selectedindex];
          }
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
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account")
              ],
            );
          }
      ),
    );
  }
}
