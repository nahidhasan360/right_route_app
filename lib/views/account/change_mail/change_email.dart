import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';
import '../../../global_widgets/custom_navbar.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
import 'package:right_routes/controllers/account/change_email_controller.dart';

class ChangeEmail extends StatelessWidget {
  ChangeEmail({super.key});

  final emailController = Get.put(ChangeEmailController());

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

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
                SizedBox(height: 39.h),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 397.w,
                      child: Text(
                        'Change Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Divider(color: AppColors.dividerColor, thickness: 1),

                    Text(
                      'This replaces the email you use to log in to this app account.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        height: 1.44,
                      ),
                    ),
                    SizedBox(height: 15.h),

                    Text(
                      'Current Right Route account email:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),

                    // 🔥 Dynamic email from AuthService
                    Obx(() => Text(
                          emailController.currentEmail.value.isEmpty
                              ? 'Loading...'
                              : emailController.currentEmail.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
                            height: 1.40,
                          ),
                        )),

                    SizedBox(height: 30.h),

                    Center(child: emailInputField(emailController)),
                    SizedBox(height: 20.h),

                    // 🔥 Button with loading state
                    Obx(() => ButtonReusable(
                          onPressed: emailController.isLoading.value
                              ? null
                              : () => emailController.changeEmail(),
                          text: emailController.isLoading.value
                              ? 'SAVING...'
                              : 'SAVE & CONTINUE',
                          width: 500.w,
                        )),

                    SizedBox(height: 20.h),
                    ButtonReusable(
                      onPressed: () => Get.toNamed(AppRoutes.accountScreen),
                      text: 'CANCEL',
                      width: 500.w,
                      fontSize: 24.sp,
                      backgroundColor: AppColors.medGray,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: CustomNavbar(),
    );
  }
}

// 🔥 Email Input Field Widget
Widget emailInputField(ChangeEmailController controller) {
  return Container(
    height: 57.h,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: AppColors.medGray,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Center(
      child: TextFormField(
        controller: controller.emailController,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
        ),
        cursorColor: Colors.white,
        cursorHeight: 20,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: "Enter new email",
          hintStyle: TextStyle(
            color: const Color(0xFFBFBFBF),
            fontSize: 16.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            height: 1.75,
          ),
          isDense: true,
        ),
      ),
    ),
  );
}
