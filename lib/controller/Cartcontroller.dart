import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen/AuthService.dart';
import '../Screen/cartitem.dart';

class CartController extends GetxController {
  AuthService _authService = AuthService();
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  void fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final cartCollection = FirebaseFirestore.instance.collection('cart');
      final cartQuery = cartCollection.where('userId', isEqualTo: userId);

      cartQuery.snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final cartData = snapshot.docs.first.data();
          final List<dynamic> orderedItems = cartData['orderedItems'] ?? [];

          cartItems.value = orderedItems
              .map((item) =>
              CartItem(
                dishName: item['itemName'],
                price: item['price'],
              ))
              .toList();

          calculateTotalPrice();
        } else {
          cartItems.clear();
          totalPrice.value = 0.0;
        }
      });
    }
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (final item in cartItems.value) {
      total += item.price;
    }
    totalPrice.value = total;
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    calculateTotalPrice();
    update(); // Notify GetX that the cart items have changed
  }
  void placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      final userName = userData?['FullName'] as String?;
      final userPhoneNumber = userData?['Phonenumber'] as String?;
      final userAddress = userData?['Address'] as String?;

      final cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        final cartData = cartSnapshot.docs.first.data();
        final restaurantId = cartData['restaurantId'] as String?;

        final orderData = {
          'customerId': userId,
          'restaurantId': restaurantId,
          'totalPrice': totalPrice.value,
          'orderedItems': cartItems.map((item) {
            return {
              'itemName': item.dishName,
              'price': item.price,
            };
          }).toList(),
          'placedTimestamp': Timestamp.now(),
          'name': userName,
          'phoneNumber': userPhoneNumber,
          'address': userAddress,
          'orderStatus': 'Pending',
        };

        await FirebaseFirestore.instance.collection('orders').add(orderData);

        final tokenSnapshot = await FirebaseFirestore.instance
            .collection('UserTokens')
            .where('resturantid', isEqualTo: restaurantId)
            .get();

        if (tokenSnapshot.docs.isNotEmpty) {
          final token = tokenSnapshot.docs.first.data()['token'] as String?;
          print(token);
          _authService.sendPushMessage(token!, 'New Order Available', 'New Order Alert');
        } else {
          print('No token found for the restaurant');
        }

        // Remove the cart document for the user
        cartSnapshot.docs.forEach((doc) {
          doc.reference.delete();
          update();
        });

        Get.dialog(
          AlertDialog(
            title: Text('Order Placed'),
            content: Text('Your order has been placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back(); // Pop back to the previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            title: Text('Error'),
            content: Text('Failed to retrieve restaurant ID from cart.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text('Cart document not found.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
