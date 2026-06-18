import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';

import '../../../utils/assets_manager.dart';
import '../../global_widgets/custom_navbar.dart';
import '../../utils/colors.dart';

class AreYouSureDeleteThisAccount extends StatelessWidget {
  const AreYouSureDeleteThisAccount({super.key});

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
          child: Column(
            children: [
              SizedBox(height: 40.h),

              /// LOGO - FIXED AT TOP (No Scroll)
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

              /// SCROLLABLE CONTENT
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are you sure?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Divider(color: AppColors.dividerColor, thickness: 1),
                        Text(
                          'Right Route - Oversized Load Navigator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            height: 1.40.h,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 17.h),

                        /// TOP IMPORTANT SECTION
                        /// ---------------------------
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "IMPORTANT: ",
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 20.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "You need to cancel your subscription in the App or Google Play store first before deleting the account in this app. Deleting this account does not stop your subscription billing but you will lose app login access and all of your data including Route History.\n\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "When you have canceled your subscription, the routing features of this app will inactive but you will still have access to your Route History and Settings until you delete this account. You will no longer be billed.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.h),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "IMPORTANT: ",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  height: 1.40.h,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "If you purchased a single user Yearly plan, your subscription will terminated at the end of its billing cycle. We don't offer refunds for unused months.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  height: 1.40.h,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        ButtonReusable(
                          onPressed: () => Get.toNamed(AppRoutes.accountDelete),
                          text: 'YES, DELETE THIS ACCOUNT',
                          width: double.infinity,
                        ),

                        SizedBox(height: 21.h),

                        ButtonReusable(
                          onPressed: () => Get.toNamed(AppRoutes.accountScreen),
                          text: 'NO. I’LL KEEP IT',
                          width: double.infinity,
                          fontSize: 24.sp,
                          backgroundColor: AppColors.medGray,
                        ),

                        SizedBox(height: 20.h), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(),
    );
  }
}

class changeEmailController extends GetxController {
  RxBool obscure = true.obs;
  final emailController = TextEditingController();
}

Widget emailInputField(changeEmailController controller) {
  return Container(
    height: 57.h,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: AppColors.medGray,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.emailController,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
            cursorColor: Colors.white,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter new email",
              hintStyle: TextStyle(
                color: const Color(0xFFBFBFBF),
                fontSize: 16.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                height: 1.75.h,
              ),
            ),
          ),
        ),
        Obx(
          () => GestureDetector(
            onTap: () => controller.obscure.toggle(),
            child: Icon(
              controller.obscure.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24.sp,
            ),
          ),
        ),
      ],
    ),
  );
}
