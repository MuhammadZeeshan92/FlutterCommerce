import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/services/order_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _placeOrder(
    BuildContext context,
    CartProvider cartProvider,
    String paymentMethod,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final orderProvider = context.read<OrderProvider>();

    try {
      final items = cartProvider.items.map((item) {
        return {"productId": item.product.id, "quantity": item.quantity};
      }).toList();

      final orderResponse = await OrderService.createOrder({
        "items": items,
        "paymentMethod": paymentMethod,
        "totalAmount": cartProvider.totalPrice,
        "status": paymentMethod == "cod" ? "pending" : "awaiting_payment",
      });

      final orderId = orderResponse.data["order"]["id"];

      await orderProvider.initiatePayment(orderId, paymentMethod);

      final paymentUrl = orderProvider.paymentUrl;

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      cartProvider.clearCart();

      if (navigator.canPop()) {
        navigator.pop();
      }

      messenger.showSnackBar(
        SnackBar(content: Text("Order placed via $paymentMethod")),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_resolveOrderErrorMessage(e))),
      );
    }
  }

  String _resolveOrderErrorMessage(Object error) {
    const fallbackMessage =
        "Payment could not be started. Please try again.";

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) {
        return "Cannot reach the server. Check your internet connection and try again.";
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return "The payment request timed out. Please try again.";
      }

      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData["message"]?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }

      if (error.response?.statusCode == 500) {
        return "JazzCash payment failed on the server. Please check backend logs or payment configuration.";
      }
    }

    final message = error.toString().trim();
    if (message.isNotEmpty && message != "Exception") {
      return message;
    }

    return fallbackMessage;
  }

  void _showPaymentDialog(BuildContext context, CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Payment Method",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              _paymentTile(
                context,
                title: "JazzCash",
                icon: Icons.phone_android,
                onTap: () => _placeOrder(context, cartProvider, "jazzcash"),
              ),

              const SizedBox(height: 12),

              _paymentTile(
                context,
                title: "Easypaisa",
                icon: Icons.account_balance_wallet,
                onTap: () => _placeOrder(context, cartProvider, "easypaisa"),
              ),

              const SizedBox(height: 12),

              _paymentTile(
                context,
                title: "Cash on Delivery",
                icon: Icons.money,
                onTap: () => _placeOrder(context, cartProvider, "cod"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    "My Cart",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  // Item count badge
                  if (cartProvider.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        "${cartProvider.items.length} items",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Divider ──
            Container(height: 1, color: const Color(0xFF1A1A2E)),

            // ── Cart Items or Empty State ──
            Expanded(
              child: cartProvider.items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      itemCount: cartProvider.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return _buildCartItem(context, item, cartProvider);
                      },
                    ),
            ),

            // ── Checkout Panel ──
            if (cartProvider.items.isNotEmpty)
              _buildCheckoutPanel(context, cartProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    dynamic item,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFD4AF37),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "Rs ${item.product.price} each",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity controls + subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Subtotal
              Text(
                "Rs ${(item.product.price * item.quantity).toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 8),
              // Qty stepper
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A3E)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () =>
                          cartProvider.decreaseQuantity(item.product.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildQtyButton(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          cartProvider.increaseQuantity(item.product.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 16),
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D18),
        border: Border(top: BorderSide(color: Color(0xFF2A2A3E), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          // Order summary rows
          _buildSummaryRow("Subtotal", "Rs ${cartProvider.totalPrice}"),
          const SizedBox(height: 8),
          _buildSummaryRow("Delivery", "Free"),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFF2A2A3E)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                "Rs ${cartProvider.totalPrice}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _showPaymentDialog(context, cartProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout_rounded,
                        color: Color(0xFF0A0A0F),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Place Order",
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value == "Free"
                ? const Color(0xFF4CAF50)
                : Colors.white.withOpacity(0.7),
          ),
        ),
      ],
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
              Icons.shopping_cart_outlined,
              color: Color(0xFFD4AF37),
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some products to get started",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF13131F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
