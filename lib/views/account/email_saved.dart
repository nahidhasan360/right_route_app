import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';

import 'package:right_routes/core/routes/all_routes.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class EmailSaved extends StatelessWidget {
  const EmailSaved({super.key});

  final String savedEmail = 'tanvirhasancr890890@gmail.com';

  // one return to back press
  void onReturnPressed(BuildContext context) {
    debugPrint('RETURN button pessed!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageManager.mapBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40.h),

                  /// LOGO
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
                  SizedBox(height: 25.h),

                  /// LOGO
                  Center(
                    child: SizedBox(
                      width: 62.w,
                      height: 62.h,
                      child: SvgPicture.asset(
                        SvgManager.blueIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 21.h),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 397.w,
                        child: Text(
                          'Your new Right Route email is saved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            height: 1.h,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Divider(color: AppColors.dividerColor, thickness: 1),
                      Text(
                        'New email:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44.h,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'tanvirhasancr@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          height: 1.40.h,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      ButtonReusable(
                        onPressed: () => Get.toNamed(AppRoutes.accountScreen),
                        text: 'RETURN',
                        width: double.infinity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomNavbar());
  }
}
