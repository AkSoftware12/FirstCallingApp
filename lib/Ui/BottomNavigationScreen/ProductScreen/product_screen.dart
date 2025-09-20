import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  final List<Map<String, String>> products = const [
    {
      'title': 'CAR COMBO',
      'price': '799',
      'originalPrice': '1595',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/car.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'CAR COMBO',
      'price': '799',
      'originalPrice': '1595',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/bike_home.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl':
          'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
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
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3.sp),
          BannerSlider(),
           SizedBox(height: 10.sp),
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
                // Handle the selected category
                print('Selected category: $selectedCategory');
                // You can pass this value to another part of your app
              },
            ),
          ),
           SizedBox(height: 15.sp),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.71,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: products
                .map(
                  (product) => ProductCard(
                    title: product['title']!,
                    price: product['price']!,
                    originalPrice: product['originalPrice']!,
                    discount: product['discount']!,
                    imageUrl: product['imageUrl']!,
                    packSize: product['packSize']!,
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

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.imageUrl,
    required this.packSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,

        // gradient: LinearGradient(
        //   colors: [ Colors.grey.shade300, Colors.grey.shade200],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(5.sp),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:  BorderRadius.vertical(
              top: Radius.circular(5.sp),
            ),
            child: Image.network(
              imageUrl,
              height: 150.sp, // Fixed height to control image size
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>  Icon(
                Icons.broken_image,
                size: 100.sp,
                color: Colors.white38,
              ),
            ),
          ),
          Expanded(
            // Wrap Column with Expanded to handle overflow
            child: Padding(
              padding:  EdgeInsets.all(5.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹$originalPrice',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
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
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            packSize,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                              color: Colors.black87,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(5.sp), // Optional: Padding around the container
                        margin: EdgeInsets.symmetric(horizontal: 0.0), // Optional: Margin
                        child: SizedBox(
                          width: 50.sp,
                          child: GestureDetector(
                            onTap: () {}, // Handles tap events (replaces onPressed)
                            child: Container(
                              height: 22.sp, // Matches the minimum height of the original ElevatedButton
                              decoration: BoxDecoration(
                                color: HexColor('#718cd9'), // Background color (replaces ElevatedButton's backgroundColor)
                                borderRadius: BorderRadius.circular(4.0), // Optional: Rounded corners like a button
                              ),
                              child: Center(
                                child: Text(
                                  'ADD',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
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
    'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/05/07/blog.png',
    'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/06/12/pet.png',
    'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/05/16/Blog___Door_Bell.png',
    'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/05/31/child-safe.png',
    'https://nekinsan-prod.s3.amazonaws.com/blog/thumbnails/2024/06/21/wrong-parking.png',
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
        SizedBox(height: 15.sp), // Space between carousel and dots
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
