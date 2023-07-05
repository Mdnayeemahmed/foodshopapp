import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewFormScreen extends StatefulWidget {
  final String restaurantId;

  const ReviewFormScreen({required this.restaurantId});

  @override
  _ReviewFormScreenState createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(
                  labelText: 'Rating',
                  hintText: 'within 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the rating';
                  }
                  final rating = int.tryParse(value);
                  if (rating == null || rating < 1 || rating > 10) {
                    return 'Please enter a valid rating between 1 and 10';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Comment',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your comment';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitReview();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitReview() {
    final String username = _usernameController.text.trim();
    final String rating = _ratingController.text.trim();
    final String comment = _commentController.text.trim();

    if (username.isNotEmpty && rating.isNotEmpty && comment.isNotEmpty) {
      // Check if the user has a delivered order with the restaurant
      FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .where('orderStatus', isEqualTo: 'Delivered')
          .get()
          .then((querySnapshot) {
        if (querySnapshot.size > 0) {
          // User has a delivered order, allow review submission
          FirebaseFirestore.instance.collection('reviews').add({
            'restaurantId': widget.restaurantId,
            'username': username,
            'rating': rating,
            'comment': comment,
          }).then((_) {
            // Review submitted successfully
            Navigator.pop(context); // Go back to the previous screen
          }).catchError((error) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('Failed to submit review: $error'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('You can only submit a review after a delivered order from this restaurant.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to check order history: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all the fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
