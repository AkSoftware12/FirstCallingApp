import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

   String userName='';
   String userAddress='';



  @override
  void initState() {
    super.initState();
    fetchProfileData();
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


  Future<void> _handlePayment() async {
    print('UserName : $userName');
    print('UserAddress : $userAddress');

    // ✅ Check for missing details before proceeding
    if (userName == null || userName!.trim().isEmpty ||
        userAddress == null || userAddress!.trim().isEmpty) {

      showDialog(
        context: context,
        barrierDismissible: false, // ✨ Non-dismissible by tapping outside
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
                  child:  Icon(
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
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> ProfileUpdatePage(
                              onProfileUpdated: () { fetchProfileData(); },)));
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


        final Map<String, dynamic>
        payload = {
          "invoice": {
            "name":userName,
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
          final prefs =
          await SharedPreferences.getInstance();
          final token = prefs.getString('token',);
          final response = await http
              .post(
            Uri.parse(
              ApiRoutes.orderAgentPlaced,
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

          if (response.statusCode == 200) {

            final data = jsonDecode(response.body);
            if (data["success"] == true) {
              final qr = data["qr_number"];
              print('Qr Data $qr');
              Navigator.push(context, MaterialPageRoute(builder: (_) => QRUpdateScreen(qrNumber: qr,)));


            } else {
              setState(() {

              });
            }



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


        }

    }
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
                      onPressed: _isLoading ? null : _handlePayment,
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