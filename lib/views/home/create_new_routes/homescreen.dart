// ═══════════════════════════════════════════════════════════════════════════
// Homescreen — Production Ready | Pixel Perfect | Responsive
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../../global_widgets/custom_navbar.dart';
import '../../../../utils/assets_manager.dart';
import '../home_api_constant/home_api_constant.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class DraftRouteModel {
  final String name;
  final String date;
  final int stops;
  const DraftRouteModel({
    required this.name,
    required this.date,
    required this.stops,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class CreateRouteService {
  static Future<Map<String, dynamic>> createRoute({
    required String name,
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.createRoute}',
      );

      debugPrint('🚀 [CreateRoute] Requesting: $url');
      debugPrint('📦 [CreateRoute] Body: ${jsonEncode({
            'name': name,
            'description': ''
          })}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'name': name, 'description': ''}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('✅ [CreateRoute] Response Status: ${response.statusCode}');
      debugPrint('📄 [CreateRoute] Response Body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'id': body['id'],
          'name': body['name'] ?? name,
        };
      } else {
        return {
          'success': false,
          'message':
              body['message'] ?? body['detail'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      debugPrint('❌ [CreateRoute] Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────
class HomeController extends GetxController {
  final RxBool isCreating = false.obs;
  final RxString errorMsg = ''.obs;

  final RxList<DraftRouteModel> draftRoutes = <DraftRouteModel>[
    const DraftRouteModel(
        name: 'Downtown Loop', date: 'Apr 28, 2026', stops: 12),
    const DraftRouteModel(
        name: 'Warehouse District', date: 'Apr 25, 2026', stops: 8),
    const DraftRouteModel(
        name: 'North Side Delivery', date: 'Apr 22, 2026', stops: 15),
  ].obs;

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  // ✅ name directly receive করে — controller এ TextEditingController নেই
  Future<void> submitCreateRoute(String name) async {
    if (name.trim().isEmpty) {
      errorMsg.value = 'Route name is required';
      return;
    }

    isCreating.value = true;
    errorMsg.value = '';

    debugPrint('🔘 [HomeController] Submitting Create Route: $name');
    final result = await CreateRouteService.createRoute(name: name.trim());

    isCreating.value = false;

    if (result['success'] == true) {
      debugPrint(
          "🔄 [Navigation] Navigating from Homescreen -> AddPermitScreen");
      debugPrint(
          "📦 [Navigation Arguments] routeName: ${result['name']}, routeId: ${result['id']}");

      Get.back(); // close dialog
      Get.toNamed(
        AppRoutes.addPermitScreen,
        arguments: {
          'routeName': result['name'],
          'routeId': result['id'],
        },
      );
    } else {
      errorMsg.value = result['message'] ?? 'Failed to create route';
    }
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  // ✅ findOrCreate — duplicate registration এড়ায়
  final HomeController _ctrl = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const CustomNavbar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(ImageManager.mapBackground, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0A0E2A).withValues(alpha: 0.72),
            ),
          ),
          SizedBox.expand(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 90.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30.h),
                        Image.asset(
                          ImageManager.splashScreenLogo,
                          width: 225.w,
                          height: 112.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'YOUR ROUTES',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 32.sp,
                            fontFamily: 'League Gothic',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.8,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Start planning your next delivery route or view your recent routes below.',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.78),
                            fontSize: 14.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            height: 1.55,
                          ),
                        ),
                        SizedBox(height: 26.h),
                        _CreateRouteButton(ctrl: _ctrl),
                        SizedBox(height: 34.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'RECENT ROUTES',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 17.sp,
                              fontFamily: 'League Gothic',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Obx(
                          () => Column(
                            children: _ctrl.draftRoutes
                                .map((r) => _DraftRouteCard(route: r))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Route Button ──────────────────────────────────────────────────────
class _CreateRouteButton extends StatelessWidget {
  final HomeController ctrl;
  const _CreateRouteButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ctrl.resetError();
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.65),
          builder: (_) => _CreateRouteDialog(ctrl: ctrl),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/New-Route-white.svg',
              width: 20.w,
              height: 20.h,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'CREATE NEW ROUTE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22.sp,
                fontFamily: 'League Gothic',
                fontWeight: FontWeight.w400,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Route Dialog (StatefulWidget) ────────────────────────────────────
// ✅ StatefulWidget — নিজস্ব TextEditingController manage করে
// HomeController এ কোনো TextEditingController নেই → disposed error নেই
class _CreateRouteDialog extends StatefulWidget {
  final HomeController ctrl;
  const _CreateRouteDialog({required this.ctrl});

  @override
  State<_CreateRouteDialog> createState() => _CreateRouteDialogState();
}

class _CreateRouteDialogState extends State<_CreateRouteDialog> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() => widget.ctrl.submitCreateRoute(_nameCtrl.text);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      // ✅ SingleChildScrollView — keyboard এলে overflow হবে না
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1535),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.unactiveColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CREATE NEW ROUTE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17.sp,
                        fontFamily: 'League Gothic',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.8,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color:
                              AppColors.unactiveColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/Close-X-white.svg',
                            width: 14.w,
                            height: 14.w,
                            colorFilter: ColorFilter.mode(
                              AppColors.white.withValues(alpha: 0.80),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: AppColors.unactiveColor.withValues(alpha: 0.3),
                height: 1,
                thickness: 1,
              ),

              // ── Body ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + title
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/New-Route-white.svg',
                              width: 20.w,
                              height: 20.w,
                              colorFilter: const ColorFilter.mode(
                                AppColors.orange,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEW ROUTE',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18.sp,
                                  fontFamily: 'League Gothic',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'Enter a name for your route',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      AppColors.white.withValues(alpha: 0.50),
                                  fontSize: 12.sp,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      'Route Name',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.75),
                        fontSize: 13.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // ✅ local _nameCtrl — disposed হওয়ার সুযোগ নেই
                    TextField(
                      controller: _nameCtrl,
                      autofocus: true,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Lato',
                      ),
                      cursorColor: AppColors.orange,
                      decoration: InputDecoration(
                        hintText: 'e.g. Downtown Loop',
                        hintStyle: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.30),
                          fontSize: 14.sp,
                          fontFamily: 'Lato',
                        ),
                        filled: true,
                        fillColor: const Color(0xFF162040),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color:
                                AppColors.unactiveColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                              color: AppColors.orange, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),

                    // Error
                    Obx(() {
                      if (widget.ctrl.errorMsg.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: Colors.redAccent, size: 14.sp),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                widget.ctrl.errorMsg.value,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12.sp,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 20.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 46.h,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.unactiveColor
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    color:
                                        AppColors.white.withValues(alpha: 0.65),
                                    fontSize: 15.sp,
                                    fontFamily: 'League Gothic',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap:
                                  widget.ctrl.isCreating.value ? null : _submit,
                              child: Container(
                                height: 46.h,
                                decoration: BoxDecoration(
                                  color: widget.ctrl.isCreating.value
                                      ? AppColors.orange.withValues(alpha: 0.6)
                                      : AppColors.orange,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Center(
                                  child: widget.ctrl.isCreating.value
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child:
                                              const CircularProgressIndicator(
                                            color: AppColors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'CREATE',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 15.sp,
                                            fontFamily: 'League Gothic',
                                            letterSpacing: 1.5,
                                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Draft Route Card ─────────────────────────────────────────────────────────
class _DraftRouteCard extends StatelessWidget {
  final DraftRouteModel route;
  const _DraftRouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1C40).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.medGray.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  route.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.42),
                    fontSize: 12.sp,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${route.stops} stops',
            maxLines: 1,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.50),
              fontSize: 12.sp,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}
