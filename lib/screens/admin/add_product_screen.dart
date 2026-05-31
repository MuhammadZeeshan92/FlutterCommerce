import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

class AddProductScreen extends StatefulWidget {
  final VoidCallback? onProductAdded;

  const AddProductScreen({super.key, this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  bool isLoading = false;
  XFile? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> addProduct() async {
    try {
      setState(() => isLoading = true);

      String imageUrl = "";

      if (selectedImage != null) {
        imageUrl = await uploadImageToCloudinary();
      }

      await ApiService.post("/products", {
        "title": titleController.text,
        "description": descriptionController.text,
        "price": double.parse(priceController.text),
        "stock": int.parse(stockController.text),
        "image": imageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully")),
      );

      widget.onProductAdded?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<String> uploadImageToCloudinary() async {
    final signatureResponse = await ApiService.get("/upload/signature");

    final signature = signatureResponse.data["signature"];
    final timestamp = signatureResponse.data["timestamp"];
    final cloudName = signatureResponse.data["cloudName"];
    final apiKey = signatureResponse.data["apiKey"];
    final folder = signatureResponse.data["folder"];

    final bytes = await selectedImage!.readAsBytes();

    MultipartFile multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: selectedImage!.name,
    );

    FormData formData = FormData.fromMap({
      "file": multipartFile,
      "api_key": apiKey,
      "timestamp": timestamp,
      "signature": signature,
      "folder": folder,
    });

    final response = await Dio().post(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      data: formData,
    );

    return response.data["secure_url"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A3E)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF0A0A0F),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──
            Container(height: 1, color: const Color(0xFF1A1A2E)),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    _buildSectionHeader(
                      Icons.info_outline_rounded,
                      "Product Details",
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Product Image"),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF13131F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A3E)),
                        ),
                        child: selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFFD4AF37),
                                    size: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Tap to select image",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: FutureBuilder<Uint8List>(
                                  future: selectedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildLabel("Product Title"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: titleController,
                      hint: "e.g. Premium Leather Wallet",
                      icon: Icons.title_rounded,
                    ),

                    const SizedBox(height: 22),

                    _buildLabel("Description"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: descriptionController,
                      hint: "Describe your product...",
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      Icons.attach_money_rounded,
                      "Pricing & Inventory",
                    ),
                    const SizedBox(height: 20),

                    // Price & Stock in a row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Price (USD)"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: priceController,
                                hint: "0.00",
                                icon: Icons.attach_money_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Stock"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: stockController,
                                hint: "0",
                                icon: Icons.warehouse_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ── Submit Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: isLoading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFB8860B),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            color: isLoading ? const Color(0xFF1A1A2E) : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFD4AF37),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Color(0xFF0A0A0F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Add Product",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0A0A0F),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.55),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A3E), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 14,
          ),
          prefixIcon: maxLines == 1
              ? Icon(icon, color: const Color(0xFFD4AF37), size: 20)
              : Padding(
                  padding: const EdgeInsets.only(left: 12, top: 14),
                  child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
                ),
          prefixIconConstraints: maxLines > 1
              ? const BoxConstraints(minWidth: 44, minHeight: 0)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 16,
          ),
        ),
      ),
    );
  }
}
