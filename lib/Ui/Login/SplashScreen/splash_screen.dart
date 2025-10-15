import 'dart:convert';
import 'package:firstcallingapp/AgentUI/AgentBottomNavigationBar/agentBottomNvaigationBar.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:firstcallingapp/Utils/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../BottomNavigationBar/bottomNvaigationBar.dart';
import '../Login/login.dart';

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
        // no login found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
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