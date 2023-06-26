import 'package:flutter/material.dart';

import '../utilities/set_color.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String orderStatus;

  const OrderCard({required this.orderId, required this.orderStatus});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(orderStatus),
        ),
        title: Text('Order ID: $orderId'),
        subtitle: Text('Order Status: $orderStatus'),
      ),
    );
  }
}
