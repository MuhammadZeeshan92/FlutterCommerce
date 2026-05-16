import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/order_service.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];

                return ListTile(
                  title: Text(item.product.title),

                  subtitle: Text("Rs ${item.product.price} x ${item.quantity}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          cartProvider.decreaseQuantity(item.product.id);
                        },
                        icon: const Icon(Icons.remove),
                      ),

                      Text(item.quantity.toString()),

                      IconButton(
                        onPressed: () {
                          cartProvider.increaseQuantity(item.product.id);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: Rs ${cartProvider.totalPrice}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final items = cartProvider.items.map((item) {
                          return {
                            "productId": item.product.id,
                            "quantity": item.quantity,
                          };
                        }).toList();

                        await OrderService.createOrder(items);

                        cartProvider.clearCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order placed successfully"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: const Text("Checkout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
