// // ═══════════════════════════════════════════════════════════════════════════
// // permit_selection_controller.dart
// // ═══════════════════════════════════════════════════════════════════════════
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:right_routes/utils/colors.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// import '../../confirm_your_routes/confirm_your_routes.dart';

// // ─── MapTiler key — same as confirm_your_routes.dart ─────────────────────────
// const _kMapTilerKey = 'dHNKoVs9jL46w6oUpFt3';
// const _kMapStyle =
//     'https://api.maptiler.com/maps/openstreetmap/style.json?key=$_kMapTilerKey';

// // ─────────────────────────────────────────────────────────────────────────────
// class PermitSelectionController extends GetxController {
//   // ─── Text Controllers ─────────────────────────────────────────────────────
//   final startingPointController = TextEditingController();
//   final endingPointController   = TextEditingController();

//   // ─── Observables ──────────────────────────────────────────────────────────
//   final RxList<Map<String, String>> permits = <Map<String, String>>[
//     {'title': 'I-5 North Bound', 'id': 'PRM-001'},
//     {'title': 'I-5 South Bound', 'id': 'PRM-002'},
//     {'title': 'Route 99 East', 'id': 'PRM-003'},
//     {'title': 'Route 99 West', 'id': 'PRM-004'},
//     {'title': 'Downtown Delivery Loop', 'id': 'PRM-005'},
//     {'title': 'Warehouse District Bypass', 'id': 'PRM-006'},
//   ].obs;

//   final RxString selectedPermitTitle = ''.obs;

//   final RxString pickedPdfName   = ''.obs;
//   final RxString pickedImagePath = ''.obs;
//   final RxBool   isListening     = false.obs;
//   final RxString spokenText      = ''.obs;
//   final RxBool   speechAvailable = false.obs;

//   // ─── Map picker state (shared for both dialogs) ───────────────────────────
//   final Rx<LatLng> mapPickedLatLng =
//       const LatLng(37.7749, -122.4194).obs; // default SF
//   final RxString mapPickedAddress  = ''.obs;
//   final RxBool   isGeocodingLoading = false.obs;

//   MapLibreMapController? _mapController;

//   // ─── Private ──────────────────────────────────────────────────────────────
//   final SpeechToText _speech = SpeechToText();
//   final ImagePicker  _picker = ImagePicker();

//   // ─── Lifecycle ────────────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();
//     _initSpeech();
//   }

//   @override
//   void onClose() {
//     startingPointController.dispose();
//     endingPointController.dispose();
//     _speech.stop();
//     super.onClose();
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // SPEECH INIT
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> _initSpeech() async {
//     speechAvailable.value = await _speech.initialize(
//       onError:  (e) => isListening.value = false,
//       onStatus: (status) {
//         if (status == 'done' || status == 'notListening') {
//           isListening.value = false;
//         }
//       },
//     );
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // PROCESS
//   // ──────────────────────────────────────────────────────────────────────────
//   void onProcess() {
//     if (startingPointController.text.trim().isEmpty ||
//         endingPointController.text.trim().isEmpty) {
//       Get.snackbar(
//         'Required Fields',
//         'Please enter both starting and ending points.',
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//       return;
//     }
//     Get.to(
//           () => EditConfirmStartYourRoute(),
//       arguments: {
//         'startLocation': startingPointController.text.trim(),
//         'endLocation'  : endingPointController.text.trim(),
//         'permitType'   : 'PERMIT 1',
//       },
//     );
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // DOCUMENT — PDF PICKER
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> onDocumentTap() async {
//     final status = await Permission.storage.request();
//     if (status.isDenied || status.isPermanentlyDenied) {
//       _showPermissionDenied('Storage permission is required to pick a PDF.');
//       return;
//     }
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type             : FileType.custom,
//         allowedExtensions: ['pdf'],
//         allowMultiple    : false,
//       );
//       if (result != null && result.files.isNotEmpty) {
//         final file = result.files.first;
//         pickedPdfName.value = file.name;
//         Get.snackbar(
//           'PDF Selected', file.name,
//           backgroundColor: const Color(0xFF1E2D4A),
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not pick PDF: $e',
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     }
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // EDIT
//   // ──────────────────────────────────────────────────────────────────────────
//   void onEditTap() {
//     Get.snackbar(
//       'Manual Edit', 'Manual edit option selected',
//       backgroundColor: AppColors.darkGray,
//       colorText: AppColors.white,
//     );
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // MIC — Speech to Text dialog  (FIX: spokenText এখন ValueNotifier-এর মতো
//   //        StatefulWidget-এ pass হয়, dialog নিজেই reactive)
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> onMicTap() async {
//     final status = await Permission.microphone.request();
//     if (status.isDenied || status.isPermanentlyDenied) {
//       _showPermissionDenied(
//           'Microphone permission is required for voice input.');
//       return;
//     }
//     if (!speechAvailable.value) {
//       Get.snackbar(
//         'Not Available',
//         'Speech recognition is not supported on this device.',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Reset
//     spokenText.value  = '';
//     isListening.value = false;

//     await Get.dialog(
//       _SpeechDialog(controller: this),
//       barrierDismissible: false,
//     );
//   }

//   Future<void> toggleListening() async {
//     if (isListening.value) {
//       await _speech.stop();
//       isListening.value = false;
//     } else {
//       isListening.value = true;
//       spokenText.value  = ''; // clear before new session
//       await _speech.listen(
//         onResult   : _onSpeechResult,
//         listenMode : ListenMode.dictation,
//         pauseFor   : const Duration(seconds: 4),
//         localeId   : 'en_US',
//       );
//     }
//   }

//   void _onSpeechResult(SpeechRecognitionResult result) {
//     // Force reactive update — always assign even if same content
//     spokenText.value = result.recognizedWords;
//     if (result.finalResult) isListening.value = false;
//   }

//   void confirmSpeechText(String field) {
//     final text = spokenText.value.trim();
//     if (text.isEmpty) return;
//     if (field == 'start') {
//       startingPointController.text = text;
//     } else {
//       endingPointController.text = text;
//     }
//     _speech.stop();
//     isListening.value = false;
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // CAMERA
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> onCameraTap() async {
//     final status = await Permission.camera.request();
//     if (status.isDenied || status.isPermanentlyDenied) {
//       _showPermissionDenied(
//           'Camera permission is required to capture a photo.');
//       return;
//     }
//     try {
//       final XFile? photo = await _picker.pickImage(
//         source      : ImageSource.camera,
//         imageQuality: 85,
//         maxWidth    : 1920,
//         maxHeight   : 1080,
//       );
//       if (photo != null) {
//         pickedImagePath.value = photo.path;
//         Get.snackbar(
//           'Photo Captured', 'Image saved successfully.',
//           backgroundColor: const Color(0xFF1E2D4A),
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not open camera: $e',
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     }
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // MAP LOCATION PICKER — Starting Point (current location icon tap)
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> onStartLocationIconTap() async {
//     // Request location permission
//     final locPermission = await Permission.locationWhenInUse.request();
//     if (locPermission.isDenied || locPermission.isPermanentlyDenied) {
//       _showPermissionDenied('Location permission is required.');
//       return;
//     }

//     // Try to get current location for map center
//     LatLng initialCenter = const LatLng(37.7749, -122.4194);
//     String? autoAddress;

//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 8),
//       );
//       initialCenter = LatLng(pos.latitude, pos.longitude);
//       // Reverse geocode the current position automatically
//       autoAddress = await _reverseGeocode(pos.latitude, pos.longitude);
//     } catch (_) {
//       // Use default if location unavailable
//     }

//     // Reset map state
//     mapPickedLatLng.value   = initialCenter;
//     mapPickedAddress.value  = autoAddress ?? '';
//     _mapController          = null;

//     await Get.dialog(
//       _MapPickerDialog(
//         controller      : this,
//         title           : 'SELECT STARTING POINT',
//         initialCenter   : initialCenter,
//         autoFillAddress : autoAddress, // non-null → pre-fill, user can still pick manually
//         onConfirm       : (address) {
//           startingPointController.text = address;
//         },
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // MAP LOCATION PICKER — Ending Point (pin_drop icon tap)
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<void> onEndLocationIconTap() async {
//     final locPermission = await Permission.locationWhenInUse.request();
//     if (locPermission.isDenied || locPermission.isPermanentlyDenied) {
//       _showPermissionDenied('Location permission is required.');
//       return;
//     }

//     // Center map on current position for convenience
//     LatLng initialCenter = const LatLng(37.7749, -122.4194);
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//         timeLimit: const Duration(seconds: 6),
//       );
//       initialCenter = LatLng(pos.latitude, pos.longitude);
//     } catch (_) {}

//     mapPickedLatLng.value  = initialCenter;
//     mapPickedAddress.value = '';
//     _mapController         = null;

//     await Get.dialog(
//       _MapPickerDialog(
//         controller      : this,
//         title           : 'SELECT END POINT',
//         initialCenter   : initialCenter,
//         autoFillAddress : null, // user must tap manually
//         onConfirm       : (address) {
//           endingPointController.text = address;
//         },
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // MAP CONTROLLER callbacks (used by _MapPickerDialog)
//   // ──────────────────────────────────────────────────────────────────────────
//   void onMapPickerCreated(MapLibreMapController mc) {
//     _mapController = mc;
//   }

//   Future<void> onMapPickerTap(LatLng latLng) async {
//     mapPickedLatLng.value  = latLng;
//     mapPickedAddress.value = '';
//     isGeocodingLoading.value = true;

//     // Move a symbol to the tapped location
//     _mapController?.clearSymbols();
//     _mapController?.addSymbol(SymbolOptions(
//       geometry: latLng,
//       iconImage: 'marker-15',
//       iconSize : 2.0,
//       iconColor: '#F58434',
//     ));

//     final address = await _reverseGeocode(latLng.latitude, latLng.longitude);
//     mapPickedAddress.value   = address ?? '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
//     isGeocodingLoading.value = false;
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // REVERSE GEOCODING — MapTiler Geocoding API
//   // ──────────────────────────────────────────────────────────────────────────
//   Future<String?> _reverseGeocode(double lat, double lng) async {
//     try {
//       final uri = Uri.parse(
//         'https://api.maptiler.com/geocoding/$lng,$lat.json?key=$_kMapTilerKey',
//       );
//       final res = await http.get(uri).timeout(const Duration(seconds: 6));
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body) as Map<String, dynamic>;
//         final features = body['features'] as List<dynamic>?;
//         if (features != null && features.isNotEmpty) {
//           return features.first['place_name'] as String?;
//         }
//       }
//     } catch (_) {}
//     return null;
//   }

//   // ──────────────────────────────────────────────────────────────────────────
//   // HELPER
//   // ──────────────────────────────────────────────────────────────────────────
//   void _showPermissionDenied(String message) {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: const Color(0xFF0D1B36),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: const BorderSide(color: Color(0xFF1E2D4A)),
//         ),
//         title: const Text(
//           'Permission Required',
//           style: TextStyle(
//             color: Colors.white,
//             fontFamily: 'League Gothic',
//             fontSize: 20,
//             letterSpacing: 1.5,
//           ),
//         ),
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Color(0xFFB0BEC5),
//             fontFamily: 'Lato',
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('CANCEL',
//                 style: TextStyle(
//                     color: Color(0xFFB0BEC5), fontFamily: 'Lato')),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               openAppSettings();
//             },
//             child: const Text(
//               'OPEN SETTINGS',
//               style: TextStyle(
//                   color: Color(0xFFF58434),
//                   fontFamily: 'Lato',
//                   fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═════════════════════════════════════════════════════════════════════════════
// // _SpeechDialog  —  FIX: uses StreamBuilder/Obx properly inside StatelessWidget
// // ═════════════════════════════════════════════════════════════════════════════
// class _SpeechDialog extends StatelessWidget {
//   final PermitSelectionController controller;
//   const _SpeechDialog({required this.controller});

//   static const _bg         = Color(0xFF0D1B36);
//   static const _border     = Color(0xFF1E2D4A);
//   static const _orange     = Color(0xFFF58434);
//   static const _labelColor = Color(0xFFB0BEC5);
//   static const _inputBg    = Color(0xFFFFFFFF);
//   static const _textDark   = Color(0xFF1A1A2E);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding:
//       const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
//       child: Container(
//         padding    : const EdgeInsets.all(20),
//         decoration : BoxDecoration(
//           color       : _bg,
//           borderRadius: BorderRadius.circular(16),
//           border      : Border.all(color: _border, width: 1),
//           boxShadow   : [
//             BoxShadow(
//               color     : Colors.black.withOpacity(0.4),
//               blurRadius: 24,
//               offset    : const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ────────────────────────────────────────────────────
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'VOICE INPUT',
//                   style: TextStyle(
//                     color        : Colors.white,
//                     fontSize     : 22,
//                     fontFamily   : 'League Gothic',
//                     fontWeight   : FontWeight.w400,
//                     letterSpacing: 2.0,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     controller._speech.stop();
//                     controller.isListening.value = false;
//                     Get.back();
//                   },
//                   child: Container(
//                     width     : 30,
//                     height    : 30,
//                     decoration: BoxDecoration(
//                       color       : _border,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: const Icon(Icons.close_rounded,
//                         color: Colors.white, size: 18),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 6),
//             const Text(
//               'Tap the mic and speak. Your words will appear below.',
//               style: TextStyle(
//                 color     : _labelColor,
//                 fontSize  : 12,
//                 fontFamily: 'Lato',
//                 height    : 1.5,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ── Mic button ─────────────────────────────────────────────────
//             Center(
//               child: Obx(() {
//                 final listening = controller.isListening.value;
//                 return GestureDetector(
//                   onTap: controller.toggleListening,
//                   child: AnimatedContainer(
//                     duration  : const Duration(milliseconds: 250),
//                     width     : 72,
//                     height    : 72,
//                     decoration: BoxDecoration(
//                       shape    : BoxShape.circle,
//                       color    : listening
//                           ? _orange
//                           : const Color(0xFF1C2E50),
//                       border   : Border.all(
//                         color: listening ? _orange : _border,
//                         width: 2,
//                       ),
//                       boxShadow: listening
//                           ? [
//                         BoxShadow(
//                           color     : _orange.withOpacity(0.45),
//                           blurRadius: 18,
//                           spreadRadius: 2,
//                         ),
//                       ]
//                           : [],
//                     ),
//                     child: Icon(
//                       listening
//                           ? Icons.mic_rounded
//                           : Icons.mic_none_rounded,
//                       color: Colors.white,
//                       size : 34,
//                     ),
//                   ),
//                 );
//               }),
//             ),

//             const SizedBox(height: 8),

//             // ── Listening label ────────────────────────────────────────────
//             Center(
//               child: Obx(() => Text(
//                 controller.isListening.value
//                     ? 'Listening...'
//                     : 'Tap mic to start',
//                 style: const TextStyle(
//                   color     : _labelColor,
//                   fontSize  : 12,
//                   fontFamily: 'Lato',
//                 ),
//               )),
//             ),

//             const SizedBox(height: 18),

//             // ── Spoken text box ────────────────────────────────────────────
//             // FIX: Obx wraps the entire Container so it rebuilds on text change
//             Obx(() {
//               final text = controller.spokenText.value;
//               return AnimatedContainer(
//                 duration   : const Duration(milliseconds: 150),
//                 width      : double.infinity,
//                 constraints: const BoxConstraints(minHeight: 80),
//                 padding    : const EdgeInsets.all(12),
//                 decoration : BoxDecoration(
//                   color       : _inputBg,
//                   borderRadius: BorderRadius.circular(10),
//                   border      : Border.all(
//                     color: text.isEmpty ? _border : _orange,
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   text.isEmpty ? 'Your speech will appear here…' : text,
//                   style: TextStyle(
//                     color     : text.isEmpty
//                         ? const Color(0xFF9E9E9E)
//                         : _textDark,
//                     fontSize  : 15,
//                     fontFamily: 'Lato',
//                     height    : 1.5,
//                   ),
//                 ),
//               );
//             }),

//             const SizedBox(height: 6),

//             const Text(
//               'Apply spoken text to:',
//               style: TextStyle(
//                 color     : _labelColor,
//                 fontSize  : 11,
//                 fontFamily: 'Lato',
//               ),
//             ),
//             const SizedBox(height: 10),

//             // ── Apply buttons ──────────────────────────────────────────────
//             Row(
//               children: [
//                 Expanded(
//                   child: _ApplyBtn(
//                     label: 'Starting Point',
//                     color: const Color(0xFF1C3A6A),
//                     onTap: () {
//                       controller.confirmSpeechText('start');
//                       Get.back();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: _ApplyBtn(
//                     label: 'Ending Point',
//                     color: _orange,
//                     onTap: () {
//                       controller.confirmSpeechText('end');
//                       Get.back();
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             Center(
//               child: GestureDetector(
//                 onTap: () {
//                   controller._speech.stop();
//                   controller.isListening.value = false;
//                   Get.back();
//                 },
//                 child: const Text(
//                   'CANCEL',
//                   style: TextStyle(
//                     color        : _labelColor,
//                     fontSize     : 12,
//                     fontFamily   : 'Lato',
//                     fontWeight   : FontWeight.w600,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═════════════════════════════════════════════════════════════════════════════
// // _MapPickerDialog  —  MapLibreMap + reverse geocoding, used for both fields
// // ═════════════════════════════════════════════════════════════════════════════
// class _MapPickerDialog extends StatefulWidget {
//   final PermitSelectionController controller;
//   final String                     title;
//   final LatLng                     initialCenter;
//   final String?                    autoFillAddress;
//   final void Function(String)      onConfirm;

//   const _MapPickerDialog({
//     required this.controller,
//     required this.title,
//     required this.initialCenter,
//     required this.autoFillAddress,
//     required this.onConfirm,
//   });

//   @override
//   State<_MapPickerDialog> createState() => _MapPickerDialogState();
// }

// class _MapPickerDialogState extends State<_MapPickerDialog> {
//   static const _bg         = Color(0xFF0D1B36);
//   static const _border     = Color(0xFF1E2D4A);
//   static const _orange     = Color(0xFFF58434);
//   static const _labelColor = Color(0xFFB0BEC5);

//   @override
//   void initState() {
//     super.initState();
//     // If auto fill address exists, set it so user sees it immediately
//     if (widget.autoFillAddress != null &&
//         widget.autoFillAddress!.isNotEmpty) {
//       widget.controller.mapPickedAddress.value = widget.autoFillAddress!;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = widget.controller;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding   : const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
//       child: Container(
//         decoration: BoxDecoration(
//           color       : _bg,
//           borderRadius: BorderRadius.circular(16),
//           border      : Border.all(color: _border, width: 1),
//           boxShadow   : [
//             BoxShadow(
//               color     : Colors.black.withOpacity(0.5),
//               blurRadius: 24,
//               offset    : const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Header ──────────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.title,
//                     style: const TextStyle(
//                       color        : Colors.white,
//                       fontSize     : 18,
//                       fontFamily   : 'League Gothic',
//                       fontWeight   : FontWeight.w400,
//                       letterSpacing: 1.8,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Get.back(),
//                     child: Container(
//                       width     : 30,
//                       height    : 30,
//                       decoration: BoxDecoration(
//                         color       : _border,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Icon(Icons.close_rounded,
//                           color: Colors.white, size: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Instruction ──────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Text(
//                 widget.autoFillAddress != null
//                     ? 'Your current location is pre-filled. Tap anywhere on the map to change it.'
//                     : 'Tap anywhere on the map to select the location.',
//                 style: const TextStyle(
//                   color     : _labelColor,
//                   fontSize  : 12,
//                   fontFamily: 'Lato',
//                   height    : 1.4,
//                 ),
//               ),
//             ),

//             // ── Map ──────────────────────────────────────────────────────
//             ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft    : Radius.circular(0),
//                 topRight   : Radius.circular(0),
//                 bottomLeft : Radius.circular(0),
//                 bottomRight: Radius.circular(0),
//               ),
//               child: SizedBox(
//                 height: 320,
//                 child: Stack(
//                   children: [
//                     MapLibreMap(
//                       styleString           : _kMapStyle,
//                       initialCameraPosition : CameraPosition(
//                         target: widget.initialCenter,
//                         zoom  : 14.0,
//                       ),
//                       onMapCreated          : (mc) {
//                         ctrl.onMapPickerCreated(mc);
//                         // If autoFill → drop a marker at current loc
//                         if (widget.autoFillAddress != null) {
//                           mc.addSymbol(SymbolOptions(
//                             geometry : widget.initialCenter,
//                             iconImage: 'marker-15',
//                             iconSize : 2.0,
//                             iconColor: '#F58434',
//                           ));
//                         }
//                       },
//                       onMapClick            : (point, latLng) =>
//                           ctrl.onMapPickerTap(latLng),
//                       myLocationEnabled     : true,
//                       myLocationTrackingMode:
//                       MyLocationTrackingMode.none,
//                       compassEnabled        : true,
//                       scrollGesturesEnabled : true,
//                       zoomGesturesEnabled   : true,
//                       rotateGesturesEnabled : true,
//                       tiltGesturesEnabled   : true,
//                       doubleClickZoomEnabled: false,
//                       minMaxZoomPreference  :
//                       const MinMaxZoomPreference(1, 20),
//                     ),

//                     // Loading overlay while geocoding
//                     Obx(() {
//                       if (!ctrl.isGeocodingLoading.value) {
//                         return const SizedBox.shrink();
//                       }
//                       return Positioned(
//                         bottom: 10,
//                         left  : 0,
//                         right : 0,
//                         child : Center(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 7),
//                             decoration: BoxDecoration(
//                               color       : Colors.black54,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(
//                                   width: 14,
//                                   height: 14,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color      : Colors.white,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Getting address…',
//                                   style: TextStyle(
//                                     color     : Colors.white,
//                                     fontSize  : 12,
//                                     fontFamily: 'Lato',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),

//                     // Tap hint
//                     Positioned(
//                       top  : 10,
//                       left : 0,
//                       right: 0,
//                       child: Center(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 5),
//                           decoration: BoxDecoration(
//                             color       : Colors.black54,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Text(
//                             'Tap on map to pin location',
//                             style: TextStyle(
//                               color     : Colors.white,
//                               fontSize  : 11,
//                               fontFamily: 'Lato',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Address preview ──────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//               child: Obx(() {
//                 final address = ctrl.mapPickedAddress.value;
//                 final isLoading = ctrl.isGeocodingLoading.value;
//                 return Container(
//                   width     : double.infinity,
//                   padding   : const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color       : const Color(0xFF0A1628),
//                     borderRadius: BorderRadius.circular(8),
//                     border      : Border.all(
//                       color: address.isNotEmpty ? _orange : _border,
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_rounded,
//                         color: address.isNotEmpty ? _orange : _labelColor,
//                         size : 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: isLoading
//                             ? const Text(
//                           'Fetching address…',
//                           style: TextStyle(
//                             color     : _labelColor,
//                             fontSize  : 13,
//                             fontFamily: 'Lato',
//                           ),
//                         )
//                             : Text(
//                           address.isEmpty
//                               ? 'No location selected yet'
//                               : address,
//                           style: TextStyle(
//                             color     : address.isEmpty
//                                 ? _labelColor
//                                 : Colors.white,
//                             fontSize  : 13,
//                             fontFamily: 'Lato',
//                             height    : 1.4,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ),

//             // ── Confirm / Cancel ─────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//               child: Row(
//                 children: [
//                   // Cancel
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => Get.back(),
//                       child: Container(
//                         height    : 46,
//                         decoration: BoxDecoration(
//                           color       : _border,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'CANCEL',
//                             style: TextStyle(
//                               color        : Colors.white,
//                               fontSize     : 14,
//                               fontFamily   : 'League Gothic',
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   // Confirm
//                   Expanded(
//                     child: Obx(() {
//                       final address   = ctrl.mapPickedAddress.value;
//                       final isLoading = ctrl.isGeocodingLoading.value;
//                       final canConfirm =
//                           address.isNotEmpty && !isLoading;

//                       return GestureDetector(
//                         onTap: canConfirm
//                             ? () {
//                           widget.onConfirm(address);
//                           Get.back();
//                         }
//                             : null,
//                         child: AnimatedContainer(
//                           duration  : const Duration(milliseconds: 200),
//                           height    : 46,
//                           decoration: BoxDecoration(
//                             color       : canConfirm
//                                 ? _orange
//                                 : _orange.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(8),
//                             boxShadow   : canConfirm
//                                 ? [
//                               BoxShadow(
//                                 color     : _orange.withOpacity(0.35),
//                                 blurRadius: 12,
//                                 offset    : const Offset(0, 4),
//                               ),
//                             ]
//                                 : [],
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'CONFIRM',
//                               style: TextStyle(
//                                 color        : Colors.white,
//                                 fontSize     : 14,
//                                 fontFamily   : 'League Gothic',
//                                 letterSpacing: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Small apply button (speech dialog) ──────────────────────────────────────
// class _ApplyBtn extends StatelessWidget {
//   final String      label;
//   final Color       color;
//   final VoidCallback onTap;
//   const _ApplyBtn({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height    : 42,
//         decoration: BoxDecoration(
//           color       : color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Center(
//           child: Text(
//             label.toUpperCase(),
//             style: const TextStyle(
//               color        : Colors.white,
//               fontSize     : 11,
//               fontFamily   : 'Lato',
//               fontWeight   : FontWeight.w700,
//               letterSpacing: 0.8,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
