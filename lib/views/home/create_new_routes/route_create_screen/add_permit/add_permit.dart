// ═══════════════════════════════════════════════════════════════════════════
// add_permit.dart — Enhanced with Map Picker, Voice, Camera, and Documents
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/controllers/route_creation/add_permit_controller.dart';

// ─── Color constants ──────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF060D1F);
  static const cardBorder = Color(0xFF1E2D4A);
  static const inputBg = Color(0xFFFFFFFF);
  static const labelColor = Color(0xFFB0BEC5);
  static const hintColor = Color(0xFF9E9E9E);
  static const textDark = Color(0xFF1A1A2E);
  static const orange = Color(0xFFF58434);
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class AddPermit extends StatelessWidget {
  AddPermit({super.key});

  final AddPermitController ctrl = Get.put(AddPermitController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _C.bg,
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: const CustomNavbar(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageManager.mapBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: _C.bg.withValues(alpha: 0.85),
            child: SizedBox.expand(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16.h),

                          // ── Logo ─────────────────────────────────────────
                          Image.asset(
                            ImageManager.splashScreenLogo,
                            width: 170.w,
                            fit: BoxFit.contain,
                          ),

                          SizedBox(height: 14.h),

                          // ── Title ─────────────────────────────────────────
                          Text(
                            'ADD PERMIT 1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.sp,
                              fontFamily: 'League Gothic',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2.2,
                              height: 1.0.h,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 22.h),

                          // ── Group 1: Waypoints ───────────────────────────
                          _GroupBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel(label: 'Starting Point'),
                                SizedBox(height: 7.h),
                                _InputField(
                                  controller: ctrl.startingPointController,
                                  hint: 'Keep or edit your current location',
                                  icon: Icons.my_location_rounded,
                                  onMapTap: () =>
                                      _showMapPickerDialog(context, true),
                                ),
                                SizedBox(height: 14.h),
                                const _FieldLabel(label: 'Ending Point'),
                                SizedBox(height: 7.h),
                                _InputField(
                                  controller: ctrl.endingPointController,
                                  hint: 'Enter permit end point',
                                  icon: Icons.pin_drop_rounded,
                                  onMapTap: () =>
                                      _showMapPickerDialog(context, false),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 14.h),

                          // ── Group 2: Document & Input Options ────────────
                          _GroupBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DOCUMENT & INPUT OPTIONS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontFamily: 'League Gothic',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Obx(() => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _OrangeIconBtn(
                                          icon: 'assets/icons/Import_white.svg',
                                          size: 64.w,
                                          onTap: () => ctrl.pickDocument(),
                                          isAdded: ctrl.pickedDocumentPath.value
                                              .isNotEmpty,
                                        ),
                                        _OrangeIconBtn(
                                          icon:
                                              'assets/icons/Edit-Pencil-white.svg',
                                          size: 64.w,
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus();
                                          },
                                        ),
                                        _OrangeIconBtn(
                                          icon: 'assets/icons/Mic-white.svg',
                                          size: 64.w,
                                          onTap: () =>
                                              _showVoiceInputDialog(context),
                                        ),
                                        _OrangeIconBtn(
                                          icon: 'assets/icons/Camera-white.svg',
                                          size: 64.w,
                                          onTap: () => ctrl.pickImage(),
                                          isAdded: ctrl
                                              .pickedImagePath.value.isNotEmpty,
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // ── PROCESS button ────────────────────────────────
                          Obx(() => GestureDetector(
                                onTap: ctrl.isUploading.value
                                    ? null
                                    : () {
                                        debugPrint(
                                            "👆 [UI] PROCESS button tapped!");
                                        ctrl.uploadPermit();
                                      },
                                child: Container(
                                  width: 373.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: ctrl.isUploading.value
                                        ? _C.orange.withValues(alpha: 0.5)
                                        : _C.orange,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            _C.orange.withValues(alpha: 0.35),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: ctrl.isUploading.value
                                        ? SizedBox(
                                            height: 24.h,
                                            width: 24.h,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0),
                                          )
                                        : Text(
                                            'PROCESS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.sp,
                                              fontFamily: 'League Gothic',
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 3.0,
                                              height: 1.0.h,
                                            ),
                                          ),
                                  ),
                                ),
                              )),

                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Map Picker Dialog ──────────────────────────────────────────────────────
  void _showMapPickerDialog(BuildContext context, bool isStart) async {
    await ctrl.openMapPicker(context, isStart);
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _MapPickerDialog(
          controller: ctrl,
          title: isStart ? 'PICK STARTING POINT' : 'PICK ENDING POINT',
          onConfirm: (address) {
            if (isStart) {
              ctrl.startingPointController.text = address;
              ctrl.startLatLng.value = ctrl.mapPickedLatLng.value;
            } else {
              ctrl.endingPointController.text = address;
              ctrl.endLatLng.value = ctrl.mapPickedLatLng.value;
            }
          },
        ),
      );
    }
  }

  // ─── Voice Input Dialog ─────────────────────────────────────────────────────
  void _showVoiceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _C.bg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VOICE INPUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontFamily: 'League Gothic',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              Obx(() => AvatarGlow(
                    animate: ctrl.isListening.value,
                    glowColor: _C.orange,
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: GestureDetector(
                      onTap: () {
                        if (ctrl.isListening.value) {
                          ctrl.stopListening();
                        } else {
                          ctrl.startListening();
                        }
                      },
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: _C.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ctrl.isListening.value
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _C.cardBorder),
                ),
                child: Obx(() => Text(
                      ctrl.recognizedText.value.isEmpty
                          ? "Tap microphone to speak..."
                          : ctrl.recognizedText.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Lato',
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        ctrl.stopListening();
                        Get.back();
                      },
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFamily: 'League Gothic',
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (ctrl.recognizedText.value.isNotEmpty) {
                          ctrl.endingPointController.text =
                              ctrl.recognizedText.value;
                        }
                        ctrl.stopListening();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'League Gothic',
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map Picker Dialog Widget ─────────────────────────────────────────────────
class _MapPickerDialog extends StatelessWidget {
  final AddPermitController controller;
  final String title;
  final Function(String) onConfirm;

  const _MapPickerDialog({
    required this.controller,
    required this.title,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontFamily: 'League Gothic',
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 350.h,
              child: Stack(
                children: [
                  MapLibreMap(
                    styleString: AddPermitController.kMapStyle,
                    initialCameraPosition: CameraPosition(
                      target: controller.mapPickedLatLng.value,
                      zoom: 14.0,
                    ),
                    onMapCreated: (mc) {
                      controller.mapController = mc;
                      debugPrint(
                          "📍 [MapDialog] Map created, tap anywhere to place marker");
                    },
                    onMapClick: (point, latLng) =>
                        controller.onMapPickerTap(latLng),
                    myLocationEnabled: true,
                  ),
                  Positioned(
                    top: 10.h,
                    left: 0.w,
                    right: 0.w,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: _C.orange.withValues(alpha: 0.5),
                              width: 1.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded,
                                color: _C.orange, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Tap anywhere to place marker',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() => controller.isGeocodingLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: _C.orange))
                      : SizedBox.shrink()),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Obx(() => Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: _C.cardBorder),
                        ),
                        child: Text(
                          controller.mapPickedAddress.value.isEmpty
                              ? "Select a location on the map"
                              : controller.mapPickedAddress.value,
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.sp),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 18.sp,
                                fontFamily: 'League Gothic'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                              onPressed: controller
                                          .mapPickedAddress.value.isNotEmpty &&
                                      !controller.isGeocodingLoading.value
                                  ? () {
                                      onConfirm(
                                          controller.mapPickedAddress.value);
                                      Get.back();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                              ),
                              child: Text(
                                'CONFIRM',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontFamily: 'League Gothic'),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group Box ────────────────────────────────────────────────────────────────
class _GroupBox extends StatelessWidget {
  final Widget child;
  const _GroupBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _C.cardBorder, width: 1.0.w),
      ),
      child: child,
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: _C.labelColor,
        fontSize: 12.sp,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── White Input Field ────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onMapTap;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: _C.inputBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: _C.textDark,
              style: TextStyle(
                color: _C.textDark,
                fontSize: 14.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _C.hintColor,
                  fontSize: 13.sp,
                  fontFamily: 'Lato',
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Map icon
          GestureDetector(
            onTap: onMapTap,
            child: Icon(Icons.map_outlined, color: _C.orange, size: 22.sp),
          ),
          SizedBox(width: 10.w),

          // Orange icon badge
          Container(
            width: 32.w,
            height: 32.h,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: _C.orange,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: Colors.white, size: 16.sp),
          ),
        ],
      ),
    );
  }
}

// ─── Orange Square Icon Button ────────────────────────────────────────────────
class _OrangeIconBtn extends StatelessWidget {
  final String icon;
  final double size;
  final VoidCallback onTap;
  final bool isAdded;

  const _OrangeIconBtn({
    required this.icon,
    required this.size,
    required this.onTap,
    this.isAdded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isAdded ? Colors.green : _C.orange,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: (isAdded ? Colors.green : _C.orange)
                      .withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: (size * 0.44).w,
                height: (size * 0.44).h,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          if (isAdded)
            Positioned(
              top: -6.h,
              right: -6.w,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ]),
                child: Icon(Icons.check, color: Colors.green, size: 14.sp),
              ),
            ),
        ],
      ),
    );
  }
}
