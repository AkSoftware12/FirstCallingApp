import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/color.dart';

class AgentListItem extends StatefulWidget {
  final String type;
  final String title;
  const AgentListItem({super.key, required this.type, required this.title});

  @override
  State<AgentListItem> createState() => _AgentListItemState();
}

class _AgentListItemState extends State<AgentListItem> with TickerProviderStateMixin {
  List<dynamic> qrDetails = [];
  List<dynamic> filteredQrDetails = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchQrDetails();
    _searchController.addListener(_onSearchChanged);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredQrDetails = qrDetails;
      } else {
        filteredQrDetails = qrDetails.where((item) {
          final qrNumber = (item["qr_number"] ?? '').toString().toLowerCase();
          return qrNumber.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchQrDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.agentItemList}${widget.type}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ItemListData $data');
        if (data['success'] == true && data['qr_details'] != null) {
          setState(() {
            qrDetails = data['qr_details'] ?? [];
            filteredQrDetails = qrDetails;
            isLoading = false;
          });
        }else{
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching QR details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.navyBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.navyBlue, AppColors.navyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title:  Text(
          '${widget.title}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [

        ],
      ),
      body: isLoading
          ? Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CupertinoActivityIndicator(
            radius: 25,
            color: AppColors.navyBlue,
          ),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Search Bar with Better Animation and UI
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by QR Number...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                        prefixIcon: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12.w),
                          child: Icon(
                            Icons.search,
                            color: AppColors.navyBlue,
                            size: 20.sp,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide(color: AppColors.navyBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.sp,
                          horizontal: 20.w,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${filteredQrDetails.length} results',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Item List Only
            Expanded(
              child: filteredQrDetails.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_outlined,
                        size: 80.sp,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      _searchController.text.isNotEmpty
                          ? "No QR details found for your search"
                          : "No QR details available",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Pull to refresh or try a different search",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: fetchQrDetails,
                color: AppColors.navyBlue,
                displacement: 20.h,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: filteredQrDetails.length,
                  itemBuilder: (context, index) {
                    final item = filteredQrDetails[index];
                    final status = item["qr_code"]?["status"] ?? 'N/A';
                    final statusColor = _getStatusColor(status);
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shadowColor: statusColor.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(color: AppColors.navyBlue, width: 1),
                        ),
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Enhanced Icon with Badge
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          statusColor.withOpacity(0.1),
                                          statusColor.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_2,
                                      color: AppColors.navyBlue,
                                      size: 22.sp,
                                    ),
                                  ),
                                  if (status == 'active')
                                    Positioned(
                                      right: 4.w,
                                      top: 4.h,
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 10.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [

                                        Expanded(
                                          child: Text(
                                            "QR No : ${item["qr_number"] ?? 'N/A'}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.sp,
                                              color: AppColors.navyBlue,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8.sp,
                                          color: statusColor,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Status: $status",
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}