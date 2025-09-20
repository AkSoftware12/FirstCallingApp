import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message,
    {Color bgColor = Colors.black, IconData icon = Icons.info}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 16))),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
