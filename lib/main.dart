
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Ui/Cart/CartProvider/cart_provider.dart';
import 'Ui/Login/SplashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyASMmPy8mhABFOGTEHmkI-vv559WTiw814',
        appId: '1:164105009272:android:67e2bc460fd3b44376158d',
        messagingSenderId: '164105009272',
        projectId: 'cjm-shimla-parent',
        storageBucket: "cjm-shimla-parent.firebasestorage.app",
      ),
    );
  } else {
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
  }

  // Sirf portraitUp (normal) aur portraitDown (ulot ke saath) chahiye toh:
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

class MyApp extends StatelessWidget {
  const MyApp({super.key, });

  @override
  Widget build(BuildContext context) {
    return   ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return  MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
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





