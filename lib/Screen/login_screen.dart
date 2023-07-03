import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/Resturant/resturant_dashboard.dart';
import 'package:foodshopapp/Screen/User/dashboard.dart';
import 'package:foodshopapp/Screen/signup.dart';
import 'package:get/get.dart';
import '../../utilities/common_style.dart';
import '../../widgets/common_button_style.dart';
import '../../widgets/common_password_field.dart';
import '../../widgets/common_text_field.dart';
import 'AuthService.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({Key? key}) : super(key: key);

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService _authService = AuthService();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/foodlogo.png',
                  height: 100,
                  width: 100,
                ),
                Text(
                  "Welcome Back",
                  style: titleStyle,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Please Enter Your Email Address",
                  style: subStyle,
                ),
                SizedBox(
                  height: 16,
                ),
                commontextfield(
                  controller: _emailcontroller,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter A Valid Email';
                    }
                    return null;
                  },
                  hinttext: 'Email Address',
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 16,
                ),
                commonpasstextfield(
                  controller: _passcontroller,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter Your password';
                    }
                    return null;
                  },
                  hinttext: 'Password',
                  textInputType: TextInputType.visiblePassword,
                ),
                SizedBox(
                  height: 16,
                ),
                Stack(
                  children: [
                    commonbuttonstyle(
                      tittle: 'Login',
                      onTap: () async {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          UserCredential? userCredential =
                          await _authService.signInWithEmailAndPassword(
                            _emailcontroller.text.toString(),
                            _passcontroller.text.toString(),
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          if (userCredential != null) {
                            // Sign in successful
                            print('sign in');

                            DocumentSnapshot snapshot = await _firestore
                                .collection('Users')
                                .doc(userCredential.user!.uid)
                                .get();

                            bool isRestaurant =
                                (snapshot.data() as Map<String, dynamic>)['IsRestaurant'] as bool? ?? false;

                            print(isRestaurant);

                            if (isRestaurant) {
                              Get.offAll(ResturantDeshboard());
                            } else {
                              Get.offAll(Dashboard());
                            }
                          } else {
                            // Sign in failed
                            // Show an error message or perform other actions
                            Get.snackbar(
                              'Login Failed',
                              'Invalid email or password',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    Get.to(Signup());
                    //Navigator.pushNamed(context, "/signup");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: subStyle,
                      ),
                      Text(
                        " Sign Up",
                        style: highlight,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
