import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/CreateMenu.dart';
import 'package:foodshopapp/Screen/Ordermanagmentresturant.dart';
import 'package:get/get.dart';

import '../utilities/app_colors.dart';
import '../utilities/common_style.dart';
import '../widgets/common_container.dart';
import 'AuthService.dart';
import 'Create_Your_Resturant.dart';
import 'login_screen.dart';

class ResturantDeshboard extends StatefulWidget {
  const ResturantDeshboard({Key? key}) : super(key: key);

  @override
  State<ResturantDeshboard> createState() => _ResturantDeshboardState();
}

class _ResturantDeshboardState extends State<ResturantDeshboard> {
  AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          flexibleSpace: Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Are You Cooking Today!',
                  style: titleStyle,
                ),
                Text(
                  _user?.email ?? '',
                  style: subStyle,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await _authService.signOut();
                  Get.offAll(loginscreen());
                },
                icon: Icon(Icons.output))
          ],
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              common_container(
                title: 'Create Your Resturant',
                onTap: () {
                  Get.to(CreateRestaurant());
                },
              ),
              SizedBox(
                width: 10,
              ),
              common_container(
                title: 'Create Menu',
                onTap: () {
                  Get.to(Createmenu());
                },
              ),
              SizedBox(
                width: 10,
              ),
              common_container(
                title: 'View On Going Order',
                onTap: () {
                  Get.to(OrderManagementRestaurant());
                },
              )
            ],
          ),
        ));
  }
}
