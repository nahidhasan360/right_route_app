import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../drive_screen/drive_screen.dart' show DriveRouteMap;
import 'package:right_routes/controllers/route_creation/preview_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final PreviewController controller;

  @override
  void initState() {
    super.initState();
    Get.delete<PreviewController>(force: true);
    controller = Get.put(PreviewController());
  }

  @override
  void dispose() {
    Get.delete<PreviewController>(force: true);
    super.dispose();
  }

  // Map Style (Light OSM Style matching screenshot)
  static const String _kMapStyle = 'https://api.maptiler.com/maps/openstreetmap/style.json?key=dHNKoVs9jL46w6oUpFt3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── MAP LAYER ───
          MapLibreMap(
            styleString: _kMapStyle,
            initialCameraPosition: const CameraPosition(
              target: LatLng(43.5460, -96.7313), // Default, will fit bounds later
              zoom: 11.0,
            ),
            onMapCreated: controller.onMapCreated,
            onStyleLoadedCallback: controller.onStyleLoaded,
            myLocationEnabled: true,
            compassEnabled: false,
          ),

          // ─── LOADING INDICATOR ───
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: CircularProgressIndicator(color: Color(0xFFF28546)),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // ─── INFO TOOLTIP (Duration & Distance) ───
          Obx(() {
            if (controller.isLoading.value || controller.routeDistance.value == '... miles') {
              return SizedBox.shrink();
            }
            return Positioned(
              bottom: 85.h, // Positioned above the buttons
              right: 60.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, color: Colors.black87, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          controller.routeDuration.value,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.only(left: 28.0.w),
                      child: Text(
                        controller.routeDistance.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ─── ACTION BUTTONS (Back, Drive, Save) ───
          Positioned(
            bottom: 20.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrangeButton('Back', () => Get.back()),

                // 🔴 Drive Button Updated: Navigating with arguments
                _buildOrangeButton('Drive', () {
                  Get.to(() => const DriveRouteMap(), arguments: {
                    'routePoints': controller.waypoints, // Passing waypoints
                    'routeName': 'Navigating Route',
                    'routeId': controller.routeId.value,
                  });
                }),

                _buildOrangeButton('Save', () {
                  Get.snackbar('Route Saved', 'Your route has been saved in history.', backgroundColor: Colors.blue, colorText: Colors.white);
                }),
              ],
            ),
          ),
        ],
      ),

      // ─── BOTTOM NAVIGATION BAR ───
      bottomNavigationBar: Container(
        color: const Color(0xFF5A5A5A),
        padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.refresh, 'New Route', true),
            _buildNavItem(Icons.group, 'Teams', false),
            _buildNavItem(Icons.history, 'History', false),
            _buildNavItem(Icons.person_outline, 'Account', false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrangeButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0.w),
        child: SizedBox(
          height: 38.h,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF28546),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              elevation: 3,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }
}