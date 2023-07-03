import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../widgets/order_card.dart';

class TrackOrder extends StatefulWidget {
  const TrackOrder({Key? key}) : super(key: key);

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final User? user = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot>? _orderSubscription;
  Map<String, Timer> _orderTimers = {}; // Store timers for each order
  Map<String, bool> _isOrderCancelled = {
  }; // Track cancellation state for each order

  @override
  void initState() {
    super.initState();
    startOrderSubscription();
  }

  @override
  void dispose() {
    cancelOrderSubscription();
    cancelAllOrderTimers();
    super.dispose();
  }

  void startOrderSubscription() {
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: user!.uid)
        .where('orderStatus', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final orderId = change.doc.id;
        final orderData = change.doc.data() as Map<String, dynamic>;
        final placedTimestamp = orderData['placedTimestamp'] as Timestamp?;

        if (change.type == DocumentChangeType.added) {
          if (placedTimestamp != null &&
              !_isOrderCancelled.containsKey(orderId)) {
            final currentTime = Timestamp.now();
            final difference = currentTime.millisecondsSinceEpoch -
                placedTimestamp.millisecondsSinceEpoch;

            if (difference >= 60000) {
              cancelOrder(orderId);
              setState(() {
                _isOrderCancelled[orderId] = true;
              });
            } else {
              final remainingTime = 60000 - difference;
              startTimer(orderId, remainingTime);
            }
          }
        } else if (change.type == DocumentChangeType.modified) {
          if (orderData['orderStatus'] == 'Cancelled') {
            cancelOrderTimer(orderId);
            setState(() {
              _isOrderCancelled[orderId] = true;
            });
          }
        }
      }
    });
  }

  void cancelOrderSubscription() {
    _orderSubscription?.cancel();
  }

  void startTimer(String orderId, int duration) {
    cancelOrderTimer(orderId);
    _orderTimers[orderId] = Timer(Duration(milliseconds: duration), () {
      cancelOrder(orderId);
      setState(() {
        _isOrderCancelled[orderId] = true;
      });
    });
  }

  void cancelOrder(String orderId) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'orderStatus': 'Cancelled'})
        .catchError((error) {
      // Handle the error if necessary
    });
  }

  void cancelOrderTimer(String orderId) {
    _orderTimers[orderId]?.cancel();
  }

  void cancelAllOrderTimers() {
    for (final timer in _orderTimers.values) {
      timer.cancel();
    }
    _orderTimers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final orderList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              final orderId = orderList[index].id;
              final order = orderList[index].data() as Map<String, dynamic>;
              final orderStatus = order['orderStatus'] as String? ?? '';

              return OrderCard(
                orderId: orderId,
                orderStatus: orderStatus,
              );
            },
          );
        },
      ),
    );
  }
}
