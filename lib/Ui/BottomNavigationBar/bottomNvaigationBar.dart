import 'package:firstcallingapp/Utils/color.dart';
import 'package:firstcallingapp/Utils/textSize.dart';
import 'package:firstcallingapp/Widgets/CustomText/custom_text.dart';
import 'package:flutter/material.dart';
import '../../Utils/string.dart';
import '../BottomNavigationScreen/Helpline/helpline.dart';
import '../BottomNavigationScreen/IVRCall/ivr_call.dart';
import '../BottomNavigationScreen/ProductScreen/product_screen.dart';
import '../BottomNavigationScreen/QRScanScreen/qr_scan_screen.dart';
import '../BottomNavigationScreen/SOS/sos_screen.dart';
import '../BottomNavigationScreen/SetFlash/set_flash.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _HomePageState();
}

class _HomePageState extends State<BottomNavigationBarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 2;

  static const List<Widget> _screens = [
    SetFlashScreen(),
    IVRCallScreen(),
    ProductListScreen(),
    HelplineScreen(),
    SOSScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      key: _scaffoldKey,
      appBar: AppBar(
        leading:Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(10)
            ),
            child: IconButton(
              icon: Icon(Icons.dashboard, color: Colors.white, size: 25),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ),
        title: CustomText(text: AppStrings.appName, colors: AppColors.colorWhite, size: AppTextSizes.text17),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.navyBlue,
                AppColors.navyBlue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(30)
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_active_sharp, color: Colors.white, size: 20),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor:  AppColors.navyBlue, // Navy blue background
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200, // Increased height to accommodate profile details
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyBlue,AppColors.navyBlue,],
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
                    backgroundColor: Colors.grey.shade300, // Fallback color if image fails
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // User contact number
                  const Text(
                    '+91 123 456 7890',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white10,
              thickness: 1,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.flash_on,
                    title: 'Set Flash',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  _DrawerItem(
                    icon: Icons.phone,
                    title: 'IVR Call',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  _DrawerItem(
                    icon: Icons.qr_code_scanner,
                    title: 'Products',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  _DrawerItem(
                    icon: Icons.contact_phone,
                    title: 'Helplines',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  _DrawerItem(
                    icon: Icons.sos,
                    title: 'SOS',
                    isSelected: _selectedIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ProductListScreen(),
      bottomNavigationBar: Container(
        height: 100,
        color: AppColors.bottomRed, // Navy blue bottom nav
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.flash_on,
                    color: _selectedIndex == 0 ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _onItemTapped(0),
                ),
                const Text(
                  'Set Flash',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: _selectedIndex == 1 ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _onItemTapped(1),
                ),
                const Text(
                  'IVR Call',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 38.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeScannerPage(
                          onScan: (code) {
                            // if (code != null && !_scanHistory.contains(code)) {
                            //   setState(() {
                            //     _scanHistory.add(code);
                            //   });
                            // }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.contact_phone,
                    color: _selectedIndex == 3 ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _onItemTapped(3),
                ),
                const Text(
                  'Helplines',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.sos,
                    color: _selectedIndex == 4 ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _onItemTapped(4),
                ),
                const Text(
                  'SOS',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
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
      leading: Icon(
        icon,
        color: isSelected ? Colors.red : Colors.white,
      ),
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
