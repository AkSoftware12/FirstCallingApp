import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../BaseUrl/baseurl.dart';
import '../../../Utils/color.dart';
import '../CartModel/cart_model.dart';
import '../CartProvider/cart_provider.dart';
import '../OrderConfirmationScreen/order_confirmation.dart';

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
  String userMobile = '';
  String userEmail = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late Razorpay _razorpay;

  bool _isPlacingOrder = false;
  bool _isStartingPayment = false;

  String? razorpayOrderId = '';
  String? _razorpayKey = '';

  @override
  void initState() {
    super.initState();

    fetchProfileData();
    razorpayKeyData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _animationController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse(ApiRoutes.getProfile);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        setState(() {
          userEmail = jsonData['email'] ?? '';
          userMobile = jsonData['contact'] ?? '';
        });

        print('UserProfile$jsonData');
        // Save updated profile data to SharedPreferences for drawer
        // await _saveProfileToPrefs(jsonData);
      } else {
      }
    } catch (e) {
    } finally {
    }
  }

  Future<void> razorpayKeyData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(ApiRoutes.getRazorpayKey);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          _razorpayKey = jsonData['razor_pay_id'].toString();
          print('RazorPay Key$jsonData');

        });
      } else {
        throw Exception('Failed to load Razorpay key');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading Razorpay key: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }



  double get subtotal {
    if (widget.orderItems.isEmpty) return 0.0;
    return widget.orderItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item.rate) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  double get totalAmount => subtotal + widget.deliveryCharge;


  int get totalAmountPaise => (totalAmount * 100).round();

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CupertinoActivityIndicator(
        radius: 25,
        color: AppColors.navyBlue,
      ),),
    );
  }

  void _hideLoading() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _showStatusDialog({
    required bool success,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: success
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.cancel,
                  color: success ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                height: 44.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    success ? AppColors.navyBlue : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg, {Color bg = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
      ),
    );
  }

  /// ✅ 1) Create Razorpay Order from your backend (recommended)
  /// Returns razorpay_order_id or null if failed
  Future<String?> _createRazorpayOrderOnServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ✅ Replace with your API that returns: { order_id: "order_xxx" }
      // Example: ApiRoutes.createRazorpayOrder
      final url = Uri.parse(ApiRoutes.ordersIdRazorpay);

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "amount": totalAmountPaise, // in paise
          "currency": "INR",
          // "receipt": "orderId${DateTime.now().millisecondsSinceEpoch}", // optional
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final oid = data['data']["id"]?.toString();
        if (oid != null && oid.isNotEmpty) return oid;

        print('OrderId$data');

      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// ✅ 2) Start Payment (order_id optional)
  Future<void> _startRazorpayPayment() async {
    if (_isStartingPayment) return;
    _isStartingPayment = true;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast("Please enter your name", bg: Colors.red);
      _isStartingPayment = false;
      return;
    }

    _showLoading();

    String? serverOrderId;
    try {
      serverOrderId = await _createRazorpayOrderOnServer();
    } catch (_) {
      serverOrderId = null;
    }

    _hideLoading();

    // ❌ HARD STOP if order_id not received
    if (serverOrderId == null || serverOrderId.isEmpty) {
      _toast(
        "Unable to create payment order. Please try again.",
        bg: Colors.red,
      );
      _isStartingPayment = false;
      return;
    }

    // ✅ ONLY valid case reaches here
    final options = {
      'key': _razorpayKey,
      'amount': totalAmountPaise,
      'order_id': serverOrderId, // 🔒 mandatory now
      'name': 'First Calling App',
      'description': 'Order Payment',
      'prefill': {'contact': userMobile, 'email': userEmail},
      'notes': {
        'customer_name': name,
        'address': widget.address,
      },
      'theme': {'color': '#010071'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _toast("Razorpay Error: $e", bg: Colors.red);
    } finally {
      _isStartingPayment = false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _showStatusDialog(
      success: true,
      title: "Payment Successful ✅",
      message: "Payment ID: ${response.paymentId ?? '-'}",
    );

    String orderId = response.orderId ?? "";
    String paymentId = response.paymentId ?? "";
    String signature = response.signature ?? "";
    String status = "success";
    String currency = "INR";
    String paymentMethod = "UPI";
    String txnDate = DateTime.now().toString();

    StorePaymnet(
      totalAmount.toStringAsFixed(2), // ✅ ₹
      orderId,
      paymentId,
      currency,
      status,
      signature,
      paymentMethod,
      txnDate,
      null,
      '',
      null,
    );

    // await _placeOrderAfterPayment(
    //   razorpayPaymentId: response.paymentId,
    //   razorpayOrderId: response.orderId, // may be null in fallback
    //   razorpaySignature: response.signature, // may be null in fallback
    // );
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    //
    await _showStatusDialog(
      success: false,
      title: "Payment Failed ❌",
      message: response.message ?? "Payment cancelled or failed. Please try again.",
    );


    String orderId = '';
    String paymentId = '';
    String signature = '';
    String status = "Failed";
    String currency = "INR";
    String paymentMethod = "UPI";
    String txnDate = DateTime.now().toString();

    StorePaymnet(
      totalAmount.toStringAsFixed(2),
      orderId,
      paymentId,
      currency,
      status,
      signature,
      paymentMethod,
      txnDate,
      response.code,
      response.message,
      response.error,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _toast("External Wallet: ${response.walletName}");
  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: 30.sp,
                    child: CircularProgressIndicator()),
                SizedBox(width: 16.sp),
                Text(
                  "Processing...",
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
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

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  Future<void> StorePaymnet(
      String price,
      String orderId,
      String paymentId,
      String currency,
      String status,
      String signature,
      String paymentMethod,
      String txnDate,
      int? errorCode,
      String? errorDescription,
      Map<dynamic, dynamic>? failureReason,
      ) async {
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      Map<String, dynamic> responseData = {
        "order_id": orderId,
        "payment_id": paymentId,
        "amount": price.toString(),
        "currency": currency,
        "status": status,
        "signature": signature,
        "payment_method": paymentMethod,
        "txn_date": txnDate,
        "error_code": errorCode,
        "error_description": errorDescription,
        "failure_reason": failureReason == null ? null : jsonEncode(failureReason),
      };

      final response = await http.post(
        Uri.parse(ApiRoutes.paymentStore),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(responseData),
      );

      if (response.statusCode == 200) {
        await _placeOrderAfterPayment(
          razorpayPaymentId: paymentId,
          razorpayOrderId: orderId, // may be null in fallback
          razorpaySignature: signature, // may be null in fallback
        );
      } else {
        hideLoadingDialog(context);
        await _showStatusDialog(
          success: false,
          title: "Order Failed ❌",
          message: "Server Error: ${response.body}",
        );      }
    } catch (e) {
      hideLoadingDialog(context);
      await _showStatusDialog(
        success: false,
        title: "Something went wrong ❌",
        message: e.toString(),
      );
    }
  }
  Future<void> _placeOrderAfterPayment({
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    if (_isPlacingOrder) return;
    _isPlacingOrder = true;

    final cart = Provider.of<CartProvider>(context, listen: false);

    _showLoading();

    final payload = {
      "invoice": {
        "name": _nameController.text.trim(),
        "address": widget.address,
        "gst_include": "EXCLUDE",
        "total_amount": totalAmount,
        "delivery_charge": widget.deliveryCharge,
        "discount": 0,
        "payment_gateway": "RAZORPAY",
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_order_id": razorpayOrderId, // can be null
        "razorpay_signature": razorpaySignature, // can be null
      },
      "products": cart.items.map((item) => item.toJson()).toList(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiRoutes.orderPlaced),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      _hideLoading();
      _isPlacingOrder = false;

      if (response.statusCode == 200) {
        cart.clearCart();
        cart.notifyListeners();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
        );
      } else {
        await _showStatusDialog(
          success: false,
          title: "Order Failed ❌",
          message: "Server Error: ${response.body}",
        );
      }
    } catch (e) {
      _hideLoading();
      _isPlacingOrder = false;
      await _showStatusDialog(
        success: false,
        title: "Something went wrong ❌",
        message: e.toString(),
      );
    }
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
                          // ✅ Order Summary
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0.95)],
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
                                          color: AppColors.navyBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
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
                                  ...widget.orderItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300 + (index * 150)),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  const Divider(color: Colors.grey, thickness: 0.5),
                                  const SizedBox(height: 12),
                                  _buildPriceRow("Subtotal", subtotal),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '(GST Included)',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPriceRow("Delivery Charge 🚚", widget.deliveryCharge),
                                  const Divider(color: Colors.grey, thickness: 0.5),
                                  const SizedBox(height: 12),
                                  _buildPriceRow("Total 💰", totalAmount, isTotal: true),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ✅ Address
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5.sp),
                            child: Padding(
                              padding: EdgeInsets.all(15.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, color: AppColors.navyBlue, size: 24),
                                  const SizedBox(width: 8),
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

                          // ✅ Name
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
                                  keyboardType: TextInputType.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
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
                                  ),
                                ),
                              ),
                            ],
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

      // ✅ Pay button
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
            onPressed: cart.items.isEmpty ? null : _startRazorpayPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Pay & Place Order 💳",
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
