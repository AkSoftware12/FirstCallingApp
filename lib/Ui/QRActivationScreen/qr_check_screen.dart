import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gscankit/gscankit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/color.dart';
import '../QRScanScreen/TorchScreen/torch_screen.dart';
import 'OTPQRCheck/otp_qr_check.dart';
import 'QRPayment/qr_payment.dart';

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
  MobileScannerController controllerScan = MobileScannerController(
    returnImage: true,
  );
  bool _isScanning = false;
  int selected = 0;
  final controller = PageController();





  void _handleDetect(BarcodeCapture capture) async {
    if (_isScanning) return;
    _isScanning = true;


    final String? value = capture.barcodes.first.rawValue;

    if (value != null && value.isNotEmpty) {
      if (_isValidUrl(value)) {
        try {
          final Uri url = Uri.parse(value);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            _showResult(value);
          }
        } catch (e) {
          debugPrint("⚠️ URL launch error: $e");
          _showResult(value);
        }
      } else {
        _showResult(value);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid QR/Barcode")));
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isScanning = false;
    });
  }




  bool _isValidUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
  }

  void _showResult(String data) {
    try {
      _isScanning = false; // ✅ Scanner ko band karo jaise hi result mil gaya
      Navigator.pop(context);
     _checkQRNumber(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid data format")),
      );
      _isScanning = false; // ✅ Error ke case me bhi scanner band
    }
  }
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

    // Show Circular Progress Popup with Card
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(
                    radius: 20,
                    color: AppColors.navyBlue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Please wait...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );


    try {
      final uri = Uri.parse(
        "${ApiRoutes.qrCodeCheck}$number",
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

      Navigator.of(context).pop(); // 👈 Hide the loading popup

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final qr = data["qr"];
          final product = data["product"];
          int isPaid = qr["is_paid"];

          print('Qr Data $qr');

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

            Fluttertoast.showToast(
              msg: data['error'].toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
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
      Navigator.of(context).pop(); // 👈 Hide popup on error too
      setState(() {
        _statusMessage = "Something went wrong: $e";
        _statusColor = AppColors.redAccent;
        _statusIcon = Icons.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,

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
                  "QR Activation",
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

      body:  SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70.sp),

            // Enhanced Header with Animation
            // Enhanced Form Container
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.all(0.sp),
                  child: Column(
                    children: [
                      // ScaleTransition(
                      //   scale: _pulseAnimation,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(20),
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       gradient: RadialGradient(
                      //         colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                      //       ),
                      //     ),
                      //     child: ClipRRect(
                      //       borderRadius: BorderRadius.circular(10.sp),
                      //
                      //       child: Image.asset(
                      //         'assets/applogo.jpg',
                      //         width: 110.sp,
                      //         height: 110.sp,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                SizedBox(height: 50.sp),

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
                              // prefixIcon: Icon(Icons.qr_code, color: AppColors.navyBlue),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.qr_code_scanner, color:AppColors.navyBlue),
                                onPressed: () {

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GscanKit(
                                        controller: controllerScan,
                                        onDetect: _handleDetect,
                                        appBar: (context, controller) {
                                          return AppBar(
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
                                                      "Scan any QR",
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
                                            backgroundColor: Colors.transparent,
                                            actions: [],
                                          );
                                        },
                                        floatingOption: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton.filled(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: CupertinoColors.systemGrey6,
                                                      foregroundColor: CupertinoColors.darkBackgroundGray,
                                                    ),
                                                    icon: Icon(CupertinoIcons.camera_rotate),
                                                    onPressed: () => controllerScan.switchCamera(),
                                                  ),
                                                  SizedBox(width: 5.sp),
                                                  ValueListenableBuilder(
                                                    valueListenable: controllerScan,
                                                    builder: (context, state, child) {
                                                      final isTorchOn = state.torchState == TorchState.on;
                                                      return TorchToggleButton(
                                                        isTorchOn: isTorchOn,
                                                        onPressed: () => controllerScan.toggleTorch(),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: 5.sp),
                                                  IconButton.filled(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: CupertinoColors.systemGrey6,
                                                      foregroundColor: CupertinoColors.darkBackgroundGray,
                                                    ),
                                                    icon: Icon(CupertinoIcons.photo),
                                                    onPressed: () async {
                                                      final picker = ImagePicker();
                                                      final pickedFile = await picker.pickImage(
                                                        source: ImageSource.gallery,
                                                      );
                                                      if (pickedFile != null) {
                                                        try {
                                                          final result = await controllerScan.analyzeImage(pickedFile.path);
                                                          if (result != null) {
                                                            _handleDetect(result);
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text("No QR/Barcode found in image")),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          debugPrint("Error scanning from gallery: $e");
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20.sp),
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 50.sp),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 150.sp,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10.sp),
                                                      ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(10.sp),
                                                                child: Image.asset(
                                                                  'assets/playstore.png',
                                                                  height: 50.sp,
                                                                  width: 50.sp,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                              SizedBox(height: 10.sp),
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        gscanOverlayConfig: GscanOverlayConfig(
                                          scannerScanArea: ScannerScanArea.center,
                                          scannerBorder: ScannerBorder.visible,
                                          scannerBorderPulseEffect: ScannerBorderPulseEffect.enabled,
                                          borderColor: AppColors.navyBlue,
                                          borderRadius: 24.0,
                                          scannerLineAnimationColor: AppColors.navyBlue,
                                          scannerOverlayBackground: ScannerOverlayBackground.blur,
                                          scannerLineAnimation: ScannerLineAnimation.enabled,
                                        ),
                                      ),
                                    ),
                                  );
                                  // TODO: Implement QR Scanner
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


                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 120.sp),

            Container(
              width: 150.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.sp),
                        child: Image.asset(
                          'assets/playstore.png',
                          height: 50.sp,
                          width: 50.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10.sp),
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
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.sp),

          ],
        ),
      ),
    );
  }
}