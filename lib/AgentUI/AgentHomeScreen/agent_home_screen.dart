import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Utils/textSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstcallingapp/Utils/HexColorCode/HexColor.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Ui/BottomNavigationScreen/BannerScreen/banner.dart';
import '../../Utils/string.dart';
import '../AgentListItem/agent_list_item.dart';

class AgentScreen extends StatefulWidget {
  final String name;
  const AgentScreen({super.key, required this.name});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int totalQr = 0;
  int allotedQr = 0;
  int availableQr = 0;
  List<dynamic> qrDetails = [];

  Future<void> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("No token found!");
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'No authentication token found.';
        });
        return;
      }

      var url = Uri.parse(ApiRoutes.agentDashboard);
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      debugPrint('URL: $url');
      debugPrint('Headers: $headers');

      var response = await http.get(url, headers: headers);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data["success"] == true && data["qr_details"] != null) {
          var qrData = data["qr_details"];

          setState(() {
            totalQr = qrData["total_qr"] ?? 0;
            allotedQr = qrData["alloted_qr"] ?? 0;
            availableQr = qrData["available_qr"] ?? 0;
            qrDetails = qrData["qrdetail"] ?? [];
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = data["message"] ?? 'Failed to load data.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Network error: $e';
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MMM-yyyy').format(now);
    debugPrint(formattedDate);
    return isLoading
        ?  Center(
      child: CupertinoActivityIndicator(
        radius: 25,
        color: AppColors.navyBlue,
      ),
    )
        : hasError
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.sp),
          Text(
            errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.sp),
          ElevatedButton(
            onPressed: fetchProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    )
        : SingleChildScrollView(
      padding: EdgeInsets.all(5.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerSlider(),
          SizedBox(height: 5.sp),
        Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.name}!',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(
                        context,
                      ).textTheme.displayLarge,
                      fontSize:
                      MediaQuery.of(context)
                          .size
                          .width *
                          0.045,
                      fontWeight: FontWeight.w800,
                      color: AppColors.colorBlack,
                    ),
                  ),
                  SizedBox(height: 5.sp),
                  Text(
                   'Serving excellence every day.',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(
                        context,
                      ).textTheme.displayLarge,
                      fontSize:
                      MediaQuery.of(context)
                          .size
                          .width *
                          0.035,
                      color: AppColors.colorBlack,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 25.sp,
                    decoration: BoxDecoration(
                      color: AppColors.bottomBg,
                      borderRadius:
                      BorderRadius.circular(5.sp),
                    ),
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 5.sp,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 15.sp,
                            color:
                            AppColors.navyBlue,
                          ),
                          SizedBox(width: 5.sp),
                          Text(
                            formattedDate,
                            style:
                            GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight:
                              FontWeight.w500,
                              color:
                              AppColors.colorBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 11.sp),
                ],
              ),
            ],
          ),
        ),

          Padding(
            padding: EdgeInsets.all(0.sp),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                // color: HexColor('#fefefe'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bottomBg, AppColors.bottomBg.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.sp),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.sp,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.sp,
                      offset: Offset(0, 2.sp),
                    ),
                  ],
                ),


                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Dashboard Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.colorBlack,
                        ),
                      ),
                      SizedBox(height: 16.sp),
                      // First row: QR Stats
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgentListItem(
                                        type: 'all', title: 'Total QRs',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.sp),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.bottomBg, AppColors.bottomBg.withOpacity(0.8)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp),
                                    border: Border.all(
                                      color: AppColors.navyBlue,
                                      width: 1.sp,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8.sp,
                                        offset: Offset(0, 2.sp),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner,
                                          size: 32.sp,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(height: 8.sp),
                                        Text(
                                          'Total QRs',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.colorBlack.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(height: 4.sp),
                                        Text(
                                          totalQr.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.colorBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgentListItem(
                                        type: 'available', title: 'Available QRs',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.sp),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.bottomBg, AppColors.bottomBg.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp),
                                    border: Border.all(
                                      color: AppColors.navyBlue,
                                      width: 1.sp,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8.sp,
                                        offset: Offset(0, 2.sp),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: Colors.green,
                                        ),
                                        SizedBox(height: 8.sp),
                                        Text(
                                          'Available QRs',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.colorBlack.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(height: 4.sp),
                                        Text(
                                          availableQr.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.colorBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 16.sp),
                      // Second row: EMI and Employees
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AgentListItem(
                                        type: 'assigned', title: 'Alloted QRs',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.sp),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.bottomBg, AppColors.bottomBg.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp),
                                    border: Border.all(
                                       color: AppColors.navyBlue,

                                      width: 1.sp,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8.sp,
                                        offset: Offset(0, 2.sp),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: AppColors.navyBlue,
                                        ),
                                        SizedBox(height: 8.sp),
                                        Text(
                                          'Alloted QRs',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.navyBlue,
                                          ),
                                        ),
                                        SizedBox(height: 4.sp),
                                        Text(
                                          allotedQr.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.navyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.sp),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.bottomBg, AppColors.bottomBg.withOpacity(0.8)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp),
                                    border: Border.all(
                                      color: AppColors.navyBlue,
                                      width: 1.sp,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8.sp,
                                        offset: Offset(0, 2.sp),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.currency_rupee_rounded,
                                          size: 32.sp,
                                          color:AppColors.navyBlue,
                                        ),
                                        SizedBox(height: 8.sp),
                                        Text(
                                          'Commission QRs',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color:AppColors.navyBlue,

                                          ),
                                        ),
                                        SizedBox(height: 4.sp),
                                        Text(
                                          '0',
                                          style: GoogleFonts.poppins(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color:AppColors.navyBlue,

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.sp),
                      // Third row: Additional Stats - Recent Activity & Pending Tasks
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding:  EdgeInsets.all(8.sp),
            child: Text(
              'Recently Alloted',
              style: GoogleFonts.poppins(
                textStyle: Theme.of(
                  context,
                ).textTheme.displayLarge,
                fontSize:
                MediaQuery.of(context)
                    .size
                    .width *
                    0.045,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
          ),
          qrDetails.isEmpty
              ? Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48.sp, color: Colors.grey),
                SizedBox(height: 10.h),
                Text(
                  "No QR items available",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: qrDetails.length > 3 ? 3 : qrDetails.length,
                itemBuilder: (context, index) {
                  final item = qrDetails[index];
                  return Card(
                    color: Colors.grey.shade100,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 3.sp),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(Icons.qr_code,
                            color: AppColors.navyBlue, size: 22.sp),
                      ),
                      title: Text(
                        "QR Number: ${item["qr_number"] ?? 'N/A'}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                      subtitle: Text(
                        "Status: ${item["qr_code"]?["status"] ?? 'N/A'}",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13.sp),
                      ),

                    ),
                  );
                },
              ),

            ],
          )

        ],
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
