import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color colors;
  const CustomText({super.key, required this.text, required this.colors, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
        style: GoogleFonts.poppins(
          color: colors,
          fontSize: size,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.normal,
        ),
    );
  }
}
