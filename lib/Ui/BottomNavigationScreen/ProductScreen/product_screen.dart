import 'dart:convert';
import 'dart:ui';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Ui/Login/Login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Cart/CartModel/cart_model.dart';
import '../../Cart/CartProvider/cart_provider.dart';
import '../../QRActivationScreen/qr_check_screen.dart';
import '../BannerScreen/banner.dart';

class Product {
  final int? id;
  final String? name;
  final int? mrp;
  final int? sellingPrice;
  final int? gst;
  final String? description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.mrp,
    required this.sellingPrice,
    required this.gst,
    required this.description,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      mrp: json['mrp'],
      sellingPrice: json['selling_price'],
      gst: json['gst'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}

class ProductListScreen extends StatefulWidget {
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement)
  onItemClick;

  ProductListScreen({super.key, required this.onItemClick});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;

  Future<void> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("Apitoken: $token");

      // if (token == null || token.isEmpty) {
      //   if (mounted) {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       if (mounted) showSessionExpiredDialog(context);
      //     });
      //   }
      //   return;
      // }

      var url = Uri.parse(ApiRoutes.getAllProducts);

      // ✅ Token header add kiya
      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List list = data['products'];

        setState(() {
          products = list.map((e) => Product.fromJson(e)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // ✅ Unauthorized → session expire
        // if (mounted) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) showSessionExpiredDialog(context);
        //   });
        // }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Error: $e");

      // if (mounted) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (mounted) showSessionExpiredDialog(context);
      //   });
      // }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts();
    });
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
      pageBuilder: (ctx, _, __) => _SessionExpiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              radius: 25,
              color: AppColors.navyBlue,
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(5.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerSlider(),
                SizedBox(height: 5.sp),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRActive()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6C63FF,
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF6C63FF,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF43E8C5),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        const Text(
                                          'QR STICKER',
                                          style: TextStyle(
                                            color: Color(0xFF43E8C5),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        'Activate ',
                                        style: TextStyle(
                                          color: Color(0xFFF0EEFF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'New QR',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        ' Sticker',
                                        style: TextStyle(
                                          color: Color(0xFFF0EEFF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'TAP TO SCAN & ACTIVATE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/applogo.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Our All Products",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8.sp,
                  mainAxisSpacing: 8.sp,
                  children: products
                      .map(
                        (product) => ProductCard(
                          title: product.name.toString(),
                          price: product.sellingPrice.toString(),
                          originalPrice: product.mrp.toString(),
                          discount: '',
                          imageUrl: product.imageUrl.toString(),
                          packSize: '',
                          onClick: widget.onItemClick,
                          gst: product.gst!.toDouble(),
                          id: product.id.toString(),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String id;
  final String price;
  final String originalPrice;
  final String discount;
  final double gst;
  final String imageUrl;
  final String packSize;
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement)
  onClick;

  const ProductCard({
    super.key,
    required this.title,
    required this.id,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.imageUrl,
    required this.packSize,
    required this.onClick,
    required this.gst,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey widgetKey = GlobalKey();

    return Padding(
      padding: EdgeInsets.all(0.sp),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#aacfdd'),
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(width: 2.sp, color: AppColors.navyBlue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5.sp)),
              child: Container(
                key: widgetKey,
                height: 150.sp,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    size: 100.sp,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '₹$price',
                                  style: TextStyle(
                                    color: AppColors.navyBlue,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  '₹$originalPrice',
                                  style: TextStyle(
                                    color: HexColor('#cf0c14'),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final qty = cart.getQuantity(title);
                            if (qty == 0) {
                              return GestureDetector(
                                onTap: () {
                                  cart.addItem(
                                    CartItem(
                                      product_name: title,
                                      rate: price,
                                      imageUrl: imageUrl,
                                      product_gst: gst,
                                      product_id: id,
                                    ),
                                  );
                                  final item = CartItem(
                                    product_name: title,
                                    rate: price,
                                    imageUrl: imageUrl,
                                    product_gst: gst,
                                    product_id: id,
                                  );
                                  onClick(widgetKey, context, item, true);
                                },
                                child: Container(
                                  height: 22.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  constraints: BoxConstraints(minWidth: 44.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.navyBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final item = cart.items.firstWhere(
                                      (e) => e.product_name == title,
                                    );
                                    cart.decreaseQty(item);
                                    onClick(widgetKey, context, item, false);
                                  },
                                  child: Container(
                                    height: 20.h,
                                    width: 22.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: HexColor('#cf0c14'),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 22.w,
                                  child: Text(
                                    '$qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final item = cart.items.firstWhere(
                                      (e) => e.product_name == title,
                                    );
                                    cart.increaseQty(item);
                                    onClick(widgetKey, context, item, true);
                                  },
                                  child: Container(
                                    height: 20.h,
                                    width: 22.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.navyBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected; // Callback to pass selected value

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _CategoryChipsState createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late String selectedCategory; // Track the selected category

  @override
  void initState() {
    super.initState();
    // Set the first category as selected by default
    selectedCategory = widget.categories.isNotEmpty ? widget.categories[0] : '';
    // Call callback with default selection
    if (selectedCategory.isNotEmpty) {
      widget.onCategorySelected(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.sp, // Set height to 30.sp
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.sp),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category; // Update selected category
                });
                widget.onCategorySelected(category); // Pass selected value
              },
              child: Chip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                backgroundColor: isSelected
                    ? AppColors.navyBlue
                    : Colors.grey[200],
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                side: BorderSide(
                  color: isSelected ? AppColors.navyBlue : Colors.transparent,
                  width: 1.sp, // 1.sp border for selected chip
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.sp),
                ),
              ),
            ),
          );
        },
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
        pageBuilder: (_, animation, __) => const LoginScreen(),
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
