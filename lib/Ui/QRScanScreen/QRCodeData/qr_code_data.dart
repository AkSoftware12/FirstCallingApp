import 'dart:convert';
import 'package:firstcallingapp/Ui/QRScanScreen/QRCodeData/video_recording.dart';
import 'package:firstcallingapp/Utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../../BaseUrl/baseurl.dart';



class ResultPage extends StatefulWidget {
  final String data;
  final String type;

  const ResultPage({super.key, required this.data, required this.type});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  bool isLoading = true;
  Map<String, dynamic>? qrData; // सिर्फ QR का object


  @override
  void initState() {
    super.initState();
    fetchQrDetails();
  }


  Future<void> fetchQrDetails() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiRoutes.qrCodeScan}${widget.data}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            qrData = data['data']['QR']; // सिर्फ QR वाला हिस्सा
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        debugPrint("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Exception: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final String userName = qrData?['name'] ?? 'Unknown';
    final Object userAge = qrData?['dob'].toString() ?? 0;
    final String userGender = qrData?['gender'] ?? 'Not specified';
    final String userEmail = qrData?['email'] ?? '';
    final String userPhone = qrData?['contact_no1'] ?? '';
    final String userContact = qrData?['contact_no2'] ?? '';
    final String userAddress = qrData?['address'] ?? '';
    final String profileImage = qrData?['picture_data'] ?? '';



    final String family_member1_name = qrData?['family_member1_name'] ?? '';
    final String family_member1_relation = qrData?['family_member1_relation'] ?? '';
    final String family_member1_no = qrData?['family_member1_no'] ?? '';
    final String family_member2_name = qrData?['family_member2_name'] ?? '';
    final String family_member2_relation = qrData?['family_member2_relation'] ?? '';
    final String family_member2_no = qrData?['family_member2_no'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Details',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 17.sp,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(
              height: 40.sp,
              child: Image.asset('assets/calling_text.gif'),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.sp),
            bottomRight: Radius.circular(20.sp),
          ),
        ),
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),

      body: widget.data.isNotEmpty? Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80.0,
                color: AppColors.navyBlue.withOpacity(0.5),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Data Not Found',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Try adjusting your search or filters to find what you\'re looking for.',
                style: TextStyle(
                  color: AppColors.navyBlue.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      )
          :
      SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(0.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                if(widget.type=='parking')

                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 3.sp),
                        child: Container(
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: AppColors.navyBlue,
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(color: Colors.blue.shade100, width: 0),
                          ),
                          child: Center(
                            child: Text(
                              'User Details',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // User Details Card with Animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 15,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadowColor: Colors.blue.shade200.withOpacity(0.4),
                          child: Container(
                            padding: EdgeInsets.all(15.sp),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.blue.shade100, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Center(
                                      child: Hero(
                                        tag: 'profileImage',
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: profileImage.isNotEmpty
                                              ? NetworkImage(profileImage)
                                              : null,
                                          child: profileImage.isEmpty
                                              ? Icon(
                                            Icons.person,
                                            size: 50.sp,
                                            color: Colors.blue.shade700,
                                          )
                                              : null,
                                          backgroundColor: Colors.blue.shade100,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.sp),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Text(
                                            userEmail,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue.shade900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              // Text(
                                              //   DateFormat('dd-MM-yyyy').format( DateTime.parse(userAge)),
                                              //   style: TextStyle(
                                              //     fontSize: 12.sp,
                                              //     fontWeight: FontWeight.w500,
                                              //     color: Colors.blue.shade900,
                                              //   ),
                                              // ),
                                              Text(
                                                ' / ${userGender}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.sp),
                                Divider(thickness: 1.sp, color: Colors.grey.shade200),

                                _buildDetailRow(
                                  'Phone',
                                  userPhone,
                                  context,
                                  isPhone: true,
                                ),
                                Divider(thickness: 1.sp, color: Colors.grey.shade200),

                                _buildDetailRow(
                                  'Contact',
                                  userContact,
                                  context,
                                  isPhone: true,
                                ),
                                Divider(thickness: 1.sp, color: Colors.grey.shade200),

                                _buildDetailRow('Address', userAddress, context),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.sp),

                    ],
                  ),
                ),


                if(widget.type=='emergency')
                  Container(
                    child: Column(
                      children: [
                        // Family Members Section
                        Container(
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(color: Colors.blue.shade100, width: 0),
                          ),
                          child: Center(
                            child: Text(
                              'Family Details',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.sp),
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Card(
                              elevation: 10,
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              shadowColor: Colors.redAccent.shade200
                                  .withOpacity(0.4),

                              child: Container(
                                padding: EdgeInsets.all(0.sp),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.redAccent.shade100,
                                    width: 1.sp,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10.sp),
                                  title: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Center(
                                            child: Hero(
                                              tag: 'profileImage',
                                              child: CircleAvatar(
                                                radius: 20.sp,
                                                backgroundImage:
                                                profileImage.isNotEmpty
                                                    ? NetworkImage(
                                                  '',
                                                )
                                                    : null,
                                                child: profileImage.isEmpty
                                                    ? Icon(
                                                  Icons.person,
                                                  size: 30.sp,
                                                  color: Colors
                                                      .blue
                                                      .shade700,
                                                )
                                                    : null,
                                                backgroundColor:
                                                Colors.blue.shade100,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.sp),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  family_member1_name,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Colors.red.shade900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                Text(
                                                  '($family_member1_relation)' ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color:
                                                    Colors.red.shade900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 2.sp,
                                        color: Colors.red.shade100,
                                      ),
                                      _buildDetailRow2(
                                        'Contact',
                                        family_member1_no ?? 'N/A',
                                        context,
                                        isPhone:
                                        family_member1_no != null &&
                                            family_member1_no
                                                .isNotEmpty,
                                      ),


                                    ],
                                  ),
                                  // subtitle: Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     _buildDetailRow2(
                                  //       'Relation',
                                  //       member['relation'] ?? 'Not specified',
                                  //       context,
                                  //     ),
                                  //     Divider(
                                  //       thickness: 1.sp,
                                  //       color: Colors.red.shade50,
                                  //     ),
                                  //     _buildDetailRow2(
                                  //       'Contact',
                                  //       member['contactNumber'] ?? 'N/A',
                                  //       context,
                                  //       isPhone:
                                  //           member['contactNumber'] != null &&
                                  //           member['contactNumber'].isNotEmpty,
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.sp),
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Card(
                              elevation: 10,
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              shadowColor: Colors.redAccent.shade200
                                  .withOpacity(0.4),

                              child: Container(
                                padding: EdgeInsets.all(0.sp),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.redAccent.shade100,
                                    width: 1.sp,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10.sp),
                                  title: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Center(
                                            child: Hero(
                                              tag: 'profileImage',
                                              child: CircleAvatar(
                                                radius: 20.sp,
                                                backgroundImage:
                                                profileImage.isNotEmpty
                                                    ? NetworkImage(
                                                  'profileImage',
                                                )
                                                    : null,
                                                backgroundColor:
                                                Colors.blue.shade100,
                                                child: profileImage.isEmpty
                                                    ? Icon(
                                                  Icons.person,
                                                  size: 30.sp,
                                                  color: Colors
                                                      .blue
                                                      .shade700,
                                                )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.sp),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  family_member2_name,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Colors.red.shade900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                Text(
                                                  '($family_member2_relation)' ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color:
                                                    Colors.red.shade900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 2.sp,
                                        color: Colors.red.shade100,
                                      ),
                                      _buildDetailRow2(
                                        'Contact',
                                        family_member2_no ?? 'N/A',
                                        context,
                                        isPhone:
                                        family_member2_no != null &&
                                            family_member2_no
                                                .isNotEmpty,
                                      ),


                                    ],
                                  ),
                                  // subtitle: Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     _buildDetailRow2(
                                  //       'Relation',
                                  //       member['relation'] ?? 'Not specified',
                                  //       context,
                                  //     ),
                                  //     Divider(
                                  //       thickness: 1.sp,
                                  //       color: Colors.red.shade50,
                                  //     ),
                                  //     _buildDetailRow2(
                                  //       'Contact',
                                  //       member['contactNumber'] ?? 'N/A',
                                  //       context,
                                  //       isPhone:
                                  //           member['contactNumber'] != null &&
                                  //           member['contactNumber'].isNotEmpty,
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  )


              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build detail rows with call button for phone numbers
  Widget _buildDetailRow(
    String label,
    String value,
    BuildContext context, {
    bool isPhone = false,
  }) {
    String displayValue = value;
    if (value.length > 4) {
      displayValue =
          value.substring(0, 2) +
              '*' * (value.length - 4) +
              value.substring(value.length - 2);
    } else if (value.length >= 2) {
      displayValue = value; // If 4 or fewer digits, show as is
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    '$label',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    displayValue,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          if (isPhone && value.isNotEmpty)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(3.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                ),
                child: Icon(Icons.phone, color: Colors.white, size: 20.sp),
              ),
              tooltip: 'Call $value',
              onPressed: () => _makePhoneCall(value),
              splashRadius: 24.sp,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow2(
    String label,
    String value,
    BuildContext context, {
    bool isPhone = false,
  }) {
    String displayValue = value;
    if (isPhone && value.isNotEmpty) {
      if (value.length > 4) {
        displayValue =
            value.substring(0, 2) +
            '*' * (value.length - 4) +
            value.substring(value.length - 2);
      } else if (value.length >= 2) {
        displayValue = value; // If 4 or fewer digits, show as is
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    '$label',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    displayValue,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          if (isPhone && value.isNotEmpty)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(3.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.red.shade700, Colors.red.shade900],
                  ),
                ),
                child: Icon(Icons.phone, color: Colors.white, size: 20.sp),
              ),
              tooltip: 'Call $value',
              onPressed: () => _makePhoneCall(value),
              splashRadius: 24.sp,
            ),
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(3.sp),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                ),
              ),
              child: Icon(Icons.video_call, color: Colors.white, size: 20.sp),
            ),
            tooltip: 'Call $value',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoRecordingScreen(phoneNumber: value)),
              );
            },
            splashRadius: 24.sp,
          )
        ],
      ),
    );
  }

  // Method to initiate a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Could not make a call to $phoneNumber'),
      //     backgroundColor: Colors.red.shade400,
      //   ),
      // );
    }
  }

  // Method to parse family object into a list
  List<Map<String, dynamic>> parseFamily(Map<String, dynamic> family) {
    List<Map<String, dynamic>> members = [];

    if (family['father'] != null) {
      members.add({
        'relation': 'Father',
        'name': family['father']['name'],
        'age': family['father']['age'] ?? '',
        'contactNumber': family['father']['contactNumber'] ?? '',
      });
    }

    if (family['mother'] != null) {
      members.add({
        'relation': 'Mother',
        'name': family['mother']['name'],
        'age': family['mother']['age'] ?? '',
        'contactNumber': family['mother']['contactNumber'] ?? '',
      });
    }

    if (family['spouse'] != null) {
      members.add({
        'relation': 'Spouse',
        'name': family['spouse']['name'],
        'age': family['spouse']['age'] ?? '',
        'contactNumber': family['spouse']['contactNumber'] ?? '',
      });
    }

    if (family['children'] != null) {
      for (var child in family['children']) {
        members.add({
          'relation': 'Child',
          'name': child['name'],
          'age': child['age'] ?? '',
          'contactNumber': child['contactNumber'] ?? '',
        });
      }
    }

    return members;
  }
}
