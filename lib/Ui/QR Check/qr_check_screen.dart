import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/color.dart';
import '../BottomNavigationBar/bottomNvaigationBar.dart';

class QRActive extends StatefulWidget {
  const QRActive({super.key});

  @override
  _QRActiveState createState() => _QRActiveState();
}

class _QRActiveState extends State<QRActive> with TickerProviderStateMixin {
  final TextEditingController _qrController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.info;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _checkQRNumber(String number) async {
    if (number.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    _animationController.reset();
    _animationController.forward();

    try {
      final uri = Uri.parse(
        "http://192.168.1.20/firstcallingapp/api/qr/check?qr_number=$number",
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final qr = data["qr"];
          final product = data["product"];
          int isPaid = qr["is_paid"];

          if (isPaid == 1) {
            setState(() {
              _statusMessage = "OTP verification required. Navigating to OTP screen.";
              _statusColor = AppColors.navyBlue;
              _statusIcon = Icons.verified_user;
            });

            Future.delayed(const Duration(milliseconds: 800), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OTPScreen(qrData: qr)),
              );
            });
          } else {
            setState(() {
              _statusMessage = "Payment pending. Navigating to Payment screen.";
              _statusColor = Colors.green;
              _statusIcon = Icons.payment;
            });

            Future.delayed(const Duration(milliseconds: 800), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(qrData: qr, productData: product),
                ),
              );
            });
          }
        } else {
          setState(() {
            _statusMessage = "QR number does not exist.";
            _statusColor = AppColors.redAccent;
            _statusIcon = Icons.error;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _statusMessage = "Unauthorized! Token invalid or expired.";
          _statusColor = AppColors.redAccent;
          _statusIcon = Icons.lock;
        });
      } else {
        setState(() {
          _statusMessage = "Server error: ${response.statusCode}";
          _statusColor = AppColors.redAccent;
          _statusIcon = Icons.error;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Something went wrong: $e";
        _statusColor = AppColors.redAccent;
        _statusIcon = Icons.error;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.navyBlue,
        title: Text('QR Activation',style: TextStyle(color: Colors.white,fontSize: 14.sp),),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navyBlue,
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Enhanced Header with Animation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.sp),

                              child: Image.asset(
                                'assets/applogo.jpg',
                                width: 110.sp,
                                height: 110.sp,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'QR Activation',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        Text(
                          'Enter your QR number',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Enhanced Form Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.colorWhite, Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: AppColors.navyBlue.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:  EdgeInsets.all(20.sp),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Enhanced QR Input with Glow Effect
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navyBlue.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _qrController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Enter QR Number',
                                prefixIcon: Icon(Icons.qr_code, color: AppColors.navyBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.qr_code_scanner, color: Colors.purple),
                                  onPressed: () {
                                    // TODO: Implement QR Scanner
                                    _checkQRNumber(_qrController.text);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                labelStyle: TextStyle(color: AppColors.navyBlue.withOpacity(0.7)),
                              ),
                              onSubmitted: _checkQRNumber,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Enhanced Submit Button with Gradient and Animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _checkQRNumber(_qrController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isLoading ? [Colors.grey, Colors.grey[300]!] : [AppColors.navyBlue, Color(0xFF3B82F6)],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isLoading ? Colors.grey : AppColors.navyBlue).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Checking...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                                    : const Center(
                                  child: Text(
                                    'Check',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (_statusMessage.isNotEmpty) ...[
                            const SizedBox(height: 40),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _statusColor.withOpacity(0.15),
                                      _statusColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _statusColor.withOpacity(0.4), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _statusColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _statusColor.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(_statusIcon, color: _statusColor, size: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _statusMessage,
                                        style: TextStyle(
                                          color: _statusColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      final uri = Uri.parse("http://192.168.1.20/firstcallingapp/api/qr/verifyOtp");

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
                builder: (_) => UpdateScreen(qrData: widget.qrData,),
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
}



class UpdateScreen extends StatefulWidget {
  final Map qrData;
  const UpdateScreen({super.key, required this.qrData,}); // Make token required

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  // Form controllers to track changes
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _contactNo1Controller;
  late TextEditingController _contactNo2Controller;

  // Family members controllers
  late TextEditingController _family1NameController;
  late TextEditingController _family1RelationController;
  late TextEditingController _family1NoController;
  late TextEditingController _family2NameController;
  late TextEditingController _family2RelationController;
  late TextEditingController _family2NoController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial values
    _nameController = TextEditingController(text: widget.qrData['name'] ?? 'N/A');
    _dobController = TextEditingController(text: widget.qrData['dob'] ?? 'N/A');
    _addressController = TextEditingController(text: widget.qrData['address'] ?? 'N/A');
    _genderController = TextEditingController(text: widget.qrData['gender'] ?? 'N/A');
    _emailController = TextEditingController(text: widget.qrData['email'] ?? 'N/A');
    _contactNo1Controller = TextEditingController(text: widget.qrData['contact_no1'] ?? 'N/A');
    _contactNo2Controller = TextEditingController(text: widget.qrData['contact_no2'] ?? 'N/A');

    _family1NameController = TextEditingController(text: widget.qrData['family_member1_name'] ?? 'N/A');
    _family1RelationController = TextEditingController(text: widget.qrData['family_member1_relation'] ?? 'N/A');
    _family1NoController = TextEditingController(text: widget.qrData['family_member1_no'] ?? 'N/A');

    _family2NameController = TextEditingController(text: widget.qrData['family_member2_name'] ?? 'N/A');
    _family2RelationController = TextEditingController(text: widget.qrData['family_member2_relation'] ?? 'N/A');
    _family2NoController = TextEditingController(text: widget.qrData['family_member2_no'] ?? 'N/A');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _contactNo1Controller.dispose();
    _contactNo2Controller.dispose();

    _family1NameController.dispose();
    _family1RelationController.dispose();
    _family1NoController.dispose();
    _family2NameController.dispose();
    _family2RelationController.dispose();
    _family2NoController.dispose();
    super.dispose();
  }

  // Function to collect all data and hit API with token
  Future<void> _updateData() async {
    // Collect updated data into a Map
    Map<String, dynamic> updateData = {
      'qr_number': widget.qrData['qr_number'],
      'name': _nameController.text,
      'dob': _dobController.text,
      'address': _addressController.text,
      'gender': _genderController.text,
      'email': _emailController.text,
      'contact_no1': _contactNo1Controller.text,
      'contact_no2': _contactNo2Controller.text,
      'family_member1_name': _family1NameController.text,
      'family_member1_relation': _family1RelationController.text,
      'family_member1_no': _family1NoController.text,
      'family_member2_name': _family2NameController.text,
      'family_member2_relation': _family2RelationController.text,
      'family_member2_no': _family2NoController.text,
    };

    // Replace with your actual API endpoint URL
    const String apiUrl = 'http://192.168.1.20/firstcallingapp/api/qr/update'; // Update this URL

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Added Bearer token for auth
          // Add other headers if needed
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        showSuccessPopup(context);
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Click outside se close na ho
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Container(
            // Height remove kar di – auto size ho jayega
            padding: EdgeInsets.all(24), // Padding thoda badhaya for breathing room
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Yeh add kiya – compact size ke liye
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon with animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'QR Update Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your QR code has been updated successfully.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24), // Thoda kam kiya for balance
                // Close Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
                    // );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          " QR Code Update",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.colorWhite,
        elevation: 0,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 00),
              _buildSectionTitle("Personal Information"),
              _buildTextField("Name", _nameController),
              _buildTextField("Date of Birth", _dobController),
              _buildTextField("Address", _addressController),
              _buildTextField("Gender", _genderController),
              _buildTextField("Email", _emailController),
              _buildTextField("Contact No 1", _contactNo1Controller),
              _buildTextField("Contact No 2", _contactNo2Controller),
              const SizedBox(height: 20),
              _buildSectionTitle("Family Members"),
              _buildFamilyMemberSection("Family Member 1", 1),
              const SizedBox(height: 15),
              _buildFamilyMemberSection("Family Member 2", 2),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _updateData, // Calls API with token
                  label: Text("UPDATE", style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: AppColors.colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: AppColors.navyBlue,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, // Use controller instead of initialValue
            decoration: InputDecoration(
              prefixIcon: Icon(
                _getIconForLabel(label), // Helper to get icon based on label
                color: AppColors.navyBlue.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: AppColors.colorWhite,
              contentPadding: const EdgeInsets.all(15),
            ),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.colorBlack,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get icon based on label (you can expand this)
  IconData _getIconForLabel(String label) {
    switch (label) {
      case "Name":
        return Icons.person;
      case "Date of Birth":
        return Icons.cake;
      case "Address":
        return Icons.location_on;
      case "Gender":
        return Icons.wc;
      case "Email":
        return Icons.email;
      case "Contact No 1":
      case "Contact No 2":
        return Icons.phone;
      default:
        return Icons.info;
    }
  }

  Widget _buildFamilyMemberSection(String title, int memberNumber) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            _buildSmallTextField("Name", memberNumber == 1 ? _family1NameController : _family2NameController),
            _buildSmallTextField("Relation", memberNumber == 1 ? _family1RelationController : _family2RelationController),
            _buildSmallTextField("Contact No", memberNumber == 1 ? _family1NoController : _family2NoController),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.navyBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller, // Use controller
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.2)),
                ),
                filled: true,
                fillColor: AppColors.colorWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.colorBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  final Map qrData;
  final Map productData;
  const PaymentScreen({super.key, required this.qrData, required this.productData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          "भुगतान",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: AppColors.colorWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: 60,
                          color: Colors.green[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "QR नंबर: ${qrData['qr_number']}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "उत्पाद: ${productData['name']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "मूल्य: ₹${productData['selling_price']}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Payment Logic (e.g., integrate Razorpay or similar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.payment, color: Colors.white),
                            SizedBox(width: 8),
                            Text('भुगतान प्रक्रिया शुरू...'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "अभी भुगतान करें",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}