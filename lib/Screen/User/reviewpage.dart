import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodshopapp/Screen/User/reviewformscreen.dart';

class ReviewScreen extends StatelessWidget {
  final String restaurantId;

  const ReviewScreen({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('restaurantId', isEqualTo: restaurantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data?.docs ?? [];

          if (reviews.isEmpty) {
            return Center(child: Text('No reviews available.'));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final reviewData = reviews[index].data();
              final username = reviewData['username'] ?? '';
              final rating = reviewData['rating'] ?? '';
              final comment = reviewData['comment'] ?? '';

              return ListTile(
                title: Text(username),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: $rating'),
                    SizedBox(height: 4),
                    Text(comment),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReviewFormScreen(restaurantId: restaurantId)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

