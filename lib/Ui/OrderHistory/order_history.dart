import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order History',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      home: const OrderHistoryScreen(),
    );
  }
}

// Model for Order (unchanged)
class Order {
  final int id;
  final int orderNo;
  final String customerName;
  final String address;
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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var details = json['order_details'] as List;
    List<OrderDetail> orderDetailsList =
    details.map((i) => OrderDetail.fromJson(i)).toList();

    return Order(
      id: json['id'],
      orderNo: json['order_no'],
      customerName: json['customer_name'],
      address: json['address'],
      contactNo: json['contact_no'],
      entryDate: json['entry_date'],
      totalAmount: json['total_amount'].toDouble(),
      amountInWords: json['amount_in_words'],
      status: json['status'],
      orderDetails: orderDetailsList,
    );
  }
}

// Model for OrderDetail (unchanged)
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
      mrp: json['mrp'].toDouble(),
      totalGst: json['total_gst'].toString(),
      lineTotal: json['line_total'].toString(),
    );
  }
}

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
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Token$token');
      final response = await http.get(
        Uri.parse(ApiRoutes.getOrderHistory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Handle dropdown actions
  void _handleOrderAction(String? action, Order order) {
    if (action == null) return;
    switch (action) {
      case 'View Details':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing details for Order #${order.orderNo}')),
        );
        break;
      case 'Reorder':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reordering Order #${order.orderNo}')),
        );
        break;
      case 'Cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancelling Order #${order.orderNo}')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title:  Text('Order History',style: TextStyle(color: Colors.white,fontSize: 16.sp),),
        centerTitle: true,
        backgroundColor: AppColors.navyBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: isLoading
          ?  Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
        ),
      )
          : orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.navyBlue,
                  child: Text(
                    '#${order.orderNo}',
                    style:  TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  order.customerName,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  order.entryDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        order.status,
                        style: TextStyle(
                          color: order.status == 'Delivered' || order.status == 'Active'
                              ? Colors.green
                              : order.status == 'Pending'
                              ? Colors.orange
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: order.status == 'Delivered' || order.status == 'Active'
                          ? Colors.green.shade100
                          : order.status == 'Pending'
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding:  EdgeInsets.all(10.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.location_on, 'Address', order.address),
                        _buildInfoRow(Icons.phone, 'Contact', order.contactNo),
                        _buildInfoRow(Icons.account_balance_wallet, 'Total', '₹${order.totalAmount}'),
                        _buildInfoRow(Icons.text_fields, 'Amount in Words', order.amountInWords),
                         SizedBox(height: 10.sp),
                        Text(
                          'Items',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                         SizedBox(height: 5.sp),
                        ...order.orderDetails.map((detail) => Card(
                          elevation: 2,
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12.0),
                            title: Text(
                              detail.itemName,
                              style:  TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Branch: ${detail.branchName}'),
                                Text('Qty: ${detail.quantity}'),
                                Text('MRP: ₹${detail.mrp}'),
                                Text('GST: ₹${detail.totalGst}'),
                                Text('Total: ₹${detail.lineTotal}'),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.navyBlue),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}