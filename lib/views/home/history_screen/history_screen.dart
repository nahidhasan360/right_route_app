import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';

/// ---------------------------------------------------------------------------
/// CONTROLLER (GetX)
/// ---------------------------------------------------------------------------
class HistoryController extends GetxController {
  final TextEditingController searchController = TextEditingController(); // ✅ Added controller
  RxString searchQuery = "".obs;
  RxBool selectAll = false.obs;

  RxList<RouteItem> routes = <RouteItem>[
    RouteItem(
      id: "001",
      date: "05/26/2025",
      title: "Aurora Wind Farm in Tygard",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "002",
      date: "06/04/2025",
      title: "Badger Wind Farm in Logan",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "003",
      date: "06/12/2025",
      title: "Propane Tanks Downtown Fargo",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "004",
      date: "06/21/2025",
      title: "Beethoven Wind SD",
      isSelected: false.obs,
      highlighted: true,
    ),
    RouteItem(
      id: "005",
      date: "07/15/2025",
      title: "Crane move in Dallas",
      isSelected: false.obs,
    ),
    RouteItem(
      id: "006",
      date: "08/28/2025",
      title: "Equipment Transport",
      isSelected: false.obs,
    ),
  ].obs;

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void toggleSelectAll() {
    selectAll.value = !selectAll.value;
    for (var route in routes) {
      route.isSelected.value = selectAll.value;
    }
  }

  void toggleRoute(int index) {
    routes[index].isSelected.value = !routes[index].isSelected.value;
    selectAll.value = routes.every((route) => route.isSelected.value);
  }

  void deleteSelected() {
    final selectedCount = routes.where((route) => route.isSelected.value).length;

    if (selectedCount == 0) {
      Get.snackbar(
        'No Selection',
        'Please select routes to delete',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
      return;
    }

    // ✅ UPDATED: New red dialog with single line text
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFB71C1C)),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 20),
                  GestureDetector(
                    onTap: () {
                      routes.removeWhere((route) => route.isSelected.value);
                      selectAll.value = false;
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Routes deleted successfully',
                        backgroundColor: Colors.green.shade400,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    child: Container(
                      width: 79,
                      height: 23,
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Are you sure you want to delete $selectedCount Route(s)?',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ✅ UPDATED: Duplicate navigates to Edit Route screen, no popup
  void duplicateSelected() {
    final selectedRoutes = routes.where((route) => route.isSelected.value).toList();

    if (selectedRoutes.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select a route to duplicate',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
      return;
    }

    if (selectedRoutes.length > 1) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AppColors.darkGray,
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Error', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'You can only duplicate one route at a time. Please check one only.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // ✅ Navigate to Edit Route screen (08f)
    final routeToDuplicate = selectedRoutes.first;
    Get.toNamed('/edit-route', arguments: routeToDuplicate); // Update with your actual route

    // Optional: Show snackbar
    Get.snackbar(
      'Opening Editor',
      'Edit and save your duplicated route',
      backgroundColor: Colors.blue.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  void cancel() {
    for (var route in routes) {
      route.isSelected.value = false;
      route.highlighted = false;
    }
    selectAll.value = false;

    Get.snackbar(
      'Cancelled',
      'All selections cleared',
      backgroundColor: Colors.grey.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
    );
  }

  // ✅ UPDATED: Search functionality fixed
  void searchRoutes() {
    final query = searchController.text.trim(); // ✅ Use controller value

    if (query.isEmpty) {
      for (var route in routes) {
        route.highlighted = false;
      }
      Get.snackbar(
        'Search',
        'Please enter a search term',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
      return;
    }

    bool foundMatch = false;

    for (var route in routes) {
      final searchLower = query.toLowerCase();
      final matchesId = route.id.toLowerCase().contains(searchLower);
      final matchesDate = route.date.toLowerCase().contains(searchLower);
      final matchesTitle = route.title.toLowerCase().contains(searchLower);

      if (matchesId || matchesDate || matchesTitle) {
        route.highlighted = true;
        foundMatch = true;
      } else {
        route.highlighted = false;
      }
    }

    routes.refresh(); // ✅ Refresh list

    if (!foundMatch) {
      Get.snackbar(
        'No Results',
        'No routes found matching "$query"',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Search Complete',
        'Found matching routes',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 1),
      );
    }
  }

  void openRouteDetails(int index) {
    final route = routes[index];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Text('Route Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${route.id}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('Date: ${route.date}', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Title: ${route.title}', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Close', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/route-edit', arguments: route);
            },
            child: Text('Edit Route', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose(); // ✅ Dispose controller
    super.onClose();
  }
}

class RouteItem {
  final String id;
  final String date;
  final String title;
  final RxBool isSelected;
  bool highlighted;

  RouteItem({
    required this.id,
    required this.date,
    required this.title,
    required this.isSelected,
    this.highlighted = false,
  });
}

/// ---------------------------------------------------------------------------
/// MAIN SCREEN
/// ---------------------------------------------------------------------------
class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
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
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                SizedBox(height: 18),

                Text(
                  "My Routes History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 22),

                Row(
                  children: [
                    Obx(
                          () => GestureDetector(
                        onTap: controller.toggleSelectAll,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: controller.selectAll.value
                                ? Color(0xFFFF6B35)
                                : AppColors.medGray,
                            border: Border.all(
                              color: controller.selectAll.value
                                  ? Color(0xFFFF6B35)
                                  : AppColors.medGray,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: controller.selectAll.value
                              ? Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _smallButton("Delete", onTap: controller.deleteSelected),
                        _smallButton("Duplicate", onTap: controller.duplicateSelected),
                        _smallButton("Cancel", onTap: controller.cancel),
                        _smallButton("Exit", onTap: () => Get.back()),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 15),
                Divider(color: AppColors.white, thickness: 1),
                SizedBox(height: 5),

                // ✅ UPDATED: Search bar same as Team Manager (05c)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 24),
                    SizedBox(width: 2),
                    Container(
                      width: 195,
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.medGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        cursorColor: AppColors.white,
                        cursorHeight: 18,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 2.29,
                        ),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.29,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        onChanged: controller.updateSearch,
                      ),
                    ),
                    SizedBox(width: 3),
                    GestureDetector(
                      onTap: controller.searchRoutes, // ✅ Fixed: Now calls searchRoutes
                      child: Container(
                        width: 33,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.medGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'GO',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Expanded(
                  child: Obx(
                        () => ListView.builder(
                      itemCount: controller.routes.length,
                      itemBuilder: (context, index) => _routeItem(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _smallButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeItem(int index) {
    final route = controller.routes[index];

    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: route.isSelected.value
                  ? Color(0xFF3A4A6B).withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => controller.toggleRoute(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: route.isSelected.value
                          ? Color(0xFFFF6B35)
                          : AppColors.medGray,
                      border: Border.all(
                        color: route.isSelected.value
                            ? Color(0xFFFF6B35)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: route.isSelected.value
                        ? Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${route.id} ${route.date}",
                        style: TextStyle(
                          color: route.isSelected.value
                              ? Color(0xFFFF6B35)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        route.title,
                        style: TextStyle(
                          color: route.isSelected.value
                              ? Color(0xFFFF6B35).withValues(alpha: 0.8)
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => controller.openRouteDetails(index),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: route.isSelected.value
                        ? Color(0xFFFF6B35)
                        : AppColors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          if (index < controller.routes.length - 1)
            Divider(color: AppColors.dividerColor, thickness: 1, height: 1),
        ],
      );
    });
  }
}