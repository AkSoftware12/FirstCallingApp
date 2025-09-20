import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:firstcallingapp/Utils/textSize.dart';
import 'package:firstcallingapp/Widgets/CustomText/custom_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gscankit/gscankit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/string.dart';
import '../BottomNavigationScreen/Helpline/helpline.dart';
import '../BottomNavigationScreen/IVRCall/ivr_call.dart';
import '../BottomNavigationScreen/ProductScreen/product_screen.dart';
import '../BottomNavigationScreen/SOS/sos_screen.dart';
import '../QRScanScreen/QRCodeData/qr_code_data.dart';
import '../QRScanScreen/TorchScreen/torch_screen.dart';

// Sample data structure for emergency numbers
class EmergencyNumber {
  final String police;
  final String ambulance;
  final String fire;

  EmergencyNumber({
    required this.police,
    required this.ambulance,
    required this.fire,
  });
}

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _HomePageState();
}

class _HomePageState extends State<BottomNavigationBarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MobileScannerController controllerScan = MobileScannerController(
    returnImage: true,
  );
  bool _isScanning = false;

  int selected = 0;
  final controller = PageController();





  // Sample data (extend with full list from sources like Wikipedia)
  final List<EmergencyNumber> emergencyNumbers = [
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),
    EmergencyNumber(police: '100', ambulance: '102', fire: '112'),

    // Add more countries here...
  ];

  void showEmergencyNumbersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              elevation: 8,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.navyBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone,
                            color: AppColors.navyBlue,
                            size: 25.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Emergency Numbers',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    /// 👇 Constrain list height to avoid overflow
                    SizedBox(
                      height: 250.h, // adjust height as needed
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: emergencyNumbers.length,
                        itemBuilder: (context, index) {
                          final number = emergencyNumbers[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: HexColor('#f26652')),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_police, color: Colors.red),
                                SizedBox(height: 4.h),
                                Text(
                                  number.police,
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// Close button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 100.w,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.navyBlue, AppColors.maroonRed],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navyBlue.withOpacity(0.3),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
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
  void _handleDetect(BarcodeCapture capture) async {
    if (_isScanning) return;
    _isScanning = true;

    final String? value = capture.barcodes.first.rawValue;

    if (value != null && value.isNotEmpty) {
      if (_isValidUrl(value)) {
        final Uri url = Uri.parse(value);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showResult(value);
        }
      } else {
        _showResult(value);
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isScanning = false;
    });
  }

  bool _isValidUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
  }

  void _showResult(String data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(result: data),
      ),
    ).then((_) {
      _isScanning = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.appName,
              style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),),




          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.sp),
            bottomRight: Radius.circular(20.sp),
          ),
        ),
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(8.0), // Adjust padding as needed
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Set grey background for drawer icon
                shape: BoxShape.circle, // Optional: makes the background circular
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.black), // Drawer icon
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Opens the drawer
                },
              ),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GscanKit(
                    controller: controllerScan,
                    onDetect: _handleDetect,
                    appBar: (context, controller) {
                      return AppBar(
                        title: Text(""),
                        leading: Icon(Icons.arrow_back_ios),
                        backgroundColor: Colors.transparent,
                        actions: [
                          // IconButton.filled(
                          //   style: IconButton.styleFrom(
                          //     backgroundColor: CupertinoColors.systemGrey6,
                          //     foregroundColor:
                          //     CupertinoColors.darkBackgroundGray,
                          //   ),
                          //   icon: Icon(CupertinoIcons.camera_rotate),
                          //   onPressed: () => controller.switchCamera(),
                          // ),
                          ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (context, state, child) {
                              final isTorchOn =
                                  state.torchState == TorchState.on;
                              return TorchToggleButton(
                                isTorchOn: isTorchOn,
                                onPressed: () => controller.toggleTorch(),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },

                    floatingOption: [
                      // IconButton.filled(
                      //   style: IconButton.styleFrom(
                      //     backgroundColor: CupertinoColors.systemGrey6,
                      //     foregroundColor:
                      //     CupertinoColors.darkBackgroundGray,
                      //   ),
                      //   icon: const Icon(CupertinoIcons.camera_rotate),
                      //   onPressed: () => controllerScan.switchCamera(),
                      // ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          Padding(
                            padding:  EdgeInsets.only(bottom: 70.sp),
                            child: Column(
                              children: [

                Container(
                  width: 150.sp,
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(10.sp),

                    // Gradient background for a modern look
                    gradient: LinearGradient(
                      colors: [HexColor('#012169'),HexColor('#012169')],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: Image.asset(
                              'assets/playstore.png',
                              height: 80.sp,
                              width: 80.sp,
                              fit: BoxFit.cover, // Ensures the image fits within the rounded container
                            ),
                          ),
                          SizedBox(
                            height: 10.sp,
                          ),
                          // Styled "First Calling App" text
                          Text(
                            'First Calling App',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          // Optional: Add a subtitle or description
                          // Padding(
                          //   padding:  EdgeInsets.all(8.sp),
                          //   child: Text(
                          //     'Connect with your loved ones seamlessly',
                          //     style: GoogleFonts.poppins(
                          //       fontSize: 11.sp,
                          //       fontWeight: FontWeight.w400,
                          //       color: Colors.white70,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),

                            ],
                            ),
                          ),
                        ],
                      ),

                    ],
                    gscanOverlayConfig: const GscanOverlayConfig(
                      scannerScanArea: ScannerScanArea.center,
                      scannerBorder: ScannerBorder.visible,
                      scannerBorderPulseEffect:
                      ScannerBorderPulseEffect.enabled,
                      borderColor: Colors.white,
                      borderRadius: 24.0,
                      scannerLineAnimationColor: Colors.green,
                      scannerOverlayBackground:
                      ScannerOverlayBackground.blur,
                      scannerLineAnimation: ScannerLineAnimation.enabled,
                    ),
                  ),
                ),
              );
            },
            child: SizedBox(
                height: 25.sp,
                width: 25.sp,
                child: Image.asset('assets/scan.gif',)),
          ),
          IconButton(
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const Cart(appBar: 'Hone')));
            },
            icon: Stack(
              children: [
                Padding(
                  padding:  EdgeInsets.only(bottom: 5.sp),
                  child:Image.asset('assets/bag.gif',fit: BoxFit.cover,height: 45.sp,width: 45.sp,)
                ),

              ],
            ),
          )
        ],
      ),


      // appBar: AppBar(
      //   leading: Padding(
      //     padding: const EdgeInsets.all(6.0),
      //     child: Container(
      //       height: 25,
      //       width: 25,
      //       decoration: BoxDecoration(
      //         color: Colors.white38,
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //       child: IconButton(
      //         icon: Icon(Icons.dashboard, color: Colors.white, size: 25),
      //         onPressed: () {
      //           _scaffoldKey.currentState?.openDrawer();
      //         },
      //       ),
      //     ),
      //   ),
      //   title: CustomText(
      //     text: AppStrings.appName,
      //     colors: AppColors.colorWhite,
      //     size: AppTextSizes.text17,
      //   ),
      //   centerTitle: false,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [AppColors.navyBlue, AppColors.navyBlue],
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomCenter,
      //       ),
      //     ),
      //   ),
      //   actions: [
      //     Container(
      //       height: 40,
      //       width: 40,
      //       decoration: BoxDecoration(
      //         color: Colors.white38,
      //         borderRadius: BorderRadius.circular(30),
      //       ),
      //       child: IconButton(
      //         icon: Icon(
      //           Icons.notifications_active_sharp,
      //           color: Colors.white,
      //           size: 20,
      //         ),
      //         onPressed: () {
      //           _scaffoldKey.currentState?.openDrawer();
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      drawer: Drawer(
        backgroundColor: AppColors.navyBlue, // Navy blue background
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200, // Increased height to accommodate profile details
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyBlue, AppColors.navyBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular profile image
                  CircleAvatar(
                    radius: 40, // Adjust size as needed
                    backgroundImage: NetworkImage(
                      'https://example.com/user-profile-image.jpg', // Replace with actual image URL or use AssetImage for local assets
                    ),
                    backgroundColor:
                        Colors.grey.shade300, // Fallback color if image fails
                  ),
                  const SizedBox(height: 10),
                  // User name
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // User email
                  const Text(
                    'nek.insan@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  // User contact number
                  const Text(
                    '+91 123 456 7890',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white10, thickness: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                // children: [
                //   _DrawerItem(
                //     icon: Icons.flash_on,
                //     title: 'Set Flash',
                //     isSelected: _selectedIndex == 0,
                //     onTap: () => _onItemTapped(0),
                //   ),
                //   _DrawerItem(
                //     icon: Icons.phone,
                //     title: 'IVR Call',
                //     isSelected: _selectedIndex == 1,
                //     onTap: () => _onItemTapped(1),
                //   ),
                //   _DrawerItem(
                //     icon: Icons.qr_code_scanner,
                //     title: 'Products',
                //     isSelected: _selectedIndex == 2,
                //     onTap: () => _onItemTapped(2),
                //   ),
                //   _DrawerItem(
                //     icon: Icons.contact_phone,
                //     title: 'Helplines',
                //     isSelected: _selectedIndex == 3,
                //     onTap: () => _onItemTapped(3),
                //   ),
                //   _DrawerItem(
                //     icon: Icons.sos,
                //     title: 'SOS',
                //     isSelected: _selectedIndex == 4,
                //     onTap: () => _onItemTapped(4),
                //   ),
                // ],
              ),
            ),
          ],
        ),
      ),
      // body: ProductListScreen(),
      bottomNavigationBar: Container(
        color: Colors.grey.shade200,

        height: 70.sp,
        child: CustomBottomNavBar(
          currentIndex: selected,
          onTap: (index) {
            controller.jumpToPage(index);
            setState(() => selected = index);
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: 55.sp,
        height: 55.sp,
        child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GscanKit(
                    controller: controllerScan,
                    onDetect: _handleDetect,
                    appBar: (context, controller) {
                      return AppBar(
                        title: Text(""),
                        leading: Icon(Icons.arrow_back_ios),
                        backgroundColor: Colors.transparent,
                        actions: [
                          // IconButton.filled(
                          //   style: IconButton.styleFrom(
                          //     backgroundColor: CupertinoColors.systemGrey6,
                          //     foregroundColor:
                          //     CupertinoColors.darkBackgroundGray,
                          //   ),
                          //   icon: Icon(CupertinoIcons.camera_rotate),
                          //   onPressed: () => controller.switchCamera(),
                          // ),
                          ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (context, state, child) {
                              final isTorchOn =
                                  state.torchState == TorchState.on;
                              return TorchToggleButton(
                                isTorchOn: isTorchOn,
                                onPressed: () => controller.toggleTorch(),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },

                    floatingOption: [
                      // IconButton.filled(
                      //   style: IconButton.styleFrom(
                      //     backgroundColor: CupertinoColors.systemGrey6,
                      //     foregroundColor:
                      //     CupertinoColors.darkBackgroundGray,
                      //   ),
                      //   icon: const Icon(CupertinoIcons.camera_rotate),
                      //   onPressed: () => controllerScan.switchCamera(),
                      // ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          Padding(
                            padding:  EdgeInsets.only(bottom: 70.sp),
                            child: Column(
                              children: [

                                Container(
                                  width: 150.sp,
                                  decoration:  BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.sp),

                                    // Gradient background for a modern look
                                    gradient: LinearGradient(
                                      colors: [HexColor('#012169'),HexColor('#012169')],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10.sp),
                                            child: Image.asset(
                                              'assets/playstore.png',
                                              height: 80.sp,
                                              width: 80.sp,
                                              fit: BoxFit.cover, // Ensures the image fits within the rounded container
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          // Styled "First Calling App" text
                                          Text(
                                            'First Calling App',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10.0,
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(2.0, 2.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Optional: Add a subtitle or description
                                          // Padding(
                                          //   padding:  EdgeInsets.all(8.sp),
                                          //   child: Text(
                                          //     'Connect with your loved ones seamlessly',
                                          //     style: GoogleFonts.poppins(
                                          //       fontSize: 11.sp,
                                          //       fontWeight: FontWeight.w400,
                                          //       color: Colors.white70,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                    gscanOverlayConfig: const GscanOverlayConfig(
                      scannerScanArea: ScannerScanArea.center,
                      scannerBorder: ScannerBorder.visible,
                      scannerBorderPulseEffect:
                      ScannerBorderPulseEffect.enabled,
                      borderColor: Colors.white,
                      borderRadius: 24.0,
                      scannerLineAnimationColor: Colors.green,
                      scannerOverlayBackground:
                      ScannerOverlayBackground.blur,
                      scannerLineAnimation: ScannerLineAnimation.enabled,
                    ),
                  ),
                ),
              );
            },
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.sp)),
          child: SizedBox(
            height: 30.sp,
              width: 30.sp,
              child: Image.asset("assets/scan.gif"))

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: [
             ProductListScreen(),
            // SetFlashScreen(),
            const IVRCallScreen(),
            const IVRCallScreen(),
            const HelplineScreen(),
            const SOSScreen(),
          ],
        ),
      ),

    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}





class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.phone, 'label': 'IVR Call'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan QR'},
      {'icon': Icons.contact_phone, 'label': 'Helplines'},
      {'icon': Icons.sos, 'label': 'SOS'},
    ];

    return Container(
      color: Colors.grey.shade200,
      child: BottomAppBar(
        color: Colors.blue.shade900, // replace with AppColors.navyBlue if you have it
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.sp,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              child: SizedBox(
                height: 70.sp, // ✅ height bhi responsive
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index == 2) ...[
                      SizedBox(height: 28.sp), // sirf FAB ke liye empty gap
                    ] else ...[
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.grey,
                        size: isSelected ? 25.sp : 21.sp,
                      ),
                      SizedBox(height: 2.sp), // responsive gap
                      Text(
                        items[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),

              ),
            );
          }),
        ),
      ),
    );
  }
}
