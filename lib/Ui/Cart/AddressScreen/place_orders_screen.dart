import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this dependency: google_fonts: ^6.2.1 in pubspec.yaml
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../BaseUrl/baseurl.dart';
import '../../../Utils/color.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';
import '../CartModel/cart_model.dart';
import '../CartProvider/cart_provider.dart';
import '../OrderConfirmationScreen/order_confirmation.dart';
import 'package:http/http.dart' as http;

class AddressScreen extends StatefulWidget {
  final List<CartItem> orderItems;
  final String address;
  final double deliveryCharge;

  const AddressScreen({
    super.key,
    required this.orderItems,
    this.deliveryCharge = 50,
    required this.address,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with TickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

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
      double price = double.tryParse(item.rate) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }


  double get totalAmount => subtotal  + widget.deliveryCharge;

  // Future<void> _placeOrder(BuildContext context, Function clearCart,) async {
  //   if (widget.address.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const Icon(Icons.error_outline, color: Colors.white),
  //             const SizedBox(width: 8),
  //             const Text("Please enter your address! 😅"),
  //           ],
  //         ),
  //         backgroundColor: Colors.redAccent,
  //         behavior: SnackBarBehavior.floating,
  //         margin: const EdgeInsets.all(16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   // Clear the cart
  //
  //
  //   // Show progress indicator
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const Center(
  //         child:
  //         CircularProgressIndicator(),
  //       );
  //     },
  //   );
  //
  //   final Map<String, dynamic>
  //   payload = {
  //     "invoice": {
  //       "name": _nameController.text.trim(),
  //       "address": widget.address,
  //       "gst_include": "EXCLUDE",
  //       "total_amount": totalAmount,
  //       "discount": 0,
  //     },
  //     "products": cart..items
  //         .map((item) => item.toJson(),)
  //         .toList(),
  //   };
  //
  //   print('Payload: $payload');
  //
  //   try {
  //     final prefs =
  //     await SharedPreferences.getInstance();
  //     final token = prefs.getString(
  //       'auth_token',
  //     );
  //     final response = await http
  //         .post(
  //       Uri.parse(
  //         ApiRoutes.orderPlaced,
  //       ),
  //       headers: {
  //         'Content-Type':
  //         'application/json',
  //         'Authorization':
  //         'Bearer $token',
  //       },
  //       body: json.encode(
  //         payload,
  //       ),
  //     );
  //
  //     Navigator.of(
  //       context,
  //     ).pop(); // Hide loading
  //
  //     if (response.statusCode ==
  //         200) {
  //       clearCart();
  //
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (_) => OrderConfirmationScreen()));
  //     } else {
  //       // messenger.showSnackBar(
  //       //   SnackBar(
  //       //     content: TextBuilder(
  //       //       text:
  //       //       'Failed to place order. Try again.',
  //       //       color: Colors.white,
  //       //       fontSize: 14.sp,
  //       //     ),
  //       //     backgroundColor:
  //       //     Colors.red,
  //       //   ),
  //       // );
  //     }
  //
  //
  //     // Navigator.pushReplacement(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => const OrderConfirmationScreen(),
  //     //   ),
  //     // );
  //   } catch (e) {
  //     Navigator.of(
  //       context,
  //     ).pop(); // Hide loading
  //
  //     // messenger.showSnackBar(
  //     //   SnackBar(
  //     //     content: TextBuilder(
  //     //       text:
  //     //       'Something went wrong. Please check your connection.',
  //     //       color: Colors.white,
  //     //       fontSize: 14.sp,
  //     //     ),
  //     //     backgroundColor: Colors.red,
  //     //   ),
  //     // );
  //   }
  // }
  // Example cart clear function (replace with your actual cart logic)
  void _clearCart() {
    Provider.of<CartProvider>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

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
                                              "${item.product_name} ×${item.quantity}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "₹${((double.tryParse(item.rate) ?? 0.0) * item.quantity).toStringAsFixed(2)}",
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                          child: Text('(GST Included)',style: TextStyle(color: Colors.red,fontSize: 5.sp,fontWeight: FontWeight.bold),))
                                    ],
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
                          Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin:  EdgeInsets.symmetric(horizontal: 0, vertical: 5.sp),
                            child: Padding(
                              padding:  EdgeInsets.all(15.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.navyBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8), // Space between icon and text
                                  Expanded(
                                    child: Text(
                                      widget.address,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.sp, bottom: 8.sp),
                                child: Text(
                                  'Full Name',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.sp),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200.withOpacity(0.9),
                                    hintText: 'Enter your Name',
                                    labelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'PoppinsSemiBold',
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500,
                                      fontFamily: 'Poppins-Medium',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.sp),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.sp),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.sp),
                                      borderSide: BorderSide(color: AppColors.navyBlue, width: 1),
                                    ),
                                    prefixIcon: Icon(Icons.account_circle, color: Colors.grey.shade600),
                                    contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                                  ),
                                  keyboardType: TextInputType.name, // Changed to TextInputType.name for better UX
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Poppins-Medium',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15.sp, top: 0.sp),
                                child: Text(
                                  'Enter the name as it appears on your billing details',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.navyBlue,
                                    fontFamily: 'Poppins-Regular',
                                  ),
                                ),
                              ),
                            ],
                          )
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
            // onPressed: () {
            //   // Click pe ye call hoga - mast simple!
            //   _placeOrder(
            //     context,
            //     _clearCart,
            //   ); // Pass context and clearCart function
            // },

            onPressed: () async {
              final ScaffoldMessengerState
              messenger = ScaffoldMessenger.of(
                context,
              );

              if (_nameController.text == '') {
                messenger.showSnackBar(
                  SnackBar(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                    backgroundColor:
                    Theme.of(
                      context,
                    ).brightness ==
                        Brightness.dark
                        ? Colors.grey[800]
                        : Colors.red,
                    behavior: SnackBarBehavior
                        .floating,
                    content: Text('Please enter your name',style: TextStyle(  color: Colors.white,
                      fontSize: 14.sp,),)

                  ),
                );
                return;
              }




              // Show progress indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                },
              );

              final Map<String, dynamic>
              payload = {
                "invoice": {
                  "name": _nameController.text.trim(),
                  "address": widget.address,
                  "gst_include": "EXCLUDE",
                  "total_amount": totalAmount,
                  "delivery_charge": widget.deliveryCharge,
                  "discount": 0,
                },
                "products": cart.items.map((item) => item.toJson(),).toList(),
              };

              print('Payload: $payload');

              try {
                final prefs =
                await SharedPreferences.getInstance();
                final token = prefs.getString('token',);
                final response = await http
                    .post(
                  Uri.parse(
                    ApiRoutes.orderPlaced,
                  ),
                  headers: {
                    'Content-Type':
                    'application/json',
                    'Authorization':
                    'Bearer $token',
                  },
                  body: json.encode(
                    payload,
                  ),
                );

                Navigator.of(
                  context,
                ).pop(); // Hide loading

                if (response.statusCode ==
                    200) {

                  cart.clearCart();
                  cart.notifyListeners();

                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderConfirmationScreen()));

                } else {
                  // messenger.showSnackBar(
                  //   SnackBar(
                  //     content: TextBuilder(
                  //       text:
                  //       'Failed to place order. Try again.',
                  //       color: Colors.white,
                  //       fontSize: 14.sp,
                  //     ),
                  //     backgroundColor:
                  //     Colors.red,
                  //   ),
                  // );
                }
              } catch (e) {
                Navigator.of(
                  context,
                ).pop(); // Hide loading

                // messenger.showSnackBar(
                //   SnackBar(
                //     content: TextBuilder(
                //       text:
                //       'Something went wrong. Please check your connection.',
                //       color: Colors.white,
                //       fontSize: 14.sp,
                //     ),
                //     backgroundColor: Colors.red,
                //   ),
                // );
              }
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
