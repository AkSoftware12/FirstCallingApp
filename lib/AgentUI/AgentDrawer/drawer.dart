import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Ui/DrawerScreen/privacy.dart';
import '../../Ui/Login/Login/login.dart';
import '../../Ui/Notification/notification.dart';
import '../../Ui/Profile/update_profile.dart';
import '../../Utils/HexColorCode/HexColor.dart';
import '../../Utils/color.dart';
import '../../Utils/textSize.dart';
import '../AgentBottomNavigationBar/agentBottomNvaigationBar.dart';


class AgentDrawerPageScreen extends StatefulWidget {

  final String currentVersion;

  const AgentDrawerPageScreen({
    super.key,
    required this.currentVersion,
  });

  @override
  State<AgentDrawerPageScreen> createState() => _DrawerPageScreenState();
}

class _DrawerPageScreenState extends State<AgentDrawerPageScreen> {
  final AppTextSizes textSizes = AppTextSizes();
  String userName = '';
  String userPhotoUrl = '';
  String userContact = '';
  bool _isLoggingOut = false;


  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User Name';
      userPhotoUrl = prefs.getString('user_photo_url') ?? '';
      userContact = prefs.getString('user_contact') ?? '';
    });
  }
  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true; // Show loading state
    });

    // Wait for 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to LoginScreen
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
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                    const SizedBox(height: 20),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:  AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Are you sure you want to logout?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                            setState(() => _isLoggingOut = true);
                            await _handleLogout();
                            setState(() => _isLoggingOut = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  AppColors.navyBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: _isLoggingOut
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child:  CupertinoActivityIndicator(
                              radius: 10,
                              color: AppColors.navyBlue,
                            ),
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
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 25.sp,
            color: AppColors.navyBlue,
          ),
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
                      Image.asset('assets/calling_text.gif',height: 40.sp,),
                      Padding(
                        padding: EdgeInsets.only(right: 10.sp),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,

                            // FontAwesomeIcons.xmark,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),

                    ],
                  )),
            ],
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(0.sp),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.navyBlue,
                      AppColors.navyBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  children: [
                    // CircleAvatar(
                    //   radius: 30.sp,
                    //   backgroundImage: const AssetImage('assets/playstore.png'),
                    //   backgroundColor: AppColors.lightGray,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       border: Border.all(color: Colors.white, width: 2.sp),
                    //     ),
                    //   ),
                    // ),
                    ClipOval(
                      child: Container(
                          width: 50.sp,
                          height: 50.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child:userPhotoUrl.isNotEmpty
                              ? CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(userPhotoUrl),
                          )
                              : const CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.person, size: 60),
                          )),
                    ),

                    SizedBox(width: 10.sp),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userName.isNotEmpty
                              ? Text.rich(
                            TextSpan(
                              text: userName,
                              style: GoogleFonts.radioCanada(
                                textStyle: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 17.sp,
                                  // Adjust font size as needed
                                  fontWeight:
                                  FontWeight
                                      .bold, // Adjust font weight as needed
                                ),
                              ),
                            ),
                            textAlign:
                            TextAlign
                                .start, // Ensure text starts at the beginning
                          )
                              : Text.rich(
                            TextSpan(
                              text: 'User',
                              style: GoogleFonts.radioCanada(
                                textStyle: TextStyle(
                                  color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontSize: 17.sp,
                                  // Adjust font size as needed
                                  fontWeight:
                                  FontWeight
                                      .bold, // Adjust font weight as needed
                                ),
                              ),
                            ),
                            textAlign:
                            TextAlign
                                .start, // Ensure text starts at the beginning
                          ),

                          Text(
                            userContact,
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
          ),
          Divider(
            height: 2.sp,
            thickness: 5,
            color: HexColor('#ff0000'),
          ),
          SizedBox(height: 10.sp),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[

                // Drawer List
                ListTile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          HexColor('#800000'),
                          HexColor('#800000'),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(
                      Icons.apps,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Be alert. Be safe. Act on time.',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context); // Drawer band karo
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentBottomNavigationBarScreen(initialIndex: 0),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          HexColor('#9A6324'),
                          HexColor('#9A6324'),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.person, color: Colors.white,size: 20.sp,),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'View profile insights',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileUpdatePage(
                          onProfileUpdated: () {
                            setState(() {
                              _loadProfileData();
                            }); // This will refresh the drawer/profile section
                          },
                        ),
                      ),
                    );
                  },
                ),



                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey,
                          Colors.grey,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.notifications, color: Colors.white,size: 20.sp,),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Stay Updated, Never Miss Out',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                ListTile(
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
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share App',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Invite your friends',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Share.share(
                      'Check out this Vidnexa Video Player App: https://play.google.com/store/apps/details?id=com.vidnexa.videoplayer&pcampaignid=web_share',
                      subject: 'Download this App',
                    );
                  },
                ),
                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:  HexColor('#ff0000'),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.bloodtype,
                        color: Colors.white, size: 20.sp),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Donation',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Give Blood, Save Lives.',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: "Coming Soon",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );

                  },
                ),
                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    height: 35.sp,
                    width: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          HexColor('#469990'),
                          HexColor('#469990'),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Icon(Icons.privacy_tip,
                        color: Colors.white, size: 20.sp),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trem & Condition',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Read carefully before proceeding.',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPage()));
                  },
                ),
                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          HexColor('#334155'),
                          HexColor('#334155'),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(10.sp),
                    child: Icon(Icons.policy,
                        color: Colors.white, size: 20.sp),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize:AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Privacy & security',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPage()));
                  },
                ),

                SizedBox(height: 10.sp),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          HexColor('#ff0000'),
                          HexColor('#ff0000'),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(10.sp),
                    child: Icon(Icons.logout,
                        color: Colors.white, size: 17.sp),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color:   HexColor('#ff0000'),
                            fontSize:AppTextSizes.text14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Sign out safely from your account.',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color:  HexColor('#ff0000'),

                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    _showLogoutDialog(context);

                  },
                ),
                SizedBox(height: 20.sp),

                // Extra space at the bottom for better scrolling
              ],
            ),
          ),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              // color: HexColor('#ff0000'),
              borderRadius: BorderRadius.circular(0),
            ),
            padding: EdgeInsets.all(0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [


                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //     height: 18.sp,
                      //     child: Image.asset('assets/calling_text.gif',)),

                      Padding(
                        padding:  EdgeInsets.only(left: 5.sp,bottom: 2.sp),
                        child: Text(
                          'App Version :- (${widget.currentVersion})',
                          style: GoogleFonts.radioCanada(
                            textStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
