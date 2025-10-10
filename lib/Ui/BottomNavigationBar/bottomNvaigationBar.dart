import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:firstcallingapp/Ui/Login/Login/login.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../OrderHistory/order_history.dart';
import '../Profile/update_profile.dart';
import '../QRActivationScreen/qr_check_screen.dart';
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
  String? userName;
  String userImage = "";
  // Cart animation
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var _cartQuantityItems = 0;


  @override
  void initState() {
    checkForVersion(context);
    selected = widget.initialIndex;
    controller = PageController(initialPage: selected);
    super.initState();
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
                    SizedBox(
                      height: 250.h,
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

    if (capture.barcodes.isEmpty) {
      debugPrint("❌ No barcode found in capture.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No QR/Barcode found")),
      );
      _isScanning = false;
      return;
    }

    final String? value = capture.barcodes.first.rawValue;

    if (value != null && value.isNotEmpty) {
      debugPrint("✅ Scanned: $value");
      if (_isValidUrl(value)) {
        try {
          final Uri url = Uri.parse(value);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            _showPopup(value);
          }
        } catch (e) {
          debugPrint("⚠️ URL launch error: $e");
          _showPopup(value);
        }
      } else {
        _showPopup(value);
      }
    } else {
      debugPrint("⚠️ Barcode detected but value empty.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR/Barcode")),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isScanning = false;
    });
  }
// Popup function with Parking and Emergency buttons
  void _showPopup(String value) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "QR/Barcode Detected",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      debugPrint("🚗 Parking clicked");
                      // Add Parking logic here
                    },
                    icon: const Icon(Icons.local_parking),
                    label: const Text("Parking"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      debugPrint("🚨 Emergency clicked");
                      // Add Emergency logic here
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text("Emergency"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  bool _isValidUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
  }

  void _showResult(String data) {
    try {
      // Parse the scanned data as JSON
      // final Map<String, dynamic> parsedData = jsonDecode(data);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(data: data, type: '',),
        ),
      ).then((_) {
        _isScanning = false;
      });
    } catch (e) {
      debugPrint("⚠️ JSON parsing error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid data format")),
      );
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

  Future<void> checkForVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
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
              currentVersion: currentVersion,
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








class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Use a subtle, light background
      backgroundColor: AppColors.lightGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0.0)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 20.sp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black,size: 25.sp,),
                    onPressed: () {
                      Navigator.pop(context); // Drawer band karega
                    },
                  ),
                ],
              ),
            ),

            // Header
            _buildHeader(),
            Divider(
              thickness: 2.sp,
              color: Colors.grey.shade300,
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding:  EdgeInsets.symmetric(horizontal: 5.sp),
                children: [
                  _buildListTile(
                    context: context,
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=> ProfileUpdatePage()));
                    },
                  ),
                  _buildListTile(
                    context: context,
                    icon: Icons.qr_code,
                    title: 'Activate New QR Sticker',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QRActive()));

                    },
                  ),
                  _buildListTile(
                    context: context,
                    icon: Icons.shop,
                    title: 'My Orders/Products',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen()));

                    },
                  ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.share,
                  //   title: 'Share Tap',
                  //   onTap: () {},
                  // ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.account_balance_wallet,
                  //   title: 'Wallet',
                  //   onTap: () {},
                  // ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.touch_app,
                  //   title: 'Active/Deactive QR',
                  //   onTap: () {},
                  // ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.block,
                  //   title: 'Block A Number',
                  //   onTap: () {},
                  // ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.bookmark,
                  //   title: 'My Story',
                  //   onTap: () {},
                  // ),
                  // _buildListTile(
                  //   context: context,
                  //   icon: Icons.call,
                  //   title: 'Call Log',
                  //   onTap: () {},
                  // ),
                  _buildListTile(
                    context: context,
                    icon: Icons.notifications,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context: context,
                    icon: Icons.policy,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPage()));
                    },
                  ),
                  _buildListTile(
                    context: context,
                    icon: Icons.description,
                    title: 'Grievances',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context: context,
                    icon: Icons.bloodtype,
                    title: 'Blood Donation',
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
              _buildListTile(
                context: context,
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // ✅ Clear all stored data

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );

                },
              )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.sp,
            backgroundImage: const AssetImage('assets/playstore.png'),
            backgroundColor: AppColors.lightGray,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue, width: 3.sp),
              ),
            ),
          ),
           SizedBox(height: 8.sp),
          Text(
            'Ravikant Saini',
            style: TextStyle(
              color: AppColors.navyBlue,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.sp),

        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = AppColors.primaryBlue,
    Color iconColor = AppColors.primaryBlue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          // Add a splash color for a nice touch
          child: Padding(
            padding:  EdgeInsets.symmetric(
              horizontal: 16.sp,
              vertical: 12.sp,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:  AppColors.navyBlue,
                  size: 24.sp,
                ),
                 SizedBox(width: 12.sp),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:  AppColors.navyBlue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}