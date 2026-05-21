import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/models/route_permit_model.dart';
import 'preview_screen/preview_screen.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class PermitSegmentModel {
  final RxString route;
  PermitSegmentModel({required String route}) : route = route.obs;
}

class PermitModel {
  final String id; // local UI id (timestamp)
  final String backendId; // actual permit id from API
  final String routeId; // route id from API
  final String title;
  final RxList<PermitSegmentModel> segments;

  // API data for full detail view
  final String startLocationName;
  final double startLatitude;
  final double startLongitude;
  final String endLocationName;
  final double endLatitude;
  final double endLongitude;
  final String? permitFile;
  final List<WaypointItem> apiWaypoints;

  // UI state: whether the intermediate waypoints are expanded
  final RxBool waypointsExpanded = false.obs;

  PermitModel({
    required this.id,
    required this.backendId,
    required this.routeId,
    required this.title,
    required List<PermitSegmentModel> segments,
    this.startLocationName = '',
    this.startLatitude = 0.0,
    this.startLongitude = 0.0,
    this.endLocationName = '',
    this.endLatitude = 0.0,
    this.endLongitude = 0.0,
    this.permitFile,
    this.apiWaypoints = const [],
  }) : segments = segments.obs;

  /// All waypoints as LatLng list (start → intermediates → end)
  List<LatLng> get allLatLngs {
    final points = <LatLng>[];
    if (startLatitude != 0.0 || startLongitude != 0.0) {
      points.add(LatLng(startLatitude, startLongitude));
    }
    for (final wp in apiWaypoints) {
      if (wp.latitude != 0.0 || wp.longitude != 0.0) {
        points.add(LatLng(wp.latitude, wp.longitude));
      }
    }
    if (endLatitude != 0.0 || endLongitude != 0.0) {
      points.add(LatLng(endLatitude, endLongitude));
    }
    return points;
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────
class PermitListController extends GetxController {
  final RxList<PermitModel> permits = <PermitModel>[].obs;
  final RxBool isLoading = false.obs;
  List<LatLng> routeCoordinates = [];

  // ── Global routeId — set when any permit is loaded from API ──────────────
  // This ensures "ADD PERMIT SEGMENT" always has a valid routeId
  String globalRouteId = '';

  /// Checks if a permit with same title and same start/end coordinates already exists
  bool _isDuplicatePermit(String title, double startLat, double startLng,
      double endLat, double endLng) {
    const double tolerance = 0.0001; // ~11 meters tolerance
    for (final p in permits) {
      final sameTitle =
          p.title.trim().toUpperCase() == title.trim().toUpperCase();
      final sameStart = (p.startLatitude - startLat).abs() < tolerance &&
          (p.startLongitude - startLng).abs() < tolerance;
      final sameEnd = (p.endLatitude - endLat).abs() < tolerance &&
          (p.endLongitude - endLng).abs() < tolerance;
      if (sameTitle && sameStart && sameEnd) return true;
    }
    return false;
  }

  void addNewPermit(
    String routeName,
    List<String> segments,
    List<LatLng> coordinates,
  ) {
    String title = 'PERMIT ${permits.length + 1}';
    routeCoordinates = coordinates;

    String startName = '';
    double startLat = 0.0;
    double startLng = 0.0;
    String endName = '';
    double endLat = 0.0;
    double endLng = 0.0;
    final List<WaypointItem> wps = [];

    if (coordinates.isNotEmpty) {
      startLat = coordinates.first.latitude;
      startLng = coordinates.first.longitude;
      startName = (segments.isNotEmpty) ? segments.first : 'Start Location';

      if (coordinates.length > 1) {
        endLat = coordinates.last.latitude;
        endLng = coordinates.last.longitude;
        endName = (segments.length > 1) ? segments.last : 'End Location';

        // Intermediate coordinates map to waypoints
        for (int i = 1; i < coordinates.length - 1; i++) {
          final latlng = coordinates[i];
          final name = (i < segments.length) ? segments[i] : 'Waypoint $i';
          wps.add(WaypointItem(
            id: i,
            order: i,
            name: name,
            latitude: latlng.latitude,
            longitude: latlng.longitude,
            icon: '',
            createdAt: '',
            permit: 0,
          ));
        }
      }
    }

    // Duplicate route check
    if (_isDuplicatePermit(title, startLat, startLng, endLat, endLng)) {
      Get.snackbar(
        'Duplicate Route',
        'This route already exists. Please modify at least one waypoint before saving.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    permits.add(
      PermitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        backendId: '',
        routeId: '',
        title: title,
        segments:
            segments.map((seg) => PermitSegmentModel(route: seg)).toList(),
        startLocationName: startName,
        startLatitude: startLat,
        startLongitude: startLng,
        endLocationName: endName,
        endLatitude: endLat,
        endLongitude: endLng,
        apiWaypoints: wps,
      ),
    );
  }

  /// Called after permit creation — fetches real API data and populates the card
  Future<void> addPermitFromApi(String routeId, String permitId) async {
    debugPrint(
        '🔄 [PermitListController] Fetching permit API: routeId=$routeId, permitId=$permitId');

    // ── Store globally so ADD SEGMENT always has a valid routeId ──────────
    if (routeId.isNotEmpty) {
      globalRouteId = routeId;
      debugPrint(
          '✅ [PermitListController] globalRouteId set to: $globalRouteId');
    }
    try {
      final item =
          await RoutePermitService.fetchSinglePermit(routeId, permitId);
      if (item == null) {
        debugPrint('❌ [PermitListController] Permit not found in API response');
        // Fallback: add a basic permit
        permits.add(PermitModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          backendId: permitId,
          routeId: routeId,
          title: 'PERMIT #$permitId',
          segments: [],
        ));
        return;
      }

      // Sort intermediate waypoints by order
      final sorted = List.of(item.waypoints)
        ..sort((a, b) => a.order.compareTo(b.order));

      // Build segments for display (start + intermediates + end)
      final segs = <PermitSegmentModel>[
        PermitSegmentModel(
            route: item.startLocationName.isNotEmpty
                ? item.startLocationName
                : 'Start'),
        ...sorted.map((wp) => PermitSegmentModel(route: wp.name)),
        PermitSegmentModel(
            route:
                item.endLocationName.isNotEmpty ? item.endLocationName : 'End'),
      ];

      final permitTitle = item.displayTitle.toUpperCase();

      // Duplicate route check
      if (_isDuplicatePermit(permitTitle, item.startLatitude,
          item.startLongitude, item.endLatitude, item.endLongitude)) {
        Get.snackbar(
          'Duplicate Route',
          'This route already exists. Please modify at least one waypoint before saving.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      permits.add(PermitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        backendId: item.id.toString(),
        routeId: routeId,
        title: permitTitle,
        segments: segs,
        startLocationName: item.startLocationName,
        startLatitude: item.startLatitude,
        startLongitude: item.startLongitude,
        endLocationName: item.endLocationName,
        endLatitude: item.endLatitude,
        endLongitude: item.endLongitude,
        permitFile: item.permitFile,
        apiWaypoints: sorted,
      ));

      debugPrint(
          '✅ [PermitListController] Permit added: ${item.displayTitle}, waypoints: ${sorted.length}');
    } catch (e) {
      debugPrint('❌ [PermitListController] API error: $e');
      Get.snackbar('Error', 'Failed to fetch permit data.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Fetches all permits for [routeId] from the API.
  /// Clears local permits before loading to guarantee no stale cache.
  Future<void> fetchAllPermits(String routeId, {bool showLocalLoading = true}) async {
    if (routeId.isEmpty) {
      debugPrint('⚠️ [PermitListController] fetchAllPermits: routeId is empty, skipping.');
      return;
    }

    if (showLocalLoading) {
      isLoading.value = true;
      // Evict cache completely as requested
      permits.clear();
    }
    debugPrint('🔄 [PermitListController] fetchAllPermits started for routeId: $routeId (showLocalLoading: $showLocalLoading)');

    globalRouteId = routeId;

    try {
      final response = await RoutePermitService.fetchPermitsForRoute(routeId);

      debugPrint('✅ [PermitListController] fetchAllPermits API call succeeded.');
      debugPrint('🌐 GET URL → /navigation/route/$routeId/permit/');
      debugPrint('📦 Response JSON: success=${response.success}, permitsCount=${response.data.permits.length}');

      final mapped = <PermitModel>[];
      for (final item in response.data.permits) {
        // Sort intermediate waypoints by order
        final sorted = List.of(item.waypoints)
          ..sort((a, b) => a.order.compareTo(b.order));

        // Build segments list
        final segs = <PermitSegmentModel>[
          PermitSegmentModel(
              route: item.startLocationName.isNotEmpty
                  ? item.startLocationName
                  : 'Start'),
          ...sorted.map((wp) => PermitSegmentModel(route: wp.name)),
          PermitSegmentModel(
              route:
                  item.endLocationName.isNotEmpty ? item.endLocationName : 'End'),
        ];

        final title = item.displayTitle.toUpperCase();

        mapped.add(PermitModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_${item.id}',
          backendId: item.id.toString(),
          routeId: routeId,
          title: title,
          segments: segs,
          startLocationName: item.startLocationName,
          startLatitude: item.startLatitude,
          startLongitude: item.startLongitude,
          endLocationName: item.endLocationName,
          endLatitude: item.endLatitude,
          endLongitude: item.endLongitude,
          permitFile: item.permitFile,
          apiWaypoints: sorted,
        ));
        
        debugPrint('   👉 Mapped Permit: "$title", ID: ${item.id}, waypoints count: ${sorted.length}');
      }

      permits.assignAll(mapped);
      debugPrint('✅ [PermitListController] Set ${permits.length} mapped permits.');
    } catch (e) {
      debugPrint('❌ [PermitListController] fetchAllPermits error: $e');
      Get.snackbar(
        'Error',
        'Failed to load permits from API.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      debugPrint('🔄 [PermitListController] fetchAllPermits completed. isLoading=false');
    }
  }

  Future<void> deletePermit(PermitModel permit) async {
    final confirm = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1735),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF2A3F6A),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'DELETE PERMIT?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontFamily: 'League Gothic',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to permanently delete this permit from your route list? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13.sp,
                  fontFamily: 'Lato',
                  height: 1.45,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E294B),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFF2A3F6A),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'League Gothic',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: true),
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'DELETE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'League Gothic',
                              letterSpacing: 1.2,
                            ),
                          ),
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

    if (confirm != true) return;

    if (permit.backendId.isEmpty || permit.routeId.isEmpty) {
      debugPrint('ℹ️ [PermitListController] deletePermit: Empty backendId or routeId, performing local fallback removal.');
      permits.removeWhere((p) => p.id == permit.id);
      return;
    }

    isLoading.value = true;
    try {
      final success = await RoutePermitService.deletePermit(permit.routeId, permit.backendId);
      if (success) {
        permits.removeWhere((p) => p.id == permit.id);
        Get.snackbar(
          'Success',
          'Permit deleted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete permit from backend.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ [PermitListController] deletePermit error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while deleting the permit.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addSegment(String permitId, String routeName) {
    final permit = permits.firstWhereOrNull((p) => p.id == permitId);
    permit?.segments.add(PermitSegmentModel(route: routeName));
  }

  void onViewPermit(PermitModel permit) {
    Get.toNamed(
      AppRoutes.viewPermitScreen,
      arguments: permit,
    );
  }

  void onPreview() {
    debugPrint(
        '🔎 [PermitListScreen] onPreview clicked. permits count: ${permits.length}, routeCoordinates count: ${routeCoordinates.length}');
    // Collect all waypoint coordinates across all permits
    final allPoints = <LatLng>[];
    for (int i = 0; i < permits.length; i++) {
      final p = permits[i];
      final lats = p.allLatLngs;
      debugPrint(
          '   👉 Permit #$i ("${p.title}") allLatLngs count: ${lats.length}, points: $lats');
      allPoints.addAll(lats);
    }

    // Merge routeCoordinates to ensure no data is left behind
    if (routeCoordinates.isNotEmpty) {
      debugPrint(
          '   👉 Merging ${routeCoordinates.length} routeCoordinates...');
      for (final pt in routeCoordinates) {
        if (!allPoints.contains(pt)) {
          allPoints.add(pt);
        }
      }
    }

    final activeRouteId =
        permits.firstWhereOrNull((p) => p.routeId.isNotEmpty)?.routeId ?? '';
    debugPrint(
        '🔎 [PermitListScreen] Final allPoints generated for preview. Count: ${allPoints.length}, activeRouteId: "$activeRouteId"');

    if (allPoints.isEmpty) {
      debugPrint(
          '⚠️ [PermitListScreen] allPoints is empty! Showing error snackbar and aborting navigation.');
      Get.snackbar('Error', 'No route data available for preview.',
          backgroundColor: Colors.red, colorText: AppColors.white);
      return;
    }

    debugPrint(
        '🔎 [PermitListScreen] Navigating to PreviewScreen with arguments: {points: $allPoints, routeId: $activeRouteId}');
    Get.to(() => const PreviewScreen(), arguments: {
      'points': allPoints,
      'routeId': activeRouteId,
    });
  }

  void onSave() {
    Get.snackbar('Success', 'All permits saved successfully!',
        backgroundColor: Colors.green, colorText: AppColors.white);
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class PermitListScreen extends StatefulWidget {
  const PermitListScreen({super.key});

  @override
  State<PermitListScreen> createState() => _PermitListScreenState();
}

class _PermitListScreenState extends State<PermitListScreen> {
  final PermitListController _ctrl =
      Get.put(PermitListController(), permanent: true);

  static const Color _bg = Color(0xFF0B1129);
  static const Color _green = Color(0xFF2E7D32);

  String _getRouteId() {
    String routeId = '';
    final args = Get.arguments;
    if (args != null) {
      if (args is Map && args.containsKey('routeId') && args['routeId'] != null) {
        routeId = args['routeId'].toString();
      } else if (args is String) {
        routeId = args;
      }
    }

    if (routeId.isEmpty && _ctrl.globalRouteId.isNotEmpty) {
      routeId = _ctrl.globalRouteId;
    }
    return routeId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeId = _getRouteId();
      debugPrint('🏁 [PermitListScreen] initState: routeId determined as "$routeId"');
      if (routeId.isNotEmpty) {
        _ctrl.fetchAllPermits(routeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const CustomNavbar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: _bg.withValues(alpha: 0.87),
          child: SizedBox.expand(
            child: RefreshIndicator(
              color: AppColors.orange,
              backgroundColor: const Color(0xFF1E294B),
              onRefresh: () async {
                final routeId = _getRouteId();
                debugPrint('🔄 [PermitListScreen] Pull to refresh triggered for routeId: "$routeId"');
                if (routeId.isNotEmpty) {
                  await _ctrl.fetchAllPermits(routeId, showLocalLoading: false);
                }
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverPadding(
                      padding: EdgeInsets.only(
                        left: 18.w,
                        right: 18.w,
                        bottom: 100.h,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: 14.h),

                          // ── Header
                          const _AppHeader(),

                          SizedBox(height: 20.h),

                          // ── Permit Cards
                          Obx(
                            () {
                              if (_ctrl.isLoading.value) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                                    ),
                                  ),
                                );
                              }

                              if (_ctrl.permits.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: Center(
                                    child: Text(
                                      'NO PERMITS FOUND',
                                      style: TextStyle(
                                        color: AppColors.white.withValues(alpha: 0.6),
                                        fontSize: 16.sp,
                                        fontFamily: 'League Gothic',
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: _ctrl.permits.map((permit) {
                                  return _PermitBlock(
                                    permit: permit,
                                    onViewPermit: () => _ctrl.onViewPermit(permit),
                                    onAddSegment: () async {
                                      // Priority: permit.routeId → other permits → globalRouteId
                                      String routeId = permit.routeId;

                                      if (routeId.isEmpty) {
                                        // Search other permits
                                        for (final p in _ctrl.permits) {
                                          if (p.routeId.isNotEmpty) {
                                            routeId = p.routeId;
                                            debugPrint(
                                                "🔍 [PermitList] Found routeId from another permit: $routeId");
                                            break;
                                          }
                                        }
                                      }

                                      // Fallback to globalRouteId
                                      if (routeId.isEmpty &&
                                          _ctrl.globalRouteId.isNotEmpty) {
                                        routeId = _ctrl.globalRouteId;
                                        debugPrint(
                                                "🔍 [PermitList] Using globalRouteId: $routeId");
                                      }

                                      if (routeId.isEmpty) {
                                        debugPrint(
                                            "❌ [PermitList] No valid routeId found anywhere");
                                        Get.snackbar(
                                          'Error',
                                          'Route ID not found. Please create a permit first.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      debugPrint(
                                          "✅ [PermitList] Navigating to AddSegment with routeId: $routeId");

                                      final result = await Get.toNamed(
                                        AppRoutes.addPermitSegmentScreen,
                                        arguments: {
                                          'routeId': routeId,
                                          'permitId': permit.backendId,
                                        },
                                      );

                                      if (result != null &&
                                          result is Map &&
                                          result['success'] == true) {
                                        final returnedRouteId = result['routeId'];
                                        debugPrint(
                                            "🔄 [PermitList] New segment created successfully: routeId=$returnedRouteId");
                                        if (returnedRouteId != null) {
                                          await _ctrl.fetchAllPermits(returnedRouteId.toString());
                                        }
                                      }
                                    },
                                    onDelete: () => _ctrl.deletePermit(permit),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          SizedBox(height: 8.h),

                          // ── PREVIEW / SAVE
                          _ActionButtons(
                            onPreview: _ctrl.onPreview,
                            onSave: _ctrl.onSave,
                            green: _green,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App Header ───────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          ImageManager.splashScreenLogo,
          width: 175.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 14.h),
        Text(
          'YOUR PERMITS',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 34.sp,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Manage your route permits and add new ones as\nneeded.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.68),
            fontSize: 13.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// ─── Permit Block ─────────────────────────────────────────────────────────────
class _PermitBlock extends StatelessWidget {
  final PermitModel permit;
  final VoidCallback onViewPermit;
  final VoidCallback onAddSegment;
  final VoidCallback onDelete;

  const _PermitBlock({
    required this.permit,
    required this.onViewPermit,
    required this.onAddSegment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Permit Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: const Color(0xFF2A3F6A),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title row — icon + title
                      Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.description_rounded,
                              color: AppColors.white,
                              size: 19.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            permit.title,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16.sp,
                              fontFamily: 'League Gothic',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // ── Segment rows (Start always visible)
                      Obx(() {
                        if (permit.segments.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Always show first (start)
                        final widgets = <Widget>[
                          _SegmentInputRow(
                              segment: permit.segments.first, isStart: true),
                        ];

                        // Intermediate waypoints
                        final hasMiddle = permit.segments.length > 2;
                        if (hasMiddle) {
                          // Expand/collapse toggle
                          widgets.add(
                            GestureDetector(
                              onTap: () => permit.waypointsExpanded.value =
                                  !permit.waypointsExpanded.value,
                              child: Obx(() => Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          permit.waypointsExpanded.value
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          color: AppColors.orange,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          permit.waypointsExpanded.value
                                              ? 'Hide waypoints'
                                              : '${permit.segments.length - 2} waypoints — tap to show',
                                          style: TextStyle(
                                            color: AppColors.orange,
                                            fontSize: 11.sp,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          );

                          // Middle segments (collapsible)
                          Obx(() {
                            if (permit.waypointsExpanded.value) {
                              for (int i = 1;
                                  i < permit.segments.length - 1;
                                  i++) {
                                widgets.add(_SegmentInputRow(
                                    segment: permit.segments[i]));
                              }
                            }
                            return const SizedBox.shrink();
                          });

                          // Reactive middle segments
                          widgets.add(
                            Obx(() => permit.waypointsExpanded.value
                                ? Column(
                                    children: permit.segments
                                        .sublist(1, permit.segments.length - 1)
                                        .map((seg) =>
                                            _SegmentInputRow(segment: seg))
                                        .toList(),
                                  )
                                : const SizedBox.shrink()),
                          );
                        }

                        // Always show last (end) if more than 1 segment
                        if (permit.segments.length > 1) {
                          widgets.add(_SegmentInputRow(
                            segment: permit.segments.last,
                            isEnd: true,
                          ));
                        }

                        return Column(children: widgets);
                      }),

                      SizedBox(height: 10.h),

                      // ── VIEW PERMIT button
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: onViewPermit,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(7.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.orange.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'VIEW PERMIT',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 13.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Positioned Close Button
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: SvgPicture.asset(
                      'assets/icons/Close-X-Circle.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── ADD PERMIT SEGMENT
          Transform.translate(
            offset: Offset(-10.w, 0),
            child: GestureDetector(
              onTap: onAddSegment,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(top: 6.h, bottom: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 16.sp,
                      ),
                    ),
                    Container(
                      width: 16.w,
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      color: AppColors.white.withValues(alpha: 0.40),
                    ),
                    Text(
                      'ADD PERMIT SEGMENT.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.80),
                        fontSize: 11.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segment Input Row ────────────────────────────────────────────────────────
class _SegmentInputRow extends StatelessWidget {
  final PermitSegmentModel segment;
  final bool isStart;
  final bool isEnd;

  const _SegmentInputRow({
    required this.segment,
    this.isStart = false,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = AppColors.orange;
    IconData iconData = Icons.location_on_rounded;
    if (isStart) {
      iconData = Icons.radio_button_checked;
      iconColor = const Color(0xFF4CAF50);
    } else if (isEnd) {
      iconData = Icons.location_on_rounded;
      iconColor = AppColors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      height: 46.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFDDE3EE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(
              () => Text(
                segment.route.value,
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 14.sp,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onSave;
  final Color green;

  const _ActionButtons({
    required this.onPreview,
    required this.onSave,
    required this.green,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // PREVIEW
        Expanded(
          child: GestureDetector(
            onTap: onPreview,
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(9.r),
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.40),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'PREVIEW',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22.sp,
                    fontFamily: 'League Gothic',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // SAVE
        Expanded(
          child: GestureDetector(
            onTap: onSave,
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(9.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.40),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22.sp,
                    fontFamily: 'League Gothic',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
