import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class Createmenu extends StatefulWidget {
  const Createmenu({Key? key}) : super(key: key);

  @override
  State<Createmenu> createState() => _CreatemenuState();
}

class _CreatemenuState extends State<Createmenu> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<Map<String, dynamic>> _menuItems = [];
  File? _imageFile;
  String? userId = FirebaseAuth.instance.currentUser?.uid;


  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  String _convertImageToBase64() {
    if (_imageFile == null) {
      return '';
    }
    final bytes = _imageFile!.readAsBytesSync();
    return base64Encode(bytes);
  }

  void _saveMenuItem() {
    final String itemName = _itemNameController.text;
    final String description = _descriptionController.text;
    final double price = double.parse(_priceController.text);
    final String base64Image = _convertImageToBase64();

    _menuItems.add({
      'itemName': itemName,
      'description': description,
      'price': price,
      'base64Image': base64Image,
    });

    _itemNameController.clear();
    _descriptionController.clear();
    _priceController.clear();

    // Reset the selected image
    setState(() {
      _imageFile = null;
    });
  }

  void _submitMenuItems() async {
    if (_menuItems.isEmpty) {
      return; // No menu items to save
    }

    final QuerySnapshot userRestaurantsSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('userId', isEqualTo: userId) // Replace 'userId' with the logged-in user's ID
        .get();

    if (userRestaurantsSnapshot.docs.isEmpty) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User has no restaurants. Create First'),
        ),
      );

      return;
    }

    final DocumentSnapshot userRestaurantSnapshot = userRestaurantsSnapshot.docs.first;
    final String restaurantId = userRestaurantSnapshot.id;
    final String restaurantName = userRestaurantSnapshot['restaurantName'];

    final CollectionReference restaurantMenuCollection = FirebaseFirestore.instance.collection('menus');
    final DocumentReference menuDocument = restaurantMenuCollection.doc(restaurantId);

    final List<Map<String, dynamic>> currentMenuItems = [];

    try {
      final DocumentSnapshot menuSnapshot = await menuDocument.get();

      if (menuSnapshot.exists) {
        final Map<String, dynamic>? currentData = menuSnapshot.data() as Map<String, dynamic>?;

        if (currentData != null && currentData.containsKey('menuItems')) {
          currentMenuItems.addAll(List<Map<String, dynamic>>.from(currentData['menuItems']));
        }
      }
    } catch (error) {
      print('Error retrieving current menu items: $error');
    }

    currentMenuItems.addAll(_menuItems);

    try {
      await menuDocument.set({
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'menuItems': currentMenuItems,
      });
      _menuItems.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Menu items saved successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                content: Text('Error saving menu items: $error'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Menu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item name.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the description.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price.';
                        }
                        return null;
                      },
                    ),
                    if (_imageFile != null) ...[
                      const SizedBox(height: 16.0),
                      Text('Selected Image:'),
                      Image.file(_imageFile!, height: 150.0),
                    ],
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImage(ImageSource.gallery);
                      },
                      child: const Text('Select Image'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveMenuItem();
                        }
                      },
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              if (_menuItems.isNotEmpty)
                Column(
                  children: [
                    const Text(
                      'Current Menu Items:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = _menuItems[index];
                        return ListTile(
                          title: Text(menuItem['itemName']),
                          subtitle: Text(menuItem['description']),
                          trailing: Text('\$${menuItem['price']}'),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitMenuItems,
                      child: const Text('Submit Menu Items'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }


}
