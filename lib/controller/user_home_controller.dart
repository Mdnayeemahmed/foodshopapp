import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../Screen/AuthService.dart';

class HomeController extends GetxController {
  final CollectionReference<Map<String, dynamic>> restaurantCollection =
  FirebaseFirestore.instance.collection('restaurants');

  final RxList<Map<String, dynamic>> restaurants = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
    getAndSaveToken();
  }

  void fetchRestaurants() {
    restaurantCollection.snapshots().listen((snapshot) {
      final List<Map<dynamic, dynamic>> restaurantData = snapshot.docs.map((doc) {
        final Map<String, dynamic>? data = doc.data();
        if (data != null) {
          final String imageUrl = data['image'] ?? '';
          final String base64Image = data['image'] != null ? data['image'].toString() : '';
          final String restaurantId = doc.id; // Retrieve the document ID

          return {
            'restaurantId': restaurantId, // Pass the document ID
            'restaurantName': data['restaurantName']?.toString() ?? '',
            'category': data['category']?.toString() ?? '',
            'deliveryTime': data['deliveryTime']?.toString() ?? '',
            'imageUrl': imageUrl.isNotEmpty ? base64Image : '',
          };
        }
        return {}; // Empty map if data is null
      }).toList();

      final List<Map<String, dynamic>> typedRestaurantData = restaurantData.cast<Map<String, dynamic>>();
      restaurants.assignAll(typedRestaurantData);
      isLoading.value = false;
    }, onError: (error) {
      print('Error fetching restaurants: $error');
    });
  }

  void getAndSaveToken() async {
    try {
      String? currentUserUID = (await _authService.getCurrentUser())?.uid;
      String deviceToken = await _authService.getDeviceToken();

      if (currentUserUID != null && deviceToken.isNotEmpty) {
        await saveToken(deviceToken, currentUserUID);
      }
    } catch (e) {
      print('Error getting and saving token: $e');
    }
  }

  Future<void> saveToken(String token, String currentUserUID) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection("UserTokens");
      final querySnapshot = await collectionRef.where('currentUserUID', isEqualTo: currentUserUID).get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;
        final existingToken = existingDoc.data()['token'];

        if (existingToken != token) {
          await existingDoc.reference.update({'token': token});
          print('Token updated successfully!');
        } else {
          print('Token already up to date!');
        }
      } else {
        await collectionRef.add({
          'currentUserUID': currentUserUID,
          'token': token,
        });
        print('Token saved successfully!');
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }
}
