import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateRestaurant extends StatefulWidget {
  const CreateRestaurant({Key? key}) : super(key: key);

  @override
  _CreateRestaurantState createState() => _CreateRestaurantState();
}

class _CreateRestaurantState extends State<CreateRestaurant> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  String _selectedCategory = '';
  final _deliveryTimeController = TextEditingController();
  File? _imageFile;
  String? _base64Image;

  List<String> _categories = [
    'Fast Food',
    'Bangla,Thai,Chinese',
    'Dessert',
    'Coffee Shop',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = base64Encode(_imageFile!.readAsBytesSync());
      });
    }
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Restaurant'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(labelText: 'Restaurant Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the restaurant name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _deliveryTimeController,
                  decoration: const InputDecoration(labelText: 'Delivery Time'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the delivery time.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (_imageFile != null) ...[
                  const Text('Selected Image:'),
                  const SizedBox(height: 8.0),
                  Image.file(_imageFile!, height: 150.0),
                ],
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await _pickImage(ImageSource.gallery);
                  },
                  child: const Text('Select Image'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _createRestaurant();
                    }
                  },
                  child: const Text('Create Restaurant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createRestaurant() async {
    final restaurantName = _restaurantNameController.text;
    final category = _selectedCategory;
    final deliveryTime = _deliveryTimeController.text;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        final restaurantQuery = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('restaurantName', isEqualTo: restaurantName)
            .where('userId', isEqualTo: uid)
            .get();

        if (restaurantQuery.docs.isNotEmpty) {
          // Restaurant already exists for the current user
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('You have already created a restaurant with the same name.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          final restaurantData = {
            'restaurantName': restaurantName,
            'category': category,
            'deliveryTime': deliveryTime,
            'image': _base64Image,
            'userId': uid,
          };

          await FirebaseFirestore.instance
              .collection('restaurants')
              .add(restaurantData);

          // Reset form fields
          _restaurantNameController.clear();
          _selectedCategory = '';
          _deliveryTimeController.clear();
          setState(() {
            _imageFile = null;
            _base64Image = null;
          });

          // Show success message or navigate to the next screen
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Restaurant created successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create restaurant: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
