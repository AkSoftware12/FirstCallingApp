import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:ui';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';
import '../Otp/otp.dart'; // Assuming OTPVerificationScreen is defined here
import 'package:firstcallingapp/Utils/color.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';




class OTPVerificationScreen extends StatefulWidget {
  final String mobileNo;
  const OTPVerificationScreen({super.key, required this.mobileNo});

  @override
  State<OTPVerificationScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _secondsRemaining = 60;
  late Timer _timer;
  bool _canResend = false;



  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<String?> getDeviceToken() async {
    final fcm = FirebaseMessaging.instance;
    return await fcm.getToken();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final deviceToken = await getDeviceToken(); // Get device token
      final response = await http.post(
        Uri.parse("http://192.168.1.2/firstcallingapp/api/verifyOtp"),
        body: {
          "contact": widget.mobileNo,
          "otp": otp,
          "device_id": deviceToken ?? "", // Include device token
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BottomNavigationBarScreen(),
            ),
          );
        }
      } else {
        showSuperCoolInvalidOtpDialog(context);
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


  void showSuperCoolInvalidOtpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AnimatedScaleDialog(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.grey[900],
            elevation: 10,
            title: Row(
              children: const [
                Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Invalid OTP!',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Whoops! The OTP you entered isn’t quite right. Try again, champ! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _resendOTP() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _startTimer();
    // Simulate resend API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent!')),
    );
  }


  @override
  void dispose() {
    _timer.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
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
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(20.sp),
                    //   child: Image.asset(
                    //     'assets/applogo.jpg',
                    //     width: 100.sp,
                    //     height: 100.sp,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    // Text(
                    //   'First Calling App',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 8.sp,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //     letterSpacing: 1.5,
                    //     shadows: [
                    //       Shadow(
                    //         blurRadius: 10.0,
                    //         color: Colors.black.withOpacity(0.3),
                    //         offset: const Offset(2.0, 2.0),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: 20.sp),
                    // Instruction text

                    SizedBox(height: 10.sp),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Enter OTP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent an OTP to your phone',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                inputFormatters: [LengthLimitingTextInputFormatter(1)],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged: (_) => _onOTPChanged(index),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child:  AnimatedContainer(
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
                              onPressed: _isLoading ? null : _verifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  :  Text(
                                'Verify OTP',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Timer and Resend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_canResend)
                              Text(
                                'Resend in ${_secondsRemaining}s',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            else
                              GestureDetector(
                                onTap: _resendOTP,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Handle wrong number
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Wrong number? Change',
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),
                    // Terms and conditions
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Custom Animated Dialog Widget
class AnimatedScaleDialog extends StatefulWidget {
  final Widget child;

  const AnimatedScaleDialog({required this.child, Key? key}) : super(key: key);

  @override
  _AnimatedScaleDialogState createState() => _AnimatedScaleDialogState();
}

class _AnimatedScaleDialogState extends State<AnimatedScaleDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}