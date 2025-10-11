// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firstcallingapp/BaseUrl/baseurl.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:twilio_voice/twilio_voice.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class CallScreen extends StatefulWidget {
//   const CallScreen({super.key});
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   String? _accessToken;
//   String callStatus = "Idle";
//   TextEditingController numberController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchToken();
//     initTwilio();
//   }
//
//   // Fetch Twilio token from backend
//   Future<void> fetchToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? authToken = prefs.getString('token');
//
//       final response = await http.get(
//         Uri.parse("http://192.168.1.3/firstcallingapp2/api/twilio/token"),
//         headers: {
//           'Authorization': 'Bearer $authToken',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final contentType = response.headers['content-type'];
//         if (contentType != null && contentType.contains('application/json')) {
//           final data = jsonDecode(response.body);
//           _accessToken = data['token'];
//
//           await prefs.setString('accessToken', _accessToken!);
//
//           // Get FCM token
//           String deviceToken = '';
//           if (Platform.isAndroid) {
//             deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
//           }
//
//           await TwilioVoice.instance.setTokens(
//             accessToken: _accessToken!,
//             deviceToken: deviceToken,
//           );
//           debugPrint("✅ Token set successfully: $deviceToken");
//         } else {
//           debugPrint("❌ Response is not JSON: $contentType");
//         }
//       } else {
//         debugPrint("❌ Token fetch failed: ${response.statusCode} ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("❌ Token fetch error: $e");
//     }
//   }
//
//   // Initialize Twilio listeners
//   void initTwilio() {
//     TwilioVoice.instance.setOnCallStateChanged((CallEvent event) {
//       debugPrint("📞 Call event: ${event.name}");
//       setState(() {
//         callStatus = event.name;
//       });
//     });
//
//     TwilioVoice.instance.setOnDeviceTokenChanged((token) {
//       debugPrint("📱 Device token updated: $token");
//     });
//   }
//
//   // Make a call
//   void makeCall() async {
//     if (_accessToken == null) {
//       debugPrint("Token not ready");
//       return;
//     }
//
//     final toNumber = numberController.text.trim();
//     if (toNumber.isEmpty) {
//       debugPrint("❌ Enter a number");
//       return;
//     }
//
//     try {
//       await TwilioVoice.instance.call.connect(to: toNumber);
//       debugPrint("✅ Calling $toNumber...");
//     } catch (e) {
//       debugPrint("❌ Call failed: $e");
//     }
//   }
//
//   // End current call
//   void endCall() async {
//     try {
//       await TwilioVoice.instance.call.hangUp();
//       debugPrint("✅ Call ended");
//     } catch (e) {
//       debugPrint("❌ End call error: $e");
//     }
//   }
//
//   // Accept incoming call
//   void acceptCall() async {
//     try {
//       await TwilioVoice.instance.call.accept();
//       debugPrint("✅ Call accepted");
//     } catch (e) {
//       debugPrint("❌ Accept call error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Twilio Voice Call")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               "Call Status: $callStatus",
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: numberController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: "Enter number (E.164 format)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: makeCall, child: const Text("Call")),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: endCall,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text("End Call"),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: acceptCall,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text("Accept Call"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
