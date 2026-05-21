// ═══════════════════════════════════════════════════════════════════════════
// view_permit.dart  (View Permit Detail Screen)
// Receives PermitModel via Get.arguments and displays full permit details
// using the exact same design language and interactive map/waypoint editing
// layout as confirm_your_routes.dart.
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math' show Point;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/home/home_api_constant/home_api_constant.dart';
import 'package:right_routes/views/home/create_new_routes/permit_list/permit_list_screen.dart';
import 'package:right_routes/views/home/create_new_routes/permit_list/preview_screen/preview_screen.dart';
import 'package:right_routes/models/route_permit_model.dart';

// ─── Design Tokens matching confirm_your_routes.dart ─────────────────────────
class _C {
  static const darkBg = Color(0xFF0D1B2A);
  static const green = Color(0xFF2E7D32);
  static const actionGreen = Color(0xFF2E5D2E);
  static const blueBadge = Color(0xFF2C4A7A);
  static const borderSubtle = Color(0xFF2C3E50);
  static const wpGreen = Color(0xFF2E7D32);
  static const wpRed = Color(0xFFCC2222);
}

// ─── Controller ───────────────────────────────────────────────────────────────
class ViewPermitController extends GetxController {
  final PermitModel permit;
  ViewPermitController(this.permit);

  static const String _maptilerKey = 'dHNKoVs9jL46w6oUpFt3';
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';
  static const Duration _osrmTimeout = Duration(seconds: 15);
  static const int _osrmMaxRetries = 2;
  static const double _pinTapThreshold = 0.003;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC OBSERVABLES  (view binds here)
  // ─────────────────────────────────────────────────────────────
  final RxString distance = '0.0 miles'.obs;
  final RxBool isMapReady = false.obs;
  final RxBool isRouteLoading = false.obs;

  // State for "Add Pin" interactive mode
  final RxBool isAddingPinMode = false.obs;

  final RxList<TextEditingController> waypointControllers =
      <TextEditingController>[].obs;
  final RxList<String> waypoints = <String>[].obs;
  final RxInt selectedWaypointIndex = (-1).obs;
  final RxBool isDragging = false.obs;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC NON-REACTIVE  (set once, read by view)
  // ─────────────────────────────────────────────────────────────
  final TextEditingController routeNameController = TextEditingController();

  LatLng currentLocation = const LatLng(43.5460, -96.7313);

  String? currentRouteId;
  String? currentPermitId;
  final RxList<int?> waypointIds = <int?>[].obs;

  // ─────────────────────────────────────────────────────────────
  // PRIVATE MAP STATE
  // ─────────────────────────────────────────────────────────────
  MapLibreMapController? mapController;

  final List<Symbol> _waypointSymbols = [];
  final List<LatLng> _waypointPositions = [];
  final List<bool> _waypointSelectedStates = [];
  Line? _routeLine;

  LatLng _mapCenter = const LatLng(43.5460, -96.7313);
  double _mapZoom = 11.0;
  bool _iconsLoaded = false;
  int? _draggingPinIndex;

  int _routeGeneration = 0;

  // ─────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    routeNameController.text = permit.title;
    currentRouteId = permit.routeId;
    currentPermitId =
        permit.backendId.isNotEmpty ? permit.backendId : permit.id;

    _initializeFromPermitModel();
  }

  @override
  void onClose() {
    routeNameController.dispose();
    _clearWaypointControllers();
    mapController = null;
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ─────────────────────────────────────────────────────────────
  void _initializeFromPermitModel() {
    try {
      waypoints.clear();
      _clearWaypointControllers();
      _waypointPositions.clear();
      _waypointSelectedStates.clear();
      waypointIds.clear();

      // Start Location
      if (permit.startLocationName.isNotEmpty) {
        _appendWaypoint(
          permit.startLocationName,
          LatLng(permit.startLatitude, permit.startLongitude),
          null,
        );
      }

      // Intermediate Waypoints
      for (final wp in permit.apiWaypoints) {
        _appendWaypoint(
          wp.name,
          LatLng(wp.latitude, wp.longitude),
          wp.id != 0 ? wp.id : null,
        );
      }

      // End Location
      if (permit.endLocationName.isNotEmpty && permit.allLatLngs.length > 1) {
        _appendWaypoint(
          permit.endLocationName,
          LatLng(permit.endLatitude, permit.endLongitude),
          null,
        );
      }

      if (_waypointPositions.isNotEmpty) {
        currentLocation = _waypointPositions.first;
        _mapCenter = _waypointPositions.first;
      }
    } catch (e) {
      debugPrint('ViewPermitController init error: $e');
      _setDefaultWaypoints();
    }
  }

  void _appendWaypoint(String label, LatLng? coord, [int? id]) {
    waypoints.add(label);
    waypointControllers.add(TextEditingController(text: label));
    _waypointSelectedStates.add(false);
    waypointIds.add(id);
    _waypointPositions.add(coord ??
        LatLng(
          currentLocation.latitude + _waypointPositions.length * 0.01,
          currentLocation.longitude + _waypointPositions.length * 0.01,
        ));
  }

  // ─────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────
  // MAP EVENTS
  // ─────────────────────────────────────────────────────────────
  void onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    isMapReady.value = true;

    controller.onSymbolTapped.add((symbol) {
      final idx = _waypointSymbols.indexOf(symbol);
      if (idx != -1) _handlePinTap(idx);
    });

    controller.onFeatureDrag.add((
      Point<double> point,
      LatLng origin,
      LatLng current,
      LatLng delta,
      String id,
      Annotation? annotation,
      DragEventType eventType,
    ) async {
      if (annotation is! Symbol) return;
      final idx = _waypointSymbols.indexOf(annotation);
      if (idx == -1) return;

      if (eventType == DragEventType.start) {
        isDragging.value = true;
        _draggingPinIndex = idx;
      }

      if (idx < _waypointPositions.length) _waypointPositions[idx] = current;

      if (eventType == DragEventType.end) {
        isDragging.value = false;
        _draggingPinIndex = null;

        final address =
            await _reverseGeocode(current.latitude, current.longitude);
        if (idx < waypoints.length) {
          waypoints[idx] = address;
          waypoints.refresh();
        }
        if (idx < waypointControllers.length) {
          waypointControllers[idx].text = address;
        }

        await _refreshMap();
      }
    });
  }

  void onCameraMove(CameraPosition position) {
    _mapCenter = position.target;
    _mapZoom = position.zoom;
  }

  Future<void> onStyleLoaded() async {
    if (mapController == null) return;
    try {
      _iconsLoaded = false;
      await _loadIcons();
      await _refreshMap();
    } catch (e) {
      debugPrint('onStyleLoaded error: $e');
    }
  }

  Future<void> onMapClick(LatLng point) async {
    if (isAddingPinMode.value) {
      isAddingPinMode.value = false;
      await _addPinAtLocation(point);
      return;
    }

    final idx = _pinNear(point);
    if (idx != null) {
      _handlePinTap(idx);
    } else {
      _deselectAll();
    }
  }

  Future<void> onMapLongClick(LatLng point) async {
    final idx = _pinNear(point);
    if (idx != null) _handlePinTap(idx);
  }

  // ─────────────────────────────────────────────────────────────
  // MAP DRAWING
  // ─────────────────────────────────────────────────────────────
  Future<void> _refreshMap() async {
    await _addAllMarkers();
    await _drawRealRoadPolyline();
    _calculateDistance();
    _fitMapToWaypoints();
  }

  Future<void> _loadIcons() async {
    if (mapController == null || _iconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await mapController!.addImage('pin-orange', bytes.buffer.asUint8List());
      _iconsLoaded = true;
    } catch (e) {
      debugPrint('Icon load error: $e');
    }
  }

  Future<void> _addAllMarkers() async {
    if (mapController == null || !_iconsLoaded) return;
    try {
      if (_waypointSymbols.isNotEmpty) {
        await mapController!.removeSymbols(_waypointSymbols);
        _waypointSymbols.clear();
      }

      for (int i = 0; i < _waypointPositions.length; i++) {
        final isSelected =
            i < _waypointSelectedStates.length && _waypointSelectedStates[i];
        final sym = await mapController!.addSymbol(SymbolOptions(
          geometry: _waypointPositions[i],
          iconImage: 'pin-orange',
          iconSize: isSelected ? 0.55 : 0.45,
          textField: '${i + 1}',
          textSize: 10.0,
          textOffset: const Offset(0, 1.2),
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 1.5,
          textHaloBlur: 0.5,
          draggable: true,
        ));
        _waypointSymbols.add(sym);
      }
    } catch (e) {
      debugPrint('AddAllMarkers error: $e');
    }
  }

  Future<void> _drawRealRoadPolyline() async {
    if (mapController == null || _waypointPositions.length < 2) {
      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
        } catch (_) {}
        _routeLine = null;
      }
      isRouteLoading.value = false;
      return;
    }

    final generation = ++_routeGeneration;
    isRouteLoading.value = true;

    try {
      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
        } catch (_) {}
        _routeLine = null;
      }

      if (generation != _routeGeneration) return;

      final routeGeometry =
          await _fetchOsrmRoute(List.from(_waypointPositions));

      if (generation != _routeGeneration) return;
      if (mapController == null) return;

      _routeLine = await mapController!.addLine(LineOptions(
        geometry: routeGeometry,
        lineColor: '#FF6B35',
        lineWidth: 5.0,
        lineOpacity: 0.9,
        lineJoin: 'round',
      ));
    } catch (e) {
      debugPrint('DrawRealRoadPolyline error: $e');
    } finally {
      if (generation == _routeGeneration) {
        isRouteLoading.value = false;
      }
    }
  }

  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> points) async {
    final coordStr =
        points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri =
        Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    for (int attempt = 0; attempt <= _osrmMaxRetries; attempt++) {
      try {
        final response = await http.get(uri,
            headers: {'User-Agent': 'RightRoutes/1.0'}).timeout(_osrmTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final geometry = (routes[0] as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List;
            return coords
                .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble(),
                    ))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM attempt ${attempt + 1} failed: $e');
        if (attempt < _osrmMaxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    return List.from(points);
  }

  void _calculateDistance() {
    if (_waypointPositions.length < 2) {
      distance.value = '0.0 miles';
      return;
    }
    double totalMeters = 0.0;
    for (int i = 0; i < _waypointPositions.length - 1; i++) {
      totalMeters += Geolocator.distanceBetween(
        _waypointPositions[i].latitude,
        _waypointPositions[i].longitude,
        _waypointPositions[i + 1].latitude,
        _waypointPositions[i + 1].longitude,
      );
    }
    distance.value = '${(totalMeters / 1609.34).toStringAsFixed(1)} miles';
  }

  void _fitMapToWaypoints() {
    if (mapController == null || _waypointPositions.isEmpty) return;

    try {
      if (_waypointPositions.length == 1) {
        mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_waypointPositions[0], 13.0));
        return;
      }

      final lats = _waypointPositions.map((p) => p.latitude);
      final lngs = _waypointPositions.map((p) => p.longitude);
      final minLat = lats.reduce((a, b) => a < b ? a : b);
      final maxLat = lats.reduce((a, b) => a > b ? a : b);
      final minLng = lngs.reduce((a, b) => a < b ? a : b);
      final maxLng = lngs.reduce((a, b) => a > b ? a : b);

      final latPad = ((maxLat - minLat) * 0.15).clamp(0.005, 5.0);
      final lngPad = ((maxLng - minLng) * 0.15).clamp(0.005, 5.0);

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - latPad, minLng - lngPad),
          northeast: LatLng(maxLat + latPad, maxLng + lngPad),
        ),
        left: 40,
        top: 60,
        right: 40,
        bottom: 60,
      ));
    } catch (e) {
      debugPrint('ViewPermitController fitMap error: $e');
    }
  }

  void _handlePinTap(int index) {
    final wasSelected = index < _waypointSelectedStates.length &&
        _waypointSelectedStates[index];
    _deselectAll();
    if (!wasSelected) {
      if (index < _waypointSelectedStates.length) {
        _waypointSelectedStates[index] = true;
      }
      selectedWaypointIndex.value = index;
    }
    _addAllMarkers();
  }

  void _deselectAll() {
    for (int i = 0; i < _waypointSelectedStates.length; i++) {
      _waypointSelectedStates[i] = false;
    }
    selectedWaypointIndex.value = -1;
  }

  int? _pinNear(LatLng tap) {
    int? bestIdx;
    double bestDist = double.infinity;
    for (int i = 0; i < _waypointPositions.length; i++) {
      final d = (tap.latitude - _waypointPositions[i].latitude).abs() +
          (tap.longitude - _waypointPositions[i].longitude).abs();
      if (d < _pinTapThreshold && d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  // ─────────────────────────────────────────────────────────────
  // PUBLIC UI ACTIONS
  // ─────────────────────────────────────────────────────────────
  Future<void> zoomIn() async {
    if (mapController == null) return;
    try {
      final z = (_mapZoom + 1).clamp(1.0, 20.0);
      await mapController!.animateCamera(
        CameraUpdate.zoomTo(z),
        duration: const Duration(milliseconds: 300),
      );
      _mapZoom = z;
    } catch (e) {
      debugPrint('ViewPermitController zoomIn error: $e');
    }
  }

  Future<void> zoomOut() async {
    if (mapController == null) return;
    try {
      final z = (_mapZoom - 1).clamp(1.0, 20.0);
      await mapController!.animateCamera(
        CameraUpdate.zoomTo(z),
        duration: const Duration(milliseconds: 300),
      );
      _mapZoom = z;
    } catch (e) {
      debugPrint('ViewPermitController zoomOut error: $e');
    }
  }

  void toggleAddPinMode() {
    isAddingPinMode.value = !isAddingPinMode.value;
  }

  Future<void> _addPinAtLocation(LatLng point) async {
    try {
      final address = await _reverseGeocode(point.latitude, point.longitude);
      int? newId;

      if (currentRouteId != null && currentPermitId != null) {
        final url = Uri.parse(
            '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/add-waypoint/');

        final request = http.MultipartRequest('POST', url);

        request.fields['latitude'] = point.latitude.toString();
        request.fields['longitude'] = point.longitude.toString();
        request.fields['name'] = address;

        final response = await request.send();
        if (response.statusCode == 201 || response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final data = json.decode(respStr);
          if (data['data'] != null && data['data']['id'] != null) {
            newId = data['data']['id'];
          }
          Get.snackbar('Success', 'Waypoint added to server',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', 'Failed to add waypoint to server',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }

      _appendWaypoint(address, point, newId);
      await _refreshMap();
    } catch (e) {
      debugPrint("❌ Add waypoint error: $e");
    }
  }

  Future<void> addMapPin() async {
    toggleAddPinMode();
  }

  Future<void> deleteSelectedMapPin() async {
    final idx = selectedWaypointIndex.value;
    if (idx == -1) {
      Get.snackbar('No pin selected', 'Tap a pin on the map to select it',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (waypoints.length <= 2) {
      Get.snackbar('Cannot remove', 'A route needs at least 2 waypoints',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final wId = waypointIds[idx];
    if (wId != null && currentRouteId != null && currentPermitId != null) {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/remove-waypoint/$wId/');

      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200 && response.statusCode != 204) {
        Get.snackbar('Error', 'Failed to delete waypoint on server',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    waypoints.removeAt(idx);
    final controllerToDispose = waypointControllers[idx];
    waypointControllers.removeAt(idx);
    controllerToDispose.dispose();

    _waypointPositions.removeAt(idx);
    _waypointSelectedStates.removeAt(idx);
    waypointIds.removeAt(idx);

    selectedWaypointIndex.value = -1;
    await _refreshMap();
  }

  void deleteSelectedWaypoint() => deleteSelectedMapPin();

  Future<void> updateRoute() async {
    final idx = selectedWaypointIndex.value;
    if (idx != -1 && currentRouteId != null && currentPermitId != null) {
      final wId = waypointIds[idx];
      if (wId != null) {
        final url = Uri.parse(
            '${HomeApiConstant.baseUrl}/navigation/route/$currentRouteId/permit/$currentPermitId/update-waypoint/$wId/');

        final point = _waypointPositions[idx];
        final name = waypointControllers[idx].text;

        final request = http.MultipartRequest('PATCH', url);

        request.fields['latitude'] = point.latitude.toString();
        request.fields['longitude'] = point.longitude.toString();
        request.fields['name'] = name;

        final response = await request.send();
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar('Success', 'Waypoint updated on server',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', 'Failed to update waypoint on server',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Local Update',
            'Waypoint updated locally (not yet saved to server)',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    }

    for (int i = 0; i < waypointControllers.length; i++) {
      if (i < waypoints.length) waypoints[i] = waypointControllers[i].text;
    }
    waypoints.refresh();
    await _refreshMap();
  }

  void selectWaypoint(int index) {
    if (index < 0 || index >= waypoints.length) return;
    final wasSelected = index < _waypointSelectedStates.length &&
        _waypointSelectedStates[index];
    _deselectAll();
    if (!wasSelected) {
      if (index < _waypointSelectedStates.length) {
        _waypointSelectedStates[index] = true;
      }
      selectedWaypointIndex.value = index;
    }
    _addAllMarkers();
  }

  void updateWaypoint(int index, String val) {
    if (index >= 0 && index < waypoints.length) {
      waypoints[index] = val;
      waypoints.refresh();
    }
  }

  void updateRouteName(String val) => routeNameController.text = val;

  void addWaypointAt(int index) {
    if (index >= _waypointPositions.length) return;
    final p1 = _waypointPositions[index];
    final p2 = (index < _waypointPositions.length - 1)
        ? _waypointPositions[index + 1]
        : LatLng(p1.latitude + 0.01, p1.longitude + 0.01);
    final mid = LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
    waypoints.insert(index + 1, 'New Stop');
    waypointControllers.insert(
        index + 1, TextEditingController(text: 'New Stop'));
    _waypointPositions.insert(index + 1, mid);
    _waypointSelectedStates.insert(index + 1, false);
    _refreshMap();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  void _setDefaultWaypoints() {
    waypoints.assignAll(['Your location', 'Stop 1', 'Stop 2']);
    _clearWaypointControllers();
    _waypointSelectedStates.clear();
    _waypointPositions.clear();
    for (int i = 0; i < waypoints.length; i++) {
      waypointControllers.add(TextEditingController(text: waypoints[i]));
      _waypointSelectedStates.add(false);
      _waypointPositions.add(LatLng(
        currentLocation.latitude + i * 0.01,
        currentLocation.longitude + i * 0.01,
      ));
    }
  }

  void _clearWaypointControllers() {
    for (final c in waypointControllers) {
      c.dispose();
    }
    waypointControllers.clear();
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final places = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = <String>[
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  List<LatLng> get waypointPositions => List.unmodifiable(_waypointPositions);
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ViewPermitScreen extends StatelessWidget {
  ViewPermitScreen({super.key});

  static const String _kMapStyle =
      'https://api.maptiler.com/maps/openstreetmap/style.json?key=dHNKoVs9jL46w6oUpFt3';

  PermitModel get permit {
    final args = Get.arguments;
    if (args is PermitModel) {
      return args;
    }
    if (args is Map) {
      if (args['permit'] is PermitModel) {
        return args['permit'] as PermitModel;
      }
      // Reconstruct PermitModel from Map keys if fields are passed directly in a Map
      return PermitModel(
        id: args['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        backendId:
            args['backendId']?.toString() ?? args['permitId']?.toString() ?? '',
        routeId: args['routeId']?.toString() ?? '',
        title: (args['title'] ?? args['permitType'] ?? 'VIEW PERMIT')
            .toString()
            .toUpperCase(),
        segments: args['segments'] != null
            ? List<PermitSegmentModel>.from(args['segments'])
            : <PermitSegmentModel>[],
        startLocationName: args['startLocationName']?.toString() ??
            args['startLocation']?.toString() ??
            '',
        startLatitude: (args['startLatitude'] as num?)?.toDouble() ?? 0.0,
        startLongitude: (args['startLongitude'] as num?)?.toDouble() ?? 0.0,
        endLocationName: args['endLocationName']?.toString() ??
            args['endLocation']?.toString() ??
            '',
        endLatitude: (args['endLatitude'] as num?)?.toDouble() ?? 0.0,
        endLongitude: (args['endLongitude'] as num?)?.toDouble() ?? 0.0,
        apiWaypoints: args['apiWaypoints'] != null
            ? List<WaypointItem>.from(args['apiWaypoints'])
            : <WaypointItem>[],
      );
    }
    // Safe fallback to prevent crash in all circumstances
    return PermitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      backendId: '',
      routeId: '',
      title: 'PERMIT DETAILS',
      segments: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ViewPermitController(permit));

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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'PERMIT DETAILS',
                              style: const TextStyle(
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
                              _buildRouteNameField(context, ctrl),
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
                        _buildMapSection(ctrl),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              _buildActionButtonsRow(context, ctrl),
                              const SizedBox(height: 16),
                              _buildWaypointsSectionHeader(context, ctrl),
                              const SizedBox(height: 8),
                              Text(
                                permit.title,
                                style: const TextStyle(
                                  color: AppColors.medGray,
                                  fontSize: 12,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildWaypointList(ctrl, context),
                              const SizedBox(height: 14),
                              Obx(() => Text(
                                    'Total miles: ${ctrl.distance.value.replaceAll(' miles', '')}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                              // PDF file section removed
                              const SizedBox(height: 18),
                              _buildBottomButtons(ctrl, context),
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

  // ─── Map Sub-Section matching confirm_your_routes.dart ─────────────────────
  Widget _buildMapSection(ViewPermitController ctrl) {
    return Container(
      width: double.infinity,
      height: 260.h,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderSubtle, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            MapLibreMap(
              styleString: _kMapStyle,
              initialCameraPosition: CameraPosition(
                target: ctrl.currentLocation,
                zoom: 11.0,
              ),
              onMapCreated: ctrl.onMapCreated,
              onStyleLoadedCallback: ctrl.onStyleLoaded,
              onMapClick: (point, latlng) => ctrl.onMapClick(latlng),
              onMapLongClick: (point, latlng) => ctrl.onMapLongClick(latlng),
              onCameraMove: ctrl.onCameraMove,
              myLocationEnabled: true,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer()),
              },
            ),

            // Zoom buttons
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  _zoomBtn(Icons.add, ctrl.zoomIn),
                  const SizedBox(height: 6),
                  _zoomBtn(Icons.remove, ctrl.zoomOut),
                ],
              ),
            ),

            // Locating/Adding Mode Overlay indicators
            Obx(() {
              if (ctrl.isAddingPinMode.value) {
                return Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.all(8),
                  child: const Center(
                    child: Text(
                      'Tap anywhere on the map to add a pin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Loading overlay
            Obx(() {
              if (ctrl.isRouteLoading.value) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              color: AppColors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Updating route...',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow(
      BuildContext context, ViewPermitController ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(() => _actionBtn(
              ctrl.isAddingPinMode.value ? 'Cancel Add' : 'Add Pin',
              color: ctrl.isAddingPinMode.value
                  ? Colors.redAccent
                  : AppColors.orange,
              onTap: () {
                FocusScope.of(context).unfocus();
                ctrl.toggleAddPinMode();
              },
            )),
        const SizedBox(width: 6),
        _actionBtn(
          'Delete Pin',
          color: const Color(0xFFCC2222),
          onTap: () {
            FocusScope.of(context).unfocus();
            ctrl.deleteSelectedWaypoint();
          },
        ),
        const SizedBox(width: 6),
        _actionBtn(
          'Update',
          color: _C.green,
          onTap: () {
            FocusScope.of(context).unfocus();
            ctrl.updateRoute();
          },
        ),
      ],
    );
  }

  Widget _buildWaypointsSectionHeader(
      BuildContext context, ViewPermitController ctrl) {
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
              child: Text(
                '?',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointList(ViewPermitController ctrl, BuildContext context) {
    return Obx(() {
      if (ctrl.waypoints.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No waypoints added',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.4),
              fontSize: 14,
              fontFamily: 'Lato',
            ),
          ),
        );
      }
      return Column(
        children: List.generate(ctrl.waypoints.length, (i) {
          if (i >= ctrl.waypointControllers.length)
            return const SizedBox.shrink();
          return Column(
            children: [
              _buildWaypointRow(ctrl, i, context),
              if (i < ctrl.waypoints.length - 1)
                _buildAddButton(ctrl, i, context),
            ],
          );
        }),
      );
    });
  }

  Widget _buildWaypointRow(
      ViewPermitController ctrl, int index, BuildContext context) {
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
                            contentPadding: EdgeInsets.zero,
                          ),
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
      ViewPermitController ctrl, int index, BuildContext context) {
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

  Widget _buildBottomButtons(ViewPermitController ctrl, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();

                final allPoints = List<LatLng>.from(ctrl.waypointPositions);
                debugPrint(
                    '🔎 [ViewPermit] PREVIEW clicked. WaypointPositions count: ${allPoints.length}, points: $allPoints');

                if (allPoints.isEmpty) {
                  debugPrint(
                      '⚠️ [ViewPermit] PREVIEW aborted. allPoints is empty.');
                  Get.snackbar('Error', 'No route data available for preview.',
                      backgroundColor: Colors.red, colorText: AppColors.white);
                  return;
                }

                final activeRouteId = ctrl.currentRouteId ?? '';
                debugPrint(
                    '🔎 [ViewPermit] Navigating to PreviewScreen with arguments: {points: $allPoints, routeId: $activeRouteId}');

                Get.to(() => const PreviewScreen(), arguments: {
                  'points': allPoints,
                  'routeId': activeRouteId,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 2,
                ),
              ),
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
                elevation: 0,
              ),
              child: const Text(
                'BACK',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB0C4D0),
          fontSize: 13,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      );

  Widget _buildRouteNameField(BuildContext context, ViewPermitController ctrl) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.borderSubtle, width: 1),
      ),
      child: TextField(
        controller: ctrl.routeNameController,
        onChanged: ctrl.updateRouteName,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
            color: AppColors.darkGray,
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400),
        cursorColor: AppColors.darkGray,
        cursorHeight: 20,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14),
          hintText: 'Name Your Route',
          hintStyle: TextStyle(
              color: Color(0xFF9AA8B2),
              fontSize: 16,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400),
          isDense: false,
        ),
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // _buildPermitFileRow method removed - PDF file section no longer displayed
}

// ─── Dialogs matching confirm_your_routes.dart ────────────────────────────────
void showConfirmRouteInfoDialog(BuildContext context) {
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
          border: Border.all(color: const Color(0xFF3A4A5A), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/icons/Vector-hand.svg',
                    width: 24, height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset('assets/icons/Close-X-Circle.svg',
                      width: 24, height: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      height: 1.55,
                    ),
                    children: const [
                      TextSpan(
                          text: 'Adding new pins: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Tap the Add Pin button then tap anywhere on the map.\n'),
                      TextSpan(
                          text: 'Selecting pins: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Tap any pin on the map to select it. It will enlarge.\n'),
                      TextSpan(
                          text: 'Moving pins: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Press and hold a pin, then drag it to a new location.\n'),
                      TextSpan(
                          text: 'Deleting pins: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Select a pin, then tap the Delete Pin button.\n'),
                      TextSpan(
                          text: 'Manipulating the map: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Drag with one finger to pan. Pinch to zoom in/out.\n'),
                      TextSpan(
                          text:
                              'Tap Update to refresh waypoints. Tap PREVIEW to see detail.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
          border: Border.all(color: const Color(0xFF3A4A5A), width: 1),
        ),
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
                      width: 24, height: 24),
                ),
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
                  'Tap Update to refresh your route before clicking PREVIEW.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
