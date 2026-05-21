import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

class SimpleImportButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onTab;

  final String leftIcon; // SVG or PNG
  final String? rightIcon; // SVG only

  const SimpleImportButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.leftIcon,
    this.rightIcon,
    this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // BUTTON
          Container(
            height: 64,
            width: 296,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:25), //  Left padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Left aligned
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT ICON - Fixed width for alignment
                  SizedBox(
                    width: 40, // Fixed width
                    child: Center(
                      child: _buildLeftIcon(),
                    ),
                  ),

                  const SizedBox(width: 5), // Icon-text spacing

                  // TEXT
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                      height: 1.17,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOP-RIGHT QUESTION ICON (optional)
          if (rightIcon != null || onTab != null)
            Positioned(
              top: 7,
              right: 7,
              child: GestureDetector(
                onTap: onTab,
                child: Center(
                  child: SvgPicture.asset("assets/icons/Question-Box-gray.svg"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftIcon() {
    if (leftIcon.endsWith(".svg")) {
      return SvgPicture.asset(
        leftIcon,
        height: 40,
        width: 40,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      return Image.asset(leftIcon, height: 40, width: 40);
    }
  }
}




