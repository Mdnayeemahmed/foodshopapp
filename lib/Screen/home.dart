import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/AuthService.dart';
import 'package:foodshopapp/Screen/login_screen.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utilities/app_colors.dart';
import '../widgets/resturant_card.dart';


class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService _authService = AuthService();

  @override
  void initState(){
    super.initState();
    gettoken();
  }

  gettoken() async{
    String? currentUserUID = (await _authService.getCurrentUser())?.uid;
    String deviceToken = await _authService.getDeviceToken();

    setState(() {
      saveToken(deviceToken, currentUserUID!);
    });
  }



  void saveToken(String token, String currentUserUID) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection("UserTokens");
      final querySnapshot = await collectionRef.where('currentUserUID', isEqualTo: currentUserUID).get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;
        final existingToken = existingDoc.data()['token'];

        if (existingToken != token) {
          await existingDoc.reference.update({'token': token});
          print('Token updated successfully!');
        } else {
          print('Token already up to date!');
        }
      } else {
        await collectionRef.add({
          'currentUserUID': currentUserUID,
          'token': token,
        });
        print('Token saved successfully!');
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }





  final CollectionReference<Map<String, dynamic>> restaurantCollection =
  FirebaseFirestore.instance.collection('restaurants');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Now'),
        actions: [
          IconButton(
            onPressed: () async {
              //DocumentSnapshot snap =
              //await FirebaseFirestore.instance.collection('User Tokens').doc('User2').get();
              //String token = snap['token'];
              //print(token);
              //sendPushMessage(token, 'Hlw','Movie Time') ;
             // print(sendPushMessage);
              await _authService.signOut();
              Get.offAll(loginscreen());
            },
            icon: Icon(Icons.output),
          )
        ],
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: restaurantCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Map> restaurantData = snapshot.data!.docs.map((doc) {
              final Map<String, dynamic>? data = doc.data();
              if (data != null) {
                final String imageUrl = data['image'] ?? '';
                final String base64Image = data['image'] != null ? data['image'].toString() : '';
                final String restaurantId = doc.id; // Retrieve the document ID

                return {
                  'restaurantId': restaurantId, // Pass the document ID
                  'restaurantName': data['restaurantName']?.toString() ?? '',
                  'category': data['category']?.toString() ?? '',
                  'deliveryTime': data['deliveryTime']?.toString() ?? '',
                  'imageUrl': imageUrl.isNotEmpty ? base64Image : '',
                };
              }
              return {}; // Empty map if data is null
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'All restaurants',
                    style: TextStyle(
                      color: greyColor,
                      fontSize: 18,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: restaurantData.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      final data = restaurantData[index];
                      return SizedBox(
                        width: 140,
                        child: ResturantCard(
                          resturantId: data['restaurantId'], // Pass the document ID
                          resturantName: data['restaurantName'],
                          category: data['category'],
                          deliveryTime: data['deliveryTime'],
                          imageUrl: data['imageUrl'],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
