
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add To Cart Animation Example',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Cart animation
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var _cartQuantityItems = 0;

  // Screens for bottom nav
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Center(child: Text("🏠 Home Page", style: TextStyle(fontSize: 22))),
      ProductsPage(onItemClick: listClick),
      const Center(child: Text("👤 Profile Page", style: TextStyle(fontSize: 22))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Shop App"),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: () {
                _cartQuantityItems = 0;
                cartKey.currentState!.runClearCartAnimation();
              },
            ),
            const SizedBox(width: 16),
            AddToCartIcon(
              key: cartKey,
              icon: const Icon(Icons.shopping_cart),
              badgeOptions: const BadgeOptions(
                active: true,
                backgroundColor: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Products"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  void listClick(GlobalKey widgetKey) async {
    await runAddToCartAnimation(widgetKey);
    await cartKey.currentState!
        .runCartAnimation((++_cartQuantityItems).toString());
  }
}

class ProductsPage extends StatelessWidget {
  final void Function(GlobalKey) onItemClick;

  const ProductsPage({super.key, required this.onItemClick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(
        15,
            (index) => AppListItem(
          onClick: onItemClick,
          index: index,
        ),
      ),
    );
  }
}

class AppListItem extends StatelessWidget {
  final GlobalKey widgetKey = GlobalKey();
  final int index;
  final void Function(GlobalKey) onClick;

  AppListItem({super.key, required this.onClick, required this.index});

  @override
  Widget build(BuildContext context) {
    Container mandatoryContainer = Container(
      key: widgetKey,
      width: 60,
      height: 60,
      color: Colors.transparent,
      child: Image.network(
        "https://cdn.jsdelivr.net/gh/omerbyrk/add_to_cart_animation/example/assets/apple.png",
        width: 60,
        height: 60,
      ),
    );

    return ListTile(
      onTap: () => onClick(widgetKey),
      leading: mandatoryContainer,
      title: Text("Animated Apple Product Image $index"),
    );
  }
}
