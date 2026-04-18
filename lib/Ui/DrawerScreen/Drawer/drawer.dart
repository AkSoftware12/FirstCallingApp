import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../BaseUrl/baseurl.dart';
import '../../../Utils/HexColorCode/HexColor.dart';
import '../../../Utils/color.dart';
import '../../../Utils/textSize.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../AccountDelete/account_delete.dart';
import '../../BottomNavigationBar/bottomNvaigationBar.dart';
import '../../Login/Login/login.dart';
import '../../Notification/notification.dart';
import '../../OrderHistory/order_history.dart';
import '../../Profile/update_profile.dart';
import '../../QRActivationScreen/qr_check_screen.dart';
import '../../TransactionHistoryScreen/transaction_history_screen.dart';
import '../eula_page.dart';
import '../privacy.dart';

class DrawerPageScreen extends StatefulWidget {
  const DrawerPageScreen({super.key});

  @override
  State<DrawerPageScreen> createState() => _DrawerPageScreenState();
}

class _DrawerPageScreenState extends State<DrawerPageScreen> {
  final AppTextSizes textSizes = AppTextSizes();

  String userName = '';
  String userPhotoUrl = '';
  String userContact = '';
  String useremail = '';

  bool _isLoggingOut = false;

  // ✅ version text
  String _versionText = "v-- (--)";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfileData();
    });
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      // Example: v1.0.7 (12)
      setState(() {
        _versionText = "v${info.version} (${info.buildNumber})";
      });
    } catch (_) {
      setState(() => _versionText = "v-- (--)");
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('user_name') ?? '';
      userPhotoUrl = prefs.getString('picture_data') ?? '';
      userContact = prefs.getString('user_contact') ?? '';
    });
  }

  Future<void> fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() {
            userName = '';
            useremail = '';
            userContact = '';
            userPhotoUrl = '';
          });
        }
        return;
      }

      // if (token == null || token.isEmpty) {
      //   if (mounted) {
      //     // ✅ Frame render hone ka wait karo, phir dialog dikhao
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       if (mounted) showSessionExpiredDialog(context);
      //     });
      //   }
      //   return;
      // }

      final uri = Uri.parse(ApiRoutes.getProfile);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        setState(() {
          userName = jsonData['name'] ?? '';
          useremail = jsonData['email'] ?? '';
          userContact = jsonData['contact'] ?? '';
          userPhotoUrl = jsonData['picture_data'] ?? '';
        });
      } else if (response.statusCode == 401) {
        // ✅ Token expire ho gaya
        // if (mounted) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) showSessionExpiredDialog(context);
        //   });
        // }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
      // if (mounted) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (mounted) showSessionExpiredDialog(context);
      //   });
      // }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    // ✅ UX-friendly: 1-2 sec enough
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BottomNavigationBarScreen()),
      (route) => false,
    );
  }

  void showSessionExpiredDialog(BuildContext context) {
    if (!Navigator.of(context).mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'session_expired',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) => const _SessionExpiredDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 50, color: AppColors.navyBlue),
                    const SizedBox(height: 14),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you sure you want to logout?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoggingOut
                              ? null
                              : () async {
                                  setStateDialog(() => _isLoggingOut = true);
                                  await _handleLogout();
                                  if (mounted) {
                                    setStateDialog(() => _isLoggingOut = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: _isLoggingOut
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CupertinoActivityIndicator(radius: 10),
                                )
                              : const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tile({
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? subColor,
  }) {
    return ListTile(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: titleColor ?? Colors.black,
                fontSize: AppTextSizes.text14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: subColor ?? Colors.grey,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _leadIcon({required IconData icon, required List<Color> colors}) {
    return Container(
      height: 35.sp,
      width: 35.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(5.sp),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }

  Future<bool> checkUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token"); // ya userId
    return token != null && token.isNotEmpty;
  }

  Future<void> handleAuthTap(BuildContext context) async {
    bool isLoggedIn = await checkUserLogin();

    if (!isLoggedIn) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(fromCheckout: true),
        ),
      );

      if (result == true) {
        setState(() {
          _loadProfileData();
          fetchProfileData();
        });
      }
    } else {
      _showLogoutDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: 25.sp, color: AppColors.navyBlue),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: AppColors.navyBlue,
                height: 35.sp,
                width: MediaQuery.sizeOf(context).width * .7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/calling_text.gif', height: 40.sp),
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // HEADER PROFILE
          Container(
            color: Colors.white,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyBlue, AppColors.navyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(15.sp),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 50.sp,
                      height: 50.sp,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: userPhotoUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: Image.network(
                                  userPhotoUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[700],
                                    );
                                  },
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person, size: 60),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty
                              ? userName
                              : "Guest",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.radioCanada(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          useremail.isNotEmpty ? useremail : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.radioCanada(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          userContact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.radioCanada(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: AppTextSizes.text12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 2.sp, thickness: 5, color: HexColor('#ff0000')),
          SizedBox(height: 10.sp),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _tile(
                  leading: _leadIcon(
                    icon: Icons.apps,
                    colors: [HexColor('#800000'), HexColor('#800000')],
                  ),
                  title: 'Dashboard',
                  subtitle: 'Be alert. Be safe. Act on time.',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BottomNavigationBarScreen(initialIndex: 0),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.person,
                    colors: [HexColor('#9A6324'), HexColor('#9A6324')],
                  ),
                  title: 'Profile',
                  subtitle: 'View profile insights',
                  onTap: () async {
                    bool isLoggedIn = await checkUserLogin();

                    if (!isLoggedIn) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(fromCheckout: true),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          // loadUserData();
                          // loadAddress();
                        });
                      }
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileUpdatePage(
                            onProfileUpdated: () => _loadProfileData(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.qr_code_scanner_outlined,
                    colors: [HexColor('#808000'), HexColor('#808000')],
                  ),
                  title: 'Activate New QR Sticker',
                  subtitle: 'Keep Your QR Active & Updated',
                  onTap: () async {
                    bool isLoggedIn = await checkUserLogin();

                    if (!isLoggedIn) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(fromCheckout: true),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          // loadUserData();
                          // loadAddress();
                        });
                      }
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRActive()),
                      );
                    }
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.shopping_cart,
                    colors: [HexColor('#911eb4'), HexColor('#911eb4')],
                  ),
                  title: 'My Orders',
                  subtitle: 'Track your past and current orders.',
                  onTap: () async {
                    bool isLoggedIn = await checkUserLogin();

                    if (!isLoggedIn) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(fromCheckout: true),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          // loadUserData();
                          // loadAddress();
                        });
                      }
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                      );
                    }
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.notifications,
                    colors: [Colors.grey, Colors.grey],
                  ),
                  title: 'Notifications',
                  subtitle: 'Stay Updated, Never Miss Out',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue,
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  title: 'Transaction History',
                  subtitle: 'Track all your successful & failed transactions',
                  onTap: () async {
                    bool isLoggedIn = await checkUserLogin();

                    if (!isLoggedIn) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(fromCheckout: true),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          // loadUserData();
                          // loadAddress();
                        });
                      }
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionHistoryScreen(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue,
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.share, color: Colors.white, size: 20.sp),
                  ),
                  title: 'Share App',
                  subtitle: 'Invite your friends',
                  onTap: () {
                    Share.share(
                      'Check out First Calling App: https://play.google.com/store/apps/details?id=com.firstcallingapp.firstcallingapp',
                      subject: 'Download this App',
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.privacy_tip,
                    colors: [HexColor('#469990'), HexColor('#469990')],
                  ),
                  title: 'Term & Condition',
                  subtitle: 'Read carefully before proceeding.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPage()),
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.policy,
                    colors: [HexColor('#334155'), HexColor('#334155')],
                  ),
                  title: 'Privacy',
                  subtitle: 'Privacy & security',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPage()),
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                _tile(
                  leading: _leadIcon(
                    icon: Icons.gavel,
                    colors: [HexColor('#0F766E'), HexColor('#0F766E')],
                  ),
                  title: 'EULA',
                  subtitle: 'Emergency & license terms (App Store)',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EulaPage()),
                    );
                  },
                ),
                SizedBox(height: 10.sp),

                FutureBuilder<bool>(
                  future: checkUserLogin(),
                  builder: (context, snap) {
                    if (snap.data != true) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tile(
                          leading: Container(
                            height: 35.sp,
                            width: 35.sp,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: HexColor('#ff0000'),
                            ),
                            padding: EdgeInsets.all(5.sp),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          title: 'Delete Account',
                          subtitle:
                              'Permanently delete your account and app data.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeleteAccountScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10.sp),
                      ],
                    );
                  },
                ),

                // _tile(
                //   leading: _leadIcon(
                //     icon: Icons.logout,
                //     colors: [HexColor('#ff0000'), HexColor('#ff0000')],
                //   ),
                //   title: 'Logout',
                //   subtitle: 'Sign out safely from your account.',
                //   titleColor: HexColor('#ff0000'),
                //   subColor: HexColor('#ff0000'),
                //   onTap: () => _showLogoutDialog(context),
                // ),
                FutureBuilder<bool>(
                  future: checkUserLogin(),
                  builder: (context, snapshot) {
                    bool isLoggedIn = snapshot.data ?? false;

                    return _tile(
                      leading: _leadIcon(
                        icon: isLoggedIn ? Icons.logout : Icons.login,
                        colors: [HexColor('#ff0000'), HexColor('#ff0000')],
                      ),
                      title: isLoggedIn ? 'Logout' : 'Login',
                      subtitle: isLoggedIn
                          ? 'Sign out safely from your account.'
                          : 'Login to access your account.',
                      titleColor: HexColor('#ff0000'),
                      subColor: HexColor('#ff0000'),
                      onTap: () => handleAuthTap(context),
                    );
                  },
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),

          // ✅ VERSION (fixed)
          Container(
            width: double.infinity,
            color: AppColors.navyBlue,
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            child: Center(
              child: Text(
                'App Version : $_versionText',
                style: GoogleFonts.radioCanada(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionExpiredDialog extends StatefulWidget {
  const _SessionExpiredDialog();

  @override
  State<_SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<_SessionExpiredDialog>
    with SingleTickerProviderStateMixin {
  bool _loading = false;

  late AnimationController _iconController;
  late Animation<double> _iconRotate;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _iconRotate = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    // Subtle idle shake on mount
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _iconController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _handleOk() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pop();

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const BottomNavigationBarScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 480),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey.shade200, Colors.grey.shade200],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyBlue.withOpacity(0.18),
                    blurRadius: 60,
                    spreadRadius: 0,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: Column(
                      children: [
                        // ── Icon ──
                        AnimatedBuilder(
                          animation: _iconRotate,
                          builder: (_, child) => Transform.rotate(
                            angle: _iconRotate.value,
                            child: child,
                          ),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.navyBlue,
                                  AppColors.navyBlue,
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.navyBlue.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navyBlue.withOpacity(0.3),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_clock_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Title ──
                        Text(
                          'Session Expired',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyBlue,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Subtitle ──
                        Text(
                          'Your session has timed out for security.\nPlease log in again to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: AppColors.navyBlue.withOpacity(0.8),
                            letterSpacing: 0.1,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Button ──
                        GestureDetector(
                          onTap: _loading ? null : _handleOk,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: _loading
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        AppColors.navyBlue,
                                        AppColors.navyBlue,
                                      ],
                                    ),
                              color: _loading
                                  ? Colors.white.withOpacity(0.07)
                                  : null,
                              boxShadow: _loading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppColors.navyBlue.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white54,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Log In Again',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
