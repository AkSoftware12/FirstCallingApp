import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this dependency: google_fonts: ^6.2.1 in pubspec.yaml
import 'package:provider/provider.dart';

import '../../../Utils/color.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';
import '../CartModel/cart_model.dart';
import '../CartProvider/cart_provider.dart';

class AddressScreen extends StatefulWidget {
  final List<CartItem> orderItems;
  final double gstPercentage;
  final double deliveryCharge;

  const AddressScreen({
    super.key,
    required this.orderItems,
    this.gstPercentage = 18,
    this.deliveryCharge = 50,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with TickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get subtotal {
    if (widget.orderItems.isEmpty) return 0.0;
    return widget.orderItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item.price) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  double get gstAmount => subtotal * widget.gstPercentage / 100;

  double get totalAmount => subtotal + gstAmount + widget.deliveryCharge;

  void _placeOrder(BuildContext context, Function clearCart) {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text("Please enter your address! 😅"),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Clear the cart
    clearCart();

    // Show quick success SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text("Order placed successfully! 🎉"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Show full-screen dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.teal],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated checkmark
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.bounceOut,
                  builder: (context, double value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 24),
                // Fun title
                const Text(
                  "Order Placed! 🎉",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Fun message
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your order is confirmed and on its way! Cart cleared, ready for your next adventure! 😎",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                // Continue button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close full-screen dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavigationBarScreen(
                        ),
                      ),
                    ); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Continue Shopping! 🚀",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Example cart clear function (replace with your actual cart logic)
  void _clearCart() {
    Provider.of<CartProvider>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFEFF2F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with gradient
              Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.navyBlue,
                      AppColors.navyBlue.withOpacity(0.9),
                    ],
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    "Delivery Address 🎁",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(CupertinoIcons.back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🛒 Order Summary Card with gradient border
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.95),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.navyBlue.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.navyBlue.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.cart_fill,
                                          color: AppColors.navyBlue,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Order Summary 🛒",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Items with quantity & total
                                  ...widget.orderItems.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return AnimatedContainer(
                                      duration: Duration(
                                        milliseconds: 300 + (index * 150),
                                      ),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${item.title} ×${item.quantity}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "₹${((double.tryParse(item.price) ?? 0.0) * item.quantity).toStringAsFixed(2)}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.navyBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  ),
                                  const SizedBox(height: 12),
                                  // Subtotal, GST, Delivery, Total
                                  _buildPriceRow("Subtotal", subtotal),
                                  const SizedBox(height: 8),
                                  _buildPriceRow(
                                    "GST (${widget.gstPercentage.toStringAsFixed(0)}%)",
                                    gstAmount,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPriceRow(
                                    "Delivery Charge 🚚",
                                    widget.deliveryCharge,
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPriceRow(
                                    "Total 💰",
                                    totalAmount,
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 🏠 Address Field with fun icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.navyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  CupertinoIcons.location_fill,
                                  color: AppColors.navyBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Delivery Address 🏠",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _addressController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  "Enter your delivery address (e.g., Door No, Street, City)... 📍",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                CupertinoIcons.location,
                                color: AppColors.navyBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.navyBlue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 16),
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
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Click pe ye call hoga - mast simple!
              _placeOrder(
                context,
                _clearCart,
              ); // Pass context and clearCart function
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0, // Removed elevation as shadow is on container
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Place Order 💳",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.green : Colors.black54,
          ),
        ),
      ],
    );
  }
}
