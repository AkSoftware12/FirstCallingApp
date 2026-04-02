import 'dart:convert';

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
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    fetchProfileData();
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
      userName = prefs.getString('user_name') ?? 'User';
      userPhotoUrl = prefs.getString('picture_data') ?? '';
      userContact = prefs.getString('user_contact') ?? '';
    });
  }
  Future<void> fetchProfileData() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse(ApiRoutes.getProfile);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        setState(() {
          userName= jsonData['name'] ?? '';
          useremail= jsonData['email'] ?? '';
          userContact = jsonData['contact'] ?? '';
          userPhotoUrl = jsonData['picture_data'] ?? '';
        });
        // Save updated profile data to SharedPreferences for drawer
        // await _saveProfileToPrefs(jsonData);
      } else {
      }
    } catch (e) {
    } finally {
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    // ✅ UX-friendly: 1-2 sec enough
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
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
                                horizontal: 20, vertical: 10),
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

  Widget _leadIcon({
    required IconData icon,
    required List<Color> colors,
  }) {
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
                        child: Icon(Icons.close,
                            color: Colors.white, size: 22.sp),
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
                              return Icon(Icons.person,
                                  size: 60,
                                  color: Colors.grey[700]);
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
                          userName.isNotEmpty ? userName : "User",
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileUpdatePage(
                          onProfileUpdated: () => _loadProfileData(),
                        ),
                      ),
                    );
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRActive()),
                    );
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                    );
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
                          builder: (context) => NotificationScreen()),
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
                    child: Icon(Icons.currency_rupee,
                        color: Colors.white, size: 20.sp),
                  ),
                  title: 'Transaction History',
                  subtitle: 'Track all your successful & failed transactions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TransactionHistoryScreen()),
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
                    child: Icon(Icons.share,
                        color: Colors.white, size: 20.sp),
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
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: HexColor('#ff0000'),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.bloodtype,
                        color: Colors.white, size: 20.sp),
                  ),
                  title: 'Blood Donation',
                  subtitle: 'Give Blood, Save Lives.',
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: "Coming Soon",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
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

                _tile(
                  leading: _leadIcon(
                    icon: Icons.logout,
                    colors: [HexColor('#ff0000'), HexColor('#ff0000')],
                  ),
                  title: 'Logout',
                  subtitle: 'Sign out safely from your account.',
                  titleColor: HexColor('#ff0000'),
                  subColor: HexColor('#ff0000'),
                  onTap: () => _showLogoutDialog(context),
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
