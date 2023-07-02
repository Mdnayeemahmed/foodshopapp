import 'package:cloud_firestore/cloud_firestore.dart';
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
    gettoken();
  }


  gettoken() async {
    String? currentUserUID = (await _authService.getCurrentUser())?.uid;
    String deviceToken = await _authService.getDeviceToken();

    setState(() {
      retrieveRestaurantId(currentUserUID!, deviceToken);
    });
  }

  void retrieveRestaurantId(String currentUserUID, String deviceToken) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .where("userId", isEqualTo: currentUserUID)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot doc = snapshot.docs.first;
        final String restaurantId = doc.id;

        saveToken(deviceToken, currentUserUID, restaurantId);
      } else {
        print("No restaurant found with matching userId");
      }
    } catch (e) {
      print('Error retrieving restaurant ID: $e');
    }
  }




  void saveToken(String token, String currentUserUID, String resturantid) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection("UserTokens");
      final querySnapshot = await collectionRef.where('currentUserUID', isEqualTo: currentUserUID).get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;
        final existingToken = existingDoc.data()['token'];
        final existingResturantId = existingDoc.data()['resturantid'];

        if (existingToken != token || existingResturantId != resturantid) {
          await existingDoc.reference.update({
            'token': token,
            'resturantid': resturantid,
          });
          print('Token and resturantid updated successfully!');
        } else {
          print('Token and resturantid already up to date!');
        }
      } else {
        await collectionRef.add({
          'currentUserUID': currentUserUID,
          'token': token,
          'resturantid': resturantid,
        });
        print('Token and resturantid saved successfully!');
      }
    } catch (e) {
      print('Error saving token and resturantid: $e');
    }
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
