import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PreviewController extends GetxController {
  static const String _kMapTilerKey = 'dHNKoVs9jL46w6oUpFt3';
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';

  MapLibreMapController? mapController;

  // State variables
  final RxBool isMapReady = false.obs;
  final RxBool isLoading = true.obs;
  final RxString routeDuration = '...'.obs;
  final RxString routeDistance = '... miles'.obs;
  final RxString routeId = ''.obs;

  List<LatLng> waypoints = [];
  Line? _routeLine;
  final List<Symbol> _waypointSymbols = [];
  bool _iconsLoaded = false;

  @override
  void onInit() {
    super.onInit();

    debugPrint(
        '🔎 [PreviewController] onInit triggered. Get.arguments: ${Get.arguments} (Type: ${Get.arguments?.runtimeType})');

    // Parse waypoints from arguments
    if (Get.arguments != null) {
      try {
        if (Get.arguments is List) {
          final rawList = Get.arguments as List;
          waypoints = rawList.map((e) {
            if (e is LatLng) return e;
            if (e is Map) {
              final lat = (e['latitude'] ?? e['lat'] ?? 0.0) as num;
              final lng = (e['longitude'] ?? e['lng'] ?? 0.0) as num;
              return LatLng(lat.toDouble(), lng.toDouble());
            }
            if (e is List && e.length >= 2) {
              return LatLng((e[0] as num).toDouble(), (e[1] as num).toDouble());
            }
            throw Exception('Invalid point format in List');
          }).toList();
          debugPrint(
              '🔎 [PreviewController] Parsed waypoints from List. Count: ${waypoints.length}');
        } else if (Get.arguments is Map) {
          final args = Get.arguments as Map;
          debugPrint(
              '🔎 [PreviewController] Get.arguments is Map. keys: ${args.keys}');
          if (args['points'] != null && args['points'] is List) {
            final rawPoints = args['points'] as List;
            waypoints = rawPoints.map((e) {
              if (e is LatLng) return e;
              if (e is Map) {
                final lat = (e['latitude'] ?? e['lat'] ?? 0.0) as num;
                final lng = (e['longitude'] ?? e['lng'] ?? 0.0) as num;
                return LatLng(lat.toDouble(), lng.toDouble());
              }
              if (e is List && e.length >= 2) {
                return LatLng((e[0] as num).toDouble(), (e[1] as num).toDouble());
              }
              throw Exception('Invalid point format in Map["points"]');
            }).toList();
            debugPrint(
                '🔎 [PreviewController] Parsed points from Map["points"]. Count: ${waypoints.length}');
          }
          if (args['routeId'] != null) {
            routeId.value = args['routeId'].toString();
            debugPrint(
                '🔎 [PreviewController] Parsed routeId: ${routeId.value}');
          }
        } else {
          debugPrint(
              '⚠️ [PreviewController] Unknown arguments type: ${Get.arguments.runtimeType}');
        }
      } catch (e) {
        debugPrint('❌ [PreviewController] Error parsing arguments: $e');
      }
    } else {
      debugPrint('⚠️ [PreviewController] Get.arguments is null!');
    }

    // No automatic location fetching - use data from arguments only
    debugPrint(
        '✅ [PreviewController] Initialization complete. No automatic GPS fetch.');
  }

  void onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    isMapReady.value = true;
  }

  Future<void> onStyleLoaded() async {
    if (mapController == null) return;
    try {
      _iconsLoaded = false;
      await _loadIcons();
      await _drawRouteAndMarkers();
    } catch (e) {
      debugPrint('onStyleLoaded error: $e');
    }
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

  Future<void> _drawRouteAndMarkers() async {
    debugPrint(
        '🔎 [PreviewController] _drawRouteAndMarkers triggered. Waypoints count: ${waypoints.length}');
    if (waypoints.isEmpty) {
      debugPrint(
          '⚠️ [PreviewController] Waypoints is empty, skipping map draw.');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      // ১. OSRM থেকে রুট এবং সময়/দূরত্ব ফেচ করা
      debugPrint(
          '🔎 [PreviewController] Fetching road route geometry from OSRM...');
      final routeData = await _fetchRouteData(waypoints);

      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
          debugPrint('🔎 [PreviewController] Removed existing route line.');
        } catch (_) {}
        _routeLine = null;
      }

      if (routeData != null) {
        debugPrint(
            '🔎 [PreviewController] OSRM route fetched successfully. Drawing real road polyline...');
        // ২. ম্যাপে সুন্দর অরেঞ্জ ব্র্যান্ড রুট লাইন ড্র করা
        _routeLine = await mapController!.addLine(LineOptions(
          geometry: routeData['geometry'],
          lineColor: '#FF6B35', // ব্র্যান্ড অরেঞ্জ কালার
          lineWidth: 5.0,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ));
      } else {
        debugPrint(
            '⚠️ [PreviewController] OSRM fetch returned null. Drawing direct fallback polyline instead.');
        // OSRM ফেইল করলে সোজা লাইনে পয়েন্টগুলো কানেক্ট করা (Fallback Polyline)
        _routeLine = await mapController!.addLine(LineOptions(
          geometry: waypoints,
          lineColor: '#FF6B35', // ব্র্যান্ড অরেঞ্জ কালার
          lineWidth: 5.0,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ));
        
        // Calculate fallback distance/duration so tooltip shows up
        _calculateFallbackDistance();
      }

      // ৩. ওয়েপয়েন্টগুলোতে সুন্দর নাম্বারিং সহ অরেঞ্জ পিন বসানো (ALWAYS DRAW THIS)
      debugPrint('🔎 [PreviewController] Adding markers for each waypoint...');
      await _addAllMarkers();

      // ৪. ক্যামেরা ফিট করা (ALWAYS FIT BOUNDS)
      debugPrint(
          '🔎 [PreviewController] Fitting camera bounds to show all waypoints...');
      _fitMapToWaypoints();
    } catch (e) {
      debugPrint('❌ [PreviewController] Error drawing route and markers: $e');
    } finally {
      isLoading.value = false;
      debugPrint(
          '🔎 [PreviewController] Done drawing route and markers (isLoading: false).');
    }
  }

  Future<void> _addAllMarkers() async {
    if (mapController == null) return;

    // Clear any existing symbols and circles completely to guarantee no duplicate stacked markers
    try {
      await mapController!.clearSymbols();
      await mapController!.clearCircles();
      _waypointSymbols.clear();
    } catch (e) {
      debugPrint('Error clearing markers: $e');
    }

    if (!_iconsLoaded) {
      debugPrint(
          '⚠️ pin-orange icon not loaded, falling back to circle markers');
      for (int i = 0; i < waypoints.length; i++) {
        await mapController!.addCircle(CircleOptions(
          geometry: waypoints[i],
          circleRadius: 8.0,
          circleColor: '#FF6B35',
          circleStrokeWidth: 2.0,
          circleStrokeColor: '#FFFFFF',
        ));
      }
      return;
    }

    try {
      for (int i = 0; i < waypoints.length; i++) {
        final sym = await mapController!.addSymbol(SymbolOptions(
          geometry: waypoints[i],
          iconImage: 'pin-orange',
          iconSize: 0.45,
          textField: '${i + 1}',
          textSize: 10.0,
          textOffset: const Offset(0, 1.2),
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 1.5,
          textHaloBlur: 0.5,
        ));
        _waypointSymbols.add(sym);
      }
    } catch (e) {
      debugPrint('AddAllMarkers error: $e');
    }
  }

  void _calculateFallbackDistance() {
    if (waypoints.isEmpty) {
      routeDistance.value = '0.0 miles';
      routeDuration.value = '0 min';
      return;
    }
    if (waypoints.length == 1) {
      routeDistance.value = '0.0 miles';
      routeDuration.value = '0 min';
      return;
    }
    double totalMeters = 0.0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      totalMeters += Geolocator.distanceBetween(
        waypoints[i].latitude,
        waypoints[i].longitude,
        waypoints[i + 1].latitude,
        waypoints[i + 1].longitude,
      );
    }
    final miles = totalMeters / 1609.34;
    routeDistance.value = '${miles.toStringAsFixed(1)} miles';
    
    // Average driving speed of 45 mph
    final double hours = miles / 45.0;
    final int durationMinutes = (hours * 60).round();
    final int h = durationMinutes ~/ 60;
    final int m = durationMinutes % 60;
    routeDuration.value = h > 0 ? '$h hr $m min' : '$m min';
    debugPrint('🔎 [PreviewController] Computed fallback distance: ${routeDistance.value}, duration: ${routeDuration.value}');
  }

  Future<Map<String, dynamic>?> _fetchRouteData(List<LatLng> points) async {
    // De-duplicate adjacent identical or extremely close coordinates (<2 meters)
    final List<LatLng> cleanPoints = [];
    for (final p in points) {
      if (p.latitude == 0.0 && p.longitude == 0.0) continue;
      
      if (cleanPoints.isEmpty) {
        cleanPoints.add(p);
      } else {
        final last = cleanPoints.last;
        final double dist = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          p.latitude,
          p.longitude,
        );
        if (dist >= 2.0) {
          cleanPoints.add(p);
        }
      }
    }

    if (cleanPoints.length < 2) {
      debugPrint('⚠️ [PreviewController] Not enough unique points after cleaning: ${cleanPoints.length}');
      return null;
    }

    final coordStr =
        cleanPoints.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri =
        Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];

        // সময় এবং দূরত্ব ক্যালকুলেট করা
        final double distanceMeters = route['distance'];
        final double durationSeconds = route['duration'];

        final miles = (distanceMeters / 1609.34).toStringAsFixed(0);
        final int hours = durationSeconds ~/ 3600;
        final int minutes = ((durationSeconds % 3600) / 60).round();

        routeDistance.value = '$miles miles';
        routeDuration.value =
            hours > 0 ? '$hours hr $minutes min' : '$minutes min';

        final geometry = route['geometry']['coordinates'] as List;
        final coords = geometry
            .map<LatLng>((c) =>
                LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();

        return {'geometry': coords};
      } else {
        debugPrint('⚠️ OSRM responded with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint('OSRM fetch failed: $e');
    }
    return null;
  }

  void _fitMapToWaypoints() {
    if (mapController == null || waypoints.isEmpty) return;
    try {
      if (waypoints.length == 1) {
        mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(waypoints.first, 14.0));
        return;
      }
      final lats = waypoints.map((p) => p.latitude);
      final lngs = waypoints.map((p) => p.longitude);
      final minLat = lats.reduce((a, b) => a < b ? a : b);
      final maxLat = lats.reduce((a, b) => a > b ? a : b);
      final minLng = lngs.reduce((a, b) => a < b ? a : b);
      final maxLng = lngs.reduce((a, b) => a > b ? a : b);

      // Calculate a small dynamic padding based on coordinates distance
      final latDelta = (maxLat - minLat).abs();
      final lngDelta = (maxLng - minLng).abs();
      final paddingLat = latDelta > 0.01 ? latDelta * 0.15 : 0.01;
      final paddingLng = lngDelta > 0.01 ? lngDelta * 0.15 : 0.01;

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - paddingLat, minLng - paddingLng),
          northeast: LatLng(maxLat + paddingLat, maxLng + paddingLng),
        ),
        left: 40, top: 60, right: 40,
        bottom: 200, // Bottom padding for tooltips & buttons
      ));
    } catch (e) {
      debugPrint('PreviewController fitMap error: $e');
    }
  }
}
