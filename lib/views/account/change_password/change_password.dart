import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../../utils/assets_manager.dart';
import 'change_password_service.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final changePassController = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Divider(color: AppColors.white, thickness: 1),
                      SizedBox(height: 5.h),
                      Text(
                        'This replaces the password you use to log in to this app account.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),
                      SizedBox(height: 27.h),
                      // Password Input section
                      _buildPasswordField(context),
                      // Password strength bar section (Animated)
                      _buildProgressBar(context),

                      // Password criteria section with validation
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ruleTile(
                              context,
                              changePassController.isSixChars.value,
                              "Use a minimum of six characters (Case sensitive)",
                            ),
                            SizedBox(height: 12.h),
                            _ruleTile(
                              context,
                              changePassController.hasNumberOrSpecial.value,
                              "Use letters with at least one number or special character",
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // 🔥 Updated Button with API Integration
                      Obx(() => ButtonReusable(
                            onPressed: changePassController.isLoading.value
                                ? null
                                : () => changePassController.changePassword(),
                            text: changePassController.isLoading.value
                                ? 'SAVING...'
                                : 'SAVE & CONTINUE',
                            width: double.infinity,
                          )),

                      SizedBox(height: 20.h),
                      ButtonReusable(
                        onPressed: () => Get.back(),
                        text: 'CANCEL',
                        width: double.infinity,
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

  /// ================= Dynamic Progress Bar ======================
  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      final progress = changePassController.strengthProgress.value;
      final color = changePassController.strengthColor.value;
      final label = changePassController.strengthLabel.value;

      return Padding(
        padding: EdgeInsets.only(
            top: 15.h, bottom: 15.h, left: 0.w, right: 70.w),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Stack(
                  children: [
                    AnimatedFractionallySizedBox(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 60.w,
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: 16.sp,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
                child: Text(label, textAlign: TextAlign.left),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ================= Password Field ======================
  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => Container(
        width: 388.w,
        height: 48.h,
        decoration: ShapeDecoration(
          color: AppColors.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Expanded(
              child: TextField(
                controller: changePassController.changeEditing,
                obscureText: changePassController.isPasswordHidden.value,
                onChanged: (v) => changePassController.password.value = v,
                cursorColor: Colors.white,
                cursorWidth: 2,
                cursorHeight: 20,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Lato',
                ),
                decoration: InputDecoration(
                  hintText: "Create a password",
                  hintStyle: TextStyle(
                    color: Color(0xffBFBFBF),
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    fontFamily: 'Lato',
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: changePassController.togglePasswordVisibility,
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  changePassController.isPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= Rule Tile ============================
  Widget _ruleTile(BuildContext context, bool active, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          margin: EdgeInsets.only(top: 2.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.orange : AppColors.medGray,
            border: Border.all(
              color: active ? AppColors.orange : AppColors.medGray,
              width: 2.w,
            ),
          ),
          child: active
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Lato',
            ),
          ),
        ),
      ],
    );
  }
}

// 🔥 Updated Controller with API Integration
class ChangePasswordController extends GetxController {
  final TextEditingController changeEditing = TextEditingController();
  var password = ''.obs;
  var isPasswordValid = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs; // 👈 Loading state added

  // Password validation flags
  var isSixChars = false.obs;
  var hasNumberOrSpecial = false.obs;

  // Strength indicator
  var strengthProgress = 0.0.obs;
  var strengthColor = AppColors.medGray.obs;
  var strengthLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to password changes
    password.listen((_) {
      validatePassword();
      updateStrength();
    });
  }

  @override
  void onClose() {
    changeEditing.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Check password validity
  void validatePassword() {
    // Check minimum 6 characters
    isSixChars.value = password.value.length >= 6;

    // Check for at least one number or special character
    final hasNumber = RegExp(r'\d').hasMatch(password.value);
    final hasSpecial = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password.value);
    hasNumberOrSpecial.value = hasNumber || hasSpecial;

    // Overall validity
    isPasswordValid.value = isSixChars.value && hasNumberOrSpecial.value;
  }

  // Update strength indicator
  void updateStrength() {
    final len = password.value.length;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password.value);
    final hasLower = RegExp(r'[a-z]').hasMatch(password.value);
    final hasNumber = RegExp(r'\d').hasMatch(password.value);
    final hasSpecial = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(password.value);

    int strength = 0;

    if (len >= 6) strength++;
    if (len >= 10) strength++;
    if (hasUpper && hasLower) strength++;
    if (hasNumber) strength++;
    if (hasSpecial) strength++;

    // Update progress, color, and label based on strength
    if (strength <= 1) {
      strengthProgress.value = 0.3;
      strengthColor.value = Colors.red;
      strengthLabel.value = 'Weak';
    } else if (strength == 2 || strength == 3) {
      strengthProgress.value = 0.6;
      strengthColor.value = Colors.yellow;
      strengthLabel.value = 'Fair';
    } else if (strength >= 4) {
      strengthProgress.value = 1.0;
      strengthColor.value = Colors.green;
      strengthLabel.value = 'Strong';
    }

    // Empty password
    if (len == 0) {
      strengthProgress.value = 0.0;
      strengthColor.value = AppColors.medGray;
      strengthLabel.value = '';
    }
  }

  // 🔥 NEW: Change Password Function with API Integration
  Future<void> changePassword() async {
    // Validation
    String newPassword = password.value.trim();

    if (newPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isPasswordValid.value) {
      Get.snackbar(
        'Error',
        'Password must meet all requirements',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Start loading
    isLoading.value = true;

    // 🔥 Call API
    final result = await ChangePasswordService.changePassword(newPassword);

    // Stop loading
    isLoading.value = false;

    // Check result
    if (result['success']) {
      // ✅ Success
      Get.snackbar(
        'Success',
        result['message'],
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      // Navigate to success screen
      await Future.delayed(Duration(milliseconds: 500));
      Get.toNamed(AppRoutes.passwordSaved);
    } else {
      // ❌ Error
      Get.snackbar(
        'Error',
        result['message'],
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }
}
