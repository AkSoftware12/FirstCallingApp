import 'dart:convert';
import 'dart:io';
import 'package:firstcallingapp/AgentUI/AgentBottomNavigationBar/agentBottomNvaigationBar.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:firstcallingapp/Utils/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Utils/HexColorCode/HexColor.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final userData = prefs.getString("user");


    print('$userData');

    await Future.delayed(const Duration(seconds: 4)); // splash delay

    if (mounted) {
      if (token != null && userData != null) {
        // decode user data
        final userMap = jsonDecode(userData);
        final isAgent = int.tryParse(userMap['is_agent'].toString()) ?? 0;

        if (isAgent != 1) {
          // normal user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
          );
        } else {
          // agent user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AgentBottomNavigationBarScreen()), // 👈 apni agent wali screen yahan lagao
          );
        }
      } else {
        // Guest: browse products & non-account features without registration (App Store 5.1.1).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationBarScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            ClipRRect(
              borderRadius: BorderRadius.circular(20.sp),

              child: Image.asset(
                'assets/applogo.jpg',
                width: 130.sp,
                height: 130.sp,
              ),
            ),
            SizedBox(height: 10.sp), // Spacing between logo and app name
            // App name
            Text(
              AppStrings.appName, // Replace with your app name
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),

            SizedBox(height: 20.sp), // Spacing before loader
            CupertinoActivityIndicator(
              radius: 25,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomUpgradeDialog extends StatelessWidget {
  final String androidAppUrl = 'https://play.google.com/store/apps/details?id=com.firstcallingapp.firstcallingapp&pcampaignid=web_share';
  final String iosAppUrl = 'https://apps.apple.com/app/idYOUR_IOS_APP_ID'; // Replace with your iOS app URL
  final String currentVersion; // Old version
  final String newVersion; // New version
  final List<String> releaseNotes; // Release notes

  const CustomUpgradeDialog({
    Key? key,
    required this.currentVersion,
    required this.newVersion,
    required this.releaseNotes,
  }) : super(key: key);

  Future<void> _launchStore() async {
    final Uri androidUri = Uri.parse(androidAppUrl);
    final Uri iosUri = Uri.parse(iosAppUrl);

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(iosUri)) {
          await launchUrl(
            iosUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch iOS App Store';
        }
      } else if (Platform.isAndroid) {
        if (await canLaunchUrl(androidUri)) {
          await launchUrl(
            androidUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch Play Store';
        }
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.sp)),
      elevation: 12,

      child: Container(
        constraints: BoxConstraints(maxWidth: 420),
        padding: EdgeInsets.all(25.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyBlue,AppColors.navyBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.sp),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      HexColor('#FFFFFF'),
                      AppColors.navyBlue.withOpacity(0.9),
                    ],
                    radius: 0.55,
                    center: Alignment.center,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white60,
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10.sp),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 52.sp,
                  color:AppColors.navyBlue,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                "🚀 New Update Available!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.sp),
              Center(
                child: Text(
                  "A new version of Upgrader is available! Version $newVersion is now available - you have $currentVersion",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.sp),

              Center(
                child: Text(
                  " Would you like to update it now?",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 5.sp),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New in Version $newVersion",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    ...releaseNotes.asMap().entries.map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 15.sp),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:AppColors.navyBlue,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 28.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sp),
                    side: BorderSide(color: Colors.white, width: 1.sp),
                  ),
                ),
                icon: Icon(Icons.rocket_launch, size: 20.sp,color: Colors.white,),
                label: Text(
                  "Update Now".toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),
                ),
                onPressed: () async {
                  await _launchStore();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();