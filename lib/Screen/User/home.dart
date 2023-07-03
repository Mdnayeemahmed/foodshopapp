import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user_home_controller.dart';
import '../../utilities/app_colors.dart';
import '../../widgets/resturant_card.dart';
import '../AuthService.dart';
import '../login_screen.dart';

class Home extends StatelessWidget {
  final AuthService _authService = AuthService();
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Now'),
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.signOut();
              Get.offAll(loginscreen());
            },
            icon: Icon(Icons.output),
          )
        ],
      ),
      body: Obx(
            () {
          if (_homeController.restaurants.isNotEmpty) {
            final restaurantData = _homeController.restaurants;
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
