import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../Utils/color.dart';


class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation for text sections
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Slide animation for content
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for cart icon
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Privacy policy',style: TextStyle(color: Colors.white),)

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Last updated: Oct 06, 2025',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '1. Introduction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Welcome to our application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this policy carefully.',
                  style: TextStyle(fontSize: 16,
                  color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '2. Information We Collect',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                      color: Colors.white

                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'We may collect information about you in a variety of ways, including:\n'
                      '- Personal Data: Information such as your name, email address, and other contact details you provide.\n'
                      '- Usage Data: Information about how you use the application, such as features used and time spent.\n'
                      '- Device Information: Details about your device, including model, operating system, and unique identifiers.',
                  style: TextStyle(fontSize: 16,                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '3. How We Use Your Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                      color: Colors.white

                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'We use the information we collect to:\n'
                      '- Provide, operate, and maintain our application.\n'
                      '- Improve, personalize, and expand our services.\n'
                      '- Communicate with you, including for customer service and updates.',
                  style: TextStyle(fontSize: 16,                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '4. Sharing Your Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,                    color: Colors.white

                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'We do not share your personal information with third parties except:\n'
                      '- With your consent.\n'
                      '- To comply with legal obligations.\n'
                      '- To protect and defend our rights and property.',
                  style: TextStyle(fontSize: 16,                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '5. Contact Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                      color: Colors.white

                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'If you have any questions about this Privacy Policy, please contact us at:\n'
                      'Email: support@example.com',
                  style: TextStyle(fontSize: 16,                    color: Colors.white
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