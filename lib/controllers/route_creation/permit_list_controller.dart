// // ═══════════════════════════════════════════════════════════════════════════
// // permit_list_screen.dart — Pixel-perfect | Real map bg + white inputs
// // ═══════════════════════════════════════════════════════════════════════════
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:maplibre_gl/maplibre_gl.dart'; // LatLng এর জন্য
// import 'package:right_routes/global_widgets/custom_navbar.dart';
// import 'package:right_routes/utils/assets_manager.dart';
// import 'package:right_routes/utils/colors.dart'; // AppColors
// import 'package:right_routes/views/home/create_new_routes/permit_list/preview_screen/preview_screen.dart';
//
//
// // ─── Models ───────────────────────────────────────────────────────────────────
// class PermitSegmentModel {
//   final RxString route;
//   PermitSegmentModel({required String route}) : route = route.obs;
// }
//
// class PermitModel {
//   final String id;
//   final String title;
//   final RxList<PermitSegmentModel> segments;
//
//   PermitModel({
//     required this.id,
//     required this.title,
//     required List<PermitSegmentModel> segments,
//   }) : segments = segments.obs;
// }
//
// // ─── Controller ───────────────────────────────────────────────────────────────
// class PermitListController extends GetxController {
//   final RxList<PermitModel> permits = <PermitModel>[].obs;
//   List<LatLng> routeCoordinates = []; // Preview এর জন্য
//
//   // 🔴 যতবার কল হবে, ততবার সিরিয়াল অনুযায়ী পারমিট অ্যাড হবে
//   void addNewPermit(String routeName, List<String> segments, List<LatLng> coordinates) {
//     String title = 'PERMIT ${permits.length + 1}';
//
//     // Preview-এর জন্য লেটেস্ট কোঅর্ডিনেট সেভ রাখা
//     routeCoordinates = coordinates;
//
//     // নতুন পারমিট লিস্টে অ্যাড করা
//     permits.add(
//         PermitModel(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           title: title,
//           segments: segments.map((seg) => PermitSegmentModel(route: seg)).toList(),
//         )
//     );
//   }
//
//   void addSegment(String permitId) {
//     final permit = permits.firstWhereOrNull((p) => p.id == permitId);
//     permit?.segments.add(PermitSegmentModel(route: 'New Stop'));
//   }
//
//   void onViewPermit(String permitId) {
//     // TODO: Get.toNamed(AppRoutes.permitDetailScreen, arguments: permitId);
//   }
//
//   void onPreview() {
//     if (routeCoordinates.isNotEmpty) {
//       Get.to(() => PreviewScreen(), arguments: routeCoordinates);
//     } else {
//       Get.snackbar('Error', 'No route data available for preview.',
//           backgroundColor: Colors.red, colorText: AppColors.white);
//     }
//   }
//
//   void onSave() {
//     Get.snackbar('Success', 'All permits saved successfully!',
//         backgroundColor: Colors.green, colorText: AppColors.white);
//   }
// }
//
// // ─── Screen ───────────────────────────────────────────────────────────────────
// class PermitListScreen extends StatelessWidget {
//   PermitListScreen({super.key});
//
//   // Controller কে permanent করা হয়েছে যাতে ব্যাক করলে ডেটা না হারায়
//   final PermitListController _ctrl = Get.put(PermitListController(), permanent: true);
//
//   // ── Colors ────────────────────────────────────────────────────────────
//   static const Color _bg          = Color(0xFF0B1129); // homescreen same
//   static const Color _green       = Color(0xFF2E7D32);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       extendBody: true,
//       extendBodyBehindAppBar: true,
//       bottomNavigationBar: const CustomNavbar(),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(ImageManager.mapBackground),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Container(
//           color: _bg.withOpacity(0.87),
//           child: SizedBox.expand(
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 SliverSafeArea(
//                   bottom: false,
//                   sliver: SliverPadding(
//                     padding: EdgeInsets.only(
//                       left: 18.w,
//                       right: 18.w,
//                       bottom: 100.h,
//                     ),
//                     sliver: SliverList(
//                       delegate: SliverChildListDelegate([
//                         SizedBox(height: 14.h),
//
//                         // ── Header ────────────────────────────────────
//                         const _AppHeader(),
//
//                         SizedBox(height: 20.h),
//
//                         // ── Permit Cards ──────────────────────────────
//                         Obx(
//                               () => Column(
//                             children: _ctrl.permits.map((permit) {
//                               return _PermitBlock(
//                                 permit: permit,
//                                 onViewPermit: () =>
//                                     _ctrl.onViewPermit(permit.id),
//                                 onAddSegment: () =>
//                                     _ctrl.addSegment(permit.id),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//
//                         SizedBox(height: 8.h),
//
//                         // ── PREVIEW / SAVE ────────────────────────────
//                         _ActionButtons(
//                           onPreview: _ctrl.onPreview,
//                           onSave: _ctrl.onSave,
//                           green: _green,
//                         ),
//                       ]),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── App Header ───────────────────────────────────────────────────────────────
// class _AppHeader extends StatelessWidget {
//   const _AppHeader();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ── Logo — splashScreenLogo (same as homescreen) ──────────────
//         Image.asset(
//           ImageManager.splashScreenLogo,
//           width: 175.w,
//           fit: BoxFit.contain,
//         ),
//
//         SizedBox(height: 14.h),
//
//         Text(
//           'YOUR PERMITS',
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 34.sp,
//             fontFamily: 'League Gothic',
//             fontWeight: FontWeight.w400,
//             letterSpacing: 2.0,
//             height: 1.0,
//           ),
//           textAlign: TextAlign.center,
//         ),
//
//         SizedBox(height: 8.h),
//
//         Text(
//           'Manage your route permits and add new ones as\nneeded.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: AppColors.white.withOpacity(0.68),
//             fontSize: 13.sp,
//             fontFamily: 'Lato',
//             fontWeight: FontWeight.w400,
//             height: 1.55,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Permit Block ─────────────────────────────────────────────────────────────
// class _PermitBlock extends StatelessWidget {
//   final PermitModel permit;
//   final VoidCallback onViewPermit;
//   final VoidCallback onAddSegment;
//
//   _PermitBlock({
//     required this.permit,
//     required this.onViewPermit,
//     required this.onAddSegment,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 4.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Permit Card — transparent bg, visible border ─────────────
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(
//                 color: const Color(0xFF2A3F6A),
//                 width: 1.2,
//               ),
//             ),
//             padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Title row ────────────────────────────────────────
//                 Row(
//                   children: [
//                     Container(
//                       width: 36.w,
//                       height: 36.h,
//                       decoration: BoxDecoration(
//                         color: AppColors.orange,
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Icon(
//                         Icons.description_rounded,
//                         color: AppColors.white,
//                         size: 19.sp,
//                       ),
//                     ),
//                     SizedBox(width: 10.w),
//                     Text(
//                       permit.title,
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontSize: 16.sp,
//                         fontFamily: 'League Gothic',
//                         fontWeight: FontWeight.w400,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 12.h),
//
//                 // ── Segment rows ──────────────────────────────────────
//                 Obx(
//                       () => Column(
//                     children: permit.segments
//                         .map((seg) => _SegmentInputRow(segment: seg))
//                         .toList(),
//                   ),
//                 ),
//
//                 SizedBox(height: 10.h),
//
//                 // ── VIEW PERMIT ───────────────────────────────────────
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: GestureDetector(
//                     onTap: onViewPermit,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20.w,
//                         vertical: 10.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.orange,
//                         borderRadius: BorderRadius.circular(7.r),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.orange.withOpacity(0.35),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         'VIEW PERMIT',
//                         style: TextStyle(
//                           color: AppColors.white,
//                           fontSize: 13.sp,
//                           fontFamily: 'Lato',
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── ADD PERMIT SEGMENT — outside card left edge ───────────────
//           Transform.translate(
//             offset: Offset(-10.w, 0),
//             child: GestureDetector(
//               onTap: onAddSegment,
//               behavior: HitTestBehavior.opaque,
//               child: Padding(
//                 padding: EdgeInsets.only(top: 6.h, bottom: 16.h),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // [+] button
//                     Container(
//                       width: 28.w,
//                       height: 28.h,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         border: Border.all(
//                           color: AppColors.white,
//                           width: 1.5,
//                         ),
//                         borderRadius: BorderRadius.circular(4.r),
//                       ),
//                       child: Icon(
//                         Icons.add,
//                         color: AppColors.white,
//                         size: 16.sp,
//                       ),
//                     ),
//
//                     // Short dash line
//                     Container(
//                       width: 16.w,
//                       height: 1,
//                       margin: EdgeInsets.symmetric(horizontal: 6.w),
//                       color: AppColors.white.withOpacity(0.40),
//                     ),
//
//                     // Label
//                     Text(
//                       'ADD PERMIT SEGMENT.',
//                       style: TextStyle(
//                         color: AppColors.white.withOpacity(0.80),
//                         fontSize: 11.sp,
//                         fontFamily: 'Lato',
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 1.6,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Segment Input Row — WHITE fill, dark text ────────────────────────────────
// class _SegmentInputRow extends StatelessWidget {
//   final PermitSegmentModel segment;
//
//   _SegmentInputRow({required this.segment});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h),
//       height: 46.h,
//       decoration: BoxDecoration(
//         color: AppColors.white,                      // ✅ White background
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(
//           color: const Color(0xFFDDE3EE),         // light grey border
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           SizedBox(width: 12.w),
//
//           // Orange location icon
//           Container(
//             width: 28.w,
//             height: 28.h,
//             decoration: BoxDecoration(
//               color: AppColors.orange.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(6.r),
//             ),
//             child: Icon(
//               Icons.location_on_rounded,
//               color: AppColors.orange,
//               size: 16.sp,
//             ),
//           ),
//
//           SizedBox(width: 10.w),
//
//           // Dark text on white bg
//           Obx(
//                 () => Text(
//               segment.route.value,
//               style: TextStyle(
//                 color: AppColors.darkGray,   // ✅ AppColors.darkGray
//                 fontSize: 14.sp,
//                 fontFamily: 'Lato',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Action Buttons ───────────────────────────────────────────────────────────
// class _ActionButtons extends StatelessWidget {
//   final VoidCallback onPreview;
//   final VoidCallback onSave;
//   final Color green;
//
//   const _ActionButtons({
//     required this.onPreview,
//     required this.onSave,
//     required this.green,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // PREVIEW — green
//         Expanded(
//           child: GestureDetector(
//             onTap: onPreview,
//             child: Container(
//               height: 54.h,
//               decoration: BoxDecoration(
//                 color: green,
//                 borderRadius: BorderRadius.circular(9.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: green.withOpacity(0.40),
//                     blurRadius: 14,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   'PREVIEW',
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 22.sp,
//                     fontFamily: 'League Gothic',
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 2.2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(width: 12.w),
//
//         // SAVE — orange
//         Expanded(
//           child: GestureDetector(
//             onTap: onSave,
//             child: Container(
//               height: 54.h,
//               decoration: BoxDecoration(
//                 color: AppColors.orange,
//                 borderRadius: BorderRadius.circular(9.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.orange.withOpacity(0.40),
//                     blurRadius: 14,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   'SAVE',
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 22.sp,
//                     fontFamily: 'League Gothic',
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 2.2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }