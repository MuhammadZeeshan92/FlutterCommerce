import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final titleController = TextEditingController();

  final descriptionController =
      TextEditingController();

  final priceController = TextEditingController();

  final stockController = TextEditingController();

  bool isLoading = false;

  Future<void> addProduct() async {
    try {
      setState(() {
        isLoading = true;
      });

      await ApiService.post(
        "/products",
        {
          "title": titleController.text,
          "description":
              descriptionController.text,

          "price": double.parse(
            priceController.text,
          ),

          "stock": int.parse(
            stockController.text,
          ),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product Added"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: priceController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: stockController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stock",
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : addProduct,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Add Product"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}