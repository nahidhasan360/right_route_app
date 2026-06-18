// // ═══════════════════════════════════════════════════════════════════════════
// // permit_selection_screen.dart
// // ═══════════════════════════════════════════════════════════════════════════
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:right_routes/global_widgets/custom_navbar.dart';
// import 'package:right_routes/utils/assets_manager.dart';
// import 'package:right_routes/utils/colors.dart';
// import 'permit_selection_controller.dart';


// // ─── Color constants ──────────────────────────────────────────────────────────
// class _C {
//   static const bg         = Color(0xFF060D1F);
//   static const cardBorder = Color(0xFF1E2D4A);
//   static const inputBg    = Color(0xFFFFFFFF);
//   static const labelColor = Color(0xFFB0BEC5);
//   static const hintColor  = Color(0xFF9E9E9E);
//   static const textDark   = Color(0xFF1A1A2E);
//   static const orange     = Color(0xFFF58434);
// }

// // ─── Screen ───────────────────────────────────────────────────────────────────
// class PermitSelectionScreen extends StatelessWidget {
//   PermitSelectionScreen({super.key});

//   final PermitSelectionController ctrl =
//   Get.find<PermitSelectionController>();

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor      : _C.bg,
//         extendBody           : true,
//         extendBodyBehindAppBar: true,
//         bottomNavigationBar  : const CustomNavbar(),
//         body: Container(
//           width : double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(ImageManager.mapBackground),
//               fit  : BoxFit.cover,
//             ),
//           ),
//           child: SizedBox.expand(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: MediaQuery.of(context).size.height,
//                 ),
//                 child: SafeArea(
//                   bottom: false,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 22.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 16.h),

//                         // ── Logo ─────────────────────────────────────────
//                         Image.asset(
//                           ImageManager.splashScreenLogo,
//                           width: 170.w,
//                           fit  : BoxFit.contain,
//                         ),

//                         SizedBox(height: 14.h),

//                         // ── Title ─────────────────────────────────────────
//                         Text(
//                           'ADD PERMIT SEGMENT',
//                           style: TextStyle(
//                             color        : Colors.white,
//                             fontSize     : 32.sp,
//                             fontFamily   : 'League Gothic',
//                             fontWeight   : FontWeight.w400,
//                             letterSpacing: 2.2,
//                             height       : 1.0.h,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),

//                         SizedBox(height: 22.h),

//                         // ── Group 1: Waypoints (RESTORED) ──────────────────
//                         _GroupBox(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const _FieldLabel(label: 'Starting Point'),
//                               SizedBox(height: 7.h),
//                               _InputField(
//                                 controller: ctrl.startingPointController,
//                                 hint      : 'Enter starting waypoint',
//                                 icon      : Icons.my_location_rounded,
//                                 onIconTap : ctrl.onStartLocationIconTap,
//                               ),

//                               SizedBox(height: 14.h),
//                               const _FieldLabel(label: 'Ending Point'),
//                               SizedBox(height: 7.h),
//                               _InputField(
//                                 controller: ctrl.endingPointController,
//                                 hint      : 'Enter ending waypoint',
//                                 icon      : Icons.pin_drop_rounded,
//                                 onIconTap : ctrl.onEndLocationIconTap,
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(height: 24.h),

//                         // ── Section Title for Permits ─────────────────────
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'SELECT PERMIT TYPE',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18.sp,
//                               fontFamily: 'League Gothic',
//                               fontWeight: FontWeight.w400,
//                               letterSpacing: 1.8,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 12.h),

//                         // ── List of Permits ──────────────────────────────
//                         Obx(() => Column(
//                           children: ctrl.permits.map((permit) {
//                             final isSelected = ctrl.selectedPermitTitle.value == permit['title'];
//                             return Padding(
//                               padding: EdgeInsets.only(bottom: 12.h),
//                               child: GestureDetector(
//                                 onTap: () => ctrl.selectedPermitTitle.value = permit['title'] ?? '',
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 16.w,
//                                     vertical: 16.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isSelected 
//                                         ? AppColors.orange.withOpacity(0.1)
//                                         : const Color(0xFF162040).withOpacity(0.6),
//                                     borderRadius: BorderRadius.circular(12.r),
//                                     border: Border.all(
//                                       color: isSelected ? AppColors.orange : const Color(0xFF2A3F6A),
//                                       width: 1.2.w,
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 40.w,
//                                         height: 40.h,
//                                         decoration: BoxDecoration(
//                                           color: isSelected 
//                                               ? AppColors.orange 
//                                               : AppColors.orange.withOpacity(0.15),
//                                           borderRadius: BorderRadius.circular(10.r),
//                                         ),
//                                         child: Icon(
//                                           Icons.description_rounded,
//                                           color: isSelected ? Colors.white : AppColors.orange,
//                                           size: 20.sp,
//                                         ),
//                                       ),
//                                       SizedBox(width: 14.w),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               permit['title'] ?? '',
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16.sp,
//                                                 fontFamily: 'Lato',
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4.h),
//                                             Text(
//                                               permit['id'] ?? '',
//                                               style: TextStyle(
//                                                 color: Colors.white.withOpacity(0.5),
//                                                 fontSize: 12.sp,
//                                                 fontFamily: 'Lato',
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       if (isSelected)
//                                         Icon(
//                                           Icons.check_circle_rounded,
//                                           color: AppColors.orange,
//                                           size: 24.sp,
//                                         )
//                                       else
//                                         Icon(
//                                           Icons.circle_outlined,
//                                           color: Colors.white.withOpacity(0.2),
//                                           size: 24.sp,
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         )),

//                         SizedBox(height: 32.h),

//                         // ── PROCESS button ────────────────────────────────
//                         Obx(() {
//                           final canProcess = ctrl.selectedPermitTitle.value.isNotEmpty &&
//                               ctrl.startingPointController.text.isNotEmpty &&
//                               ctrl.endingPointController.text.isNotEmpty;
                          
//                           return GestureDetector(
//                             onTap: canProcess ? () {
//                               debugPrint("👆 [UI] PermitSelectionScreen PROCESS tapped!");
//                               final start = ctrl.startingPointController.text;
//                               final end = ctrl.endingPointController.text;
//                               final title = ctrl.selectedPermitTitle.value;
//                               debugPrint("📦 [PermitSelectionScreen] Navigating back with: $start to $end ($title)");
//                               Get.back(result: "$start to $end ($title)");
//                             } : () {
//                                debugPrint("❌ [PermitSelectionScreen] PROCESS tapped but required fields missing!");
//                                Get.snackbar(
//                                  'Required Fields',
//                                  'Please fill waypoints and select a permit.',
//                                  backgroundColor: Colors.redAccent,
//                                  colorText: Colors.white,
//                                );
//                             },
//                             child: Container(
//                               width     : 373.w,
//                               height    : 56.h,
//                               decoration: BoxDecoration(
//                                 color       : canProcess ? _C.orange : _C.orange.withOpacity(0.4),
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'PROCESS',
//                                   style: TextStyle(
//                                     color        : Colors.white,
//                                     fontSize     : 24.sp,
//                                     fontFamily   : 'League Gothic',
//                                     fontWeight   : FontWeight.w400,
//                                     letterSpacing: 3.0,
//                                     height       : 1.0.h,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),

//                         SizedBox(height: 100.h),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Group Box ────────────────────────────────────────────────────────────────
// class _GroupBox extends StatelessWidget {
//   final Widget child;
//   const _GroupBox({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width     : double.infinity,
//       padding   : EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
//       decoration: BoxDecoration(
//         color       : Colors.transparent,
//         borderRadius: BorderRadius.circular(12.r),
//         border      : Border.all(color: _C.cardBorder, width: 1.0.w),
//       ),
//       child: child,
//     );
//   }
// }

// // ─── Field Label ──────────────────────────────────────────────────────────────
// class _FieldLabel extends StatelessWidget {
//   final String label;
//   const _FieldLabel({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       label,
//       style: TextStyle(
//         color        : _C.labelColor,
//         fontSize     : 12.sp,
//         fontFamily   : 'Lato',
//         fontWeight   : FontWeight.w600,
//         letterSpacing: 0.3,
//       ),
//     );
//   }
// }

// // ─── White Input Field — icon is now tappable ─────────────────────────────────
// class _InputField extends StatelessWidget {
//   final TextEditingController controller;
//   final String                hint;
//   final IconData              icon;
//   final VoidCallback?         onIconTap; // NEW: map dialog trigger

//   const _InputField({
//     required this.controller,
//     required this.hint,
//     required this.icon,
//     this.onIconTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height    : 48.h,
//       decoration: BoxDecoration(
//         color       : _C.inputBg,
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(width: 14.w),
//           Expanded(
//             child: TextField(
//               controller       : controller,
//               textAlignVertical: TextAlignVertical.center,
//               cursorColor      : _C.textDark,
//               style: TextStyle(
//                 color     : _C.textDark,
//                 fontSize  : 14.sp,
//                 fontFamily: 'Lato',
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 hintText      : hint,
//                 hintStyle     : TextStyle(
//                   color     : _C.hintColor,
//                   fontSize  : 13.sp,
//                   fontFamily: 'Lato',
//                 ),
//                 border        : InputBorder.none,
//                 isDense       : true,
//                 contentPadding: EdgeInsets.zero,
//               ),
//             ),
//           ),

//           // ── Tappable orange icon badge ─────────────────────────────────
//           GestureDetector(
//             onTap: onIconTap,
//             child: Container(
//               width     : 32.w,
//               height    : 32.h,
//               margin    : EdgeInsets.only(right: 8.w),
//               decoration: BoxDecoration(
//                 color       : _C.orange,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Icon(icon, color: Colors.white, size: 16.sp),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Orange Square Icon Button ────────────────────────────────────────────────
// class _OrangeIconBtn extends StatelessWidget {
//   final IconData     icon;
//   final double       size;
//   final VoidCallback onTap;

//   const _OrangeIconBtn({
//     required this.icon,
//     required this.size,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width     : size,
//         height    : size,
//         decoration: BoxDecoration(
//           color       : _C.orange,
//           borderRadius: BorderRadius.circular(10.r),
//           boxShadow   : [
//             BoxShadow(
//               color     : _C.orange.withOpacity(0.30),
//               blurRadius: 10,
//               offset    : const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size : (size * 0.44).sp,
//         ),
//       ),
//     );
//   }
// }