import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utilities/app_colors.dart';
import '../widgets/resturant_card.dart';

class Home extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> restaurantCollection =
  FirebaseFirestore.instance.collection('restaurants');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Now'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: restaurantCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Map> restaurantData = snapshot.data!.docs
                .map((doc) {
              final Map<String, dynamic>? data = doc.data();
              if (data != null) {
                final String imageUrl = data['image'] ?? '';
                final String base64Image =
                data['image'] != null ? data['image'].toString() : '';
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
