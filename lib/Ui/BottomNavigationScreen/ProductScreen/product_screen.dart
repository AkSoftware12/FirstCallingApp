import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  final List<Map<String, String>> products = const [
    {
      'title': 'CAR COMBO',
      'price': '799',
      'originalPrice': '1595',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/car.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'CAR COMBO',
      'price': '799',
      'originalPrice': '1595',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/bike_home.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'CHILD SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/Car_combo_1st.webp',
      'packSize': '(Pack of 2)',
    },
    {
      'title': 'BIKE COMBO',
      'price': '849',
      'originalPrice': '1695',
      'discount': '50% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/car_combo.webp',
      'packSize': '(Pack of 6)',
    },
    {
      'title': 'PET SAFETY QR',
      'price': '599',
      'originalPrice': '999',
      'discount': '40% OFF',
      'imageUrl': 'https://nekinsan-prod.s3.amazonaws.com/product/files/pet.webp',
      'packSize': '(Pack of 2)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          BannerSlider(),
          const Text(
            'OUR PRODUCTS',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'EMERGENCY / WRONG PARKING SAFETY QR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.71,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: products.map((product) => ProductCard(
              title: product['title']!,
              price: product['price']!,
              originalPrice: product['originalPrice']!,
              discount: product['discount']!,
              imageUrl: product['imageUrl']!,
              packSize: product['packSize']!,
            )).toList(),
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
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1B263B), const Color(0xFF2A3F5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
              child: Image.network(
                imageUrl,
                height: 180, // Fixed height to control image size
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white38,
                ),
              ),
            ),
            Expanded( // Wrap Column with Expanded to handle overflow
              child: Padding(
                padding: const EdgeInsets.all(5.0),
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
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 30),
                            ),
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      ],
                    )
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
            height: 150,
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
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
        const SizedBox(height: 8), // Space between carousel and dots
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