import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodshopapp/utilities/set_color.dart';

import 'AuthService.dart';

class OrderManagementRestaurant extends StatefulWidget {
  const OrderManagementRestaurant({Key? key}) : super(key: key);

  @override
  _OrderManagementRestaurantState createState() =>
      _OrderManagementRestaurantState();
}

class _OrderManagementRestaurantState extends State<OrderManagementRestaurant> {
  late String currentUserId;
  late Stream<QuerySnapshot> orderStream = Stream.empty();
  AuthService _authService = AuthService();


  @override
  void initState() {
    super.initState();
    fetchRestaurantId();
  }

  void fetchRestaurantId() async {
    currentUserId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('userId', isEqualTo: currentUserId)
        .get();

    if (restaurantSnapshot.docs.isNotEmpty) {
      DocumentSnapshot restaurantDocument = restaurantSnapshot.docs[0];
      String restaurantId = restaurantDocument.id;

      setState(() {
        orderStream = FirebaseFirestore.instance
            .collection('orders')
            .where('restaurantId', isEqualTo: restaurantId)
            .snapshots();
      });
    } else {
      // No restaurant found for the current user
      // Handle the scenario accordingly
    }
  }

  void updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': newStatus,
    });

    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      final orderData = orderSnapshot.data() as Map<String, dynamic>?;
      final customerId = orderData?['customerId'] as String?;

      final tokenSnapshot = await FirebaseFirestore.instance
          .collection('UserTokens')
          .where('currentUserUID', isEqualTo: customerId)
          .get();

      if (tokenSnapshot.docs.isNotEmpty) {
        final token = tokenSnapshot.docs.first.data()['token'] as String?;
        print(token);
        _authService.sendPushMessage(token!, newStatus, 'Order Alert');
      } else {
        print('No token found for the customer');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Management')),
      body: Container(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: orderStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                QuerySnapshot orderSnapshot = snapshot.data!;
                List<QueryDocumentSnapshot> orderDocuments = orderSnapshot.docs;
                return ListView.builder(
                  itemCount: orderDocuments.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot orderDocument = orderDocuments[index];
                    String orderId = orderDocument.id;
                    String orderStatus = (orderDocument.data()
                                as Map<String, dynamic>)['orderStatus']
                            as String? ??
                        '';
                    List<Map<String, dynamic>> orderItems = (orderDocument
                                    .data()
                                as Map<String, dynamic>)['orderedItems'] !=
                            null
                        ? List<Map<String, dynamic>>.from((orderDocument.data()
                            as Map<String, dynamic>)['orderedItems'])
                        : [];

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getStatusColor(orderStatus),
                          ),
                          title: Text('Order ID: $orderId'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Items:'),
                              ...orderItems.map((item) {
                                String itemName =
                                    item['itemName'] as String? ?? '';
                                return Text('$itemName');
                              }),
                            ],
                          ),
                          trailing: Text('Status: $orderStatus'),
                        ),
                        if (orderStatus == 'Pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  updateOrderStatus(orderId, 'Processing');

                                  //add notification
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text('Accept'),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Cancel Order'),
                                        content: Text(
                                            'Are you sure you want to cancel this order?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              updateOrderStatus(
                                                  orderId, 'Cancelled');
                                              //add notification

                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Yes'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Reject'),
                              ),
                            ],
                          ),
                        if (orderStatus == 'Processing')
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Mark as Delivered'),
                                    content: Text(
                                        'Are you sure you want to mark this order as delivered?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          updateOrderStatus(
                                              orderId, 'Delivered');
                                          //add notification

                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text('Mark as Delivered'),
                          ),
                        Divider(),
                      ],
                    );
                  },
                );
              } else {
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Text('Please Wait'));
              }
            },
          ),
        ),
      ),
    );
  }
}
