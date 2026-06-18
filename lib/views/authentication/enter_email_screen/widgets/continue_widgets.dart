import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/utils/colors.dart';

class ContinueWidgets extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;

  const ContinueWidgets({
    super.key,
    this.text,
    this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: _Button(
        text: text ?? "GET STARTED",
        width: width ?? double.infinity,
        height: height ?? 58.h,
        backgroundColor: backgroundColor ?? AppColors.orange,
        textColor: textColor ?? Colors.white,
        fontSize: fontSize ?? 24,
        borderRadius: borderRadius ?? 10,
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;

  const _Button({
    required this.text,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Responsive constraints
      constraints: BoxConstraints(
        minWidth: 160,
        maxWidth: 500,
        minHeight: 45,
        maxHeight: 90,
      ),

      width: width,
      height: height,

      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 10.h,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      child: Center(
        child: FittedBox(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize, // responsive handled by .sp
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 2, // responsive letter spacing
            ),
          ),
        ),
      ),
    );
  }
}
