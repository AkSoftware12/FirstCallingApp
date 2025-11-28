import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class SetFlashScreen extends StatefulWidget {
  const SetFlashScreen({super.key});

  @override
  State<SetFlashScreen> createState() => _SetFlashScreenState();
}

class _SetFlashScreenState extends State<SetFlashScreen> {
  bool _isFlashOn = false;

  Future<void> _toggleFlash() async {
    try {
      if (_isFlashOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              _isFlashOn ? 'Flashlight ON' : 'Flashlight OFF',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleFlash,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(_isFlashOn ? 'Turn OFF' : 'Turn ON'),
            ),
          ],
        ),
      ),
    );
  }
}