import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:right_routes/views/home/home_api_constant/home_api_constant.dart';

class AddPermitController extends GetxController {
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

  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint(
        "🟢 [AddPermitController] onInit called! Route ID received: ${Get.arguments?['routeId']}");
    _initSpeech();
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
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
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

    // Initial center
    LatLng initialCenter = const LatLng(37.7749, -122.4194);
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

  // ─── API Integration ───────────────────────────────────────────────────────
  Future<void> uploadPermit() async {
    debugPrint("🚀 [UploadPermit] Initiating permit upload...");
    final routeId = Get.arguments?['routeId'];
    if (routeId == null) {
      debugPrint("❌ [UploadPermit] Error: Route ID is missing from arguments.");
      Get.defaultDialog(
        title: "Error",
        middleText: "Route ID is missing. Please create the route first.",
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.red),
        middleTextStyle: TextStyle(color: Colors.black),
      );
      return;
    }

    if (startingPointController.text.isEmpty ||
        endingPointController.text.isEmpty) {
      debugPrint("❌ [UploadPermit] Error: Starting or ending point is empty.");
      Get.defaultDialog(
        title: "Validation Error",
        middleText:
            "Please pick both Starting Point and Ending Point from the map before processing.",
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.red),
        middleTextStyle: TextStyle(color: Colors.black),
      );
      return;
    }

    isUploading.value = true;
    try {
      final urlStr =
          '${HomeApiConstant.baseUrl}/navigation/route/$routeId/permit/';
      final url = Uri.parse(urlStr);

      debugPrint("🌐 [UploadPermit] Target URL: $urlStr");

      var request = http.MultipartRequest('POST', url);
      debugPrint("📋 [UploadPermit] Headers: ${request.headers}");

      // Adding text fields
      request.fields['start_location_name'] = startingPointController.text;
      if (startLatLng.value != null) {
        request.fields['start_latitude'] =
            startLatLng.value!.latitude.toString();
        request.fields['start_longitude'] =
            startLatLng.value!.longitude.toString();
      }

      request.fields['end_location_name'] = endingPointController.text;
      if (endLatLng.value != null) {
        request.fields['end_latitude'] = endLatLng.value!.latitude.toString();
        request.fields['end_longitude'] = endLatLng.value!.longitude.toString();
      }

      debugPrint("📦 [UploadPermit] Fields: ${request.fields}");

      // Adding files
      if (pickedDocumentPath.value.isNotEmpty) {
        debugPrint(
            "📎 [UploadPermit] Attaching Document: ${pickedDocumentPath.value}");
        request.files.add(await http.MultipartFile.fromPath(
            'permit_file', pickedDocumentPath.value));
      }
      if (pickedImagePath.value.isNotEmpty) {
        debugPrint(
            "📎 [UploadPermit] Attaching Image: ${pickedImagePath.value}");
        request.files.add(await http.MultipartFile.fromPath(
            'permit_file', pickedImagePath.value));
      }

      debugPrint("📤 [UploadPermit] Sending request...");
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      debugPrint("✅ [UploadPermit] Response Status: ${response.statusCode}");
      debugPrint("📄 [UploadPermit] Response Body: $responseData");

      // Helper function to navigate to confirm screen
      void navigateToConfirm(String permitId) {
        debugPrint("🔄 [Navigation] Navigating to ConfirmYourRoutes...");

        final dynamicRouteId = Get.arguments?['routeId']?.toString() ?? '';

        debugPrint(
            "🔗 [Navigation] Passing -> RouteID: $dynamicRouteId | PermitID: $permitId");

        Get.toNamed(
          '/EditConfirmStartYourRoute',
          arguments: {
            'routeId': dynamicRouteId,
            'permitId': permitId,
            'permitType': Get.arguments?['routeName'] ?? '',
            'startLocation': startingPointController.text,
            'endLocation': endingPointController.text,
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse permit_id from response
        String? newPermitId;
        try {
          final parsed = json.decode(responseData);
          if (parsed['data'] != null && parsed['data']['id'] != null) {
            newPermitId = parsed['data']['id'].toString();
            debugPrint(
                "✅ [UploadPermit] Extracted permit ID from data.id: $newPermitId");
          } else if (parsed['id'] != null) {
            newPermitId = parsed['id'].toString();
            debugPrint(
                "✅ [UploadPermit] Extracted permit ID from root id: $newPermitId");
          }
        } catch (e) {
          debugPrint(
              "❌ [UploadPermit] Failed to parse permit id from response: $e");
        }

        if (newPermitId == null) {
          debugPrint("❌ [UploadPermit] Could not find permit ID in response!");
          Get.snackbar("Error",
              "Permit created but ID could not be parsed from response",
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }

        Get.snackbar("Success", "Permit #$newPermitId created successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        navigateToConfirm(newPermitId);
      } else {
        final testPermitIdController = TextEditingController(text: '28');

        Get.defaultDialog(
          title: "Backend Error (${response.statusCode})",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                responseData.length > 100
                    ? responseData.substring(0, 100) + '...'
                    : responseData,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text("Enter a Permit ID to bypass (Test GET API):",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: testPermitIdController,
                decoration: const InputDecoration(
                  hintText: "Permit ID (e.g. 28)",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          backgroundColor: Colors.white,
          titleStyle: const TextStyle(color: Colors.red),
          textConfirm: "Test API Get",
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFFF58434),
          onConfirm: () {
            Get.back(); // close dialog
            navigateToConfirm(testPermitIdController.text);
          },
          textCancel: "Cancel",
        );
      }
    } catch (e) {
      debugPrint("❌ [UploadPermit] Network or Exception Error: $e");
      Get.defaultDialog(
        title: "Network Error",
        middleText: e.toString(),
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.red),
        middleTextStyle: TextStyle(color: Colors.black),
      );
    } finally {
      isUploading.value = false;
      debugPrint("🏁 [UploadPermit] Upload process finished.");
    }
  }

  @override
  void onClose() {
    startingPointController.dispose();
    endingPointController.dispose();
    super.onClose();
  }
}
