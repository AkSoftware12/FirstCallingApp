// main.dart
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Utils/HexColorCode/HexColor.dart';
import '../QRScanScreen/QRCodeData/qr_code_data.dart';

class FullScreenActionPage extends StatefulWidget {
  final String value;
  const FullScreenActionPage({super.key, required this.value});

  @override
  State<FullScreenActionPage> createState() => _FullScreenActionPageState();
}

class _FullScreenActionPageState extends State<FullScreenActionPage> {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
       appBar:AppBar(
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


      body:
      SingleChildScrollView(
        child: Container(
          color: AppColors.navyBlue,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),

                  // Header
                  Text(
                    'Quick Actions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  Text(
                    'Choose an action below',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                  SizedBox(height: 32.h),

                  // Cards area
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.sp),
                      side: BorderSide(width: 2.sp, color: Colors.lightBlueAccent), // Adjust color as needed
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.sp, bottom: 50.sp, left: 10.sp, right: 10.sp),
                      child: Expanded(
                        child: Center(
                          child: isPortrait ? _verticalLayout() : _horizontalLayout(),
                        ),
                      ),
                    ),
                  ),

                  // Footer hint
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
            color:  HexColor('#F40009'),
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
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32.sp, color: Colors.white),
              ),
              SizedBox(width: 12.w),

              // Text
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

  void _onParkingTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(data: widget.value, type: 'parking',),
      ),
    ).then((_) {
    });

  }

  void _onEmergencyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(data: widget.value, type: 'emergency',),
      ),
    ).then((_) {
    });
  }
}