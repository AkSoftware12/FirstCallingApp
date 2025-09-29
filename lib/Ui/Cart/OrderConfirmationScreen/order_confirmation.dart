import 'package:flutter/material.dart';

import '../../../Utils/color.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyBlue, AppColors.navyBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated checkmark
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.bounceOut,
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            // Fun title
            const Text(
              "Order Placed! 🎉",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Fun message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Your order is confirmed and on its way! Cart cleared, ready for your next adventure! 😎",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Continue button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavigationBarScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Continue Shopping! 🚀",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

