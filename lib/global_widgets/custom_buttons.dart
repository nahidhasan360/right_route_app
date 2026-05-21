import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final Icon? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor = AppColors.orange,
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // ✅ FIX: CustomButton-এর সব parameter এখন actually use হচ্ছে
        width: width ?? double.infinity,
        height: height ?? 58,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: backgroundColor ?? AppColors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize ?? 24,
                    fontFamily: 'League Gothic',
                    fontWeight: FontWeight.w400,
                    height: 1.17,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}