import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../BaseUrl/baseurl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../Utils/color.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<dynamic> banners = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    final url = Uri.parse(ApiRoutes.getBanners); // your API URL

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["success"] == true && jsonData["banners"] != null) {
          setState(() {
            banners = jsonData["banners"];
          });
        } else {
          print("⚠️ No banner data found");
        }
      } else {
        print("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error: $e");
    }
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return banners.isEmpty
        ? SizedBox(
      height: 130.sp,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: double.infinity,
          height: 130.sp,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10.sp),
          ),
        ),
      ),
    )
        : Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 130.sp,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration:
            const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: banners.map((item) {
            final imageUrl = item["image"]?.toString() ?? "";
            final link = item["title"]?.toString() ?? "";
            print('${'https://firstcallingapp.com'}$imageUrl');

            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 5.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                    image: DecorationImage(
                      image: NetworkImage('${'https://firstcallingapp.com'}$imageUrl'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 🔹 Show button only if title (link) is not null
                if (link.isNotEmpty)
                  Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        height: 20.sp,
                        child: ElevatedButton(
                          onPressed: () => _launchURL(link),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade50,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.sp,
                              vertical: 0.sp,
                            ),
                          ),
                          child: Text(
                            "Click here",
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.navyBlue
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 10.sp),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: banners.length,
          effect: WormEffect(
            dotHeight: 5,
            dotWidth: 10,
            activeDotColor: AppColors.navyBlue,
            dotColor: Colors.grey.shade400,
            spacing: 4,
          ),
        ),
      ],
    );
  }
}
