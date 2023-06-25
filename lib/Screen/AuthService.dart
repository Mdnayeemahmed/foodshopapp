import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('Users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String fullName, bool isResturant) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save additional user data to Firestore
      await _usersCollection.doc(userCredential.user!.uid).set({
        'Email': email,
        'FullName': fullName,
        'IsRestaurant': isResturant,

      });

      return userCredential;
    } catch (e) {
      // Handle sign-up errors
      print('Sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot snapshot = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      bool isRestaurant =
          (snapshot.data() as Map<String, dynamic>)['IsRestaurant'] as bool? ?? false;

      // Save user login status and user type
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('isRestaurant', isRestaurant);
      print(isRestaurant);

      return userCredential;
    } catch (e) {
      // Handle sign-in errors
      print('Sign in error: $e');
      return null;
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user login status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);

      await _auth.signOut();
    } catch (e) {
      // Handle sign-out errors
      print('Sign out error: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
