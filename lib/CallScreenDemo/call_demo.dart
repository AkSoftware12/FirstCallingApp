import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class TwilioCallScreen extends StatefulWidget {
  final String receiverPhone;

  const TwilioCallScreen({super.key, required this.receiverPhone});

  @override
  State<TwilioCallScreen> createState() => _TwilioCallScreenState();
}

class _TwilioCallScreenState extends State<TwilioCallScreen> {
  bool isCalling = false;
  bool isConnected = false;
  String status = "Idle";

  @override
  void initState() {
    super.initState();
    _initializeTwilio();
  }

  /// Twilio event listener
  void _initializeTwilio() {
    TwilioVoice.instance.callEventsListener.listen((event) {
      print("Twilio Event: $event");

      switch (event) {
        // case CallEvent.:
        case CallEvent.reconnecting:
          setState(() => status = "Connecting...");
          break;

        case CallEvent.ringing:
          setState(() => status = "Ringing...");
          FlutterRingtonePlayer().playRingtone();
          break;

        case CallEvent.connected:
          FlutterRingtonePlayer().stop();
          setState(() {
            isConnected = true;
            status = "Connected";
          });
          break;

        case CallEvent.callEnded:
          FlutterRingtonePlayer().stop();
          setState(() {
            isConnected = false;
            isCalling = false;
            status = "Disconnected";
          });
          break;

        default:
          break;
      }
    });
  }

  /// API Call with SharedPreferences token
  Future<void> _startCall() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      setState(() => status = "Token missing! Please login again.");
      return;
    }

    setState(() {
      isCalling = true;
      status = "Starting call...";
    });

    try {
      final response = await http.post(
        Uri.parse("https://firstcallingapp.com/api/calls/initiate"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          'receiver_phone': widget.receiverPhone,
        },
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => status = "Call initiated. Waiting for connection...");
        } else {
          setState(() {
            isCalling = false;
            status = "Call failed: ${data['message']}";
          });
        }
      } else {
        setState(() {
          isCalling = false;
          status = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isCalling = false;
        status = "Error: $e";
      });
    }
  }

  Future<void> _endCall() async {
    try {
      TwilioVoice.instance.call.hangUp();
      setState(() {
        status = "Call Ended";
        isCalling = false;
        isConnected = false;
      });
    } catch (e) {
      setState(() => status = "Error ending call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Twilio Voice Call")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Call Status: $status",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            if (!isCalling)
              ElevatedButton(
                onPressed: _startCall,
                child: const Text("Start Call"),
              ),
            if (isCalling && !isConnected)
              ElevatedButton(
                onPressed: _endCall,
                child: const Text("Cancel Call"),
              ),
            if (isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _endCall,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("End Call"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
