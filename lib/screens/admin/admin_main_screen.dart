import 'package:flutter/material.dart';

import 'add_product_screen.dart';
import 'admin_products_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() =>
      _AdminMainScreenState();
}

class _AdminMainScreenState
    extends State<AdminMainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const AdminProductsScreen(),
    const AddProductScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Products",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Add Product",
          ),
        ],
      ),
    );
  }
}