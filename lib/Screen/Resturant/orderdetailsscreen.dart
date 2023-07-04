import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found'));
          }

          DocumentSnapshot orderSnapshot = snapshot.data!;
          Map<String, dynamic> orderData = orderSnapshot.data() as Map<String, dynamic>;
          String customerName = orderData['name'] ?? '';
          double totalPrice = orderData['totalPrice'] ?? 0.0;
          String phoneNumber = orderData['phoneNumber'] ?? '';
          String Address = orderData['address'] ?? '';


          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: $orderId',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Customer Name: $customerName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone Number: $phoneNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Address: $Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Order Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderData['orderedItems'].length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> item = orderData['orderedItems'][index];
                    String itemName = item['itemName'] ?? '';
                    int quantity = item['quantity'] ?? 1;
                    double price = item['price'] ?? 0.0;

                    return ListTile(
                      title: Text(itemName),
                      subtitle: Text('Quantity: $quantity\nPrice: \$${price.toStringAsFixed(2)}'),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Order Status: ${orderData['orderStatus']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
