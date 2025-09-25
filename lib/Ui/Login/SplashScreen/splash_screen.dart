import 'dart:convert';
import 'package:flutter/material.dart';
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

    await Future.delayed(const Duration(seconds: 2)); // 👈 splash delay

    if (mounted) {
      if (token != null && userData != null) {
        // ✅ user already logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
        );
      } else {
        // ❌ no login found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 👈 splash loader
      ),
    );
  }
}
