import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../utilities/set_color.dart';

class OrderCard extends StatefulWidget {
  final String orderId;
  final String orderStatus;
  final int? remainingTime;

  const OrderCard({
    required this.orderId,
    required this.orderStatus,
    this.remainingTime,
  });

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with TickerProviderStateMixin {
  BehaviorSubject<DateTime> _currentTimeStream = BehaviorSubject<DateTime>();
  StreamSubscription<DateTime>? _subscription;
  AnimationController? _controller;
  Animation<double>? _animation;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    subscribeToCurrentTime();
    startCountdown();
  }

  @override
  void dispose() {
    _currentTimeStream.close();
    _subscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void subscribeToCurrentTime() {
    _subscription = Stream.periodic(Duration(seconds: 1), (_) => DateTime.now())
        .listen((currentTime) {
      _currentTimeStream.add(currentTime);
    });
  }

  void startCountdown() {
    final DateFormat formatter = DateFormat('mm:ss');
    final DateTime expirationTime = DateTime.now().add(Duration(minutes: 20));
    final DateTime currentTime = DateTime.now();
    final Duration remainingTime = widget.remainingTime != null
        ? Duration(milliseconds: widget.remainingTime!)
        : expirationTime.difference(currentTime);

    if (remainingTime.inSeconds <= 0) {
      cancelCountdown();
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: remainingTime.inMilliseconds),
    );

    _animation = Tween<double>(begin: remainingTime.inMilliseconds.toDouble(), end: 0).animate(_controller!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          cancelCountdown();
        }
      });

    _controller!.forward();

    Timer.periodic(Duration(seconds: 1), (_) {
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
  }

  void cancelCountdown() {
    setState(() {
      _countdown = 'Expired';
    });
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
              AnimatedBuilder(
                animation: _animation!,
                builder: (context, child) {
                  final milliseconds = _animation!.value.toInt();
                  final formattedTime = DateFormat('mm:ss').format(DateTime(0, 0, 0, 0, 0, 0, 0).add(Duration(milliseconds: milliseconds)));

                  return Text(
                    'Time Remaining To Update Order: $formattedTime',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
