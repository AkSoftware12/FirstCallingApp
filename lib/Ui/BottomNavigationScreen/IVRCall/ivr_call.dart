import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class IVRCallScreen extends StatelessWidget {
  const IVRCallScreen({super.key});

  void _makeCall(BuildContext context, String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot make call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_callback,
                    color: Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'IVR Call',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _IVRCard(
                      icon: Icons.headset_mic,
                      title: 'Customer Support',
                      number: '+91-123-456-7890',
                      onCall: () => _makeCall(context, '+911234567890'),
                    ),
                    _IVRCard(
                      icon: Icons.local_hospital,
                      title: 'Emergency Services',
                      number: '+91-987-654-3210',
                      onCall: () => _makeCall(context, '+919876543210'),
                    ),
                    _IVRCard(
                      icon: Icons.business_center,
                      title: 'Sales Inquiry',
                      number: '+91-555-123-4567',
                      onCall: () => _makeCall(context, '+915551234567'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IVRCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final VoidCallback onCall;

  const _IVRCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF0F4F8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

            border: Border.all(
              color: AppColors.navyBlue,
              width: 1.sp, // Responsive border thickness
            ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding:  EdgeInsets.all(15.sp),
        child: Row(
          children: [
            Icon(
              icon,
              size: 35.sp,
              color: AppColors.navyBlue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16.sp
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style:  TextStyle(
                      color: Colors.black54,
                      fontSize: 12.sp,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('CALL'),
              style: ElevatedButton.styleFrom(
                backgroundColor:  AppColors.navyBlue,

                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:  EdgeInsets.symmetric(
                  horizontal: 10.sp,
                  vertical: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}