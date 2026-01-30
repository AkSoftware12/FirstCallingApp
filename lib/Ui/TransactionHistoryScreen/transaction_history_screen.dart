import 'dart:convert';

import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<PaymentTxn> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString("token");
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _getToken();

      if (token == null || token.trim().isEmpty) {
        setState(() {
          _loading = false;
          _error = "Token missing. Please login again.";
        });
        return;
      }

      final res = await http.get(
        Uri.parse(ApiRoutes.getUserPayment),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final success = decoded["success"] == true;

        if (!success) {
          setState(() {
            _loading = false;
            _error = decoded["message"]?.toString() ?? "Something went wrong.";
          });
          return;
        }

        final data = (decoded["data"] as List<dynamic>? ?? []);
        final list = data
            .map((e) => PaymentTxn.fromJson(e as Map<String, dynamic>))
            .toList();

        // newest first (id desc)
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

        setState(() {
          _items = list;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = "API Error: ${res.statusCode}\n${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Network/Parse error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ScreenUtil init should be done in main.dart (example below)
    final bg1 = const Color(0xFF080777);
    final bg2 = const Color(0xFF0A85FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF080777),
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 42.sp,
                width: 42.sp,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "Transaction History",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              onTap: _fetchPayments,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 42.sp,
                width: 42.sp,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),

        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPayments,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        itemCount: 8,
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        children: [
          Container(
            padding: EdgeInsets.all(14.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Something went wrong",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    height: 1.35,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: _fetchPayments,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        children: [
          Container(
            padding: EdgeInsets.all(18.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 44.sp,
                  color: Colors.black54,
                ),
                SizedBox(height: 10.h),
                Text(
                  "No transactions",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),

              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
      itemCount: _items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, index) => _TxnCard(txn: _items[index]),
    );
  }
}

class _TxnCard extends StatelessWidget {
  final PaymentTxn txn;

  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isSuccess = txn.isSuccess;
    final statusColor = isSuccess
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    final amountText = txn.amountDisplay;
    final dateText = txn.prettyDate;
    final method = (txn.paymentMethod ?? "-").toUpperCase();

    final orderId = txn.orderId;
    final paymentId = txn.paymentId;

    final failure = txn.failureHuman;

    return Container(
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(width: 1,color: Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            children: [
              Container(
                height: 42.sp,
                width: 42.sp,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: statusColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹ $amountText",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      dateText,
                      style: GoogleFonts.poppins(
                        fontSize: 12.2.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: statusColor.withOpacity(0.28)),
                ),
                child: Text(
                  txn.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // method row
          Row(
            children: [
              _miniPill(icon: Icons.payments_rounded, text: method),
              SizedBox(width: 8.w),
              _miniPill(
                icon: Icons.currency_rupee_rounded,
                text: (txn.currency ?? "INR").toUpperCase(),
              ),

            ],
          ),

          // ids
          SizedBox(height: 10.h),
          if ((orderId ?? "").isNotEmpty) _kv("Order ID :", orderId!),
          if ((paymentId ?? "").isNotEmpty) _kv("Payment ID :", paymentId!),

          // // failure reason
          // if (!isSuccess && failure != null && failure.trim().isNotEmpty) ...[
          //   SizedBox(height: 10.h),
          //   Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.all(12.sp),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFDC2626).withOpacity(0.06),
          //       borderRadius: BorderRadius.circular(14.r),
          //       border: Border.all(
          //         color: const Color(0xFFDC2626).withOpacity(0.16),
          //       ),
          //     ),
          //     child: Text(
          //       failure,
          //       style: GoogleFonts.poppins(
          //         fontSize: 12.2.sp,
          //         height: 1.35,
          //         color: Colors.black87,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85.w,
            child: Text(
              k,
              style: GoogleFonts.poppins(
                fontSize: 12.2.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPill({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.black54),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 42.sp,
                width: 42.sp,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 10.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                height: 26.h,
                width: 70.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentTxn {
  final int? id;
  final DateTime? txnDate;
  final int? userId;
  final String? orderId;
  final String? paymentId;
  final String? amount;
  final String? currency;
  final String? status;
  final String? paymentMethod;
  final String? errorCode;
  final String? errorDescription;
  final String? failureReason; // may be JSON string
  final String? signature;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentTxn({
    required this.id,
    required this.txnDate,
    required this.userId,
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.errorCode,
    required this.errorDescription,
    required this.failureReason,
    required this.signature,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentTxn.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return PaymentTxn(
      id: (json["id"] is int)
          ? json["id"] as int
          : int.tryParse(json["id"]?.toString() ?? ""),
      txnDate: parseDate(json["txn_date"]),
      userId: (json["user_id"] is int)
          ? json["user_id"] as int
          : int.tryParse(json["user_id"]?.toString() ?? ""),
      orderId: json["order_id"]?.toString(),
      paymentId: json["payment_id"]?.toString(),
      amount: json["amount"]?.toString(),
      currency: json["currency"]?.toString(),
      status: json["status"]?.toString(),
      paymentMethod: json["payment_method"]?.toString(),
      errorCode: json["error_code"]?.toString(),
      errorDescription: json["error_description"]?.toString(),
      failureReason: json["failure_reason"]?.toString(),
      signature: json["signature"]?.toString(),
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
    );
  }

  bool get isSuccess {
    final s = (status ?? "").toLowerCase().trim();
    return s == "success" || s == "paid" || s == "captured";
  }

  String get statusLabel {
    final s = (status ?? "").trim();
    if (s.isEmpty) return "-";
    // normalize
    final lower = s.toLowerCase();
    if (lower == "failed" || lower == "failure") return "FAILED";
    if (lower == "success") return "SUCCESS";
    return s.toUpperCase();
  }

  String get amountDisplay {
    if (amount == null) return "-";
    final v = double.tryParse(amount!.toString()) ?? 0;
    // 1246.0 => 1,246 ; 124600 => 124,600
    return NumberFormat("#,##0.##", "en_IN").format(v);
  }

  String get prettyDate {
    final d = txnDate ?? createdAt;
    if (d == null) return "-";
    return DateFormat("dd MMM yyyy, hh:mm a").format(d);
  }

  /// Convert failure_reason JSON-string into clean line
  String? get failureHuman {
    if (failureReason == null || failureReason!.trim().isEmpty) {
      // fallback to error_description if exists
      if (errorDescription != null &&
          errorDescription!.trim().isNotEmpty &&
          errorDescription != "undefined") {
        return "Reason: ${errorDescription!}";
      }
      return null;
    }

    // sometimes it is a JSON string
    final raw = failureReason!.trim();

    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        final reason = map["reason"]?.toString();
        final step = map["step"]?.toString();
        final code = map["code"]?.toString();
        final desc = map["description"]?.toString();

        final parts = <String>[];
        if (reason != null && reason.isNotEmpty) parts.add("Reason: $reason");
        if (step != null && step.isNotEmpty) parts.add("Step: $step");
        if (code != null && code.isNotEmpty) parts.add("Code: $code");
        if (desc != null && desc.isNotEmpty && desc != "undefined")
          parts.add("Desc: $desc");

        if (parts.isNotEmpty) return parts.join("  •  ");
      }
    } catch (_) {
      // not JSON => show raw but remove long braces if needed
    }

    // clean fallback
    if (raw.length > 250) {
      return "${raw.substring(0, 250)}...";
    }
    return raw;
  }
}
