import 'package:flutter/material.dart';

// ✅ FIX: flutter_screenutil dependency সরানো হয়েছে
// ScreenUtilInit wrap না থাকলে crash করত — এখন MediaQuery দিয়ে responsive করা হয়েছে

class PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0 = Weak, 1 = Fair, 2 = Great

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    // Responsive width — screen width-এর 60% use করছে
    final double totalWidth = MediaQuery.of(context).size.width * 0.60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 6,
          width: totalWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade700,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: _getProgressWidth(strength, totalWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _getActiveColor(strength),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getLabel(strength),
          style: TextStyle(
            color: _getActiveColor(strength),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  double _getProgressWidth(int s, double total) {
    if (s == 0) return total * (1 / 3); // Weak
    if (s == 1) return total * (2 / 3); // Fair
    return total;                        // Great
  }

  Color _getActiveColor(int s) {
    if (s == 0) return Colors.red;
    if (s == 1) return Colors.yellow.shade600;
    return Colors.green;
  }

  String _getLabel(int s) {
    if (s == 0) return 'Weak';
    if (s == 1) return 'Fair';
    return 'Great';
  }
}