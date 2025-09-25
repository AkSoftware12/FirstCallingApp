import 'dart:async';
import 'dart:ui';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../Otp/otp.dart'; // Assuming OTPVerificationScreen is defined here
import 'package:firstcallingapp/Utils/color.dart';
import 'package:firstcallingapp/Utils/string.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mobileNo = _phoneController.text.trim();

      final response = await http.post(
        Uri.parse("http://192.168.1.2/firstcallingapp/api/login"), // <- API URL
        body: {
          "mobile_no": mobileNo,
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                mobileNo: mobileNo,
                // otp: data["otp"].toString(), // ✅ OTP pass kar diya
              ),
            ),
          );
        }
      } else {
        _showError(data["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearPhoneNumber() {
    _phoneController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blur
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Image.asset(
              'assets/loginbg.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Lottie animation
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Lottie.asset(
          //     'assets/animation.json',
          //     width: double.infinity,
          //     height: MediaQuery.of(context).size.height * 0.35,
          //     repeat: true,
          //     animate: true,
          //   ),
          // ),
          // Main content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: AppColors.navyBlue,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.sp),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.sp),
                        child: Image.asset(
                          'assets/applogo.jpg',
                          width: 100.sp,
                          height: 100.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        'First Calling App',
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.sp),
                      // Instruction text
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Welcome!',
                          style: GoogleFonts.roboto(
                            color: AppColors.colorWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 10.sp),

                      Text(
                        'We will send you a One Time Password on this mobile number',
                        style: GoogleFonts.roboto(
                          color: AppColors.colorWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 30.sp),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone number',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: GoogleFonts.roboto(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                fontSize: 13.sp,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/flag.png',
                                      width: 25.sp,
                                      height: 25.sp,
                                      fit: BoxFit.contain,
                                      semanticLabel: 'Indian flag',
                                    ),
                                    SizedBox(width: 5.sp),
                                    Text(
                                      '+91',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SizedBox(width: 8.sp),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                              suffixIcon: _phoneController.text.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: _clearPhoneNumber,
                              )
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                                borderSide: BorderSide(
                                  color: AppColors.navyBlue,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                                borderSide: BorderSide(
                                  color: AppColors.navyBlue,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                                borderSide: BorderSide(
                                  color: AppColors.navyBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 10) {
                                return 'Please enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}),
                          ),
                        ],
                      ),
                      // Phone input card
                      // Card(
                      //   elevation: 0,
                      //   color: Colors.white,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.sp),
                      //     side: BorderSide(
                      //       color: Colors.grey.shade300,
                      //       width: 1.sp,
                      //     ),
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.all(20.sp),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Phone number',
                      //           style: GoogleFonts.roboto(
                      //             color: Colors.grey.shade700,
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 12.sp,
                      //           ),
                      //         ),
                      //         SizedBox(height: 10.sp),
                      //         TextFormField(
                      //           controller: _phoneController,
                      //           keyboardType: TextInputType.phone,
                      //           inputFormatters: [
                      //             FilteringTextInputFormatter.digitsOnly,
                      //             LengthLimitingTextInputFormatter(10),
                      //           ],
                      //           decoration: InputDecoration(
                      //             hintText: 'Enter your phone number',
                      //             hintStyle: GoogleFonts.roboto(
                      //               color: Colors.black54,
                      //               fontWeight: FontWeight.normal,
                      //               fontSize: 13.sp,
                      //             ),
                      //             prefixIcon: Padding(
                      //               padding: EdgeInsets.symmetric(horizontal: 8.sp),
                      //               child: Row(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 children: [
                      //                   Image.asset(
                      //                     'assets/flag.png',
                      //                     width: 25.sp,
                      //                     height: 25.sp,
                      //                     fit: BoxFit.contain,
                      //                     semanticLabel: 'Indian flag',
                      //                   ),
                      //                   SizedBox(width: 5.sp),
                      //                   Text(
                      //                     '+91',
                      //                     style: GoogleFonts.roboto(
                      //                       color: Colors.black54,
                      //                       fontWeight: FontWeight.w600,
                      //                       fontSize: 13.sp,
                      //                     ),
                      //                   ),
                      //                   SizedBox(width: 8.sp),
                      //                   Container(
                      //                     width: 1,
                      //                     height: 24,
                      //                     color: Colors.grey.shade400,
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             suffixIcon: _phoneController.text.isNotEmpty
                      //                 ? IconButton(
                      //               icon: const Icon(
                      //                 Icons.clear,
                      //                 color: Colors.grey,
                      //               ),
                      //               onPressed: _clearPhoneNumber,
                      //             )
                      //                 : null,
                      //             filled: true,
                      //             fillColor: Colors.grey.shade100,
                      //             border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(12.sp),
                      //               borderSide: BorderSide(
                      //                 color: AppColors.navyBlue,
                      //                 width: 1.5,
                      //               ),
                      //             ),
                      //             focusedBorder: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(12.sp),
                      //               borderSide: BorderSide(
                      //                 color: AppColors.navyBlue,
                      //                 width: 1.5,
                      //               ),
                      //             ),
                      //             enabledBorder: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(12.sp),
                      //               borderSide: BorderSide(
                      //                 color: AppColors.navyBlue,
                      //                 width: 1.5,
                      //               ),
                      //             ),
                      //           ),
                      //           validator: (value) {
                      //             if (value == null || value.length != 10) {
                      //               return 'Please enter a valid 10-digit phone number';
                      //             }
                      //             return null;
                      //           },
                      //           onChanged: (value) => setState(() {}),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 30.sp),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50.sp,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            // color: HexColor('d63b7e'),
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.sp),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.blue.withOpacity(0.4),
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                              height: 20.sp,
                              width: 20.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              'GET STARTED',

                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      // Terms and conditions
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.sp),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'By using your phone number you accept our ',
                            style: GoogleFonts.roboto(
                              color: AppColors.colorWhite,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: GoogleFonts.roboto(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print("Terms & Conditions Clicked");
                                  },
                              ),
                            ],
                          ),
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
}