// main.dart (Full Code)
import 'dart:convert';

import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../BaseUrl/baseurl.dart';
import '../../Utils/HexColorCode/HexColor.dart';
import '../QRActivationScreen/qr_check_screen.dart';
import '../QRScanScreen/QRCodeData/qr_code_data.dart';

class FullScreenActionPage extends StatefulWidget {
  final String value;
  const FullScreenActionPage({super.key, required this.value});

  @override
  State<FullScreenActionPage> createState() => _FullScreenActionPageState();
}

class _FullScreenActionPageState extends State<FullScreenActionPage> {
  // ✅ API states
  bool isLoading = false;
  bool? apiSuccess; // null=initial, true=success, false=failed
  String apiMessage = "";
  String userContact = '';


  // ✅ QR object
  Map<String, dynamic>? qrData;
  bool needsUpdate = false;

  @override
  void initState() {
    super.initState();
    fetchQrDetails();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userContact = prefs.getString('user_contact') ?? '';
    });
  }

  bool _isNullOrEmpty(dynamic v) {
    if (v == null) return true;
    if (v is String && v.trim().isEmpty) return true;
    return false;
  }

  bool _needsUpdate(Map<String, dynamic>? qr) {
    if (qr == null) return true;
    return _isNullOrEmpty(qr["name"]) ||
        _isNullOrEmpty(qr["address"]) ||
        _isNullOrEmpty(qr["gender"]) ||
        _isNullOrEmpty(qr["email"]) ||
        _isNullOrEmpty(qr["contact_no1"]) ||
        _isNullOrEmpty(qr["contact_no2"]);
  }
  Future<void> fetchQrDetails() async {
    setState(() {
      isLoading = true;
      apiSuccess = null;
      apiMessage = "";
      qrData = null;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiRoutes.qrCodeScan}${widget.value}"),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      final bool success = data["success"] == true;

      if (success) {
        final qr = data['data']?['QR'];

        final bool needUpdate = _needsUpdate(qr);

        setState(() {
          apiSuccess = true;
          qrData = qr;
          needsUpdate = _needsUpdate(qrData); // ✅ HERE
          isLoading = false;

          // ✅ same inactive screen dikhani hai, to message optional set kar do
          // design same rahega, bas text change hoga (chahe to blank bhi rakh sakte ho)
          apiMessage = needUpdate
              ? "This QR code is not activated yet. Please update details."
              : "";
        });
      } else {
        setState(() {
          apiSuccess = false;
          apiMessage = (data["message"] ?? "Invalid or unassigned QR code").toString();
          isLoading = false;
          qrData = null;
        });
      }

    } catch (e) {
      if (!mounted) return;
      setState(() {
        apiSuccess = false;
        apiMessage = "Network error. Please try again.";
        isLoading = false;
        qrData = null;
      });
      debugPrint("❌ Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final bool showInactiveScreen =
        (apiSuccess != true) || needsUpdate;

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Parking & Emergency",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "First Calling App",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),

      body: Container(
        color: AppColors.navyBlue,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: isLoading
                ? _loadingView()
                : showInactiveScreen
                ? _inactiveQrView()
                : _successView(isPortrait),

    ),
        ),
      ),
    );
  }

  // =========================
  // ✅ LOADER VIEW
  // =========================
  Widget _loadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 55.sp,
            height: 55.sp,
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            "Checking QR Code...",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Please wait",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ✅ SUCCESS VIEW (YOUR UI)
  // =========================
  Widget _successView(bool isPortrait) {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.navyBlue,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),

              Text(
                'Quick Actions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Choose an action below',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.white),
              ),
              SizedBox(height: 32.h),

              Card(
                margin: EdgeInsets.zero,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.sp),
                  side: BorderSide(width: 2.sp, color: Colors.lightBlueAccent),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 50.sp,
                    bottom: 50.sp,
                    left: 10.sp,
                    right: 10.sp,
                  ),
                  child: Center(
                    child: isPortrait ? _verticalLayout() : _horizontalLayout(),
                  ),
                ),
              ),

              SizedBox(height: 18.h),
              const Center(
                child: Text(
                  'Swipe down or press back to close',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              SizedBox(height: 40.h),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0.sp),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalLayout() {
    return Column(
      children: [
        SizedBox(
          height: 100.h,
          child: _buildActionCard(
            title: 'Parking',
            subtitle: 'Find / Reserve spot',
            icon: Icons.local_parking,
            color: AppColors.navyBlue,
            onTap: _onParkingTap,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 100.h,
          child: _buildActionCard(
            title: 'Emergency ',
            subtitle: 'Call / Show info',
            icon: Icons.warning_amber_rounded,
            color: HexColor('#F40009'),
            onTap: _onEmergencyTap,
            showBadge: true,
          ),
        ),
      ],
    );
  }

  Widget _horizontalLayout() {
    return SizedBox(
      height: 100.h,
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              title: 'Parking',
              subtitle: 'Find / Reserve spot',
              icon: Icons.local_parking,
              color: Colors.blue,
              onTap: _onParkingTap,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: _buildActionCard(
              title: 'Emergency Card',
              subtitle: 'Call / Show info',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              onTap: _onEmergencyTap,
              showBadge: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32.sp, color: Colors.white),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ✅ FAIL VIEW (SAME SCREEN)
  // =========================
  Widget _inactiveQrView() {
    // ✅ yaha decide hoga: invalid hai ya update required hai
    final bool isUpdateRequired = (apiSuccess == true && needsUpdate == true);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40.h),

            Container(
              height: 72.sp,
              width: 72.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexColor('#F40009').withOpacity(0.14),
                border: Border.all(color: HexColor('#F40009'), width: 1.2),
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white,
                size: 42.sp,
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              isUpdateRequired ? "Update Required" : "QR Code Inactive",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              isUpdateRequired
                  ? "This QR code is valid, but your details are missing. Please update the QR profile to enable Parking & Emergency actions."
                  : (apiMessage.isNotEmpty
                  ? apiMessage
                  : "This QR code is invalid or not assigned yet."),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Column(
                children: [
                  Text(
                    isUpdateRequired ? "Update QR Details" : "Activate this QR Code",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  Text(
                    isUpdateRequired
                        ? "Complete your profile information to unlock Parking & Emergency features."
                        : "Parking and Emergency actions will be available only after activation.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.black.withOpacity(0.22),
                    ),
                    child: Text(
                      "QR Code: ${widget.value}",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.25)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      "Back",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRActive()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      isUpdateRequired ? "Update Now" : "Active",
                      style: GoogleFonts.poppins(
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // =========================
  // ✅ ACTIONS
  // =========================
  void _onParkingTap() {
    // ✅ safety
    if (qrData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          data: widget.value,
          type: 'parking',
          qrData: qrData,
          userNumber: userContact,
        ),
      ),
    );
  }

  void _onEmergencyTap() {
    // ✅ safety
    if (qrData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          data: widget.value,
          type: 'emergency',
          qrData: qrData,
          userNumber: userContact,
        ),
      ),
    );
  }
}
