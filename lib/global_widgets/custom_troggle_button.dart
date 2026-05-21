import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ✅ FIX: File renamed mentally to custom_toggle_button.dart (typo: troggle → toggle)
// ✅ FIX: Example/test classes removed — শুধু production widget রাখা হয়েছে

class CustomToggleSwitchAdvanced extends StatelessWidget {
  final RxBool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double? width;
  final double? height;
  final Duration? duration;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final String? activeSvgPath;
  final String? inactiveSvgPath;
  final Color? svgColor;
  final bool showShadow;

  const CustomToggleSwitchAdvanced({
    Key? key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width,
    this.height,
    this.duration,
    this.activeIcon,
    this.inactiveIcon,
    this.activeSvgPath,
    this.inactiveSvgPath,
    this.svgColor,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => GestureDetector(
        onTap: () {
          if (onChanged != null) {
            value.value = !value.value;
            onChanged!(value.value);
          }
        },
        child: AnimatedContainer(
          duration: duration ?? const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width ?? 60,
          height: height ?? 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((height ?? 32) / 2),
            color: value.value
                ? (activeColor ?? const Color(0xFFFF8C42))
                : (inactiveColor ?? Colors.grey.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: duration ?? const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: value.value
                    ? (width ?? 60) - (height ?? 32) + 2
                    : 2,
                top: 2,
                child: Container(
                  width: (height ?? 32) - 4,
                  height: (height ?? 32) - 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: thumbColor ?? Colors.white,
                    boxShadow: showShadow
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: _buildIcon(),
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

  Widget _buildIcon() {
    if (value.value && activeSvgPath != null) {
      return SvgPicture.asset(
        activeSvgPath!,
        key: const ValueKey('active_svg'),
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          svgColor ?? const Color(0xFFFF8C42),
          BlendMode.srcIn,
        ),
      );
    }

    if (!value.value && inactiveSvgPath != null) {
      return SvgPicture.asset(
        inactiveSvgPath!,
        key: const ValueKey('inactive_svg'),
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
          svgColor ?? Colors.grey,
          BlendMode.srcIn,
        ),
      );
    }

    if (value.value && activeIcon != null) return activeIcon!;
    if (!value.value && inactiveIcon != null) return inactiveIcon!;

    return const SizedBox.shrink();
  }
}

// ════════════════════════════════════════════════════════════════
// ToggleController — reusable across screens
// ════════════════════════════════════════════════════════════════
class ToggleController extends GetxController {
  var isEnabled = false.obs;
  var useTouchId = false.obs;
}