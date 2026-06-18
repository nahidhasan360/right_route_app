import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_map.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_document.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_route_name.dart';
import '../../../../global_widgets/custom_navbar.dart';
import '../../../../utils/assets_manager.dart';
import 'package:right_routes/controllers/home/home_controller.dart';
import 'home_screen_map.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // CREATE ROUTE TITLE
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'CREATE ROUTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36.sp,
                          fontFamily: 'League Gothic',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Enter Route Name Label
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Enter Route Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () {
                          showRouteNameDialog(context);
                        },
                        child: SvgPicture.asset(
                          'assets/icons/Question-Box-gray.svg',
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Text Field with Microphone
                  Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 0.h),
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'Lato',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            padding: EdgeInsets.all(6.h),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: SvgPicture.asset(
                              SvgManager.micWhite,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 35.h), // Increased spacing to match screenshot

                  // Permit 1
                  Center(
                    child: Obx(() => Text(
                          'Permit ${_ctrl.currentPermitIndex.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                  ),
                  SizedBox(height: 8.h), // Adjusted spacing

                  // Step 1 Label
                  Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 1: ',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 19.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _ctrl.currentPermitIndex.value > 1
                                  ? 'Set your End Point'
                                  : 'Set your Start & End Points',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: GestureDetector(
                              onTap: () {
                                dialogMap(context);
                              },
                              child: SvgPicture.asset(
                                'assets/icons/Question-Box-gray.svg',
                                width: 20.w,
                                height: 20.h,
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 12.h),

                  // Dynamic Map
                  const HomeScreenMap(),
                  SizedBox(height: 25.h),

                  // Step 2 Label
                  Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 2: ',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 19.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Import Permit ${_ctrl.currentPermitIndex.value}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: GestureDetector(
                              onTap: () {
                                showPermitDialog(context);
                              },
                              child: SvgPicture.asset(
                                'assets/icons/Question-Box-gray.svg',
                                width: 20.w,
                                height: 20.h,
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 16.h),

                  // Action Buttons Row - 90% horizontal width
                  LayoutBuilder(builder: (context, constraints) {
                    // Calculate the 90% width
                    final rowWidth = constraints.maxWidth * 0.8;
                    // Calculate button size dynamically to fit 4 buttons perfectly with spacing
                    final buttonWidth = (rowWidth - (3 * 10.w)) /
                        4; // reduced spacing slightly for smaller buttons
                    // Limit max size
                    final finalWidth = buttonWidth > 65.w ? 65.w : buttonWidth;

                    return Center(
                      child: SizedBox(
                        width: rowWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(
                                SvgManager.importWhite, finalWidth),
                            _buildActionButton(
                                SvgManager.editPencilWhite, finalWidth),
                            _buildActionButton(SvgManager.micWhite, finalWidth),
                            _buildActionButton(
                                SvgManager.cameraWhite, finalWidth),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 35.h),

                  // CONTINUE Button
                  Center(
                    child: CustomButton(
                      text: 'CONTINUE',
                      width: 200.w,
                      height: 57.h,
                      fontSize: 26.sp,
                      backgroundColor: AppColors.orange,
                      borderRadius: 13,
                      onPressed: () {
                        Get.toNamed(AppRoutes.confirmYourRoutes);
                      },
                    ),
                  ),

                  SizedBox(height: 120.h), // padding for bottom navbar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String svgPath, double width) {
    return Container(
      width: width,
      height: 60.h, // Adjusted height to make it more rectangular
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          svgPath,
          width: 36.w,
          height: 36.h,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
