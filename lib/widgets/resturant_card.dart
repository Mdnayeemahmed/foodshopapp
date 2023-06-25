import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen/menupage.dart';
import '../utilities/app_colors.dart';
import 'dart:convert';

class ResturantCard extends StatelessWidget {
  final String resturantId; // Add resturantId parameter
  final String resturantName;
  final String category;
  final String deliveryTime;
  final String imageUrl;

  const ResturantCard({
    required this.resturantId,
    required this.resturantName,
    required this.category,
    required this.deliveryTime,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(imageUrl);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 140,
        child: InkWell(
          onTap: () {
            Get.to(MenuPage(restaurantId: resturantId)); // Pass the resturantId parameter
          },
          borderRadius: BorderRadius.circular(10),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: primaryColor.withOpacity(0.2),
            child: Column(
              children: [
                Image.memory(
                  imageBytes,
                  width: 132,
                  height: 90,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resturantName,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.3,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.3,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: greyColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Within ' + deliveryTime,
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 0.3,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: greyColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
