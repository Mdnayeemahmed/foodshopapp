import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/set_color.dart';

class OrderCard extends StatefulWidget {
  final String orderId;
  final String orderStatus;

  const OrderCard({required this.orderId, required this.orderStatus});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  Timer? _countdownTimer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    if (widget.orderStatus == 'Pending') {
      startCountdown();
    }
  }

  @override
  void dispose() {
    cancelCountdown();
    super.dispose();
  }

  void startCountdown() {
    final DateFormat formatter = DateFormat('mm:ss');
    final DateTime expirationTime = DateTime.now().add(Duration(minutes: 20));

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final DateTime currentTime = DateTime.now();
      final Duration remainingTime = expirationTime.difference(currentTime);

      if (remainingTime.inSeconds <= 0) {
        cancelCountdown();
        return;
      }

      final String formattedRemainingTime = formatter.format(
        DateTime(
          0,
          0,
          0,
          0,
          remainingTime.inMinutes,
          remainingTime.inSeconds % 60,
        ),
      );

      setState(() {
        _countdown = formattedRemainingTime;
      });
    });

    final String formattedExpirationTime = formatter.format(
      DateTime(
        0,
        0,
        0,
        0,
        expirationTime.minute,
        expirationTime.second,
      ),
    );

    setState(() {
      _countdown = formattedExpirationTime;
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(widget.orderStatus),
        ),
        title: Text('Order ID: ${widget.orderId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Status: ${widget.orderStatus}'),
            if (widget.orderStatus == 'Pending')
              Text('Time Remaining To Accept or Cancel Order: $_countdown'),
          ],
        ),
      ),
    );
  }
}
