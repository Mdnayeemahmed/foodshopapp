import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuData = [
    {
      'DishName': 'Burger',
      'Description': 'Delicious burger with cheese and vegetables',
      'Price': 10.99,
      'ImageUrl': 'https://www.allrecipes.com/thmb/5JVfA7MxfTUPfRerQMdF-nGKsLY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/25473-the-perfect-basic-burger-DDMFS-4x3-56eaba3833fd4a26a82755bcd0be0c54.jpg',
    },
    {
      'DishName': 'Pizza',
      'Description': 'Classic pizza with tomato sauce and toppings',
      'Price': 12.99,
      'ImageUrl': 'https://hips.hearstapps.com/hmg-prod/images/classic-cheese-pizza-recipe-2-64429a0cb408b.jpg?crop=0.6666666666666667xw:1xh;center,top&resize=1200:*',
    },
    {
      'DishName': 'Pasta',
      'Description': 'Creamy pasta with mushrooms and garlic',
      'Price': 8.99,
      'ImageUrl': 'https://www.thechunkychef.com/wp-content/uploads/2017/08/One-Pot-Chicken-Parmesan-Pasta-feat.jpg',
    }
    // Add more menu data entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: ListView.builder(
        itemCount: menuData.length,
        itemBuilder: (context, index) {
          final data = menuData[index];

          return ListTile(
            leading: Image.network(
              data['ImageUrl'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              data['DishName'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['Description'],
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${data['Price'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implement the add to cart functionality
                },
                child: Text('Add to Cart'),
              )
          );
        },
      ),
    );
  }
}
