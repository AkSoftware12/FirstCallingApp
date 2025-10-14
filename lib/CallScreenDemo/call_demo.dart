import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:http/http.dart' as http;

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String? _accessToken;
  final String? _userIdentity='+18504294634'; // ✅ Added: Store the user identity from backend
  String callStatus = "Idle";
  bool _isInitialized = false;
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTwilio();
    fetchAndSetupToken();
  }

  /// ✅ Initialize Twilio voice listeners
  void initTwilio() {
    TwilioVoice.instance.callEventsListener.listen((CallEvent event) {
      debugPrint("📞 Twilio Event: $event");

      if (!mounted) return;

      setState(() {
        switch (event) {
          case CallEvent.incoming:
            callStatus = "Connecting...";
            break;

          case CallEvent.connected:
            callStatus = "Connected";
            break;

          case CallEvent.callEnded:
            callStatus = "Call Ended";
            break;
          case CallEvent.declined:
            callStatus = "Declined";
            break;
          default:
            callStatus = event.toString();
        }
      });
    });

    debugPrint("✅ Twilio initialized successfully (using callEventsListener)");
  }

  /// ✅ Fetch token from backend & set Twilio tokens
  Future<void> fetchAndSetupToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiRoutes.twilioToken),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['token'];
        // _userIdentity = data['identity']; // ✅ Extract identity from backend response

        if (_accessToken == null || _accessToken!.isEmpty || _userIdentity == null || _userIdentity!.isEmpty) {
          debugPrint("❌ Invalid access token or identity from backend");
          return;
        }

        await prefs.setString('accessToken', _accessToken!);
        await prefs.setString('userIdentity', _userIdentity!); // ✅ Save identity for persistence

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        fcmToken ??= '';

        await TwilioVoice.instance.setTokens(
          accessToken: _accessToken!,
          deviceToken: fcmToken,
        );

        // ✅ Register the client with identity and a display name (e.g., from prefs or backend)
        final userName = prefs.getString('userName') ?? 'User'; // TODO: Fetch actual user name if available
        await TwilioVoice.instance.registerClient(_userIdentity!, userName);

        setState(() => _isInitialized = true);
        debugPrint("✅ Twilio tokens and client registered successfully (Identity: $_userIdentity, FCM: $fcmToken)");
      } else {
        debugPrint(
            "❌ Token fetch failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching Twilio token: $e");
    }
  }

  /// ✅ Make a call
  Future<void> makeCall() async {
    if (!_isInitialized || _accessToken == null || _userIdentity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Twilio not initialized yet. Check identity and token.")),
      );
      return;
    }

    final number = numberController.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number.")),
      );
      return;
    }

    final formattedNumber = _formatNumber(number);

    // ✅ Check mic permission before calling
    if (!await TwilioVoice.instance.hasMicAccess()) {
      await TwilioVoice.instance.requestMicAccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission required for calls.")),
      );
      return;
    }

    try {
      debugPrint("📞 Starting call from: $_userIdentity to: $formattedNumber");
      await TwilioVoice.instance.call.place(
        from: _userIdentity!, // ✅ Use actual user identity as 'from'
        to: formattedNumber,  // ✅ Phone number as 'to' for PSTN
        extraOptions: { // ✅ Pass params to backend TwiML for processing
          'To': formattedNumber,
          '_TWI_SUBJECT': 'First Calling App', // Optional: App or company name
        },
      );
      setState(() => callStatus = "Calling...");
    } catch (e) {
      debugPrint("❌ Error making call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting call: $e")),
      );
    }
  }

  /// ✅ Format number to E.164 (+91XXXXXXXXXX)
  String _formatNumber(String input) {
    String clean = input.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('91') && clean.length == 12) {
      return '+$clean';
    } else if (clean.length == 10) {
      return '+91$clean';
    } else if (clean.startsWith('+')) {
      return clean;
    } else {
      return '+$clean';
    }
  }

  /// ✅ End call
  Future<void> endCall() async {
    try {
      await TwilioVoice.instance.call.hangUp();
      setState(() => callStatus = "Call Ended");
      debugPrint("✅ Call ended successfully");
    } catch (e) {
      debugPrint("❌ Error ending call: $e");
    }
  }

  /// ✅ Accept incoming call
  Future<void> acceptCall() async {
    try {
      await TwilioVoice.instance.call.answer();
      setState(() => callStatus = "Call Accepted");
      debugPrint("✅ Call accepted");
    } catch (e) {
      debugPrint("❌ Error accepting call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📞 Twilio Voice Call")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Call Status: $callStatus",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Enter Number (10 digits or +91...)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              onPressed: makeCall,
              label: const Text("Start Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              onPressed: endCall,
              label: const Text("End Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_received),
              onPressed: acceptCall,
              label: const Text("Accept Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}