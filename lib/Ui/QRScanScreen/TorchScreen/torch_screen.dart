import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TorchToggleButton extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onPressed;
  const TorchToggleButton({
    super.key,
    required this.isTorchOn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: isTorchOn ? Colors.black : Colors.white,
        foregroundColor: isTorchOn ? Colors.white : Colors.black,
      ),
      icon:
      Image.asset(
        'assets/torch.png',
        width: 20.sp,
        height: 20.sp,
        color: isTorchOn ? Colors.white : Colors.black,
      ),
      onPressed: onPressed,
    );
  }
}