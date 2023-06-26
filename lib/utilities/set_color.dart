import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Pending':
      return Colors.yellow;
    case 'Processing':
      return Colors.yellow;
    case 'Delivered':
      return Colors.green;
    case 'Cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}