import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class VideoRecordingScreen extends StatefulWidget {
  final String phoneNumber;

  const VideoRecordingScreen({super.key, required this.phoneNumber});

  @override
  _VideoRecordingScreenState createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  String? errorMessage;

  bool isRecording = false;
  int secondsElapsed = 0;
  Timer? _timer;

  static const int maxDuration = 15; // max 15 seconds

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitCamera();
  }

  Future<void> _requestPermissionsAndInitCamera() async {
    var status = await Permission.camera.request();
    await Permission.storage.request(); // storage permission

    if (!status.isGranted) {
      setState(() {
        errorMessage = 'Camera permission denied';
      });
      return;
    }

    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        setState(() {
          errorMessage = 'No cameras available';
        });
        return;
      }

      controller = CameraController(cameras!.first, ResolutionPreset.medium);
      await controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing camera: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    if (controller == null || !controller!.value.isInitialized) {
      setState(() {
        errorMessage = 'Camera not initialized';
      });
      return;
    }

    try {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        secondsElapsed = 0;
      });

      // Timer start
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          secondsElapsed++;
        });

        if (secondsElapsed >= maxDuration) {
          _stopRecording();
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    try {
      final videoFile = await controller!.stopVideoRecording();
      _timer?.cancel();

      // Save to permanent storage
      final dcimDir = Directory('/storage/emulated/0/DCIM/MyVideos');
      if (!dcimDir.existsSync()) {
        dcimDir.createSync(recursive: true);
      }

      final newPath = join(dcimDir.path, '${DateTime.now().millisecondsSinceEpoch}.mp4');
      final savedFile = await File(videoFile.path).copy(newPath);

      setState(() {
        isRecording = false;
        secondsElapsed = 0;
      });

      // ✅ Send to WhatsApp
      final phone = widget.phoneNumber.replaceAll("+", "").replaceAll(" ", "");
      final uri = Uri.parse("https://wa.me/$phone"); // WhatsApp API link

      // launch WhatsApp with file
      await Share.shareXFiles(
        [XFile(savedFile.path)],
        text: "Video for $phone",
        sharePositionOrigin: Rect.zero,
      );

      // OR if you want to force open WhatsApp chat first
      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri, mode: LaunchMode.externalApplication);
      // }

    } catch (e) {
      setState(() {
        errorMessage = 'Error stopping recording: $e';
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),

          // Timer
          if (isRecording)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(secondsElapsed),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Record/Stop button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.videocam,
                    size: 36,
                    color: isRecording ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
