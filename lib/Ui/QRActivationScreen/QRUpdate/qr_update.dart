import 'dart:convert';
import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Utils/color.dart';



class UpdateScreen extends StatefulWidget {
  final Map qrData;
  final String qrNumber;
  const UpdateScreen({super.key, required this.qrData, required this.qrNumber,}); // Make token required

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  // Form controllers to track changes
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _contactNo1Controller;
  late TextEditingController _contactNo2Controller;

  // Family members controllers
  late TextEditingController _family1NameController;
  late TextEditingController _family1RelationController;
  late TextEditingController _family1NoController;
  late TextEditingController _family2NameController;
  late TextEditingController _family2RelationController;
  late TextEditingController _family2NoController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial values
    _nameController = TextEditingController(text: widget.qrData['name'] ?? 'N/A');
    _dobController = TextEditingController(text: widget.qrData['dob'] ?? 'N/A');
    _addressController = TextEditingController(text: widget.qrData['address'] ?? 'N/A');
    _genderController = TextEditingController(text: widget.qrData['gender'] ?? 'N/A');
    _emailController = TextEditingController(text: widget.qrData['email'] ?? 'N/A');
    _contactNo1Controller = TextEditingController(text: widget.qrData['contact_no1'] ?? 'N/A');
    _contactNo2Controller = TextEditingController(text: widget.qrData['contact_no2'] ?? 'N/A');

    _family1NameController = TextEditingController(text: widget.qrData['family_member1_name'] ?? 'N/A');
    _family1RelationController = TextEditingController(text: widget.qrData['family_member1_relation'] ?? 'N/A');
    _family1NoController = TextEditingController(text: widget.qrData['family_member1_no'] ?? 'N/A');

    _family2NameController = TextEditingController(text: widget.qrData['family_member2_name'] ?? 'N/A');
    _family2RelationController = TextEditingController(text: widget.qrData['family_member2_relation'] ?? 'N/A');
    _family2NoController = TextEditingController(text: widget.qrData['family_member2_no'] ?? 'N/A');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _contactNo1Controller.dispose();
    _contactNo2Controller.dispose();

    _family1NameController.dispose();
    _family1RelationController.dispose();
    _family1NoController.dispose();
    _family2NameController.dispose();
    _family2RelationController.dispose();
    _family2NoController.dispose();
    super.dispose();
  }

  // Function to collect all data and hit API with token
  Future<void> _updateData() async {
    // Collect updated data into a Map
    Map<String, dynamic> updateData = {
      'qr_number': widget.qrNumber,
      'name': _nameController.text,
      // 'dob': _dobController.text,
      'address': _addressController.text,
      'gender': _genderController.text,
      'email': _emailController.text,
      'contact_no1': _contactNo1Controller.text,
      'contact_no2': _contactNo2Controller.text,
      'family_member1_name': _family1NameController.text,
      'family_member1_relation': _family1RelationController.text,
      'family_member1_no': _family1NoController.text,
      'family_member2_name': _family2NameController.text,
      'family_member2_relation': _family2RelationController.text,
      'family_member2_no': _family2NoController.text,
    };
print('Update Data $updateData');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(ApiRoutes.qrCodeUpdate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Added Bearer token for auth
          // Add other headers if needed
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        showSuccessPopup(context);
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Click outside se close na ho
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Container(
            // Height remove kar di – auto size ho jayega
            padding: EdgeInsets.all(24), // Padding thoda badhaya for breathing room
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Yeh add kiya – compact size ke liye
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon with animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'QR Update Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your QR code has been updated successfully.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24), // Thoda kam kiya for balance
                // Close Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
                    // );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          " QR Code Update",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.colorWhite,
        elevation: 0,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 00),
              _buildSectionTitle("Personal Information"),
              _buildTextField("Name", _nameController),
              _buildTextField("Address", _addressController),
              _buildTextField("Gender", _genderController),
              _buildTextField("Email", _emailController),
              _buildTextField("Contact No 1", _contactNo1Controller),
              _buildTextField("Contact No 2", _contactNo2Controller),
              const SizedBox(height: 20),
              _buildSectionTitle("Family Members"),
              _buildFamilyMemberSection("Family Member 1", 1),
              const SizedBox(height: 15),
              _buildFamilyMemberSection("Family Member 2", 2),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _updateData, // Calls API with token
                  label: Text("UPDATE", style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: AppColors.colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: AppColors.navyBlue,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, // Use controller instead of initialValue
            decoration: InputDecoration(
              prefixIcon: Icon(
                _getIconForLabel(label), // Helper to get icon based on label
                color: AppColors.navyBlue.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: AppColors.colorWhite,
              contentPadding: const EdgeInsets.all(15),
            ),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.colorBlack,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get icon based on label (you can expand this)
  IconData _getIconForLabel(String label) {
    switch (label) {
      case "Name":
        return Icons.person;
      case "Date of Birth":
        return Icons.cake;
      case "Address":
        return Icons.location_on;
      case "Gender":
        return Icons.wc;
      case "Email":
        return Icons.email;
      case "Contact No 1":
      case "Contact No 2":
        return Icons.phone;
      default:
        return Icons.info;
    }
  }

  Widget _buildFamilyMemberSection(String title, int memberNumber) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            _buildSmallTextField("Name", memberNumber == 1 ? _family1NameController : _family2NameController),
            _buildSmallTextField("Relation", memberNumber == 1 ? _family1RelationController : _family2RelationController),
            _buildSmallTextField("Contact No", memberNumber == 1 ? _family1NoController : _family2NoController),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.navyBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller, // Use controller
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navyBlue.withOpacity(0.2)),
                ),
                filled: true,
                fillColor: AppColors.colorWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.colorBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}