import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AddressScreen/add_address.dart';
import '../AddressScreen/place_orders_screen.dart';
import '../CartModel/cart_model.dart';
import '../CartProvider/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  String? selectedAddress; // Store selected address here

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress();
  }


  // refresh when coming back
  @override
  void didPopNext() {
    _loadSelectedAddress();
    super.didPopNext();
  }

  // Load the saved address from SharedPreferences
  Future<void> _loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAddress = prefs.getString('selected_address');
    });
  }

  // Navigate to AddAddressScreen and update the selected address
  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressScreen()),
    );
    if (result != null) {
      setState(() {
        selectedAddress = result as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);

    const double deliveryCharge = 50.0;
    final double itemTotal = cart.totalPrice;
    final double grandTotal = itemTotal + deliveryCharge;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cart',
            onPressed: cart.items.isEmpty
                ? null
                : () {
                    cart.clearCart();
                  },
          ),
        ],
      ),
      body: SafeArea(
        top: false, // keep top area flexible
        bottom: false, // bottom handled manually below
        child: cart.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your Cart is Empty",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : SafeArea(
              child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          CartItem item = cart.items[i];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error, size: 60),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product_name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${item.rate} x ${item.quantity} = ₹${(int.parse(item.rate.toString()) * item.quantity).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        color: theme.primaryColor,
                                        onPressed: () => cart.decreaseQty(item),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: theme.primaryColor,
                                        onPressed: () => cart.increaseQty(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding:  EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(0.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Delivery Address",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Navigate to AddAddressScreen and wait for result
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddAddressScreen(),
                                          ),
                                        );

                                        // Update selectedAddress if result is valid
                                        if (result != null && result is String) {
                                          setState(() {
                                            selectedAddress = result;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, // Text/icon color
                                        backgroundColor: Colors.red, // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.sp), // Rounded corners
                                        ),
                                        padding:  EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp), // Comfortable padding
                                        textStyle:  TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        minimumSize: const Size(100, 28), // Ensure sufficient touch area
                                        elevation: 2, // Subtle shadow for depth
                                      ),
                                      child: Text(
                                        selectedAddress == null ? "Add Address" : "Change Address",
                                        style: const TextStyle(color: Colors.white), // White text for contrast
                                        semanticsLabel: selectedAddress == null ? "Add new address" : "Change existing address", // Accessibility
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _navigateToAddAddress,
                                  child: Container(
                                    padding: EdgeInsets.all(5.sp),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.blue.shade900,
                                        ),
                                         SizedBox(width: 5.sp),
                                        Expanded(
                                          child: Text(
                                            selectedAddress ?? "Select an address",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: selectedAddress != null
                                                  ? Colors.black87
                                                  : Colors.grey.shade500,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                                // Add other cart-related widgets here
                              ],
                            ),
                          ),

                          // Address Section


                           Divider(height: 16.sp),

                          _buildPriceRow("Item Total", itemTotal),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  child: Text('(GST Included)',style: TextStyle(color: Colors.red,fontSize: 5.sp,fontWeight: FontWeight.bold),))
                            ],
                          ),

                          if (selectedAddress != null) ...[
                            _buildPriceRow("Delivery Charge", deliveryCharge),
                             Divider(height: 10.sp),
                            _buildPriceRow(
                              "Grand Total",
                              grandTotal,
                              isTotal: true,
                            ),
                          ],

                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: cart.items.isEmpty
                                ? null
                                : selectedAddress == null
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please select an address first!",
                                        ),
                                      ),
                                    );
                                  }
                                : () {
                              Navigator.push( context, MaterialPageRoute( builder: (context) => AddressScreen( orderItems: cart.items, address: selectedAddress!, ), ), );                              },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: AppColors.navyBlue,
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 12.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
              color: isTotal ? Colors.black87 : Colors.black
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 12.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
              color: isTotal ? Colors.black87 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
