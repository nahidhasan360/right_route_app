import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/utils/colors.dart';

class ButtonReusable extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // nullable — null হলে disabled state

  final double? width;
  final double? height;
  final double padding;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;

  const ButtonReusable({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.padding = 10,
    this.backgroundColor = AppColors.orange,
    this.textColor = Colors.white,
    this.fontSize = 24,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        // ✅ disabled হলে হালকা দেখাবে
        opacity: onPressed == null ? 0.5 : 1.0,
        child: Container(
          width: width ?? 234.w,
          height: height ?? 58.h, // Standardized button height
          padding: EdgeInsets.all(padding.r),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius.r),
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize.sp,
                fontFamily: 'League Gothic',
                fontWeight: FontWeight.w400,
                height: 1.17, // multiplier, NOT logical pixels
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}