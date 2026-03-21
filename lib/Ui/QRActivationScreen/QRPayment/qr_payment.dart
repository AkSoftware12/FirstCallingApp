import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../BaseUrl/baseurl.dart';
import '../../Cart/CartProvider/cart_provider.dart';
import '../../Cart/OrderConfirmationScreen/order_confirmation.dart';
import '../../Profile/update_profile.dart';
import '../QRUpdate/qr_update_popup.dart'; // For animations if needed

class PaymentScreen extends StatefulWidget {
  final Map qrData;
  final Map productData;
  const PaymentScreen({super.key, required this.qrData, required this.productData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  late Razorpay _razorpay;
  bool _isPlacingOrder = false;
  bool _isStartingPayment = false;

   String userName='';
   String userAddress='';
  String userMobile = '';
  String userEmail = '';
  String? razorpayOrderId = '';
  String? _razorpayKey = '';
  String? serverOrderId;

  double get sellingPriceRupees {
    final v = widget.productData['selling_price'];
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int get totalAmountPaise => (sellingPriceRupees * 100).round();


  @override
  void initState() {
    super.initState();
    fetchProfileData();
    razorpayKeyData();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  }

  Future<void> fetchProfileData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse(ApiRoutes.getProfile);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        setState(() {
          userName = jsonData['name']??'';
          userAddress= jsonData['address'] ?? '';
          userEmail = jsonData['email'] ?? '';
          userMobile = jsonData['contact'] ?? '';

        });

        // Save updated profile data to SharedPreferences for drawer
        // await _saveProfileToPrefs(jsonData);
      } else {
      }
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
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

  Future<void> _handlePayment() async {
    print('UserName : $userName');
    print('UserAddress : $userAddress');

    // ✅ Check for missing details before proceeding
    if (userName.trim().isEmpty || userAddress.trim().isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Profile Incomplete',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please update your profile before making a payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // ✅ Dialog band karo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileUpdatePage(
                              onProfileUpdated: () async {
                                // ✅ Fresh data fetch karo
                                await fetchProfileData();

                                // ✅ setState complete hone ke baad payment retry
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted &&
                                      userName.trim().isNotEmpty &&
                                      userAddress.trim().isNotEmpty) {
                                    _handlePayment(); // 🔁 Auto retry
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return; // 🚫 Stop payment process
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      final Map<String, dynamic> payload = {
        "invoice": {
          "name": userName,
          "address": userAddress,
          "qr_number": widget.qrData['qr_number'].toString(),
          "gst_include": "EXCLUDE",
          "total_amount": widget.productData['selling_price'],
          "delivery_charge": 0,
          "discount": 0,
        },
        "products": widget.productData,
      };

      print('Payload: $payload');

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final response = await http.post(
          Uri.parse(ApiRoutes.orderAgentPlaced),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(payload),
        );

        Navigator.of(context).pop(); // Hide loading

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["success"] == true) {
            final qr = data["qr_number"];
            print('Qr Data $qr');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QRUpdateScreen(qrNumber: qr),
              ),
            );
          } else {
            setState(() {});
          }
        }
      } catch (e) {
        Navigator.of(context).pop(); // Hide loading
      }
    }
  }

  // Future<void> _handlePayment() async {
  //   print('UserName : $userName');
  //   print('UserAddress : $userAddress');
  //
  //   // ✅ Check for missing details before proceeding
  //   if (userName.trim().isEmpty || userAddress.trim().isEmpty) {
  //
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false, // ✨ Non-dismissible by tapping outside
  //       builder: (context) => Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         elevation: 5,
  //         backgroundColor: Colors.white,
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.navyBlue.withOpacity(0.5),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child:  Icon(
  //                   Icons.person,
  //                   size: 50,
  //                   color: AppColors.navyBlue,
  //                 ),
  //               ),
  //               const SizedBox(height: 15),
  //               const Text(
  //                 'Profile Incomplete',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               const Text(
  //                 'Please update your profile before making a payment.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   color: Colors.black54,
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   OutlinedButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     style: OutlinedButton.styleFrom(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       side: const BorderSide(color: Colors.grey),
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 25, vertical: 12),
  //                     ),
  //                     child: const Text(
  //                       'Cancel',
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       Navigator.push(
  //                           context,
  //                           MaterialPageRoute(builder: (context)=> ProfileUpdatePage(
  //                             onProfileUpdated: () { fetchProfileData(); },)));
  //                       },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.navyBlue,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 25, vertical: 12),
  //                     ),
  //                     child: const Text(
  //                       'Update Now',
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //     return; // 🚫 Stop payment process
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   // Simulate payment processing delay
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   if (mounted) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //
  //       final Map<String, dynamic>payload = {
  //         "invoice": {
  //           "name":userName,
  //           "address": userAddress,
  //           "qr_number": widget.qrData['qr_number'].toString(),
  //           "gst_include": "EXCLUDE",
  //           "total_amount": widget.productData['selling_price'],
  //           "delivery_charge": 0,
  //           "discount": 0,
  //         },
  //         "products": widget.productData,
  //       };
  //
  //       print('Payload: $payload');
  //
  //       try {
  //         final prefs =
  //         await SharedPreferences.getInstance();
  //         final token = prefs.getString('token',);
  //         final response = await http
  //             .post(
  //           Uri.parse(
  //             ApiRoutes.orderAgentPlaced,
  //           ),
  //           headers: {
  //             'Content-Type':
  //             'application/json',
  //             'Authorization':
  //             'Bearer $token',
  //           },
  //           body: json.encode(
  //             payload,
  //           ),
  //         );
  //
  //         Navigator.of(
  //           context,
  //         ).pop(); // Hide loading
  //
  //         if (response.statusCode == 200) {
  //
  //           final data = jsonDecode(response.body);
  //           if (data["success"] == true) {
  //             final qr = data["qr_number"];
  //             print('Qr Data $qr');
  //             Navigator.push(context, MaterialPageRoute(builder: (_) => QRUpdateScreen(qrNumber: qr,)));
  //
  //
  //           } else {
  //             setState(() {
  //
  //             });
  //           }
  //
  //
  //
  //         } else {
  //           // messenger.showSnackBar(
  //           //   SnackBar(
  //           //     content: TextBuilder(
  //           //       text:
  //           //       'Failed to place order. Try again.',
  //           //       color: Colors.white,
  //           //       fontSize: 14.sp,
  //           //     ),
  //           //     backgroundColor:
  //           //     Colors.red,
  //           //   ),
  //           // );
  //         }
  //       } catch (e) {
  //         Navigator.of(
  //           context,
  //         ).pop(); // Hide loading
  //
  //
  //       }
  //
  //   }
  // }
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

    _showLoading();


    try {
      serverOrderId = await _createRazorpayOrderOnServer();
    } catch (_) {
      serverOrderId = null;
    }

    print('ordersId $serverOrderId');

    _hideLoading();

    // ❌ HARD STOP if order_id not received
    if (serverOrderId == null || serverOrderId!.isEmpty) {

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
        'customer_name': userName,
        'address': userAddress,
      },
      'theme': {'color': '#010071'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // _toast("Razorpay Error: $e", bg: Colors.red);
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
      sellingPriceRupees.toString(), // ✅ ₹
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
      sellingPriceRupees.toString(),
      serverOrderId!,
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

        _handlePayment();
        // await _placeOrderAfterPayment(
        //   razorpayPaymentId: paymentId,
        //   razorpayOrderId: orderId, // may be null in fallback
        //   razorpaySignature: signature, // may be null in fallback
        // );
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
        "name": userName,
        "address": userAddress,
        "gst_include": "EXCLUDE",
        "total_amount": totalAmountPaise,
        "delivery_charge": 0,
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
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.sp),
              child: Image.asset(
                'assets/playstore.png',
                height: 35.sp,
                width: 35.sp,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 3.sp),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure Payment",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "First Calling App",
                  style: GoogleFonts.poppins(
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.navyBlue,
        actions: [],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight - kToolbarHeight - 100),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Trust Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Secure & Encrypted Payment",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment Card
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppColors.navyBlue.withOpacity(0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // QR Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.navyBlue.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.qr_code_2_outlined,
                                    size: 64,
                                    color: AppColors.navyBlue.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "QR Payment ID",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.navyBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.navyBlue.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      widget.qrData['qr_number'].toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyBlue,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Product Details
                            _buildDetailRow(
                              Icons.inventory_2_outlined,
                              "Item",
                              widget.productData['name'] ?? 'Product Name',
                              AppColors.navyBlue,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              Icons.currency_rupee_rounded,
                              "Amount",
                              "₹ ${widget.productData['selling_price'] ?? 0}",
                              AppColors.navyBlue,
                              isBold: true,
                              isLarge: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startRazorpayPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        disabledBackgroundColor: AppColors.navyBlue.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Processing...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Pay ₹${widget.productData['selling_price'] ?? 0}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    "Powered by Secure Gateway",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      HexColor color,
      {
        bool isBold = false,
        bool isLarge = false,
      }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.navyBlue.withOpacity(0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLarge ? 24 : 18,
                  color: Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}