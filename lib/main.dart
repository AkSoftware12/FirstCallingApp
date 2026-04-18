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

/// Background FCM — top-level, `main` se pehle register hona chahiye (Android + iOS)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCE01wxa5AcekGS9RYEGnvIPadRlSbeklE',
          appId: '1:442155608498:android:a05c3b671760ddc18fdcab',
          messagingSenderId: '442155608498',
          projectId: 'first-calling-app-7a9b4',
          storageBucket: 'first-calling-app-7a9b4.firebasestorage.app',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }
  if (kDebugMode) {
    debugPrint('Background FCM: ${message.notification?.title}');
    debugPrint('Background data: ${message.data}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pehle background handler (Firebase docs)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final appLinks = AppLinks();

  final Uri? initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    handleLink(initialLink);
  }

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
  } else if (Platform.isIOS) {
    try {
      // AppDelegate pehle FirebaseApp.configure() karta hai; yahan Flutter side bind
      await Firebase.initializeApp();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Firebase iOS init: $e');
        debugPrint('$st');
      }
    }
  }

  await NotificationService().initNotifications();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final cartProvider = CartProvider();
  await cartProvider.loadCart();
  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

void handleLink(Uri link) {
  String? musicId = link.queryParameters['id'];
  if (musicId != null) {
    debugPrint("Music ID: $musicId");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          supportedLocales: const [Locale('en'), Locale('hi')],
          home: SplashScreen(),

          // localizationsDelegates: GlobalStreamChatLocalizations.delegates,
          // home: const BottomNavigationBarScreen(),
        );
      },
    );
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    if (Firebase.apps.isEmpty) {
      if (kDebugMode) {
        debugPrint('FCM skip: Firebase not initialized');
      }
      return;
    }

    if (Platform.isIOS) {
      // Foreground mein system banner (Android jaisa dikhe)
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // iOS: APNS token pehle aata hai; bina aps-environment / real device par getToken crash kar sakta hai
    await _resolveFcmToken();

    // Cold start: user ne notification tap se app khola
    final RemoteMessage? initial = await _firebaseMessaging.getInitialMessage();
    if (initial != null && kDebugMode) {
      debugPrint('Opened from notification: ${initial.notification?.title}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground FCM: ${message.notification?.title}');
        debugPrint('Data: ${message.data}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
          'Notification tap (app background): ${message.notification?.title}',
        );
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((String t) {
      if (kDebugMode) debugPrint('FCM token refresh: $t');
    });
  }

  /// iOS par kabhi APNS late aata hai — crash avoid + thodi der retry
  Future<void> _resolveFcmToken() async {
    if (Platform.isIOS) {
      for (var i = 0; i < 8; i++) {
        try {
          final apns = await _firebaseMessaging.getAPNSToken();
          if (apns != null) break;
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    try {
      final String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) debugPrint('FCM token: $token');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          'FCM getToken skipped (APNS / simulator / entitlements): $e',
        );
        debugPrint('$st');
      }
    }
  }
}
