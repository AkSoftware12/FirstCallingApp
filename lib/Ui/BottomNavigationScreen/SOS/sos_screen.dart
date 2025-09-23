import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  void _makeEmergencyCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make emergency call')),
      );
    }
  }

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // backgroundColor: const Color(0xFF1B263B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sos, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Emergency SOS',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to call emergency services or share location',
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _makeEmergencyCall(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'CALL SOS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _shareLocation(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'SHARE LOCATION',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
