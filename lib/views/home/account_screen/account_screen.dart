import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../core/constants/services/auth_service.dart';
import '../../../utils/assets_manager.dart';
import '../../authentication/enter_email_for_delete/enter_email_for_delete.dart';
import '../../authentication/login_account/login_account.dart';

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

  const RRRightArrowTile({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                height: 1.56,
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
        child: Column(
          children: [
            SizedBox(height: 50),

            // Sticky Logo (Always stays at the top)
            _buildLogo(),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildSectionTitle("Manage Account"),
                    _buildDivider(),
                    _buildEmailSection(),
                    SizedBox(height: 3),
                    _buildPasswordSection(),
                    SizedBox(height: 1),
                    _buildRouteHistory(),
                    SizedBox(height: 1),
                    _buildDivider(),
                    _buildCurrentPlan(),
                    _buildDivider(),
                    _buildCustomerCare(),
                    _buildDivider(),
                    _buildLegalSection(),
                    _buildDivider(),
                    SizedBox(height: 12),
                    _buildVersion(),
                    SizedBox(height: 18),
                    _buildExitButton(),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavbar(),
    );
  }

  // =====================================   logo ================================
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 225,
        height: 112,
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
        fontSize: 28,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w700,
        height: 1.14,
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
          "Email:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        RRRightArrowTile(
          title: "tanvirhasancr890890@gmail.com",
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
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                height: 1.56,
              ),
            ),
            SizedBox(width: 3),
            Obx(() {
              return GestureDetector(
                onTap: c.togglePassword,
                child: Icon(
                  c.showPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 24,
                  color: AppColors.white,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteHistory() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              return Text(
                c.showPassword.value ? "mypassword123" : "***************",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  height: 0.88,
                ),
              );
            }),
            RRRightArrowTile(
              title: "",
              onTap: () {
                // Navigate to route history screen
                Get.toNamed(AppRoutes.changePassword);
              },
            ),
          ],
        ),
        RRRightArrowTile(
          title: "My Route History",
          onTap: () {
            // Navigate to route history screen
            Get.toNamed(AppRoutes.historyScreen);
          },
        ),
      ],
    );
  }

  Widget _buildCurrentPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          "MY CURRENT PLAN",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 24,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "[ Plan name here ]",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        Text(
          "Users: xxxx",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        Text(
          "Renewal Date: Nov 29, 2025",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        SizedBox(height: 10),
        _buildPlanActions(),
      ],
    );
  }

  Widget _buildPlanActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.chooseATeamPlan);
              },
              child: Text.rich(
                TextSpan(
                  text: "Team Plans: ",
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 18,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    height: 1.56,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    TextSpan(
                      text: "Upgrade or Downgrade",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        height: 1.56,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RRRightArrowTile(
              onTap: () {
                // Navigate to help center
                Get.toNamed(AppRoutes.chooseATeamPlan);
              },
              title: '',
            ),
          ],
        ),
        RRRightArrowTile(
          title: "Manage Team",
          onTap: () {
            // Navigate to manage team page
            Get.toNamed(AppRoutes.teamManager);
          },
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.chooseYourPlan);
                },
                child: Text.rich(
                  TextSpan(
                    text: "Single User Plan: ",
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 18,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                      height: 1.56,
                    ),
                    children: [
                      TextSpan(
                        text: "Upgrade to Yearly Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            RRRightArrowTile(
              onTap: () {
                Get.toNamed(AppRoutes.chooseYourPlan);
              },
              title: '',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerCare() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          "CUSTOMER CARE",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 24,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 10),
        RRRightArrowTile(
          title: "Contact Support",
          onTap: () {
            // Navigate to support page
            Get.toNamed(AppRoutes.contactSupport);
          },
        ),
        RRRightArrowTile(
          title: "Help Center",
          onTap: () {
            // Navigate to help center
            Get.toNamed(AppRoutes.help);
          },
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 17),
        Text(
          "LEGAL",
          style: TextStyle(
            color: const Color(0xFFF58842),
            fontSize: 24,
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 10),
        RRRightArrowTile(
          title: "Privacy Policy",
          onTap: () {
            // Navigate to privacy policy page
            Get.toNamed(AppRoutes.privacyPolicy);
          },
        ),
        RRRightArrowTile(
          title: "Terms of Use",
          onTap: () {
            // Navigate to terms of use page
            Get.toNamed(AppRoutes.termsModal);
          },
        ),
        RRRightArrowTile(
          title: "Right Route Subscriber Agreement",
          onTap: () {
            // Navigate to subscriber agreement page
            Get.toNamed(AppRoutes.subscriberAgreement);
          },
        ),

        //==========================  logout section  ===========================
        RRRightArrowTile(
          title: "Log out",
          onTap: () {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    horizontal: 12, vertical: 4),
                                minimumSize: Size(0, 0),
                              ),
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Message content
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NOTE: text
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'NOTE: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Are you sure you want to logout?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Logout button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Get.back(); // Close dialog

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
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
          onTap: () {
            // Navigate to delete account screen
            Get.toNamed(AppRoutes.areYouSureDeleteThisAccount);
          },
        ),
      ],
    );
  }

  Widget _buildVersion() {
    return Text(
      "Version 0.0.0",
      style: TextStyle(
        color: AppColors.orange,
        fontSize: 18,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w500,
        height: 1.56,
      ),
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
          height: 50,
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
