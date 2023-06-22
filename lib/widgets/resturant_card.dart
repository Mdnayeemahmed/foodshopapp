import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen/menupage.dart';
import '../utilities/app_colors.dart';

class resturant_card extends StatelessWidget {
  const resturant_card({
    super.key, required this.ResturantName, required this.Catagory, required this.DeliveryTime, required this.ImageUrl,
  });
  final String ResturantName,Catagory,DeliveryTime, ImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 140,
        child: InkWell(
          onTap: () {
            Get.to(MenuPage());
          },
          borderRadius: BorderRadius.circular(10),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            shadowColor: primaryColor.withOpacity(0.2),
            child: Column(
              children: [
                Image.network(
                  ImageUrl,
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
                        ResturantName,
                        style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.3,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        Catagory,
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.3,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: greyColor.withOpacity(0.7)),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Within in ' +DeliveryTime ,
                        style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.3,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: greyColor.withOpacity(0.7)),
                      ),
                      SizedBox(
                        height: 4,
                      )

                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
