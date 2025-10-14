import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/color.dart';
import '../QRUpdate/qr_update.dart';

class OTPScreen extends StatefulWidget {
  final Map qrData;
  const OTPScreen({super.key, required this.qrData});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;




  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpControllers[0].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpControllers[0].text.length),
      );
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getFullOTP() {
    return _otpControllers.map((c) => c.text).join();
  }
  void _onOTPChanged(int index) {
    if (_otpControllers[index].text.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (_otpControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify if all fields filled
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOTP();
    }
  }
  void _verifyOTP() async {
    final otp = _getFullOTP();
    if (otp.length != 6) {
      _shakeError();
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse(ApiRoutes.qrVerifyOtp);

      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "qr_number": widget.qrData['qr_number'],
          "otp": otp,
          "user_id": widget.qrData['user_id'],
        }),
      );

      print("OTP Verify Response status: ${response.statusCode}");
      print("OTP Verify Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('OTP Verified!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate to Update Screen after successful verification
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateScreen(qrData: widget.qrData, qrNumber: widget.qrData['qr_number'].toString(),),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = data["message"] ?? "OTP Verification Failed!";
          });
          _clearOTP();
          _shakeError();
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Unauthorized! Token is invalid or expired.";
        });
        _clearOTP();
        _shakeError();
      } else {
        setState(() {
          _errorMessage = "Server Error: ${response.statusCode}";
        });
        _clearOTP();
        _shakeError();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong: $e";
      });
      _clearOTP();
      _shakeError();
    }

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _shakeError() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    // Auto-focus first field after clear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpControllers[0].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpControllers[0].text.length),
      );
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _resendOTP() async {
    // TODO: Implement resend OTP API if needed
    // For now, just clear and show message
    _clearOTP();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP Resent!'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          "OTP Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.colorWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.colorWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 40, // Adjusted for padding
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppColors.navyBlue,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "QR: ${widget.qrData['qr_number']}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Enter OTP (6 digits)",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorBlack,
                  ),
                ),
                _buildDetailRow(
                  'A 6-digit OTP has been sent to ',
                  widget.qrData['contact_for_otp'].toString(),
                  context,
                  isPhone: true,
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40.sp,
                      // height: 45.sp,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType:
                        TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            1,
                          ),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                            borderSide: BorderSide(
                              color:
                              Colors.blue[600]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (_) =>
                            _onOTPChanged(index),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.redAccent, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: AppColors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: AppColors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      foregroundColor: AppColors.colorWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.navyBlue.withOpacity(0.3),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isVerifying ? null : _resendOTP,
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(color: AppColors.navyBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDetailRow(
      String label,
      String value,
      BuildContext context, {
        bool isPhone = false,
      }) {
    String displayValue = value;

    if (isPhone && value.isNotEmpty) {
      // Check if number is exactly 10 digits
      if (value.length == 10) {
        displayValue = '******' + value.substring(value.length - 4);
      } else {
        displayValue = value; // if not 10 digits, show as-is
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$label',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    '+91$displayValue',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
