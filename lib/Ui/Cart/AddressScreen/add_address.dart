import 'dart:async';

import 'package:firstcallingapp/BaseUrl/baseurl.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  List<Map<String, dynamic>> addresses = [];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  bool _isPincodeValid = true;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedAddressIndex;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    _loadSelectedAddress();

    _addressController.addListener(_updateButtonState);
    _pincodeController.addListener(_updateButtonState);
    _cityController.addListener(_updateButtonState);
    _stateController.addListener(_updateButtonState);
  }
  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
  // Load the saved selected address index from SharedPreferences
  Future<void> _loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddressId = prefs.getString('selected_address_id');
    if (savedAddressId != null && addresses.isNotEmpty) {
      setState(() {
        _selectedAddressIndex = addresses.indexWhere((address) => address['id'].toString() == savedAddressId);
      });
    }
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(ApiRoutes.getAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            addresses = List<Map<String, dynamic>>.from(data['address']);
          });
          await _loadSelectedAddress();
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to fetch addresses';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch addresses: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching addresses: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCityStateFromPincode(
      String pincode,
      Function setModalState,
      ) async {
    if (pincode.length != 6) return;

    setModalState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("https://api.postalpincode.in/pincode/$pincode"),
      );

      final data = jsonDecode(response.body);

      if (data[0]["Status"] == "Success") {
        final postOffice = data[0]["PostOffice"][0];

        setModalState(() {
          _cityController.text = postOffice["District"] ?? "";
          _stateController.text = postOffice["State"] ?? "";
          _isPincodeValid = true;
        });
      } else {
        setModalState(() {
          _isPincodeValid = false;
          _cityController.clear();
          _stateController.clear();
        });
      }
    } catch (e) {
      setModalState(() {
        _errorMessage = "Failed to fetch location";
      });
    } finally {
      setModalState(() {
        _isLoading = false;
      });
    }
  }
  void _onPincodeChanged(String value, Function setModalState) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length == 6) {
        _fetchCityStateFromPincode(value, setModalState);
      } else {
        setModalState(() {
          _cityController.clear();
          _stateController.clear();
        });
      }
    });
  }

  Future<void> _addAddress(String address) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(ApiRoutes.addAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            addresses.add({
              'id': data['address_id'],
              'address': address,
            });
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to add address';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to add address: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding address: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(String addressId, int index) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('${ApiRoutes.deleteAddress}/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            addresses.removeAt(index);
            // Check if the deleted address was the selected one
            if (_selectedAddressIndex == index) {
              _selectedAddressIndex = null;
              // Clear the saved address data from SharedPreferences
              prefs.remove('selected_address_id');
              prefs.remove('selected_address');
              // Clear cart-related address data
              prefs.remove('cart_selected_address'); // Adjust key if different
            } else if (_selectedAddressIndex != null && _selectedAddressIndex! > index) {
              _selectedAddressIndex = _selectedAddressIndex! - 1;
            }
            // If no addresses remain, clear address data to ensure cart reflects this
            if (addresses.isEmpty) {
              _selectedAddressIndex = null;
              prefs.remove('selected_address_id');
              prefs.remove('selected_address');
              prefs.remove('cart_selected_address'); // Adjust key if different
            }
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to delete address';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to delete address: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting address: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showBottomSheet() {
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _pincodeController.clear();

    _isPincodeValid = true;
    _isLoading = false;
    _errorMessage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isFormValid() {
              return _addressController.text.trim().isNotEmpty &&
                  _pincodeController.text.length == 6 &&
                  _cityController.text.trim().isNotEmpty &&
                  _stateController.text.trim().isNotEmpty &&
                  !_isLoading &&
                  _isPincodeValid;
            }

            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add New Address",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!)),
                              ],
                            ),
                          ),

                        _buildTextField(
                          controller: _addressController,
                          label: "Full Address",
                          icon: Icons.home_outlined,
                          maxLines: 3,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _pincodeController,
                          label: "Pincode",
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _onPincodeChanged(value, setModalState);
                            setModalState(() {});
                          },
                          suffixIcon: _isLoading
                              ? Padding(
                            padding: EdgeInsets.all(12.sp),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                          )
                              : null,
                          errorText:
                          !_isPincodeValid ? "Enter valid 6 digit pincode" : null,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _cityController,
                          label: "City",
                          icon: Icons.location_city_outlined,
                          readOnly: true,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _stateController,
                          label: "State",
                          icon: Icons.map_outlined,
                          readOnly: true,
                          onChanged: (_) => setModalState(() {}),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isFormValid()
                                  ? AppColors.navyBlue
                                  : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isFormValid()
                                ? () {
                              _addAddress(
                                "${_addressController.text.trim()}, "
                                    "${_cityController.text.trim()}, "
                                    "${_stateController.text.trim()}, "
                                    "${_pincodeController.text.trim()}",
                              );
                              Navigator.pop(context);
                            }
                                : null,
                            child: Text(
                              "Save Address",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white

                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    String? errorText,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String addressId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          "Delete Address",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this address? If this address is selected or no addresses remain, it will also be removed from the cart.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteAddress(addressId, index);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Address",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 60.sp),
        child: FloatingActionButton.extended(
          onPressed: _showBottomSheet,
          icon: Icon(Icons.add_circle_outline, size: 20.sp),
          label: Text(
            "Add",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.navyBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.shade700,
                  strokeWidth: 3,
                ),
              )
                  : addresses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No addresses added yet!",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap below to add a new address.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 5.sp),
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final displayAddress = address['city'] != null &&
                      address['state'] != null &&
                      address['pincode'] != null
                      ? "${address['address']}, ${address['city']}, ${address['state']} - ${address['pincode']}"
                      : address['address'];
                  return FadeInAnimation(
                    delay: Duration(milliseconds: 100 * index),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _selectedAddressIndex = index;
                            });
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0.sp, vertical: 5.sp),
                            leading: Radio<int>(
                              value: index,
                              groupValue: _selectedAddressIndex,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddressIndex = value;
                                });
                              },
                              activeColor: AppColors.navyBlue,
                            ),
                            title: Text(
                              displayAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade600,
                                size: 24,
                              ),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    address['id'].toString(), index);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.colorWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (addresses.isNotEmpty && _selectedAddressIndex != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _selectedAddressIndex != null
                            ? AppColors.navyBlue
                            : Colors.green.shade200,
                        foregroundColor: Colors.white,
                        elevation: _selectedAddressIndex != null ? 8 : 0,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      onPressed: _selectedAddressIndex != null
                          ? () async {
                        final selectedAddress = addresses[_selectedAddressIndex!];
                        final displayAddress = selectedAddress['city'] != null &&
                            selectedAddress['state'] != null &&
                            selectedAddress['pincode'] != null
                            ? "${selectedAddress['address']}, ${selectedAddress['city']}, ${selectedAddress['state']} - ${selectedAddress['pincode']}"
                            : selectedAddress['address'];
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selected_address', displayAddress);
                        await prefs.setString('selected_address_id', selectedAddress['id'].toString());
                        Navigator.pop(context, displayAddress);
                      }
                          : null,
                      child: Text(
                        "Confirm Selection",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
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
}

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInAnimation({required this.child, required this.delay, super.key});

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}