import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class SimpleOrderTrackingScreen extends StatefulWidget {
  final String link;
  final String trackId;
  final String status;
  final String date;
  final String time;

  const SimpleOrderTrackingScreen({super.key, required this.link, required this.trackId, required this.status, required this.date, required this.time});

  @override
  State<SimpleOrderTrackingScreen> createState() => _SimpleOrderTrackingScreenState();
}

class _SimpleOrderTrackingScreenState extends State<SimpleOrderTrackingScreen> {
  // Sample data
  final String estimatedDelivery = "17 Oct 2024"; // 3 days
  // final String status = "Processing";
  final bool isDelivered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tracking Image
            _buildTrackingImage(),

            const SizedBox(height: 24),

            // Tracking ID Card
            _buildTrackingIdCard(),

            const SizedBox(height: 20),

            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 20),

            // Link Button
            _buildLinkButton(),

            const SizedBox(height: 20),

            // Additional Info
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image (Aap yahan network image ya asset use kar sakte hain)
            Container(
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navyBlue.withOpacity(0.8),
                    AppColors.navyBlue.withOpacity(0.8),
                  ],
                ),
                // border: Border.all(
                //   color: AppColors.navyBlue, // Border color
                //   width: 1, // Border width
                // ),
              ),
              child:  Lottie.asset('assets/bus.json'),

            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
                // border: Border.all(
                //   color: AppColors.navyBlue, // Border color
                //   width: 1, // Border width
                // ),
              ),

            ),
            Positioned(
              bottom: 5,
              left: 10,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Order is on the way!',
                    style:  TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Track your delivery in real-time',
                    style: TextStyle(color: AppColors.navyBlue.withOpacity(0.9),
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingIdCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:  AppColors.navyBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color:  AppColors.navyBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trackId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.trackId));

              // // Copy tracking ID
              // ScaffoldMessenger.of(context).showSnackBar(
              //    SnackBar(
              //     content: Text('Tracking ID ${widget.trackId} copied!'),
              //     duration: Duration(seconds: 1),
              //   ),
              // );
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = _getStatusColor(widget.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(widget.status),
                  color: statusColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timeline
          _buildTimeline(),

          const SizedBox(height: 16),

          // Delivery Date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      estimatedDelivery,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '3 days from order date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    bool isDelivered = widget.status == 'delivered'; // ya jo bhi aapka status field hai
    return Column(
      children: [
        _buildTimelineStep('Order Placed', widget.date, true),
        _buildTimelineConnector(),
        _buildTimelineStep('Processing', 'Today', true),
        _buildTimelineConnector(),
        _buildTimelineStep('Dispatched', '-', true),
        _buildTimelineConnector(),
        _buildTimelineStep('Delivered', '-', isDelivered),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String date, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey[300],
              // border: Border.all(
              //   color: isCompleted ? Colors.green : Colors.grey[400],
              //   width: 2,
              // ),
            ),
            child: isCompleted
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                if (date != '-') ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: 2,
      height: 20,
      color: Colors.grey[300],
    );
  }

  Widget _buildLinkButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          final Uri url = Uri.parse(widget.link);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
          }
        },
        icon: const Icon(Icons.link, color: Colors.white),
        label: const Text(
          'Track Order on Website',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.navyBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHelpButton('Support', Icons.support_agent),
              _buildHelpButton('Track', Icons.track_changes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton(String title, IconData icon) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon, color:  AppColors.navyBlue,),
          style: IconButton.styleFrom(
            backgroundColor:  AppColors.navyBlue.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'dispatched':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'processing':
        return Icons.schedule;
      case 'dispatched':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }
}