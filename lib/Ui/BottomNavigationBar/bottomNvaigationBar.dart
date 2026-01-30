import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:firstcallingapp/Ui/Login/Login/login.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gscankit/gscankit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../BottomNavigationScreen/Helpline/helpline.dart';
import '../BottomNavigationScreen/IVRCall/ivr_call.dart';
import '../BottomNavigationScreen/ProductScreen/product_screen.dart';
import '../BottomNavigationScreen/SOS/sos_screen.dart';
import '../Cart/CartModel/cart_model.dart';
import '../Cart/CartScreen/cart_screen.dart';
import '../DrawerScreen/Drawer/drawer.dart';
import '../DrawerScreen/privacy.dart';
import '../Login/SplashScreen/splash_screen.dart';
import '../OrderHistory/order_history.dart';
import '../ParkingScreen/parking.dart';
import '../Profile/update_profile.dart';
import '../QRActivationScreen/qr_check_screen.dart';
import '../QRScanScreen/QRCodeData/qr_code_data.dart';
import '../QRScanScreen/TorchScreen/torch_screen.dart';
import 'package:new_version_plus/new_version_plus.dart';


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
  final int initialIndex;

  const BottomNavigationBarScreen({super.key,  this.initialIndex = 0});

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
  PageController controller = PageController();

  String currentVersion = '';
  String release = "";
  String? userName;
  String userImage = "";
  bool _upgradeDialogShown = false;

  // Cart animation
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var _cartQuantityItems = 0;


  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
    controller = PageController(initialPage: selected);

    checkForVersion(context);

    final newVersion = NewVersionPlus(
      iOSId: 'com.firstcallingapp.firstcallingapp',
      androidId: 'com.firstcallingapp.firstcallingapp',
      androidPlayStoreCountry: "es_ES",
      androidHtmlReleaseNotes: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      advancedStatusCheck(newVersion); // ✅ now context is ready
    });
  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  Future<void> advancedStatusCheck(NewVersionPlus newVersion) async {
    try {
      final status = await newVersion.getVersionStatus();
      if (status == null) return;

      debugPrint("releaseNotes: ${status.releaseNotes}");
      debugPrint("appStoreLink: ${status.appStoreLink}");
      debugPrint("localVersion: ${status.localVersion}");
      debugPrint("storeVersion: ${status.storeVersion}");
      debugPrint("canUpdate: ${status.canUpdate}");

      if (!status.canUpdate) return;
      if (_upgradeDialogShown) return;
      if (!mounted) return;

      _upgradeDialogShown = true;

      showDialog(
        context: context, // ✅ yahi best hai
        barrierDismissible: false,
        builder: (dialogCtx) {
          return PopScope( // ✅ WillPopScope new replacement (Flutter 3.13+)
            canPop: false,
            onPopInvoked: (didPop) {
              SystemNavigator.pop();
            },
            child: CustomUpgradeDialog(
              currentVersion: status.localVersion,
              newVersion: status.storeVersion,
              releaseNotes: [
                (status.releaseNotes ?? "").trim().isEmpty
                    ? "New update available."
                    : status.releaseNotes!.trim(),
              ],
            ),
          );
        },
      );
    } catch (e, st) {
      debugPrint("advancedStatusCheck error: $e");
      debugPrint("$st");
    }
  }
  Future<void> checkForVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }

  // Sample data for emergency numbers
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
  ];


  String? extractNumberFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      /// 🔹 Case 1: query parameter se ( ?code=1000001 )
      if (uri.queryParameters.isNotEmpty) {
        for (final value in uri.queryParameters.values) {
          final match = RegExp(r'\d+').firstMatch(value);
          if (match != null) return match.group(0);
        }
      }

      /// 🔹 Case 2: path se ( /call/9876543210 )
      final match = RegExp(r'\d+').firstMatch(uri.path);
      if (match != null) return match.group(0);
    } catch (_) {}

    return null;
  }


  String? _lastScannedValue;
  DateTime? _lastScanTime;

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isScanning) return;

    if (capture.barcodes.isEmpty) return;

    final String? value = capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;

    // ✅ same qr duplicate block (within 2 seconds)
    final now = DateTime.now();
    if (_lastScannedValue == value &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 2000) {
      return;
    }
    _lastScannedValue = value;
    _lastScanTime = now;

    _isScanning = true;

    try {
      debugPrint("✅ Scanned: $value");

      /// 🔥 NUMBER NIKALO
      final extractedNumber = extractNumberFromUrl(value);
      debugPrint("📞 Extracted Number: $extractedNumber");

      // ✅ scanner ko stop/pause kar do navigation se pehle (agar controller hai)
      try {
        await controllerScan.stop(); // if available in your controller
      } catch (_) {}

      // ✅ push and wait till return
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullScreenActionPage(
            value: extractedNumber.toString(),
          ),
        ),
      );
    } catch (e) {
      debugPrint("⚠️ handleDetect error: $e");
    } finally {
      // ✅ wapas aake scanner start/resume
      try {
        await controllerScan.start(); // if available
      } catch (_) {}

      // ✅ lock release immediately
      _isScanning = false;
    }
  }



  void updateCart(GlobalKey widgetKey, BuildContext context, CartItem item, bool isIncrement) async {
    if (isIncrement) {
      // Add to cart (increment)
      await runAddToCartAnimation(widgetKey);
      _cartQuantityItems++;
    } else {
      // Remove from cart (decrement, not less than 0)
      if (_cartQuantityItems > 0) {
        _cartQuantityItems--;
      }
    }

    // Update cart animation
    await cartKey.currentState!
        .runCartAnimation(_cartQuantityItems.toString());
  }


  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 25.sp,
      width: 25.sp,
      opacity: 0.99,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.navyBlue,
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40.sp,
                child: Image.asset('assets/calling_text.gif'),
              ),
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
              padding: EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
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
                          automaticallyImplyLeading: true,
                          iconTheme: IconThemeData(color: Colors.white),
                          title: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25.sp),
                                child: Image.asset(
                                  'assets/playstore.png',
                                  height: 35.sp,
                                  width: 35.sp,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 3.sp),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Scan any QR",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "First Calling App",
                                    style: GoogleFonts.poppins(
                                      fontSize: 7.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          backgroundColor: Colors.transparent,
                          actions: [],
                        );
                      },
                      floatingOption: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                IconButton.filled(
                                  style: IconButton.styleFrom(
                                    backgroundColor: CupertinoColors.systemGrey6,
                                    foregroundColor: CupertinoColors.darkBackgroundGray,
                                  ),
                                  icon: Icon(CupertinoIcons.camera_rotate),
                                  onPressed: () => controllerScan.switchCamera(),
                                ),
                                SizedBox(width: 5.sp),
                                ValueListenableBuilder(
                                  valueListenable: controllerScan,
                                  builder: (context, state, child) {
                                    final isTorchOn = state.torchState == TorchState.on;
                                    return TorchToggleButton(
                                      isTorchOn: isTorchOn,
                                      onPressed: () => controllerScan.toggleTorch(),
                                    );
                                  },
                                ),
                                SizedBox(width: 5.sp),
                                IconButton.filled(
                                  style: IconButton.styleFrom(
                                    backgroundColor: CupertinoColors.systemGrey6,
                                    foregroundColor: CupertinoColors.darkBackgroundGray,
                                  ),
                                  icon: Icon(CupertinoIcons.photo),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      try {
                                        final result = await controllerScan.analyzeImage(pickedFile.path);
                                        if (result != null) {
                                          _handleDetect(result);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("No QR/Barcode found in image")),
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint("Error scanning from gallery: $e");
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20.sp),
                            Padding(
                              padding: EdgeInsets.only(bottom: 50.sp),
                              child: Column(
                                children: [
                                  Container(
                                    width: 150.sp,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.sp),
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
                                                height: 50.sp,
                                                width: 50.sp,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 10.sp),
                                            Text(
                                              'First Calling App',
                                              style: GoogleFonts.poppins(
                                                fontSize: 8.sp,
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
                      gscanOverlayConfig: GscanOverlayConfig(
                        scannerScanArea: ScannerScanArea.center,
                        scannerBorder: ScannerBorder.visible,
                        scannerBorderPulseEffect: ScannerBorderPulseEffect.enabled,
                        borderColor: AppColors.navyBlue,
                        borderRadius: 24.0,
                        scannerLineAnimationColor: AppColors.navyBlue,
                        scannerOverlayBackground: ScannerOverlayBackground.blur,
                        scannerLineAnimation: ScannerLineAnimation.enabled,
                      ),
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: 25.sp,
                width: 25.sp,
                child: Image.asset('assets/scan.gif'),
              ),
            ),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: AddToCartIcon(
                key: cartKey,
                icon:  Icon(Icons.shopping_cart),
                badgeOptions:  BadgeOptions(
                  active: true,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        drawer: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            width: MediaQuery.sizeOf(context).width * .7,
            // backgroundColor: ColorSelect.maineColor,
            child: DrawerPageScreen(
              // currentVersion: currentVersion,
            )),
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
                        automaticallyImplyLeading: true,
                        iconTheme: const IconThemeData(color: Colors.white),
                        title: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25.sp),
                              child: Image.asset(
                                'assets/playstore.png',
                                height: 35.sp,
                                width: 35.sp,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 3.sp),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Scan any QR",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "First Calling App",
                                  style: GoogleFonts.poppins(
                                    fontSize: 7.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        backgroundColor: Colors.transparent,
                      );
                    },
                    floatingOption: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: CupertinoColors.systemGrey6,
                                  foregroundColor: CupertinoColors.darkBackgroundGray,
                                ),
                                icon: Icon(CupertinoIcons.camera_rotate),
                                onPressed: () => controllerScan.switchCamera(),
                              ),
                              SizedBox(width: 5.sp),
                              ValueListenableBuilder(
                                valueListenable: controllerScan,
                                builder: (context, state, child) {
                                  final isTorchOn = state.torchState == TorchState.on;
                                  return TorchToggleButton(
                                    isTorchOn: isTorchOn,
                                    onPressed: () => controllerScan.toggleTorch(),
                                  );
                                },
                              ),
                              SizedBox(width: 5.sp),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: CupertinoColors.systemGrey6,
                                  foregroundColor: CupertinoColors.darkBackgroundGray,
                                ),
                                icon: Icon(CupertinoIcons.photo),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    try {
                                      final result = await controllerScan.analyzeImage(pickedFile.path);
                                      if (result != null) {
                                        _handleDetect(result);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("No QR/Barcode found in image")),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint("Error scanning from gallery: $e");
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          Padding(
                            padding: EdgeInsets.only(bottom: 50.sp),
                            child: Column(
                              children: [
                                Container(
                                  width: 150.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.sp),
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
                                              height: 50.sp,
                                              width: 50.sp,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 10.sp),
                                          Text(
                                            'First Calling App',
                                            style: GoogleFonts.poppins(
                                              fontSize: 8.sp,
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

                    gscanOverlayConfig: GscanOverlayConfig(
                      scannerScanArea: ScannerScanArea.center,
                      scannerBorder: ScannerBorder.visible,
                      scannerBorderPulseEffect: ScannerBorderPulseEffect.enabled,
                      borderColor: AppColors.navyBlue,
                      borderRadius: 24.0,
                      scannerLineAnimationColor: AppColors.navyBlue,
                      scannerOverlayBackground: ScannerOverlayBackground.blur,
                      scannerLineAnimation: ScannerLineAnimation.enabled,
                    ),
                  ),
                ),
              );
            },
            backgroundColor: Colors.white,
            elevation: 8, // main shadow depth
            highlightElevation: 12, // shadow on press
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.sp),
            ),
            child: SizedBox(
              height: 30.sp,
              width: 30.sp,
              child: Image.asset("assets/scan.gif"),
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          child: CustomBottomNavBar(
          currentIndex: selected,
          onTap: (int index) {
            setState(() {
              selected = index;
            });
            controller.jumpToPage(index);
          },
                ),
        ),

      body: SafeArea(
        top: false, // keep top area flexible
        bottom: false, // bottom handled manually below

        child: PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(), // 👈 Swipe disable
            children: [
              ProductListScreen(onItemClick: updateCart), // Updated to pass listClick
              const IVRCallScreen(),
              const IVRCallScreen(),
              const HelplineScreen(),
              const SOSScreen(),
            ],
          ),
        ),
      ),
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
      {'icon': 'assets/home.png', 'label': 'Home'},
      {'icon': 'assets/help.png', 'label': 'IVR Call'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan QR'},
      {'icon': 'assets/call.png', 'label': 'Helplines'},
      {'icon': 'assets/sos.png', 'label': 'SOS'},
    ];

    return Container(
      height: 55.sp,
      child: BottomAppBar(
        color: AppColors.navyBlue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.sp,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            final bool isDisabled = index == 2; // disable index 2 tap

            return Expanded(
              child: InkWell(
                onTap: isDisabled ? null : () => onTap(index),
                splashColor: isDisabled ? Colors.transparent : Colors.white24,
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 55.sp,
                  color: isSelected ? HexColor('#F40009') : Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (index == 2)

                        Column(
                    children: [
                      SizedBox(
                        height: 22.sp,
                        width: 22.sp,
                      ),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                          color: Colors.white,
                        ),
                      )
                  ],
                )
                      // Only label for index 2 (no icon)

                      else ...[
                        item['icon'] is IconData
                            ? Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 22.sp,
                        )
                            : Image.asset(
                          item['icon'].toString(),
                          height: 22.sp,
                          width: 22.sp,
                          color: Colors.white,
                        ),
                        SizedBox(height: 2.sp),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


