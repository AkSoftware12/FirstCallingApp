import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IVRCallScreen extends StatelessWidget {
  const IVRCallScreen({super.key});

  void _makeCall(BuildContext context, String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot make call')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IVR Call',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _IVRCard(
                    title: 'Customer Support',
                    number: '+91-123-456-7890',
                    onCall: () => _makeCall(context, '+911234567890'),
                  ),
                  _IVRCard(
                    title: 'Emergency Services',
                    number: '+91-987-654-3210',
                    onCall: () => _makeCall(context, '+919876543210'),
                  ),
                  _IVRCard(
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
    );
  }
}

class _IVRCard extends StatelessWidget {
  final String title;
  final String number;
  final VoidCallback onCall;

  const _IVRCard({
    required this.title,
    required this.number,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1B263B), const Color(0xFF2A3F5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            ElevatedButton(onPressed: onCall, child: const Text('CALL')),
          ],
        ),
      ),
    );
  }
}