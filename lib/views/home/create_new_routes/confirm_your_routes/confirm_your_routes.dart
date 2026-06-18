import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart'; // AppColors এখানেই আছে ধরে নিলাম
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/controllers/route_creation/confirm_controller.dart';
import 'package:right_routes/controllers/home/home_controller.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';
import '../permit_list/permit_list_screen.dart';
import '../permit_list/drive_screen/drive_screen.dart';

// ─── Map Style ────────────────────────────────────────────────────────────────
const _kMapTilerKey = 'dHNKoVs9jL46w6oUpFt3';
const _kMapStyle =
    'https://api.maptiler.com/maps/openstreetmap/style.json?key=$_kMapTilerKey';

// ─── Design Tokens (AppColors-এ যে কালারগুলো নেই সেগুলো এখানে রাখা হলো) ──────
class _C {
  static const darkBg = Color(0xFF0D1B2A);
  static const green = Color(0xFF2E7D32);
  static const actionGreen = Color(0xFF2E5D2E);
  static const blueBadge = Color(0xFF2C4A7A);
  static const borderSubtle = Color(0xFF2C3E50);
  static const wpGreen = Color(0xFF2E7D32);
  static const wpRed = Color(0xFFCC2222);
}

class EditConfirmStartYourRoute extends StatelessWidget {
  EditConfirmStartYourRoute({super.key});

  final ConfirmRouteController controller = Get.put(ConfirmRouteController());
  final HomeController homeCtrl = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put<HomeController>(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 16.h),
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
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'EDIT, SAVE, DRIVE ROUTE',
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
                              _buildRouteNameField(context),
                              SizedBox(height: 14.h),
                            ],
                          ),
                        ),
                        _buildMapSection(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
                              _buildActionButtonsRow(context),
                              SizedBox(height: 16.h),
                              _buildWaypointsSectionHeader(context),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Text(
                                    'Permit 1',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16.sp,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: controller.toggleWaypoints,
                                    child: Container(
                                      width: 22.w,
                                      height: 22.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.orange,
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      child: Obx(() => Icon(
                                          controller.isWaypointsExpanded.value
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 18)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Obx(() => controller.isWaypointsExpanded.value
                                  ? _buildWaypointList(context)
                                  : SizedBox.shrink()),
                              SizedBox(height: 14.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    homeCtrl.currentPermitIndex.value++;
                                    Get.toNamed(
                                        AppRoutes.createRouteAfterConfirmRoute);
                                  },
                                  child: Obx(() => Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.orange,
                                          borderRadius:
                                              BorderRadius.circular(7.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.black
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Add Permit ${homeCtrl.currentPermitIndex.value + 1}',
                                          style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 14.sp,
                                              fontFamily: 'Lato',
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      )),
                                ),
                              ),
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
                              _buildBottomButtons(context),
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
        bottomNavigationBar: CustomNavbar(),
      ),
    );
  }

  Widget _buildMapSection() {
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
            if (!controller.isRouteLoading.value) return SizedBox.shrink();
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
            if (!controller.isAddingPinMode.value) return SizedBox.shrink();
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

  Widget _buildActionButtonsRow(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => _actionBtn(
                  controller.isAddingPinMode.value ? 'Tap Map' : 'Add Pin',
                  color: AppColors.orange,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    controller.toggleAddPinMode();
                  },
                )),
            _actionBtn(
              'Update',
              color: _C.green,
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.updateRoute();
              },
            ),
          ],
        ),
        _actionBtn(
          'Delete Pin',
          color: AppColors.orange,
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.deleteSelectedMapPin();
          },
        ),
      ],
    );
  }

  Widget _buildWaypointsSectionHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Add/Edit Waypoints',
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
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: SvgPicture.asset(
              'assets/icons/Question-Box-gray.svg',
              width: 20.w,
              height: 20.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointList(BuildContext context) {
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
      ConfirmRouteController ctrl, int index, BuildContext context) {
    return Obx(() {
      if (index >= ctrl.waypoints.length ||
          index >= ctrl.waypointControllers.length) {
        return SizedBox.shrink();
      }

      final isFirst = index == 0;
      final isSelected = ctrl.selectedWaypointIndex.value == index;
      final isLast =
          index == ctrl.waypoints.length - 1 && ctrl.waypoints.length > 1;

      final Color bg =
          (isFirst || isLast) ? const Color(0xFF808080) : AppColors.white;
      final Color borderColor = isFirst
          ? _C.wpGreen
          : isLast
              ? _C.wpRed
              : Colors.transparent;
      final double borderWidth = borderColor == Colors.transparent ? 0 : 2.0;
      final Color textColor = isLast ? AppColors.white : AppColors.darkGray;

      return GestureDetector(
        onTap: () => ctrl.selectWaypoint(index),
        child: Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 32.w),
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
                      if (!isFirst && !isLast) ...[
                        SizedBox(width: 6.w),
                        Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(6.r)),
                          child: const Icon(Icons.mic_none,
                              color: AppColors.white, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isFirst && !isLast)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ctrl.selectWaypoint(index);
                      ctrl.deleteSelectedWaypoint();
                    },
                    child: const Icon(Icons.close,
                        color: AppColors.white, size: 24),
                  ),
                )
              else
                SizedBox(width: 32.w),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddButton(
      ConfirmRouteController ctrl, int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.h),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              ctrl.addWaypointAt(index);
            },
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: const Color(0xFF6E6E6E),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 14),
            ),
          ),
          SizedBox(width: 6.w),
          Container(width: 27.w, height: 1.h, color: const Color(0xFF6E6E6E)),
          SizedBox(width: 32.w),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 57.h,
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();

                // PermitListController কে permanent হিসেবে কল করে ডেটা দেওয়া হচ্ছে
                final permitCtrl =
                    Get.put(PermitListController(), permanent: true);

                // Use API data if available (routeId and permitId exist)
                if (controller.currentRouteId != null &&
                    controller.currentRouteId!.isNotEmpty &&
                    controller.currentPermitId != null &&
                    controller.currentPermitId!.isNotEmpty) {
                  debugPrint(
                      "✅ [ConfirmYourRoutes] Adding permit from API: routeId=${controller.currentRouteId}, permitId=${controller.currentPermitId}");
                  // globalRouteId is set inside addPermitFromApi
                  await permitCtrl.addPermitFromApi(
                      controller.currentRouteId!, controller.currentPermitId!);
                } else {
                  // Fallback to manual data (old flow)
                  debugPrint(
                      "⚠️ [ConfirmYourRoutes] No API IDs, using manual data");
                  permitCtrl.addNewPermit(
                    controller.routeNameController.text,
                    controller.waypoints.toList(),
                    controller.waypointPositions,
                  );
                }

                if (Get.previousRoute == AppRoutes.permitListScreen) {
                  Get.back();
                } else {
                  Get.offNamed(
                    AppRoutes.permitListScreen,
                    arguments: {
                      'routeId': controller.currentRouteId,
                    },
                  );
                }
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
                      fontSize: 22.sp,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 2)),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 58.h,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.to(
                  () => const DriveRouteMap(),
                  arguments: {
                    'routeId': controller.currentRouteId,
                    'routePoints': controller.waypointPositions,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0),
              child: Text('DRIVE',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
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
          color: AppColors.white,
          fontSize: 18.sp,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1));

  Widget _buildRouteNameField(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44.h,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _C.borderSubtle, width: 1.w)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.routeNameController,
              onChanged: controller.updateRouteName,
              textAlign: TextAlign.left,
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
                  hintText: 'Iowa Wind Tower',
                  hintStyle: TextStyle(
                      color: Color(0xFF9AA8B2),
                      fontSize: 15.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400),
                  isDense: true),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(6.r)),
              child:
                  const Icon(Icons.mic_none, color: AppColors.white, size: 18),
            ),
          ),
        ],
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
        child: Icon(icon,
            color: AppColors.black.withValues(alpha: 0.87), size: 22),
      ),
    );
  }

  Widget _actionBtn(String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ]),
        child: Text(label,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lato',
                letterSpacing: 0.5)),
      ),
    );
  }
}

void showConfirmRouteInfoDialog(BuildContext context) {
  Widget buildRichText(String boldPart, String normalPart) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: boldPart,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                height: 1.55.h,
              ),
            ),
            TextSpan(
              text: normalPart,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                height: 1.55.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showCustomInfoDialog(
    context: context,
    icon: SvgPicture.asset('assets/icons/Vector-hand.svg',
        width: 24.w, height: 24.h),
    customWidgets: [
      buildRichText('Adding new pins: ',
          'Tap the Add Pin button then tap anywhere on the map.'),
      buildRichText('Selecting pins: ',
          'Tap any pin on the map to select it. It will enlarge.'),
      buildRichText('Moving pins: ',
          'Press and hold a pin, then drag it to a new location.'),
      buildRichText(
          'Deleting pins: ', 'Select a pin, then tap the Delete Pin button.'),
      buildRichText('Manipulating the map: ',
          'Drag with one finger to pan. Pinch to zoom in/out.'),
      buildRichText(
          'Tap Update to refresh waypoints. Tap GO to start your route.', ''),
    ],
  );
}

void showWaypointsInfoDialog(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: const Icon(Icons.location_on, color: AppColors.white, size: 24),
    texts: const [
      'Tap inside a field to select a waypoint.',
      'Tap the "+" icon to add a field.',
      'Tap the "X" icon to remove that waypoint.',
      'Tap pins on map to select, then use Delete Pin button.',
      'Drag pins on the map to reposition them.',
      'Tap Update to refresh your route before clicking GO.',
    ],
  );
}
