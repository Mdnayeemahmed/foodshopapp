import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/Cartcontroller.dart';

class CartPage extends StatelessWidget {
  final cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: GetBuilder<CartController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = controller.cartItems[index];

                    return ListTile(
                      title: Text(cartItem.dishName),
                      subtitle:
                      Text('\$${cartItem.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => controller.removeFromCart(index),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Obx(
                          () => Text(
                        '\$${controller.totalPrice.value.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.placeOrder,
                child: Text('Place Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}
