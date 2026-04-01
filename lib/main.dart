
import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Ui/Cart/CartProvider/cart_provider.dart';
import 'Ui/Login/SplashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appLinks = AppLinks();

  // Initial link check when app starts
  final Uri? initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    handleLink(initialLink);
  }

  // Listen to links while app is running
  appLinks.uriLinkStream.listen((Uri? link) {
    if (link != null) {
      handleLink(link);
    }
  });

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCE01wxa5AcekGS9RYEGnvIPadRlSbeklE',
        appId: '1:442155608498:android:a05c3b671760ddc18fdcab',
        messagingSenderId: '442155608498',
        projectId: 'first-calling-app-7a9b4',
        storageBucket: "first-calling-app-7a9b4.firebasestorage.app",
      ),
    );
  } else {
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
  }
  await NotificationService().initNotifications();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown, // agar upside-down bhi allow karna ho toh uncomment karo
  ]);
  final cartProvider = CartProvider();
  await cartProvider.loadCart(); // पहले load करना जरूरी है
  runApp(   ChangeNotifierProvider(
    create: (_) => CartProvider(),
    child: const MyApp(),
  ),);
}
void handleLink(Uri link) {
  String? musicId = link.queryParameters['id'];
  if (musicId != null) {
    print("Music ID: $musicId");
    // Add your music play logic here
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key, });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  Widget build(BuildContext context) {
    return   ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return  MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.light(),
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
          ],
          // localizationsDelegates: GlobalStreamChatLocalizations.delegates,
          // home: const BottomNavigationBarScreen(),
          home:  SplashScreen(),
        );

      },
    );

  }
}



class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // इनिशियलाइज़ नोटिफिकेशन्स
  Future<void> initNotifications() async {
    // Android और iOS के लिए नोटिफिकेशन परमिशन रिक्वेस्ट करें
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }

    // FCM टोकन प्राप्त करें
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // फोरग्राउंड में नोटिफिकेशन्स हैंडल करें
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground Message: ${message.notification?.title}');
        print('Message Data: ${message.data}');
      }
      // यहाँ आप नोटिफिकेशन UI दिखा सकते हैं (जैसे Flutter का SnackBar)
    });

    // बैकग्राउंड में नोटिफिकेशन हैंडल करें
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    // ऐप बंद होने पर नोटिफिकेशन टैप करने पर हैंडल करें
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened: ${message.notification?.title}');
      }
      // यहाँ नेविगेशन या अन्य एक्शन जोड़ सकते हैं
    });
  }

  // बैकग्राउंड हैंडलर (टॉप-लेवल फंक्शन)
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background Message: ${message.notification?.title}');
    }
  }
}


