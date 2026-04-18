import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// App Store (2.1a): request camera before opening QR scanner — same behavior on Android/iOS.
Future<bool> ensureCameraPermission(BuildContext context) async {
  var status = await Permission.camera.status;
  if (status.isDenied || status.isRestricted || status.isLimited) {
    status = await Permission.camera.request();
  }
  if (status.isGranted) return true;

  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Camera permission'),
      content: const Text(
        'Camera access is required to scan QR codes. You can enable it in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await openAppSettings();
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
  return false;
}
