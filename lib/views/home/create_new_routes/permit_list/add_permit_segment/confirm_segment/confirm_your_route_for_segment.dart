import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/home/create_new_routes/permit_list/permit_list_screen.dart';
import 'confirm_your_route_segment_controller.dart';

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
                    width: 225,
                    height: 112,
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
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'CONFIRM YOUR ROUTE',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontFamily: 'League Gothic',
                                fontWeight: FontWeight.w400,
                                height: 0.88,
                                letterSpacing: 1.50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Route Name'),
                              const SizedBox(height: 6),
                              _buildRouteNameField(context, controller),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _sectionLabel('Enter Permit Directions'),
                                  const SizedBox(width: 6),
                                  SvgPicture.asset(
                                    'assets/icons/Question-Box-gray.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _permitIconBtn(Icons.upload_file),
                                  const SizedBox(width: 8),
                                  _permitIconBtn(Icons.camera_alt_outlined),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        _buildMapSection(controller),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              _buildActionButtonsRow(context, controller),
                              const SizedBox(height: 16),
                              _buildWaypointsSectionHeader(context, controller),
                              const SizedBox(height: 8),
                              const Text(
                                'Permit 1',
                                style: TextStyle(
                                  color: AppColors.medGray,
                                  fontSize: 12,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildWaypointList(context, controller),
                              const SizedBox(height: 14),
                              Obx(() => Text(
                                    'Total miles: ${controller.distance.value.replaceAll(' miles', '')}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                              const SizedBox(height: 18),
                              _buildBottomButtons(context, controller),
                              const SizedBox(height: 24),
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
      height: 260,
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
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.54),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.orange),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Calculating route…',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
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
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tap anywhere on map to add pin',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isDragging.value) return const SizedBox.shrink();
            return Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.54),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Drag pin to reposition',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontFamily: 'Lato')),
                ),
              ),
            );
          }),
          Positioned(
            right: 10,
            top: 10,
            child: Column(
              children: [
                _zoomBtn(Icons.add, controller.zoomIn),
                const SizedBox(height: 8),
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
        const SizedBox(width: 6),
        _actionBtn(
          'Delete Pin',
          color: AppColors.orange,
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.deleteSelectedMapPin();
          },
        ),
        const SizedBox(width: 6),
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
        const SizedBox(width: 6),
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
        const Text(
          'Permit Add/Edit Waypoints',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            showWaypointsInfoDialog(context);
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: _C.blueBadge, borderRadius: BorderRadius.circular(5)),
            child: const Center(
                child: Text('?',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('No waypoints added',
              style: TextStyle(
                  color: AppColors.white.withOpacity(0.4),
                  fontSize: 14,
                  fontFamily: 'Lato')),
        );
      }
      return Column(
        children: List.generate(controller.waypoints.length, (i) {
          if (i >= controller.waypointControllers.length) {
            return const SizedBox.shrink();
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
        return const SizedBox.shrink();
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
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 44,
                child: Icon(Icons.drag_indicator,
                    color: AppColors.white.withOpacity(0.55), size: 18),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl.waypointControllers[index],
                          onChanged: (v) => ctrl.updateWaypoint(index, v),
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400),
                          cursorColor:
                              isLast ? AppColors.white : AppColors.darkGray,
                          cursorHeight: 16,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.gps_fixed,
                            color: AppColors.white, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isFirst)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ctrl.selectWaypoint(index);
                      ctrl.deleteSelectedWaypoint();
                    },
                    child: SvgPicture.asset('assets/icons/Close-X-white.svg',
                        width: 22, height: 22),
                  ),
                )
              else
                const SizedBox(width: 30),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddButton(
      ConfirmYourRouteSegmentController ctrl, int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              ctrl.addWaypointAt(index);
            },
            child: SvgPicture.asset(
                'assets/icons/Check-Box-gray-white-border.svg',
                width: 24,
                height: 24),
          ),
          const SizedBox(width: 4),
          Container(width: 29, height: 2, color: AppColors.dividerColor),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
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
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              child: const Text('SAVE',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 2)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              child: const Text('BACK',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFFB0C4D0),
          fontSize: 13,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1));

  Widget _buildRouteNameField(BuildContext context, ConfirmYourRouteSegmentController controller) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.borderSubtle, width: 1)),
      child: TextField(
        controller: controller.routeNameController,
        onChanged: controller.updateRouteName,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
            color: AppColors.darkGray,
            fontSize: 15,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500),
        cursorColor: AppColors.darkGray,
        cursorHeight: 18,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            hintText: 'Name Your Route',
            hintStyle: TextStyle(
                color: Color(0xFF9AA8B2),
                fontSize: 15,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400),
            isDense: true),
      ),
    );
  }

  Widget _permitIconBtn(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
          color: AppColors.orange, borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, color: AppColors.white, size: 20),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.26),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Icon(icon, color: AppColors.black.withOpacity(0.87), size: 22),
      ),
    );
  }

  Widget _actionBtn(String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ]),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
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
          const EdgeInsets.only(top: 60, bottom: 100, left: 20, right: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF2A3A4A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A4A5A), width: 1)),
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
                        width: 24, height: 24)),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: const Text(
                  'Tap inside a field to select a waypoint.\n'
                  'Tap the "+" icon to add a field.\n'
                  'Tap the "X" icon to remove that waypoint.\n'
                  'Tap pins on map to select, then use Delete Pin button.\n'
                  'Drag pins on the map to reposition them.\n'
                  'Tap Update to refresh your route before clicking GO.',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      height: 1.55),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
