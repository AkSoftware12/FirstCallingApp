import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

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
              'Helplines',
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
                  _HelplineCard(
                    title: 'National Emergency',
                    number: '112',
                    onCall: () => _makeCall(context, '112'),
                  ),
                  _HelplineCard(
                    title: 'Police',
                    number: '100',
                    onCall: () => _makeCall(context, '100'),
                  ),
                  _HelplineCard(
                    title: 'Ambulance',
                    number: '108',
                    onCall: () => _makeCall(context, '108'),
                  ),
                  _HelplineCard(
                    title: 'Fire Services',
                    number: '101',
                    onCall: () => _makeCall(context, '101'),
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

class _HelplineCard extends StatelessWidget {
  final String title;
  final String number;
  final VoidCallback onCall;

  const _HelplineCard({
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