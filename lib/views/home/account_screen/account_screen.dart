import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../core/constants/services/auth_service.dart';
import '../../../utils/assets_manager.dart';
import 'logout_api_service.dart';

// -----------------------------------------------------------------------------
// CONTROLLER (GetX)
// -----------------------------------------------------------------------------
class ManageAccountController extends GetxController {
  RxBool showPassword = false.obs;

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }
}

// -----------------------------------------------------------------------------
// COLOR PALETTE
// -----------------------------------------------------------------------------
class RRColors {
  static const Color bgDarkBlue = Color(0xFF020B2E);
  static const Color accentOrange = Color(0xFFFF7A29);
  static const Color white = Colors.white;
}

// REUSABLE WIDGETS
// -----------------------------------------------------------------------------
class RRRightArrowTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final FontWeight fontWeight;

  const RRRightArrowTile({
    super.key,
    required this.title,
    this.onTap,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19.sp,
                fontFamily: 'Lato',
                fontWeight: fontWeight,
                height: 1.56.h,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: RRColors.white, size: 26.sp),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final c = Get.put(ManageAccountController());

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
              SizedBox(height: 20.h),

              // Sticky Logo (Always stays at the top)
              _buildLogo(),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildSectionTitle("Manage Account"),
                      _buildDivider(),
                      _buildEmailSection(),
                      SizedBox(height: 6.h),
                      _buildPasswordSection(),
                      SizedBox(height: 4.h),
                      _buildRouteHistory(),
                      SizedBox(height: 1.h),
                      _buildDivider(),
                      _buildCurrentPlan(),
                      _buildDivider(),
                      _buildCustomerCare(),
                      _buildDivider(),
                      _buildLegalSection(),
                      _buildDivider(),
                      SizedBox(height: 12.h),
                      _buildVersion(),
                      SizedBox(height: 12.h),
                      _buildDivider(),
                      _buildLogoutSection(),
                      SizedBox(height: 18.h),
                      _buildExitButton(),
                      SizedBox(height: 60.h),
                    ],
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

  // ===================================== logo ================================
  Widget _buildLogo() {
    return Center(
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
    );
  }

  // ======================= screen header ==============================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28.sp,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w700,
        height: 1.14.h,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.white, thickness: 1);
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56.h,
          ),
        ),
        RRRightArrowTile(
          title: "emailaddress@email.com",
          onTap: () {
            Get.toNamed(AppRoutes.changeEmail);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                height: 1.56.h,
              ),
            ),
            SizedBox(width: 7.w),
            Obx(() {
              return GestureDetector(
                onTap: c.togglePassword,
                child: SvgPicture.asset(
                  c.showPassword.value
                      ? SvgManager.eyeSlashBigPupil
                      : SvgManager.eyeBigPupil,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Text(
                  c.showPassword.value ? "mypassword123" : "**********",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    height: 0.88,
                  ),
                ),
              );
            }),
            RRRightArrowTile(
              title: "",
              onTap: () {
                Get.toNamed(AppRoutes.changePassword);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteHistory() {
    return RRRightArrowTile(
      title: "My Route History",
      fontWeight: FontWeight.w500,
      onTap: () {
        Get.toNamed(AppRoutes.historyScreen);
      },
    );
  }

  Widget _buildCurrentPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          "CURRENT PLAN",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 24.sp,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17.h,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "sub.100 monthly",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56.h,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Enrolled Users: 4 of 100",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56.h,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Renewal Date: 07/03/2026",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56.h,
          ),
        ),
        SizedBox(height: 4.h),
        RRRightArrowTile(
          title: "Change Plan",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.toNamed(AppRoutes.chooseYourPlan);
          },
        ),
        RRRightArrowTile(
          title: "Manage Team",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.toNamed(AppRoutes.teamManager);
          },
        ),
      ],
    );
  }

  Widget _buildCustomerCare() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Text(
          "CUSTOMER CARE",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 24.sp,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17.h,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 10.h),
        RRRightArrowTile(
          title: "Contact Support",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.toNamed(AppRoutes.contactSupport);
          },
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 17.h),
        Text(
          "LEGAL",
          style: TextStyle(
            color: const Color(0xFFF58842),
            fontSize: 24.sp,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17.h,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 10.h),
        RRRightArrowTile(
          title: "Privacy Policy",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.toNamed(AppRoutes.privacyPolicy);
          },
        ),
        RRRightArrowTile(
          title: "Terms of Use",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.toNamed(AppRoutes.termsModal);
          },
        ),
        RRRightArrowTile(
          title: "Disclaimer",
          fontWeight: FontWeight.w500,
          onTap: () {
            // Replace with appropriate route
          },
        ),
      ],
    );
  }

  Widget _buildVersion() {
    return Text(
      "Version 1.00.0",
      style: TextStyle(
        color: AppColors.orange,
        fontSize: 18.sp,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w500,
        height: 1.56.h,
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RRRightArrowTile(
          title: "Logout",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 20,
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Get.back(); // Close dialog
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 4.h),
                                minimumSize: Size(0, 0),
                              ),
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'NOTE: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Are you sure you want to logout?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Get.back(); // Close dialog

                                  // Backend Logout
                                  await LogoutApiService.logout();

                                  // Local Logout
                                  await AuthService.logout();
                                  Get.offAllNamed(AppRoutes.enterEmailScreen);

                                  Get.snackbar(
                                    'Logged Out',
                                    'You have been logged out successfully',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFFB71C1C),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                child: Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        RRRightArrowTile(
          title: "Delete Account",
          fontWeight: FontWeight.w500,
          onTap: () {
            // Navigate to delete account screen
            Get.toNamed(AppRoutes.areYouSureDeleteThisAccount);
          },
        ),
      ],
    );
  }

  Widget _buildExitButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.homeScreen);
        },
        child: Container(
          width: double.infinity,
          height: 58.h,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            'EXIT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              height: 1.17.h,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
