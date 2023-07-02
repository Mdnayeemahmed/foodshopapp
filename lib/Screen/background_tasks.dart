import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';

void backgroundTaskCallback() {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  FirebaseFirestore.instance
      .collection('orders')
      .where('customerId', isEqualTo: user.uid)
      .where('orderStatus', isEqualTo: 'Pending')
      .get()
      .then((snapshot) {
    for (final doc in snapshot.docs) {
      final orderId = doc.id;
      final orderData = doc.data() as Map<String, dynamic>;
      final placedTimestamp = orderData['placedTimestamp'] as Timestamp?;

      if (placedTimestamp != null) {
        final currentTime = Timestamp.now();
        final difference = currentTime.millisecondsSinceEpoch -
            placedTimestamp.millisecondsSinceEpoch;

        if (difference >= 60000) {
          FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({'orderStatus': 'Cancelled'})
              .catchError((error) {
            // Handle the error if necessary
          });
        }
      }
    }
  });
}

void callbackDispatcher() {
  final workmanager = Workmanager();
  workmanager.executeTask((task, inputData) {
    backgroundTaskCallback();
    return Future.value(true);
  });
}

void registerBackgroundTasks() {
  final workmanager = Workmanager();
  workmanager.initialize(callbackDispatcher);
  workmanager.registerPeriodicTask(
    "backgroundTask",
    "backgroundTask",
    frequency: Duration(minutes: 1),
  );
}
