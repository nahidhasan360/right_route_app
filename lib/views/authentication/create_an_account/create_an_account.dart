// create_an_account.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../global_widgets/custom_troggle_button.dart';
import '../../../utils/assets_manager.dart';
import 'create_password_controller.dart';

class CreateAnAccount extends StatelessWidget {
  CreateAnAccount({super.key});

  final controller = Get.put(CreatePasswordController());
  final troggleController = Get.put(ToggleController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              SizedBox(height: 40),
              Center(child: _buildLogo()),
              SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create an account to continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            height: 1.12,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Creating an account gives you full functionality, '
                              'access to your route history, account settings and subscription status.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            height: 1.44,
                          ),
                        ),
                        SizedBox(height: 17),
                        _buildEmailDisplay(),
                        SizedBox(height: 32),
                        _buildPasswordField(screenWidth),
                        _buildProgressBar(),
                        Obx(
                              () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ruleTile(
                                controller.isSixChars.value,
                                "Use a minimum of six characters ( Case sensitive )",
                              ),
                              SizedBox(height: 12),
                              _ruleTile(
                                controller.hasNumberOrSpecial.value,
                                "Use letters with at least one number or special character",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            CustomToggleSwitchAdvanced(
                              height: 24,
                              width: 51,
                              value: troggleController.isEnabled,
                              onChanged: (val) {
                                controller.useTouchId.value = val;
                                print('Touch ID Toggle: $val');
                              },
                              activeSvgPath: 'assets/icons/Check-orange.svg',
                              svgColor: AppColors.orange,
                              activeColor: Color(0xFFFF8C42),
                              inactiveColor: Colors.white.withOpacity(0.3),
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Use touch ID',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 21),
                        Obx(() => _buildTermsCheckbox()),
                        SizedBox(height: 12),
                        Obx(() => _buildPrivacyCheckbox()),
                        SizedBox(height: 28),
                        Obx(() => _buildContinueButton()),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 225,
      height: 112,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageManager.splashScreenLogo),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final progress = controller.strengthProgress.value;
      final color = controller.strengthColor.value;
      final label = controller.strengthLabel.value;

      return Padding(
        padding: EdgeInsets.only(top: 7, bottom: 15, left: 0, right: 70),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.medGray,
                  borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
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

  Widget _buildEmailDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account using',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            height: 1.44,
          ),
        ),
        Row(
          children: [
            Obx(
                  () => Text(
                controller.email.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.44,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.enterEmailScreen);
              },
              child: Text(
                'edit',
                style: TextStyle(
                  color: AppColors.editEmailColor,
                  fontSize: 18,
                  height: 1.44,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  decorationColor: AppColors.purple,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField(double screenWidth) {
    return Obx(
          () => Container(
        width: 388,
        height: 48,
        decoration: ShapeDecoration(
          color: AppColors.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                onChanged: (v) => controller.password.value = v,
                cursorColor: Colors.white,
                cursorWidth: 2,
                cursorHeight: 20,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Lato',
                ),
                decoration: InputDecoration(
                  hintText: "Create a password",
                  hintStyle: TextStyle(
                    color: Color(0xffBFBFBF),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    fontFamily: 'Lato',
                    height: 1.75,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  controller.isPasswordHidden.value
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

  Widget _ruleTile(bool active, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.orange : AppColors.medGray,
            border: Border.all(
              color: active ? AppColors.orange : AppColors.medGray,
              width: 2,
            ),
          ),
          child: active
              ? Icon(
            Icons.check,
            color: Colors.white,
            size: 12,
            fontWeight: FontWeight.bold,
          )
              : null,
        ),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Lato',
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomCheckbox(
          controller.agreeTerms.value,
              () => controller.agreeTerms.value = !controller.agreeTerms.value,
        ),
        SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "I have read & agree to the ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Lato',
                    height: 1.38,
                  ),
                ),
                TextSpan(
                  text: "Terms of Use",
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 16,
                    fontFamily: 'Lato',
                    height: 1.38,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = controller.viewTermsOfUse,
                ),
                TextSpan(
                  text: ".",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCheckbox() {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomCheckbox(
            controller.agreePrivacy.value,
                () => controller.agreePrivacy.value = !controller.agreePrivacy.value,
          ),
          SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "I have read & understand the ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                  TextSpan(
                    text: "Privacy & Policy",
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 16,
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.viewPrivacyPolicy,
                  ),
                  TextSpan(
                    text:
                    ", and understand the nature of my consent to the collection, use and/or disclosure of my personal data and the consequences of such consent.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        margin: EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: value ? AppColors.orange : AppColors.medGray,
          border: Border.all(
            color: value ? AppColors.orange : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: value
            ? SvgPicture.asset(
          "assets/icons/Check-Box-orange.svg",
          width: 12,
          height: 12,
        )
            : null,
      ),
    );
  }

  /// ✅ Updated Button - API call করবে
  Widget _buildContinueButton() {
    final isEnabled = controller.isFormValid;

    return GestureDetector(
      onTap: isEnabled && !controller.isLoading.value
          ? () {
        controller.createAccount(); // 🔥 API call
      }
          : null,
      child: Container(
        width: 393,
        height: 55,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(colors: [Color(0xffF58842), Color(0xffF58842)])
              : null,
          color: isEnabled ? null : AppColors.orange.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: controller.isLoading.value
              ? CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          )
              : Text(
            'AGREE & CONTINUE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              height: 1.17,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}