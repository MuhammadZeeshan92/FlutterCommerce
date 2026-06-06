import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Discover",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Our Collection",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Cart icon with badge
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFB8860B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFF0A0A0F),
                                size: 22,
                              ),
                            ),
                            if (cartProvider.totalItems > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0A0A0F),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cartProvider.totalItems.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF13131F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2A3E)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Search products...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "All Products",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(width: 12),
                  if (!productProvider.isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        "${productProvider.products.length} items",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Product List ──
            Expanded(
              child: productProvider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading products...",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ],
                      ),
                    )
                  : productProvider.products.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      itemCount: productProvider.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final product = productProvider.products[index];
                        return _buildProductCard(context, product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                    ),
                    image: product.image != null && product.image.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFF13131F),
                  ),
                  child: (product.image == null || product.image.isEmpty)
                      ? const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFFD4AF37),
                          size: 24,
                        )
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Rs ${product.price}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stock badge
                if (product.stock != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.stock > 0
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: product.stock > 0
                            ? const Color(0xFF4CAF50).withOpacity(0.25)
                            : Colors.red.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      product.stock > 0 ? "In Stock" : "Out",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.stock > 0
                            ? const Color(0xFF4CAF50)
                            : Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),

            // Description
            if (product.description != null &&
                product.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Divider
            Container(height: 1, color: const Color(0xFF1A1A2E)),
            const SizedBox(height: 14),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFFD4AF37),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Added to cart",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF1A1A2E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Color(0xFF0A0A0F),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0F),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFFD4AF37),
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No products available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for new arrivals",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
