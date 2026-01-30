import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../TrackingScreen/tracking_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order History',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        primaryColor: AppColors.navyBlue,
        fontFamily: null,
      ),
      home: const OrderHistoryScreen(),
    );
  }
}

// =====================
// ✅ Order Model
// =====================
class Order {
  final int id;
  final int orderNo;
  final String customerName;
  final String address;
  final String? trackingUrl;
  final String? trackingNumber;
  final String? deliveredAt;
  final String contactNo;
  final String entryDate;
  final double totalAmount;
  final String amountInWords;
  final String status;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.address,
    required this.contactNo,
    required this.entryDate,
    required this.totalAmount,
    required this.amountInWords,
    required this.status,
    required this.orderDetails,
    this.trackingUrl,
    this.trackingNumber,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var details = (json['order_details'] as List? ?? []);
    List<OrderDetail> orderDetailsList =
    details.map((i) => OrderDetail.fromJson(i)).toList();

    return Order(
      id: json['id'],
      orderNo: json['order_no'],
      customerName: json['customer_name'],
      address: json['address'],
      trackingUrl: json['tracking_url'],
      trackingNumber: json['tracking_number'],
      deliveredAt: json['delivered_at'],
      contactNo: json['contact_no'],
      entryDate: json['entry_date'],
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      amountInWords: json['amount_in_words'] ?? '',
      status: (json['delivery_status'] ?? '').toString(),
      orderDetails: orderDetailsList,
    );
  }
}

// =====================
// ✅ OrderDetail Model
// =====================
class OrderDetail {
  final int id;
  final String itemName;
  final String branchName;
  final int quantity;
  final double mrp;
  final String totalGst;
  final String lineTotal;

  OrderDetail({
    required this.id,
    required this.itemName,
    required this.branchName,
    required this.quantity,
    required this.mrp,
    required this.totalGst,
    required this.lineTotal,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      itemName: json['item_name'],
      branchName: json['branch_name'],
      quantity: json['quantity'],
      mrp: double.tryParse(json['mrp'].toString()) ?? 0.0,
      totalGst: json['total_gst'].toString(),
      lineTotal: json['line_total'].toString(),
    );
  }
}

// =====================
// ✅ Main Screen (UI Mast)
// =====================
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiRoutes.getOrderHistory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            orders = (data['orders'] as List)
                .map((orderJson) => Order.fromJson(orderJson))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load orders');
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // =====================
  // ✅ UI BUILD
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.navyBlue,
        title: Text(
          'Order History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchOrders,
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(18.h),
          child: Container(
            height: 18.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F7FB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CupertinoActivityIndicator(
          radius: 18.r,
          color: AppColors.navyBlue,
        ),
      )
          : orders.isEmpty
          ? _emptyState()
          : RefreshIndicator(
        color: AppColors.navyBlue,
        onRefresh: fetchOrders,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 16.h),
          itemCount: orders.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _orderCard(order);
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 92.sp,
              width: 92.sp,
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 46.sp,
                color: AppColors.navyBlue.withOpacity(0.65),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'When you place an order, it will show up here with tracking & details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.3,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(Order order) {
    final status = (order.status).trim().toLowerCase();

    final statusUi = _statusUi(status);

    final hasTracking = (order.trackingUrl ?? '').isNotEmpty &&
        (order.trackingNumber ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: Colors.white,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              leading: _orderNoBadge(order.orderNo),
              title: Text(
                order.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5.sp,
                  color: const Color(0xFF111827),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        size: 14.sp, color: const Color(0xFF6B7280)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        order.entryDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: hasTracking
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimpleOrderTrackingScreen(
                            link: order.trackingUrl!,
                            trackId: order.trackingNumber!,
                            status: order.status,
                            date: order.entryDate.toString(),
                            time: (order.deliveredAt ?? '').toString(),
                          ),
                        ),
                      );
                    }
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Tracking information not available for this order.'),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    },
                    child: _statusPill(
                      label: order.status,
                      bg: statusUi.bg,
                      fg: statusUi.fg,
                      icon: statusUi.icon,
                      showTrackHint: hasTracking,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9CA3AF), size: 22.sp),
                ],
              ),
              children: [
                SizedBox(height: 6.h),

                // Quick info row
                Row(
                  children: [
                    Expanded(
                      child: _infoMini(
                        icon: Icons.account_balance_wallet_rounded,
                        label: "Total",
                        value: "₹${order.totalAmount}",
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _infoMini(
                        icon: Icons.phone_rounded,
                        label: "Contact",
                        value: order.contactNo,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                _infoLine(
                  icon: Icons.location_on_rounded,
                  title: "Address",
                  value: order.address,
                ),
                SizedBox(height: 8.h),
                _infoLine(
                  icon: Icons.text_snippet_rounded,
                  title: "Amount in Words",
                  value: order.amountInWords.isEmpty
                      ? "-"
                      : order.amountInWords,
                ),

                SizedBox(height: 12.h),

                // Items header
                Row(
                  children: [
                    Container(
                      height: 28.h,
                      width: 28.h,
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.inventory_2_rounded,
                          size: 16.sp, color: AppColors.navyBlue),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Items (${order.orderDetails.length})",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5.sp,
                        color: AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Items list
                ...order.orderDetails.map((d) => _itemCard(d)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderNoBadge(int orderNo) {
    return Container(
      height: 44.sp,
      width: 44.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          colors: [
            AppColors.navyBlue,
            AppColors.navyBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        "#$orderNo",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10.5.sp,
          height: 1.05,
        ),
      ),
    );
  }

  Widget _statusPill({
    required String label,
    required Color bg,
    required Color fg,
    required IconData icon,
    bool showTrackHint = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: fg),
          SizedBox(width: 6.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: 10.8.sp,
              letterSpacing: 0.3,
            ),
          ),
          if (showTrackHint) ...[
            SizedBox(width: 6.w),
            Icon(Icons.open_in_new_rounded, size: 13.sp, color: fg),
          ]
        ],
      ),
    );
  }

  Widget _infoMini({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 34.sp,
            width: 34.sp,
            decoration: BoxDecoration(
              color: AppColors.navyBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.navyBlue),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34.sp,
            width: 34.sp,
            decoration: BoxDecoration(
              color: AppColors.navyBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.navyBlue),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value.isEmpty ? "-" : value,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.25,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(OrderDetail d) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34.sp,
                width: 34.sp,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.navyBlue.withOpacity(0.95),
                      AppColors.navyBlue.withOpacity(0.70),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.shopping_cart_rounded,
                    size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  d.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.2.sp,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _kvRow(Icons.store_rounded, "Branch", d.branchName),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(child: _miniChip(Icons.numbers_rounded, "Qty", "${d.quantity}")),
              SizedBox(width: 8.w),
              Expanded(child: _miniChip(Icons.currency_rupee_rounded, "MRP", "${d.mrp}")),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _miniChip(Icons.receipt_long_rounded, "GST", "₹${d.totalGst}")),
              SizedBox(width: 8.w),
              Expanded(child: _miniChip(Icons.payments_rounded, "Total", "₹${d.lineTotal}")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvRow(IconData icon, String k, String v) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 6.w),
        Text(
          "$k: ",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF374151),
          ),
        ),
        Expanded(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: AppColors.navyBlue),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              "$label: $value",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.8.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusUi _statusUi(String status) {
    // tune these mappings as per your backend values
    if (status == 'delivered' || status == 'active') {
      return _StatusUi(
        bg: const Color(0xFFE9F9EF),
        fg: const Color(0xFF16A34A),
        icon: Icons.check_circle_rounded,
      );
    }
    if (status == 'pending' || status == 'processing') {
      return _StatusUi(
        bg: const Color(0xFFFFF4E6),
        fg: const Color(0xFFF59E0B),
        icon: Icons.timelapse_rounded,
      );
    }
    if (status == 'cancelled' || status == 'canceled') {
      return _StatusUi(
        bg: const Color(0xFFFFEBEE),
        fg: const Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
      );
    }
    return _StatusUi(
      bg: const Color(0xFFEFF6FF),
      fg: const Color(0xFF2563EB),
      icon: Icons.local_shipping_rounded,
    );
  }
}

class _StatusUi {
  final Color bg;
  final Color fg;
  final IconData icon;
  _StatusUi({required this.bg, required this.fg, required this.icon});
}
