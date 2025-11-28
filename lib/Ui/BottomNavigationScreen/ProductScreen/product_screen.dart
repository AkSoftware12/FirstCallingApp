
import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Cart/CartModel/cart_model.dart';
import '../../Cart/CartProvider/cart_provider.dart';
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
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement) onItemClick;

  ProductListScreen({super.key, required this.onItemClick});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;

  Future<void> fetchProducts() async {
    try {
      var url = Uri.parse(ApiRoutes.getAllProducts); // apna API endpoint
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List list = data['products'];

        setState(() {
          products = list.map((e) => Product.fromJson(e)).toList();
          isLoading = false;
        });
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
    }
  }
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading
        ? Center(
      child: CupertinoActivityIndicator(
        radius: 25,
        color: AppColors.navyBlue,
      ),
    )

        :

      SingleChildScrollView(
      padding: EdgeInsets.all(5.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BannerSlider(),
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
                    gst:  product.gst!.toDouble(),
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
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement) onClick;

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
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(5.sp),
              ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Row(
                          children: [
                            Text(
                              '₹$price',
                              style: TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹$originalPrice',
                              style: TextStyle(
                                color: HexColor('#cf0c14'),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          margin: EdgeInsets.symmetric(horizontal: 0.0),
                          child: SizedBox(
                            width: 80.sp,
                            child: Consumer<CartProvider>(
                              builder: (context, cart, child) {
                                final qty = cart.getQuantity(title);

                                if (qty == 0) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        cart.addItem(
                                          CartItem(
                                            product_name: title,
                                            rate: price,
                                            imageUrl: imageUrl,
                                            product_gst:gst,
                                            product_id: id
                                          ),
                                        );
                                        final item = CartItem(
                                            product_name: title,
                                            rate: price,
                                            imageUrl: imageUrl,
                                            product_gst:gst,
                                            product_id: id
                                        );
                                        onClick(widgetKey, context, item,true);
                                      },
                                      child: Container(
                                        height: 22.sp,
                                        width: 50.sp,
                                        decoration: BoxDecoration(
                                          color: AppColors.navyBlue,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'ADD',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final item = cart.items.firstWhere(
                                                (e) => e.product_name == title,
                                          );
                                          if (item != null) cart.decreaseQty(item);


                                          onClick(widgetKey, context, item,false);
                                        },
                                        child: Container(
                                          height: 20.sp,
                                          width: 20.sp,
                                          decoration: BoxDecoration(
                                            color: HexColor('#cf0c14'),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: const Icon(Icons.remove, color: Colors.white, size: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.sp),
                                        child: Text(
                                          "$qty",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final item = cart.items.firstWhere(
                                                (e) => e.product_name == title,
                                          );
                                          if (item != null) cart.increaseQty(item);
                                          onClick(widgetKey, context, item,true);

                                        },
                                        child: Container(
                                          height: 20.sp,
                                          width: 20.sp,
                                          decoration: BoxDecoration(
                                            color: AppColors.navyBlue,
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: const Icon(Icons.add, color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
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
