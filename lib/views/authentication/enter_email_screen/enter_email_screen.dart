import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/controllers/auth/enter_email_controller.dart';

class EnterEmailScreen extends StatelessWidget {
  // Get.put() use করছি - এটা automatically inject করবে যদি না থাকে
  final controller = Get.put(EnterEmailController());

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
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.h),
                    SizedBox(
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
                    SizedBox(height: 21.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your email to continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 21.h),
                        SizedBox(
                          child: Text(
                            "Log in to your Route Pilot account. If you don't have one, you will be prompted to create one.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: 50.h,
                        maxHeight: 70.h,
                        maxWidth: 500.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.medGray,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TextFormField(
                        controller: controller.emailController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          height: 1.4.h,
                          letterSpacing: 0.2,
                        ),
                        cursorColor: Color(0xFFFFFFFF),
                        cursorHeight: 22.h,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Color(0xFFBFBFBF),
                            fontSize: 16.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                          ),
                          isDense: false,
                          contentPadding: EdgeInsets.only(
                            top: 15.h,
                            left: 15.w,
                            right: 10.w,
                            bottom: 10.h,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Obx(() => CustomButton(
                          text: controller.isLoading.value ? 'LOADING...' : 'CONTINUE',
                          width: double.infinity,
                          height: 57.h,
                          isLoading: controller.isLoading.value,
                          showSpinner: false,
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.checkEmail();
                                },
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
