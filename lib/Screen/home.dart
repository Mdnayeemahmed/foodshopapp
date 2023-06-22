import 'package:flutter/material.dart';
import 'package:foodshopapp/widgets/resturant_card.dart';
import '../utilities/app_colors.dart';

class Home extends StatelessWidget {
  final List<Map<String, String>> restaurantData = [
    {
      'ResturantName': 'Taazaa',
      'Category': 'Fast Food',
      'DeliveryTime': '1 Hr',
      'ImageUrl': 'https://images.deliveryhero.io/image/fd-bd/Products/4916053.jpg?width=%s',
    },
    {
      'ResturantName': 'Taazaa',
      'Category': 'Fast Food',
      'DeliveryTime': '1 Hr',
      'ImageUrl': 'https://images.deliveryhero.io/image/fd-bd/Products/4916053.jpg?width=%s',
    },
    {
      'ResturantName': 'Taazaa',
      'Category': 'Fast Food',
      'DeliveryTime': '1 Hr',
      'ImageUrl': 'https://images.deliveryhero.io/image/fd-bd/Products/4916053.jpg?width=%s',
    }
    // Add more restaurant data entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Now'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'All restaurants',
              style: TextStyle(
                color: greyColor,
                fontSize: 18,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: restaurantData.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                final data = restaurantData[index];
                print(data);

                return SizedBox(
                  width: 140,
                  child: resturant_card(
                    ResturantName: data['ResturantName'].toString(),
                    Catagory: data['Category'].toString(),
                    DeliveryTime: data['DeliveryTime'].toString(),
                    ImageUrl: data['ImageUrl'].toString(),
                  ),
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
