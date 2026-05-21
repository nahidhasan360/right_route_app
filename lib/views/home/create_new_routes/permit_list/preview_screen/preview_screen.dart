// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';
// import 'preview_controller.dart';
//
// class PreviewScreen extends StatelessWidget {
//   PreviewScreen({super.key});
//
//   final PreviewController controller = Get.put(PreviewController());
//
//   // Map Style (Light OSM Style matching screenshot)
//   static const String _kMapStyle = 'https://api.maptiler.com/maps/openstreetmap/style.json?key=dHNKoVs9jL46w6oUpFt3';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // ─── MAP LAYER ───
//           MapLibreMap(
//             styleString: _kMapStyle,
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(43.5460, -96.7313), // Default, will fit bounds later
//               zoom: 11.0,
//             ),
//             onMapCreated: controller.onMapCreated,
//             onStyleLoadedCallback: controller.onStyleLoaded,
//             myLocationEnabled: true,
//             compassEnabled: false,
//           ),
//
//           // ─── LOADING INDICATOR ───
//           Obx(() {
//             if (controller.isLoading.value) {
//               return const Center(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: CircularProgressIndicator(color: Color(0xFFF28546)),
//                   ),
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//
//           // ─── INFO TOOLTIP (Duration & Distance) ───
//           Obx(() {
//             if (controller.isLoading.value || controller.routeDistance.value == '... miles') {
//               return const SizedBox.shrink();
//             }
//             return Positioned(
//               bottom: 85, // বাটন ছোট করায় একটু নিচে নামিয়ে দেওয়া হলো
//               right: 60,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: const [
//                     BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.directions_car, color: Colors.black87, size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           controller.routeDuration.value,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                             color: Colors.black87,
//                             fontFamily: 'Lato',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 28.0),
//                       child: Text(
//                         controller.routeDistance.value,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w500,
//                           fontFamily: 'Lato',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//
//           // ─── ACTION BUTTONS (Back, Drive, Save) ───
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildOrangeButton('Back', () => Get.back()),
//                 _buildOrangeButton('Drive', () {
//                   Get.snackbar('Drive Started', 'Navigating to destination...', backgroundColor: Colors.green, colorText: Colors.white);
//                   // TODO: Navigate to Turn-by-Turn Navigation Screen
//                 }),
//                 _buildOrangeButton('Save', () {
//                   Get.snackbar('Route Saved', 'Your route has been saved in history.', backgroundColor: Colors.blue, colorText: Colors.white);
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//
//       // ─── BOTTOM NAVIGATION BAR ───
//       bottomNavigationBar: Container(
//         color: const Color(0xFF5A5A5A), // Dark grey matching the design
//         padding: const EdgeInsets.only(bottom: 20, top: 10), // Padding for safe area
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(Icons.refresh, 'New Route', true),
//             _buildNavItem(Icons.group, 'Teams', false),
//             _buildNavItem(Icons.history, 'History', false),
//             _buildNavItem(Icons.person_outline, 'Account', false),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔴 Helper Widget for Orange Buttons (আপডেট করা হয়েছে)
//   Widget _buildOrangeButton(String text, VoidCallback onPressed) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         child: SizedBox(
//           height: 38, // 🔴 বাটন চিকন করার জন্য Height ফিক্স করা হলো (আগে অনেক বড় ছিল)
//           child: ElevatedButton(
//             onPressed: onPressed,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF28546), // Match exactly with image
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.zero, // ভেতরের ডিফল্ট প্যাডিং মুছে দেওয়া হলো
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               elevation: 3,
//             ),
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 14, // 🔴 টেক্সট সাইজ ১৬ থেকে ১৪ করা হলো যাতে বাটনের সাথে মানায়
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Lato',
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper Widget for Bottom Navigation Items
//   Widget _buildNavItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white, size: 28),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             fontFamily: 'Lato',
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../drive_screen/drive_screen.dart' show DriveRouteMap;
import 'preview_controller.dart';

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
              return const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFFF28546)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ─── INFO TOOLTIP (Duration & Distance) ───
          Obx(() {
            if (controller.isLoading.value || controller.routeDistance.value == '... miles') {
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 85, // Positioned above the buttons
              right: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(width: 8),
                        Text(
                          controller.routeDuration.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        controller.routeDistance.value,
                        style: const TextStyle(
                          fontSize: 14,
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
            bottom: 20,
            left: 16,
            right: 16,
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
        padding: const EdgeInsets.only(bottom: 20, top: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF28546),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 3,
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }
}