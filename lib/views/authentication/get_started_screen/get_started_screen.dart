import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../utils/assets_manager.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Common Text Styles
    TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 32.sp,
      fontFamily: 'League Gothic',
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 1,
    );

    TextStyle bodyStyle = TextStyle(
      color: Colors.white,
      fontSize: 18.sp,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      height: 1.40,
    );

    TextStyle subBodyStyle = TextStyle(
      color: Colors.white,
      fontSize: 16.sp,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      height: 1.44,
    );

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
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              /// Sticky Logo
              Container(
                width: 225.w,
                height: 112.h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ImageManager.splashScreenLogo),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),

                      /// Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Text.rich(
                          TextSpan(
                            text:
                                'EXPERIENCE THE EASE OF\nAUTOMATED VISUAL AND VOICE\nGUIDED PERMITTED ROUTE\nNAVIGATION',
                            style: titleStyle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 19.h),

                      /// Description
                      Text(
                        'Start automated routing with your 7-\nday free trial, then \$14.99/mo for\nindividuals.',
                        style: bodyStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 19.h),

                      /// Companies Info
                      Text(
                        'Companies: See pricing tiers\nafter sign-up.',
                        style: subBodyStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),

                      /// Get Started Button
                      CustomButton(
                        text: "GET STARTED",
                        width: 234.w,
                        fontSize: 24.sp,
                        onPressed: () {
                          Get.toNamed(AppRoutes.enterEmailScreen);
                        },
                      ),
                      SizedBox(height: 140.h),
                    ],
                  ),
                ),
              ),

              /// Already a Subscriber & SIGN IN
              Column(
                children: [
                  Text(
                    'Already a Subscriber?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.loginAccount);
                    },
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 18.sp,
                        fontFamily: 'League Gothic',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
