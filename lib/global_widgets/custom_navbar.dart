// // ═══════════════════════════════════════════════════════════════════════════
// // CustomNavbar — Fixed Version
// // ═══════════════════════════════════════════════════════════════════════════
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import '../core/routes/all_routes.dart';
//
// // ════════════════════════════════════════════════════════════════
// // NavController
// // ════════════════════════════════════════════════════════════════
// class NavController extends GetxController {
//   RxInt selectedIndex = 0.obs;
//
//   final Map<String, int> _routeToIndex = {
//     AppRoutes.homeScreen: 0,
//     AppRoutes.teamManager: 1,
//     AppRoutes.historyScreen: 2,
//     AppRoutes.accountScreen: 3,
//   };
//
//   void changeTab(int index) {
//     selectedIndex.value = index;
//     update(['navbar']);
//   }
//
//   void updateFromCurrentRoute() {
//     final currentRoute = Get.currentRoute;
//     final index = _routeToIndex[currentRoute];
//     if (index != null && selectedIndex.value != index) {
//       selectedIndex.value = index;
//       update(['navbar']);
//     }
//   }
// }
//
// // ════════════════════════════════════════════════════════════════
// // CustomNavbar Widget
// // ════════════════════════════════════════════════════════════════
// class CustomNavbar extends StatefulWidget {
//   const CustomNavbar({super.key});
//
//   @override
//   State<CustomNavbar> createState() => _CustomNavbarState();
// }
//
// class _CustomNavbarState extends State<CustomNavbar> {
//   // ✅ FIX: permanent:true — app জুড়ে একটাই instance থাকবে
//   // findOrNull দিয়ে আগে check করছি — duplicate put এড়াতে
//   late NavController _navController;
//
//   @override
//   void initState() {
//     super.initState();
//     _navController = Get.isRegistered<NavController>()
//         ? Get.find<NavController>()
//         : Get.put(NavController(), permanent: true);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // ✅ FIX: postFrameCallback — build শেষ হওয়ার পর route sync করছি
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _navController.updateFromCurrentRoute();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<NavController>(
//       id: 'navbar',
//       builder: (controller) {
//         return Container(
//           // ✅ FIX: screenutil দিয়ে responsive height
//           // + bottom padding for gesture bar (Android/iOS)
//           height: 65.h + MediaQuery.of(context).padding.bottom,
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             // ✅ FIX: Dark navy color — screenshot match
//             color: Color(0xFF0D1230),
//             border: Border(
//               top: BorderSide(
//                 color: Color(0xFF1C2448),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: SafeArea(
//             top: false,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _navItem(
//                   controller: controller,
//                   index: 0,
//                   svgIcon: "assets/icons/New-Route-white.svg",
//                   label: "New Route",
//                   route: AppRoutes.homeScreen,
//                 ),
//                 _navItem(
//                   controller: controller,
//                   index: 1,
//                   svgIcon: "assets/icons/team_white.svg",
//                   label: "Teams",
//                   route: AppRoutes.teamManager,
//                 ),
//                 _navItem(
//                   controller: controller,
//                   index: 2,
//                   svgIcon: "assets/icons/History-white.svg",
//                   label: "History",
//                   route: AppRoutes.historyScreen,
//                 ),
//                 _navItem(
//                   controller: controller,
//                   index: 3,
//                   svgIcon: "assets/icons/Account-white.svg",
//                   label: "Account",
//                   route: AppRoutes.accountScreen,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _navItem({
//     required NavController controller,
//     required int index,
//     required String svgIcon,
//     required String label,
//     required String route,
//   }) {
//     final bool isSelected = controller.selectedIndex.value == index;
//
//     return GestureDetector(
//       onTap: () {
//         // ✅ FIX: same route এ থাকলে navigate করবে না
//         if (Get.currentRoute == route) return;
//         controller.changeTab(index);
//         // ✅ FIX: offAllNamed → offNamed
//         // offAllNamed পুরো stack clear করে দেয়
//         // offNamed শুধু current page replace করে — back stack ঠিক থাকে
//         Get.offNamed(route);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
//         color: Colors.transparent,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               svgIcon,
//               width: 24.w,
//               height: 24.h,
//               colorFilter: ColorFilter.mode(
//                 // ✅ FIX: active color — screenshot match #FF8742
//                 isSelected
//                     ? const Color(0xFFFF8742)
//                     : Colors.white.withOpacity(0.55),
//                 BlendMode.srcIn,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 fontFamily: 'Lato',
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
//                 color: isSelected
//                     ? const Color(0xFFFF8742)
//                     : Colors.white.withOpacity(0.55),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  late NavController _navController;

  @override
  void initState() {
    super.initState();
    // ✅ FIX 1: Get.put() moved to initState — build()-এ আর নেই
    _navController = Get.put(NavController(), permanent: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ FIX 2: postFrameCallback একবারই register হবে, build()-এ নয়
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navController.updateFromCurrentRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      id: 'navbar',
      builder: (controller) {
        return Container(
          // ✅ FIX 3: Fixed height — SafeArea + bottomPadding handle করছে
          height: 65 + MediaQuery.of(context).padding.bottom,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF5A5A5A),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(
                  controller: controller,
                  index: 0,
                  svgIcon: "assets/icons/New-Route-white.svg",
                  label: "New Route",
                  route: AppRoutes.homeScreen,
                ),
                _navItem(
                  controller: controller,
                  index: 1,
                  svgIcon: "assets/icons/team_white.svg",
                  label: "Teams",
                  route: AppRoutes.teamManager,
                ),
                _navItem(
                  controller: controller,
                  index: 2,
                  svgIcon: "assets/icons/History-white.svg",
                  label: "History",
                  route: AppRoutes.historyScreen,
                ),
                _navItem(
                  controller: controller,
                  index: 3,
                  svgIcon: "assets/icons/Account-white.svg",
                  label: "Account",
                  route: AppRoutes.accountScreen,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem({
    required NavController controller,
    required int index,
    required String svgIcon,
    required String label,
    required String route,
  }) {
    final bool isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () {
        if (Get.currentRoute == route) return;
        controller.changeTab(index);
        Get.offAllNamed(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        color: Colors.transparent,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIcon,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFFFF8742) : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFFFF8742) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// NavController
// ════════════════════════════════════════════════════════════════
class NavController extends GetxController {
  RxInt selectedIndex = 0.obs;
  final List<String> _routeHistory = [];

  final Map<String, int> _routeToIndex = {
    AppRoutes.homeScreen: 0,
    AppRoutes.teamManager: 1,
    AppRoutes.historyScreen: 2,
    AppRoutes.accountScreen: 3,
  };

  void changeTab(int index) {
    selectedIndex.value = index;
    update(['navbar']);
  }

  void saveCurrentNavbarRoute() {
    final currentRoute = Get.currentRoute;
    if (_routeToIndex.containsKey(currentRoute)) {
      _routeHistory
        ..clear()
        ..add(currentRoute);
    }
  }

  void updateFromCurrentRoute() {
    final currentRoute = Get.currentRoute;

    if (_routeToIndex.containsKey(currentRoute)) {
      final index = _routeToIndex[currentRoute]!;
      if (selectedIndex.value != index) {
        selectedIndex.value = index;
        update(['navbar']);
      }
      if (_routeHistory.isEmpty || _routeHistory.last != currentRoute) {
        _routeHistory
          ..clear()
          ..add(currentRoute);
      }
    } else if (_routeHistory.isNotEmpty) {
      final lastNavbarRoute = _routeHistory.last;
      final index = _routeToIndex[lastNavbarRoute]!;
      if (selectedIndex.value != index) {
        selectedIndex.value = index;
        update(['navbar']);
      }
    }
  }
}