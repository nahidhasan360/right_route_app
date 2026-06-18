import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final bool showSpinner;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor = AppColors.orange,
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.icon,
    this.isLoading = false,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // Responsive constraints from ContinueWidgets
        constraints: BoxConstraints(
          minWidth: 160.w,
          maxWidth: 500.w,
          minHeight: 45.h,
          maxHeight: 90.h,
        ),
        width: width ?? double.infinity,
        height: height ?? 58.h,
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: (isLoading && onPressed == null)
              ? (backgroundColor ?? AppColors.orange).withOpacity(0.5)
              : (backgroundColor ?? AppColors.orange),
          borderRadius: BorderRadius.circular((borderRadius ?? 10).r),
        ),
        child: Center(
          child: (isLoading && showSpinner)
              ? CircularProgressIndicator(
                  color: textColor ?? Colors.white,
                  strokeWidth: 2.5,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      SizedBox(width: 8.w),
                    ],
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: fontSize ?? 24.sp,
                            fontFamily: 'League Gothic',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
