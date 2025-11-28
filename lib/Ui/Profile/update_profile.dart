import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../BaseUrl/baseurl.dart';
import '../../Utils/color.dart';

class ProfileUpdatePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;
  const ProfileUpdatePage({super.key,  this.onProfileUpdated,});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController addressController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  File? file;
  final picker = ImagePicker();
  bool _isLoading = false;
  String photoUrl = '';
  String userMobile = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  void dispose() {
    addressController.dispose();
    pinController.dispose();
    cityController.dispose();
    nameController.dispose();
    emailController.dispose();
    stateController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse(ApiRoutes.getProfile);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        setState(() {
          nameController.text = jsonData['name'] ?? '';
          emailController.text = jsonData['email'] ?? '';
          pinController.text = jsonData['pin']?.toString() ?? '';
          addressController.text = jsonData['address'] ?? '';
          cityController.text = jsonData['district'] ?? '';
          userMobile = jsonData['contact'] ?? '';
          photoUrl = jsonData['picture_data'] ?? '';
          stateController.text = jsonData['state'] ?? '';
        });
        // Save updated profile data to SharedPreferences for drawer
        // await _saveProfileToPrefs(jsonData);
      } else {
        _showToast("Failed to load profile data", Colors.red);
      }
    } catch (e) {
      _showToast("Something went wrong: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameController.text ?? '');
    await prefs.setString('user_photo_url', photoUrl ?? '');
  }

  Future<void> _updateProfile(File? file) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _showLoadingDialog();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final apiUrl = ApiRoutes.getUpdateProfile;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields.addAll({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'district': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pin': pinController.text.trim(),
      });
      request.headers['Authorization'] = 'Bearer $token';
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body)['user'];
        // Update local state with new data
        setState(() {
        });
        // Save to SharedPreferences
        await _saveProfileToPrefs();
        // Notify parent (drawer) via callback
        widget.onProfileUpdated?.call();
        _showToast("Profile updated successfully", Colors.green);
        Navigator.pop(context); // Close loading dialog
        // Optionally, navigate back or refresh
      } else {
        _showToast("Failed to update profile: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showToast("Error updating profile: $e", Colors.red);
    } finally {
      if (mounted) {
        Navigator.pop(context); // Ensure dialog is closed
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>  Center(
        child: CupertinoActivityIndicator(
          radius: 25,
          color: AppColors.navyBlue,
        ),

      ),
    );
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.sp,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _showPicker({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Text(
                'Select Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading:  Icon(Icons.photo_library, color: AppColors.navyBlue),
              title: Text(
                'Photo Library',
                style: GoogleFonts.poppins(fontSize: 16.sp),
              ),
              onTap: () {
                getImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:  Icon(Icons.photo_camera, color: AppColors.navyBlue),
              title: Text(
                'Camera',
                style: GoogleFonts.poppins(fontSize: 16.sp),
              ),
              onTap: () {
                getImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource img) async {
    setState(() => _isLoading = true);
    try {
      XFile? pickedFile = await picker.pickImage(
        source: img,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => file = File(pickedFile.path));
        _showToast("Image selected successfully", Colors.green);
      }
    } catch (e) {
      _showToast("Image selection error: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your pin code';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Pin code must be 6 digits';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your city';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your state';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : () => _updateProfile(file),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child:CupertinoActivityIndicator(
        radius: 25,
        color: AppColors.navyBlue,
      ),
      )
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Section
              Card(
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:  EdgeInsets.all(20.sp),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Hero(
                            tag: 'profile_image',
                            child: CircleAvatar(
                              radius: 60.r,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: file != null
                                    ? Image.file(
                                  file!,
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildProfileIcon(),
                                )
                                    : (photoUrl.isNotEmpty
                                    ? Image.network(
                                  photoUrl,
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildProfileIcon(),
                                )
                                    : _buildProfileIcon()),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _showPicker(context: context),
                              child: CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor: AppColors.navyBlue,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              // Form Fields Section
              Card(
                color: Colors.white,
                elevation: 4,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    children: [
                      _buildFieldRow(
                        label: 'Personal Info',
                        icon: Icons.person_outline,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextFormField(
                        label: 'Full Name',
                        controller: nameController,
                        icon: Icons.account_circle_outlined,
                        validator: _validateName,
                        color: Colors.blue,
                      ),
                      _buildTextFormField(
                        label: 'Email ID',
                        controller: emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        color: Colors.green,
                      ),
                      _buildReadOnlyField(
                        label: 'Contact No',
                        value: '+91 $userMobile',
                        icon: Icons.call_outlined,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 20.h),
                      _buildFieldRow(
                        label: 'Address Info',
                        icon: Icons.location_on_outlined,
                        color: Colors.purple,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextFormField(
                        label: 'Address',
                        controller: addressController,
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        validator: _validateAddress,
                        color: Colors.purple,
                      ),
                      _buildTextFormField(
                        label: 'City',
                        controller: cityController,
                        icon: Icons.location_city_outlined,
                        validator: _validateCity,
                        color: Colors.indigo,
                      ),
                      _buildTextFormField(
                        label: 'State',
                        controller: stateController,
                        icon: Icons.map_outlined,
                        validator: _validateState,
                        color: Colors.teal,
                      ),
                      _buildTextFormField(
                        label: 'Pin Code',
                        controller: pinController,
                        icon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validatePin,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _updateProfile(file),
        backgroundColor: AppColors.navyBlue,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          'Save Changes',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildFieldRow({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: color.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: color.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        style: GoogleFonts.poppins(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        enabled: false,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: color.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: color.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}