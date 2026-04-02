// otp.dart (FULL CODE)
// NOTE: Apne project ke hisaab se imports / route names match kar lena.

import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../AgentUI/AgentBottomNavigationBar/agentBottomNvaigationBar.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNo;
  final bool fromCheckout;   // 👈 add this


  const OTPVerificationScreen({super.key, required this.mobileNo,  this.fromCheckout = false,});

  @override
  State<OTPVerificationScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  // ---------------- TIMER ----------------
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // ---------------- FCM TOKEN ----------------
  Future<String?> getDeviceToken() async {
    final fcm = FirebaseMessaging.instance;
    return await fcm.getToken();
  }

  // ---------------- OTP PASTE DISTRIBUTE ----------------
  void _setOtpFromPaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    final otp = digits.length >= 6 ? digits.substring(0, 6) : digits;

    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = (i < otp.length) ? otp[i] : '';
    }

    // Focus next
    final nextIndex = otp.length >= 6 ? 5 : otp.length;
    if (nextIndex >= 0 && nextIndex < 6) _focusNodes[nextIndex].requestFocus();

    // Auto verify
    if (otp.length == 6) _verifyOTP();
  }

  // ---------------- BACKSPACE FIX ----------------
  void _handleKeyPress(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      // If current has value -> clear it
      if (_otpControllers[index].text.isNotEmpty) {
        _otpControllers[index].clear();
        return;
      }

      // If current empty -> move previous + clear previous
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
        _otpControllers[index - 1].clear();
      }
    }
  }

  // ---------------- ON CHANGED SMART (typing + paste) ----------------
  void _onOtpChangedSmart(int index, String value) {
    // Paste case: multiple chars in one box
    if (value.length > 1) {
      _setOtpFromPaste(value);
      return;
    }

    // Normal typing
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) _verifyOTP();
  }

  // ---------------- VERIFY OTP ----------------
  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final deviceToken = await getDeviceToken();

      final response = await http.post(
        Uri.parse(ApiRoutes.verifyOtp),
        body: {
          "contact": widget.mobileNo,
          "otp": otp,
          "device_id": deviceToken ?? "",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));

        await _saveProfileToPrefs(
          (data["user"]?["contact"] ?? "").toString(),
          (data["user"]?["name"] ?? "").toString(),
          (data["user"]?["image"] ?? "").toString(),
        );

        final int isAgent =
            int.tryParse((data["user"]?["is_agent"] ?? "0").toString()) ?? 0;

        if (!mounted) return;
        setState(() => _isLoading = false);


        // 👇 IMPORTANT PART
        if (widget.fromCheckout) {
          Navigator.pop(context, true); // checkout screen par wapas
          Navigator.pop(context, true); // checkout screen par wapas
          return;
        }

        if (isAgent != 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavigationBarScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const AgentBottomNavigationBarScreen()),
          );
        }
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showInvalidOtpDialog(context);
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProfileToPrefs(String number, String name, String image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_contact', number);
    await prefs.setString('user_name', name);
    await prefs.setString('user_photo_url', image);
  }

  // ---------------- RESEND ----------------
  void _resendOTP() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _startTimer();

    // TODO: yaha resend OTP API hit karni hai
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('OTP resent!')));
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // ---------------- INVALID DIALOG ----------------
  void showInvalidOtpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutBack,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.error_rounded,
                        color: Color(0xFFFF0000),
                        size: 40,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Invalid OTP!',
                        style: TextStyle(
                          color: Color(0xFFFF0000),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your OTP is not correct. Let’s try that again! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.navyBlue, AppColors.navyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 20.sp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Text
                        Padding(
                          padding: EdgeInsets.only(top: 0.sp, bottom: 20.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Code',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text:
                                  'A 6-Digit OTP (One time password) has been sent by WhatsApp to ',
                                  style: GoogleFonts.roboto(
                                    color: AppColors.colorWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' +91${widget.mobileNo}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.lightBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.sp),

                        // OTP Card + Verify Button
                        Center(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                elevation: 4,
                                color: Colors.white,
                                margin: EdgeInsets.only(bottom: 40.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.sp),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20.sp),
                                      Text(
                                        'Enter OTP',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navyBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'We sent an OTP to your phone',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.navyBlue,
                                        ),
                                      ),
                                      SizedBox(height: 40.sp),

                                      // OTP Inputs (FIXED: backspace + paste)
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: List.generate(6, (index) {
                                          return SizedBox(
                                            width: 40.sp,
                                            child: RawKeyboardListener(
                                              focusNode: FocusNode(),
                                              onKey: (event) =>
                                                  _handleKeyPress(index, event),
                                              child: TextField(
                                                controller:
                                                _otpControllers[index],
                                                focusNode: _focusNodes[index],
                                                keyboardType:
                                                TextInputType.number,
                                                textAlign: TextAlign.center,
                                                enableInteractiveSelection:
                                                true,
                                                autofillHints: const [
                                                  AutofillHints.oneTimeCode
                                                ],
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      6),
                                                ],
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                    borderSide: BorderSide(
                                                      color: Colors.blue[600]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[50],
                                                ),
                                                onChanged: (val) =>
                                                    _onOtpChangedSmart(
                                                        index, val),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),

                                      SizedBox(height: 40.sp),
                                    ],
                                  ),
                                ),
                              ),

                              // Verify Button
                              Positioned(
                                bottom: 25,
                                child: SizedBox(
                                  width: 150.sp,
                                  height: 40.sp,
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.navyBlue,
                                          Colors.blue.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(20.sp),
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                      _isLoading ? null : _verifyOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20.sp),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                        height: 20.sp,
                                        width: 20.sp,
                                        child:
                                        const CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(Colors.white),
                                        ),
                                      )
                                          : Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Verify OTP',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          SizedBox(width: 8.sp),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 16.sp,
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

                        SizedBox(height: 20.sp),

                        // Resend OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_canResend)
                              Text(
                                'Resend in ${_secondsRemaining}s',
                                style: const TextStyle(
                                  color: Color(0xFFFF0000),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: _resendOTP,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Wrong Number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Wrong number? Change',
                                style: TextStyle(color: Colors.blue[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Footer
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20.sp,
                color: AppColors.navyBlue,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Provided by  ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Ak Software',
                          style: GoogleFonts.poppins(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
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
      ),
    );
  }
}
