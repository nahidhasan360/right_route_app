import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/home/create_new_routes/permit_list/permit_list_screen.dart';
import 'package:right_routes/controllers/route_creation/confirm_your_route_segment_controller.dart';

// ─── Map Style ────────────────────────────────────────────────────────────────
const _kMapTilerKey = 'dHNKoVs9jL46w6oUpFt3';
const _kMapStyle =
    'https://api.maptiler.com/maps/openstreetmap/style.json?key=$_kMapTilerKey';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static const darkBg = Color(0xFF0D1B2A);
  static const green = Color(0xFF2E7D32);
  static const actionGreen = Color(0xFF2E5D2E);
  static const blueBadge = Color(0xFF2C4A7A);
  static const borderSubtle = Color(0xFF2C3E50);
  static const wpGreen = Color(0xFF2E7D32);
  static const wpRed = Color(0xFFCC2222);
}

class ConfirmYourRouteForSegment extends StatelessWidget {
  const ConfirmYourRouteForSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfirmYourRouteSegmentController controller = Get.put(ConfirmYourRouteSegmentController());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _C.darkBg,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageManager.mapBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 225.w,
                    height: 112.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageManager.splashScreenLogo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Text(
                              'CONFIRM YOUR ROUTE',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 32.sp,
                                fontFamily: 'League Gothic',
                                fontWeight: FontWeight.w400,
                                height: 0.88.h,
                                letterSpacing: 1.50,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Route Name'),
                              SizedBox(height: 6.h),
                              _buildRouteNameField(context, controller),
                              SizedBox(height: 14.h),
                              Row(
                                children: [
                                  _sectionLabel('Enter Permit Directions'),
                                  SizedBox(width: 6.w),
                                  SvgPicture.asset(
                                    'assets/icons/Question-Box-gray.svg',
                                    width: 16.w,
                                    height: 16.h,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  _permitIconBtn(Icons.upload_file),
                                  SizedBox(width: 8.w),
                                  _permitIconBtn(Icons.camera_alt_outlined),
                                ],
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),
                        ),
                        _buildMapSection(controller),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
                              _buildActionButtonsRow(context, controller),
                              SizedBox(height: 16.h),
                              _buildWaypointsSectionHeader(context, controller),
                              SizedBox(height: 8.h),
                              Text(
                                'Permit 1',
                                style: TextStyle(
                                  color: AppColors.medGray,
                                  fontSize: 12.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              _buildWaypointList(context, controller),
                              SizedBox(height: 14.h),
                              Obx(() => Text(
                                    'Total miles: ${controller.distance.value.replaceAll(' miles', '')}',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13.sp,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                              SizedBox(height: 18.h),
                              _buildBottomButtons(context, controller),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomNavbar(),
      ),
    );
  }

  Widget _buildMapSection(ConfirmYourRouteSegmentController controller) {
    return SizedBox(
      width: double.infinity,
      height: 260.h,
      child: Stack(
        children: [
          MapLibreMap(
            styleString: _kMapStyle,
            initialCameraPosition: CameraPosition(
              target: controller.currentLocation,
              zoom: 11.0,
            ),
            onMapCreated: controller.onMapCreated,
            onStyleLoadedCallback: controller.onStyleLoaded,
            onCameraMove: controller.onCameraMove,
            onMapClick: (point, latLng) => controller.onMapClick(latLng),
            onMapLongClick: (point, latLng) =>
                controller.onMapLongClick(latLng),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.none,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            doubleClickZoomEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
          ),
          Obx(() {
            if (!controller.isRouteLoading.value) {
              return SizedBox.shrink();
            }
            return Positioned(
              bottom: 10.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.orange),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Calculating route…',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12.sp,
                            fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isAddingPinMode.value) {
              return SizedBox.shrink();
            }
            return Positioned(
              top: 10.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Tap anywhere on map to add pin',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isDragging.value) return SizedBox.shrink();
            return Positioned(
              top: 10.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('Drag pin to reposition',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.sp,
                          fontFamily: 'Lato')),
                ),
              ),
            );
          }),
          Positioned(
            right: 10.w,
            top: 10.h,
            child: Column(
              children: [
                _zoomBtn(Icons.add, controller.zoomIn),
                SizedBox(height: 8.h),
                _zoomBtn(Icons.remove, controller.zoomOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Row(
      children: [
        Obx(() => _actionBtn(
              controller.isAddingPinMode.value ? 'Tap Map' : 'Add Pin',
              color: controller.isAddingPinMode.value
                  ? AppColors.orange
                  : _C.actionGreen,
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.toggleAddPinMode();
              },
            )),
        SizedBox(width: 6.w),
        _actionBtn(
          'Delete Pin',
          color: AppColors.orange,
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.deleteSelectedMapPin();
          },
        ),
        SizedBox(width: 6.w),
        _actionBtn(
          'Clear All',
          color: _C.actionGreen,
          onTap: () {
            FocusScope.of(context).unfocus();
            while (controller.waypoints.length > 1) {
              controller.selectWaypoint(controller.waypoints.length - 1);
              controller.deleteSelectedWaypoint();
            }
          },
        ),
        SizedBox(width: 6.w),
        _actionBtn(
          'Update',
          color: _C.green,
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.updateRoute();
          },
        ),
      ],
    );
  }

  Widget _buildWaypointsSectionHeader(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Row(
      children: [
        Text(
          'Permit Add/Edit Waypoints',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            showWaypointsInfoDialog(context);
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
                color: _C.blueBadge, borderRadius: BorderRadius.circular(5.r)),
            child: Center(
                child: Text('?',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700))),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointList(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Obx(() {
      if (controller.waypoints.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text('No waypoints added',
              style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.4),
                  fontSize: 14.sp,
                  fontFamily: 'Lato')),
        );
      }
      return Column(
        children: List.generate(controller.waypoints.length, (i) {
          if (i >= controller.waypointControllers.length) {
            return SizedBox.shrink();
          }
          return Column(
            children: [
              _buildWaypointRow(controller, i, context),
              if (i < controller.waypoints.length - 1)
                _buildAddButton(controller, i, context),
            ],
          );
        }),
      );
    });
  }

  Widget _buildWaypointRow(
      ConfirmYourRouteSegmentController ctrl, int index, BuildContext context) {
    return Obx(() {
      if (index >= ctrl.waypoints.length ||
          index >= ctrl.waypointControllers.length) {
        return SizedBox.shrink();
      }

      final isFirst = index == 0;
      final isSelected = ctrl.selectedWaypointIndex.value == index;
      final isLast =
          index == ctrl.waypoints.length - 1 && ctrl.waypoints.length > 1;

      final Color bg = isFirst
          ? AppColors.white
          : isLast
              ? const Color(0xFF3A3A3A)
              : AppColors.white;
      final Color borderColor = isSelected
          ? AppColors.orange
          : isFirst
              ? _C.wpGreen
              : isLast
                  ? _C.wpRed
                  : Colors.transparent;
      final double borderWidth = borderColor == Colors.transparent ? 0 : 2.0;
      final Color textColor = isLast ? AppColors.white : AppColors.darkGray;

      return GestureDetector(
        onTap: () => ctrl.selectWaypoint(index),
        child: Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28.w,
                height: 44.h,
                child: Icon(Icons.drag_indicator,
                    color: AppColors.white.withValues(alpha: 0.55), size: 18),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl.waypointControllers[index],
                          onChanged: (v) => ctrl.updateWaypoint(index, v),
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 14.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400),
                          cursorColor:
                              isLast ? AppColors.white : AppColors.darkGray,
                          cursorHeight: 16,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(6.r)),
                        child: const Icon(Icons.gps_fixed,
                            color: AppColors.white, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isFirst)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ctrl.selectWaypoint(index);
                      ctrl.deleteSelectedWaypoint();
                    },
                    child: SvgPicture.asset('assets/icons/Close-X-white.svg',
                        width: 22.w, height: 22.h),
                  ),
                )
              else
                SizedBox(width: 30.w),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddButton(
      ConfirmYourRouteSegmentController ctrl, int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              ctrl.addWaypointAt(index);
            },
            child: SvgPicture.asset(
                'assets/icons/Check-Box-gray-white-border.svg',
                width: 24.w,
                height: 24.h),
          ),
          SizedBox(width: 4.w),
          Container(width: 29.w, height: 2.h, color: AppColors.dividerColor),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();

                debugPrint("✅ [ConfirmYourRouteForSegment] Save clicked. Returning success routeId: ${controller.currentRouteId}");
                
                // Trigger auto refresh from API to guarantee permit list screen updates immediately
                if (controller.currentRouteId != null && Get.isRegistered<PermitListController>()) {
                  Get.find<PermitListController>().fetchAllPermits(controller.currentRouteId!);
                }

                // Return success and routeId to PermitListScreen for dynamic API reload
                Get.back(result: {
                  'success': true,
                  'routeId': controller.currentRouteId,
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0),
              child: Text('SAVE',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 2)),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0),
              child: Text('BACK',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: TextStyle(
          color: Color(0xFFB0C4D0),
          fontSize: 13.sp,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1));

  Widget _buildRouteNameField(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Container(
      width: double.infinity,
      height: 44.h,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _C.borderSubtle, width: 1.w)),
      child: TextField(
        controller: controller.routeNameController,
        onChanged: controller.updateRouteName,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
            color: AppColors.darkGray,
            fontSize: 15.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500),
        cursorColor: AppColors.darkGray,
        cursorHeight: 18,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
            hintText: 'Name Your Route',
            hintStyle: TextStyle(
                color: Color(0xFF9AA8B2),
                fontSize: 15.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400),
            isDense: true),
      ),
    );
  }

  Widget _permitIconBtn(IconData icon) {
    return Container(
      width: 38.w,
      height: 38.h,
      decoration: BoxDecoration(
          color: AppColors.orange, borderRadius: BorderRadius.circular(6.r)),
      child: Icon(icon, color: AppColors.white, size: 20),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.26),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Icon(icon, color: AppColors.black.withValues(alpha: 0.87), size: 22),
      ),
    );
  }

  Widget _actionBtn(String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ]),
        child: Text(label,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
                letterSpacing: 0.3)),
      ),
    );
  }
}

void showWaypointsInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          EdgeInsets.only(top: 60.h, bottom: 100.h, left: 20.w, right: 20.w),
      child: Container(
        padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w),
        decoration: BoxDecoration(
            color: const Color(0xFF2A3A4A),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF3A4A5A), width: 1.w)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.edit_location_alt,
                    color: AppColors.white, size: 24),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset('assets/icons/Close-X-Circle.svg',
                        width: 24.w, height: 24.h)),
              ],
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  'Tap inside a field to select a waypoint.\n'
                  'Tap the "+" icon to add a field.\n'
                  'Tap the "X" icon to remove that waypoint.\n'
                  'Tap pins on map to select, then use Delete Pin button.\n'
                  'Drag pins on the map to reposition them.\n'
                  'Tap Update to refresh your route before clicking GO.',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      height: 1.55.h),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
