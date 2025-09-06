import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Ui/BottomNavigationBar/bottomNvaigationBar.dart'; // For flashlight functionality

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '',
          theme: ThemeData(
            primaryColor: Colors.red,
            scaffoldBackgroundColor: const Color(0xFF1B263B),
            // Navy blue background
            cardTheme: const CardThemeData(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
              labelLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          home:  BottomNavigationBarScreen(),
        );
      },
    );
  }
}









