import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart'; // agar tum use karte ho, warna hata do
import 'package:firstcallingapp/Utils/color.dart';     // tumhara AppColors
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;
  String _error = '';
  List<AppNotification> _items = [];


  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ yaha tumhare project ka token key jo bhi hai wo set kar do
    // common keys: "token", "access_token", "user_token"
    return prefs.getString("token") ?? prefs.getString("access_token");
  }

  Future<void> fetchNotifications({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _error = "Token not found. Please login again.";
        });
        return;
      }

      final res = await http.get(
        Uri.parse(ApiRoutes.getNotifications),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        final List list = (body["data"] ?? []) as List;

        setState(() {
          _items = list.map((e) => AppNotification.fromJson(e)).toList();
          _loading = false;
          _error = '';
        });
      } else {
        setState(() {
          _loading = false;
          _error = body["message"]?.toString() ?? "Something went wrong";
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Network error: $e";
      });
    }
  }

  void _markReadLocal(int id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      setState(() {
        _items[idx] = _items[idx].copyWith(isRead: 1);
      });
    }
  }

  int get _unreadCount => _items.where((e) => e.isRead == 0).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.navyBlue, // apna color
        title: Row(
          children: [
            Text(
              "Notifications",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (_unreadCount > 0) _UnreadChip(count: _unreadCount),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchNotifications(showLoader: false),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView.builder(
        itemCount: 8,
        padding: EdgeInsets.all(12.sp),
        itemBuilder: (_, __) => const _ShimmerTile(),
      );
    }

    if (_error.isNotEmpty) {
      return ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          _ErrorCard(
            message: _error,
            onRetry: () => fetchNotifications(),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        padding: EdgeInsets.all(16.sp),
        children: const [
          _EmptyState(),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.sp),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final n = _items[index];
        return _NotificationTile(
          n: n,
          onTap: () {
            _markReadLocal(n.id);
            _openDetailSheet(n);
          },
        );
      },
    );
  }

  void _openDetailSheet(AppNotification n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationDetailSheet(n: n),
    );
  }
}

// ===================== MODEL =====================

class AppNotification {
  final int id;
  final String title;
  final String message;
  final int isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json["id"] ?? 0) is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      title: (json["title"] ?? "").toString(),
      message: (json["message"] ?? "").toString(),
      isRead: (json["is_read"] ?? 0) is int ? json["is_read"] : int.tryParse("${json["is_read"]}") ?? 0,
      createdAt: (json["created_at"] ?? "").toString(),
    );
  }

  AppNotification copyWith({int? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

// ===================== UI WIDGETS =====================

class _UnreadChip extends StatelessWidget {
  final int count;
  const _UnreadChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        "$count Unread",
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;

  const _NotificationTile({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = n.isRead == 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isUnread ? Colors.blue.withOpacity(0.22) : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeadingIcon(isUnread: isUnread),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title.isEmpty ? "Notification" : n.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isUnread) _Dot(),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    n.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14.sp, color: Colors.black38),
                      SizedBox(width: 6.w),
                      Text(
                        n.createdAt,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: isUnread ? Colors.blue.withOpacity(0.10) : Colors.grey.withOpacity(0.12),
                        ),
                        child: Text(
                          isUnread ? "NEW" : "READ",
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: isUnread ? Colors.blue : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final bool isUnread;
  const _LeadingIcon({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.sp,
      width: 44.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          colors: isUnread
              ? [Colors.blue.shade400, Colors.indigo.shade500]
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
        color: Colors.white,
        size: 22.sp,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.sp,
      width: 8.sp,
      margin: EdgeInsets.only(left: 8.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.redAccent,
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final AppNotification n;
  const _NotificationDetailSheet({required this.n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.sp,
        right: 16.sp,
        top: 12.sp,
        bottom: 16.sp + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(Icons.notifications_rounded, color: Colors.black87, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  n.title.isEmpty ? "Notification" : n.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              n.message,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16.sp, color: Colors.black45),
              SizedBox(width: 6.w),
              Text(
                n.createdAt,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
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

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 42.sp, color: Colors.redAccent),
          SizedBox(height: 10.h),
          Text(
            "Oops!",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_off_rounded, size: 52.sp, color: Colors.black26),
          SizedBox(height: 12.h),
          Text(
            "No notifications",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Jab koi update aayega, yaha show ho jayega.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    // simple skeleton (no package needed)
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            height: 44.sp,
            width: 44.sp,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12.h, width: 160.w, color: Colors.grey.shade200),
                SizedBox(height: 8.h),
                Container(height: 10.h, width: double.infinity, color: Colors.grey.shade200),
                SizedBox(height: 6.h),
                Container(height: 10.h, width: 220.w, color: Colors.grey.shade200),
                SizedBox(height: 10.h),
                Container(height: 10.h, width: 120.w, color: Colors.grey.shade200),
              ],
            ),
          )
        ],
      ),
    );
  }
}
