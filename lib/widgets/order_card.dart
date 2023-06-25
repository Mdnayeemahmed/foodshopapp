import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String orderStatus;

  const OrderCard({required this.orderId, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (orderStatus) {
      case 'Pending':
        statusColor = Colors.yellow;
        break;
      case 'Process':
        statusColor = Theme.of(context).primaryColor;
        break;
      case 'Delivery':
        statusColor = Colors.green;
        break;
      case 'Cancel':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
        break;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
        ),
        title: Text('Order ID: $orderId'),
        subtitle: Text('Order Status: $orderStatus'),
      ),
    );
  }
}
