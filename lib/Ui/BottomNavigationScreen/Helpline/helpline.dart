import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Utils/color.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:  EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                     Text(
                      'Emergency Helplines',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                 Text(
                  'Quick Access to Help',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _HelplineCard(
                        icon: Icons.emergency,
                        title: 'National Emergency',
                        number: '112',
                        color: Colors.red,
                        onCall: () => _makeCall(context, '112'),
                      ),
                      _HelplineCard(
                        icon: Icons.local_police,
                        title: 'Police',
                        number: '100',
                        color: Colors.blue,
                        onCall: () => _makeCall(context, '100'),
                      ),
                      _HelplineCard(
                        icon: Icons.local_hospital,
                        title: 'Ambulance',
                        number: '108',
                        color: Colors.green,
                        onCall: () => _makeCall(context, '108'),
                      ),
                      _HelplineCard(
                        icon: Icons.local_fire_department,
                        title: 'Fire Services',
                        number: '101',
                        color: Colors.orange,
                        onCall: () => _makeCall(context, '101'),
                      ),
                    ],
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

class _HelplineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final Color color;
  final VoidCallback onCall;

  const _HelplineCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(bottom: 10.sp),
      child: Card(
        elevation: 8,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding:  EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 1.sp, // Responsive border thickness
            ),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:  EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.sp,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 13.sp
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
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
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding:  EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}