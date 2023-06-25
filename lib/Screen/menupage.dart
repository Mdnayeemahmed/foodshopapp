import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:foodshopapp/Screen/cart.dart';

class MenuPage extends StatelessWidget {
  final String restaurantId;

  const MenuPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('menus')
            .doc(restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final menuData = snapshot.data!.data();
              final menuItems = menuData?['menuItems'] as List<dynamic>?;

              if (menuItems != null) {
                return ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final data = menuItems[index];
                    final base64Image = data['base64Image'] as String?;

                    return ListTile(
                      leading: base64Image != null
                          ? Image.memory(
                        base64Decode(base64Image),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey, // Placeholder color
                      ),
                      title: Text(
                        data['itemName'] ?? '',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['description'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${(data['price'] as num?)?.toDouble().toStringAsFixed(2) ?? ''}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          final FirebaseAuth _auth = FirebaseAuth.instance;
                          final User? user = _auth.currentUser;
                          if (user != null) {
                            final String userId = user.uid;
                            addToCart(data, restaurantId, userId, context);
                          } else {
                            print('User is not signed in');
                          }
                        },
                        child: Text('Add to Cart'),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No menu items available.'));
              }
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void addToCart(Map<String, dynamic> itemData, String restaurantId, String userId, BuildContext context) {
    // Get the item details
    final String itemName = itemData['itemName'] as String? ?? '';
    final double itemPrice = (itemData['price'] as num?)?.toDouble() ?? 0.0;

    // Create the cart item object
    final cartItem = {
      'itemName': itemName,
      'price': itemPrice,
    };

    // Check if the cart document exists for the user and restaurant
    FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .where('restaurantId', isEqualTo: restaurantId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size > 0) {
        // Cart document exists, update the orderedItems array
        final cartDoc = querySnapshot.docs.first;
        final List<dynamic> orderedItems = cartDoc.data()['orderedItems'] as List<dynamic>;
        orderedItems.add(cartItem);
        cartDoc.reference.update({
          'orderedItems': orderedItems,
        }).then((_) {
          showSnackbar(context, 'Item added to cart', 'View Cart');
        }).catchError((error) {
          showSnackbar(context, 'Failed to add item to cart: $error', 'Retry');
        });
      } else {
        // Cart document does not exist, create a new one
        FirebaseFirestore.instance
            .collection('cart')
            .add({
          'userId': userId,
          'restaurantId': restaurantId,
          'orderedItems': [cartItem],
        })
            .then((_) {
          showSnackbar(context, 'Item added to cart', 'View Cart');
        }).catchError((error) {
          showSnackbar(context, 'Failed to add item to cart: $error', 'Retry');
        });
      }
    }).catchError((error) {
      showSnackbar(context, 'Failed to check cart existence: $error', 'Retry');
    });
  }

  void showSnackbar(BuildContext context, String message, String actionText) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: actionText,
          onPressed: () {
            // Handle snackbar action here
            if (actionText == 'View Cart') {
              // Navigate to the cart page
              // Replace `CartPage` with the actual cart page widget
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            } else if (actionText == 'Retry') {
              // Retry the action
              // Implement your retry logic here
            }
          },
        ),
      ),
    );
  }
}

