// ═══════════════════════════════════════════════════════════════════════════
// add_permit_segment_controller.dart — Production-Ready Controller
// Fetches existing permit data via GET API and allows segment addition
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:right_routes/views/home/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/routes/all_routes.dart';

class AddPermitSegmentController extends GetxController {
  final startingPointController = TextEditingController();
  final endingPointController = TextEditingController();

  // ─── Constants ─────────────────────────────────────────────────────────────
  static const kMapTilerKey = 'dHNKoVs9jL46w6oUpFt3';
  static const kMapStyle =
      'https://api.maptiler.com/maps/openstreetmap/style.json?key=$kMapTilerKey';

  // ─── Speech to Text ────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxString recognizedText = "".obs;

  // ─── Image & File ──────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  final RxString pickedImagePath = "".obs;
  final RxString pickedDocumentPath = "".obs;

  // ─── Map Picking State ─────────────────────────────────────────────────────
  final Rx<LatLng> mapPickedLatLng = const LatLng(37.7749, -122.4194).obs;
  final RxString mapPickedAddress = "".obs;
  final RxBool isGeocodingLoading = false.obs;
  MapLibreMapController? mapController;

  final Rx<LatLng?> startLatLng = Rx<LatLng?>(null);
  final Rx<LatLng?> endLatLng = Rx<LatLng?>(null);

  // ─── Loading States ────────────────────────────────────────────────────────
  final RxBool isLoadingData = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool hasStartingPoint =
      false.obs; // true = API-তে starting point আছে → read-only show
  // hasRouteData kept for backward compat
  RxBool get hasRouteData => hasStartingPoint;

  // Reactive starting point text (TextEditingController.text is NOT reactive)
  final RxString startingPointText = ''.obs;

  // ─── Route & Permit IDs ────────────────────────────────────────────────────
  String? routeId;
  String? permitId;

  @override
  void onInit() {
    super.onInit();
    debugPrint("🟢 [AddPermitSegmentController] onInit called!");

    // Extract route ID from arguments
    final args = Get.arguments;
    debugPrint("📋 [AddPermitSegmentController] Raw arguments: $args");

    routeId = args?['routeId']?.toString();
    permitId = args?['permitId']?.toString();

    debugPrint("📋 [AddPermitSegmentController] Route ID: '$routeId'");
    debugPrint("📋 [AddPermitSegmentController] Permit ID: '$permitId'");

    // Validation
    if (routeId == null || routeId!.isEmpty) {
      debugPrint(
          "❌ [AddPermitSegmentController] ERROR: Route ID is null or empty!");
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          'Error',
          'Route ID is missing. Please go back and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
      return;
    }

    _initSpeech();

    // Fetch starting point from route API
    fetchStartingPoint();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (errorNotification) =>
          debugPrint('Speech error: $errorNotification'),
    );
    if (!available) {
      debugPrint('Speech recognition not available');
    }
  }

  // ─── GET API: Fetch Starting Point Data ───────────────────────────────────
  Future<void> fetchStartingPoint() async {
    if (routeId == null || routeId!.isEmpty) {
      debugPrint(
          "❌ [FetchStartingPoint] Route ID is null/empty — showing editable field");
      hasStartingPoint.value = false;
      startingPointText.value = '';
      isLoadingData.value = false;
      return;
    }

    isLoadingData.value = true;
    debugPrint(
        "🔄 [FetchStartingPoint] Fetching starting point for route: $routeId");

    try {
      final urlStr =
          '${HomeApiConstant.baseUrl}/navigation/starting-point/route/$routeId/';
      final url = Uri.parse(urlStr);

      debugPrint("🌐 [FetchStartingPoint] GET URL: $urlStr");

      final response = await ApiClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint(
          "✅ [FetchStartingPoint] Response Status: ${response.statusCode}");
      debugPrint("📄 [FetchStartingPoint] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final routeData = data['data'];

          final startLocationName = routeData['start_location_name'] as String?;
          final rawLat = routeData['start_latitude'];
          final rawLng = routeData['start_longitude'];

          // ── Safe double parsing (handles int, double, String from API) ──
          double? parsedLat;
          double? parsedLng;
          try {
            parsedLat = (rawLat is num)
                ? rawLat.toDouble()
                : double.tryParse(rawLat.toString());
            parsedLng = (rawLng is num)
                ? rawLng.toDouble()
                : double.tryParse(rawLng.toString());
          } catch (e) {
            debugPrint("❌ [FetchStartingPoint] Lat/Lng parse error: $e");
          }

          final bool hasStart = startLocationName != null &&
              startLocationName.isNotEmpty &&
              parsedLat != null &&
              parsedLng != null;

          if (hasStart) {
            startingPointController.text = startLocationName;
            startingPointText.value = startLocationName;
            startLatLng.value = LatLng(parsedLat, parsedLng);
            hasStartingPoint.value = true;
            debugPrint(
                "✅ [FetchStartingPoint] Starting point loaded: $startLocationName ($parsedLat, $parsedLng)");
          } else {
            hasStartingPoint.value = false;
            startingPointText.value = '';
            debugPrint(
                "⚠️ [FetchStartingPoint] No valid starting point → editable field shown");
          }
        } else {
          hasStartingPoint.value = false;
          startingPointText.value = '';
          debugPrint(
              "⚠️ [FetchStartingPoint] status=false or data=null → editable field shown");
        }
      } else if (response.statusCode == 401) {
        hasStartingPoint.value = false;
        startingPointText.value = '';
        debugPrint("❌ [FetchStartingPoint] 401 Unauthorized — token expired?");
      } else if (response.statusCode == 404) {
        hasStartingPoint.value = false;
        startingPointText.value = '';
        debugPrint(
            "⚠️ [FetchStartingPoint] 404 Not Found — no starting point for this route");
      } else {
        hasStartingPoint.value = false;
        startingPointText.value = '';
        debugPrint(
            "⚠️ [FetchStartingPoint] Unexpected status ${response.statusCode}");
      }
    } catch (e) {
      hasStartingPoint.value = false;
      startingPointText.value = '';
      debugPrint("❌ [FetchStartingPoint] Error: $e");
    } finally {
      isLoadingData.value = false;
    }
  }

  // ─── Speech Recognition ────────────────────────────────────────────────────
  void startListening() async {
    if (!isListening.value) {
      bool available = await _speech.initialize();
      if (available) {
        isListening.value = true;
        recognizedText.value = "";
        _speech.listen(
          onResult: (result) {
            recognizedText.value = result.recognizedWords;
          },
        );
      }
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  // ─── Camera & Documents ────────────────────────────────────────────────────
  Future<void> pickImage() async {
    debugPrint("📷 [Camera] Requesting camera permission...");
    final status = await Permission.camera.request();
    if (status.isGranted) {
      debugPrint("📷 [Camera] Permission granted. Opening camera...");
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        pickedImagePath.value = image.path;
        debugPrint("✅ [Camera] Image captured: ${image.path}");
        Get.snackbar("Success", "Image captured: ${image.name}",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        debugPrint("⚠️ [Camera] Image capture cancelled by user.");
      }
    } else {
      debugPrint("❌ [Camera] Permission denied.");
      _showPermissionDenied("Camera permission is required");
    }
  }

  Future<void> pickDocument() async {
    debugPrint("📄 [Document] Opening file picker...");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      pickedDocumentPath.value = result.files.single.path ?? "";
      debugPrint("✅ [Document] File selected: ${pickedDocumentPath.value}");
      Get.snackbar("Success", "File selected: ${result.files.single.name}",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      debugPrint("⚠️ [Document] File picking cancelled by user.");
    }
  }

  // ─── Map Picking Logic ─────────────────────────────────────────────────────
  Future<void> onMapPickerTap(LatLng latLng) async {
    debugPrint(
        "📍 [MapPicker] User tapped at: ${latLng.latitude}, ${latLng.longitude}");

    mapPickedLatLng.value = latLng;
    mapPickedAddress.value = "";
    isGeocodingLoading.value = true;

    // Clear existing markers and add new circle marker at tapped location
    try {
      await mapController?.clearCircles();
      await mapController?.clearSymbols();
      debugPrint("🗑️ [MapPicker] Cleared existing markers");

      // Add a shadow circle (larger, semi-transparent)
      await mapController?.addCircle(CircleOptions(
        geometry: latLng,
        circleRadius: 12.0,
        circleColor: '#F58434',
        circleOpacity: 0.2,
      ));

      // Add main marker circle
      await mapController?.addCircle(CircleOptions(
        geometry: latLng,
        circleRadius: 8.0,
        circleColor: '#F58434',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.5,
      ));
      debugPrint(
          "📌 [MapPicker] Added orange circle marker at tapped location");
    } catch (e) {
      debugPrint("❌ [MapPicker] Error adding marker: $e");
    }

    final address = await _reverseGeocode(latLng.latitude, latLng.longitude);
    mapPickedAddress.value = address ??
        '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
    isGeocodingLoading.value = false;
    debugPrint("✅ [MapPicker] Address resolved: ${mapPickedAddress.value}");
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://api.maptiler.com/geocoding/$lng,$lat.json?key=$kMapTilerKey');
      final res = await ApiClient.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final features = body['features'] as List?;
        if (features != null && features.isNotEmpty) {
          return features.first['place_name'];
        }
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
    return null;
  }

  void _showPermissionDenied(String message) {
    Get.snackbar("Permission Denied", message,
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  Future<void> openMapPicker(BuildContext context, bool isStart) async {
    // Request permission
    final status = await Permission.locationWhenInUse.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDenied(
          "Location permission is required to pick from map.");
      return;
    }

    // Initial center - use existing start location if available
    LatLng initialCenter =
        startLatLng.value ?? const LatLng(37.7749, -122.4194);

    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      initialCenter = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}

    // Reset state
    mapPickedLatLng.value = initialCenter;
    mapPickedAddress.value = "";
    mapController = null;
  }

  // ─── POST API: Upload Permit Segment ─────────────────────────────────────
  Future<void> uploadPermitSegment() async {
    debugPrint("🚀 [UploadPermitSegment] Initiating segment upload...");

    if (routeId == null) {
      Get.snackbar(
          "Error", "Route ID is missing. Please go back and try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (endingPointController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Ending Point is required. Please pick from map or enter manually.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;
    try {
      final urlStr =
          '${HomeApiConstant.baseUrl}/navigation/route/$routeId/permit/';
      final url = Uri.parse(urlStr);
      debugPrint("🌐 [UploadPermitSegment] POST URL: $urlStr");

      var request = http.MultipartRequest('POST', url);

      // ── Starting point fields (only if available) ─────────────────────────
      final startText = startingPointController.text.trim();
      if (startText.isNotEmpty) {
        request.fields['start_location_name'] = startText;
      }
      if (startLatLng.value != null) {
        request.fields['start_latitude'] =
            startLatLng.value!.latitude.toString();
        request.fields['start_longitude'] =
            startLatLng.value!.longitude.toString();
      }

      // ── Ending point fields ───────────────────────────────────────────────
      request.fields['end_location_name'] = endingPointController.text.trim();
      if (endLatLng.value != null) {
        request.fields['end_latitude'] = endLatLng.value!.latitude.toString();
        request.fields['end_longitude'] = endLatLng.value!.longitude.toString();
      } else {
        // User typed manually without map — warn in debug but still send
        debugPrint(
            "⚠️ [UploadPermitSegment] end_latitude/longitude missing (manual text entry)");
      }

      debugPrint("📦 [UploadPermitSegment] Fields: ${request.fields}");

      // ── Attachments ───────────────────────────────────────────────────────
      if (pickedDocumentPath.value.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            'permit_file', pickedDocumentPath.value));
        debugPrint(
            "📎 [UploadPermitSegment] Attached PDF: ${pickedDocumentPath.value}");
      }
      if (pickedImagePath.value.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
            'permit_file', pickedImagePath.value));
        debugPrint(
            "📎 [UploadPermitSegment] Attached Image: ${pickedImagePath.value}");
      }

      debugPrint("📤 [UploadPermitSegment] Sending request...");
      final streamedResponse =
          await ApiClient.sendMultipartRequest(request).timeout(const Duration(seconds: 30));
      final responseData = await streamedResponse.stream.bytesToString();

      debugPrint(
          "✅ [UploadPermitSegment] Status: ${streamedResponse.statusCode}");
      debugPrint("📄 [UploadPermitSegment] Body: $responseData");

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        String? newPermitId;
        try {
          final parsed = json.decode(responseData);
          newPermitId = (parsed['data']?['id'] ?? parsed['id'])?.toString();
          debugPrint(
              "✅ [UploadPermitSegment] Extracted permit ID: $newPermitId");
        } catch (e) {
          debugPrint("❌ [UploadPermitSegment] Failed to parse permit id: $e");
        }

        Get.offNamed(
          AppRoutes.confirmYourRouteForSegment,
          arguments: {
            'routeId': routeId,
            'permitId': newPermitId,
          },
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to create segment. Status: ${streamedResponse.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("❌ [UploadPermitSegment] Network Error: $e");
      Get.snackbar("Network Error", "Please check your connection.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploading.value = false;
      debugPrint("🏁 [UploadPermitSegment] Upload process finished.");
    }
  }

  @override
  void onClose() {
    startingPointController.dispose();
    endingPointController.dispose();
    super.onClose();
  }
}


