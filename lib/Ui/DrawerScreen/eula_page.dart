import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Utils/color.dart';

/// App Store Guideline 5.1.5 — EULA with emergency / location disclaimer (in-app).
class EulaPage extends StatelessWidget {
  const EulaPage({super.key});

  static const String _text = '''
END USER LICENSE AGREEMENT (EULA)

Last updated: March 31, 2026
ROSHVEER SERVICES PRIVATE LIMITED

1. Services
This app may include QR scanning, calling features, IVR-related flows, and a shortcut to dial public emergency numbers (e.g. 112) using your device’s phone app.

2. Emergency services and location — disclaimer
• If the app offers a control to call an emergency number, it places a standard telephone call through your device. We do not guarantee that the call will connect, be answered, or that any authority will respond.
• The app does not automatically send your GPS coordinates to government emergency dispatch unless a separate in-app feature clearly states so and you grant permission where required.
• This app is not a substitute for official emergency services. Follow local instructions in a real emergency.

3. Limitation of liability
To the maximum extent permitted by law, we are not liable for damages arising from use of the app, including emergency-related use.

4. Contact
Use the contact details in the app or on the App Store product page.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('EULA', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Text(
          _text,
          style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.45),
        ),
      ),
    );
  }
}
