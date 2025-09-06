import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCodeScannerPage extends StatefulWidget {
  final Function(String?) onScan;

  const QRCodeScannerPage({super.key, required this.onScan});

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  MobileScannerController controller = MobileScannerController();
  String? scanResult;
  String? lastScannedCode;
  bool isProcessing = false;

  Future<void> _launchURL(String? code) async {
    if (code == null || isProcessing || code == lastScannedCode) return;

    setState(() {
      isProcessing = true;
      scanResult = code;
    });

    widget.onScan(code);

    final Uri? uri = Uri.tryParse(code);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          setState(() {
            lastScannedCode = code;
          });
        } else {
          setState(() {
            scanResult = 'Could not launch $code';
          });
        }
      } catch (e) {
        setState(() {
          scanResult = 'Error launching URL: $e';
        });
      }
    }

    await controller.stop();
    await Future.delayed(const Duration(seconds: 2));
    await controller.start();

    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), centerTitle: true),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  _launchURL(code);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scanResult != null)
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Scanned: $scanResult',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
                  : const Text(
                'Scan a QR code',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                controller.toggleTorch();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              child: Text(
                'Toggle Flash: ${controller.torchEnabled ? 'On' : 'Off'}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
