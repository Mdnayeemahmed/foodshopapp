import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../widgets/order_card.dart';

class TrackOrder extends StatefulWidget {
  const TrackOrder({Key? key}) : super(key: key);

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final User? user = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot>? _orderSubscription;
  Timer? _timer;
  bool _isOrderCancelled = false;

  @override
  void initState() {
    super.initState();
    startOrderTimer();
  }

  @override
  void dispose() {
    cancelOrderTimer();
    _orderSubscription?.cancel();
    super.dispose();
  }

  void startOrderTimer() {
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: user!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final orderData = snapshot.docs[0].data() as Map<String, dynamic>;
        final orderStatus = orderData['orderStatus'] as String? ?? '';
        final placedTimestamp = orderData['placedTimestamp'] as Timestamp?;

        if (orderStatus == 'Pending' &&
            placedTimestamp != null &&
            !_isOrderCancelled) {
          final currentTime = Timestamp.now();
          final difference = currentTime.millisecondsSinceEpoch -
              placedTimestamp.millisecondsSinceEpoch;

          if (difference >= 60000) { // 1 minute = 60 seconds = 60000 milliseconds
            cancelOrder();
            setState(() {
              _isOrderCancelled = true;
            });
          } else {
            final remainingTime = 60000 - difference;
            startTimer(remainingTime);
          }
        }
      }
    });
  }

  void startTimer(int duration) {
    cancelOrderTimer();
    _timer = Timer(Duration(milliseconds: duration), () {
      cancelOrder();
      setState(() {
        _isOrderCancelled = true;
      });
    });
  }

  void cancelOrder() {
    FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: user!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final orderRef = snapshot.docs[0].reference;
        orderRef.update({'orderStatus': 'Cancelled'});
      }
    });
  }

  void cancelOrderTimer() {
    _timer?.cancel();
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
