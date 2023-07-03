import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screen/AuthService.dart';

class AccountController extends GetxController {
  DocumentSnapshot? userSnapshot;
  AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final currentUser = await _authService.getCurrentUser();
    final currentUserId = currentUser?.uid;

    if (currentUserId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .get();

      userSnapshot = userDoc;
      update(); // Notify the listeners that the data has changed
    }
  }
}
