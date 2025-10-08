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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing SOS Icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.2),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sos,
                          color: Colors.red,
                          size: 80,
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Loop the animation
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Emergency SOS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stay calm. Tap to get help immediately.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Call SOS Button with Icon
                Container(
                  width: double.infinity,
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _makeEmergencyCall(context),
                    icon: const Icon(Icons.phone, size: 28),
                    label: const Text(
                      'CALL EMERGENCY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: Colors.red.withOpacity(0.5),
                    ),
                  ),
                ),
                // Share Location Button with Icon
                Container(
                  width: double.infinity,
                  height: 70,
                  child: OutlinedButton.icon(
                    onPressed: () => _shareLocation(context),
                    icon: const Icon(Icons.location_on, size: 28),
                    label: const Text(
                      'SHARE LOCATION',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.red.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Additional Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will connect you to local emergency services.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
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