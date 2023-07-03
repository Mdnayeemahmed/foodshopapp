import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../controller/Account_contoller.dart';

class Account extends StatelessWidget {
  final AccountController _accountController = Get.put(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: GetBuilder<AccountController>(
        builder: (_) {
          return _accountController.userSnapshot == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _accountController.userSnapshot!['FullName'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(_accountController.userSnapshot!['Email']),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title:
                          Text(_accountController.userSnapshot!['Phonenumber']),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(_accountController.userSnapshot!['Address']),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
