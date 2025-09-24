
// ProductListScreen.dart
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Cart/CartModel/cart_model.dart';
import '../../Cart/CartProvider/cart_provider.dart';

class ProductListScreen extends StatelessWidget {
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement) onItemClick;

  ProductListScreen({super.key, required this.onItemClick});

  final List<Map<String, String>> products = const [
    {
      'title': 'Car SAFETY QR',
      'price': '999',
      'originalPrice': '1499',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/4RBpR42W/1.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/S45YPpsb/2.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Mobile SAFETY QR',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://i.ibb.co/vxnXrmWN/4.jpg',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'Key SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/d4xsrhYf/3.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Bike SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/BV708VdL/5.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Laptop SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/xKtMmyTx/6.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Trolley SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/hJyjjHL1/8.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Smart Doorbell QR',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://i.ibb.co/xqF4jLFB/7.jpg',
      'packSize': '(Pack of 6)',
    },

    {
      'title': 'Bag SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://i.ibb.co/jvtRydYp/9.jpg',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'Luggage SAFETY QR',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://i.ibb.co/4ZYTB6ZC/10.jpg',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'Child SAFETY QR',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://i.ibb.co/gMNkSYj6/12.jpg',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'Smart card SAFETY QR',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://i.ibb.co/0pJxN6px/11.jpg',
      'packSize': '(Pack of 6)',
    },

  ];

  final List<String> categories = [
    'All',
    'Car',
    'Bike',
    'Keys',
    'Lock',
    'Mobile',
    'Pet',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                "Category",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () {
                  print('Click See All Button');
                },
                child: SizedBox(
                  width: 60.sp,
                  child: Center(
                    child: Text(
                      "See All",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),
          Padding(
            padding: EdgeInsets.all(0.sp),
            child: CategoryChips(
              categories: categories,
              onCategorySelected: (selectedCategory) {
                print('Selected category: $selectedCategory');
              },
            ),
          ),
          SizedBox(height: 15.sp),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.73,
            crossAxisSpacing: 8.sp,
            mainAxisSpacing: 8.sp,
            children: products
                .map(
                  (product) => ProductCard(
                title: product['title']!,
                price: product['price']!,
                originalPrice: product['originalPrice']!,
                discount: product['discount']!,
                imageUrl: product['imageUrl']!,
                packSize: product['packSize']!,
                onClick: onItemClick,
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
  final String price;
  final String originalPrice;
  final String discount;
  final String imageUrl;
  final String packSize;
  final void Function(GlobalKey, BuildContext, CartItem, bool isIncrement) onClick;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.imageUrl,
    required this.packSize,
    required this.onClick,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              discount,
                              style: TextStyle(
                                color: HexColor('#cf0c14'),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              packSize,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.navyBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 8.sp,
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
                                            title: title,
                                            price: price,
                                            imageUrl: imageUrl,
                                          ),
                                        );
                                        final item = CartItem(
                                          title: title,
                                          price: price,
                                          imageUrl: imageUrl,
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
                                                (e) => e.title == title,
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
                                                (e) => e.title == title,
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

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final List<String> bannerImages = [
    'https://i.ibb.co/RkhfdVc1/1.jpg',
    'https://i.ibb.co/RpKJ6t3c/2.jpg',
    // 'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/05/16/Blog___Door_Bell.png',
    // 'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/05/31/child-safe.png',
    // 'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/06/21/wrong-parking.png',
  ];

  int _currentIndex = 0;
  final CarouselController _carouselController =
      CarouselController(); // Controller for CarouselSlider

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          // carouselController: _carouselController, // Assign controller to CarouselSlider
          options: CarouselOptions(
            height: 130.sp,
            // Set banner height
            autoPlay: true,
            // Auto-scroll banners
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            // Enlarge the center banner
            viewportFraction: 1,
            // Show partial next/previous banners
            enableInfiniteScroll: true,
            // Loop through banners
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index; // Update current index
              });
            },
          ),
          items: bannerImages.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin:  EdgeInsets.symmetric(horizontal: 3.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.fill, // Fit image to container
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10.sp), // Space between carousel and dots
        SmoothPageIndicator(
          controller: PageController(initialPage: _currentIndex),
          // Use PageController for SmoothPageIndicator
          count: bannerImages.length,
          effect: WormEffect(
            dotHeight: 5,
            dotWidth: 10,
            activeDotColor: AppColors.navyBlue,
            dotColor: Colors.grey.shade400,
            spacing: 3,
          ),
          onDotClicked: (index) {
            // _carouselController.animateToPage(index); // Sync dot click with carousel
          },
        ),
      ],
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
