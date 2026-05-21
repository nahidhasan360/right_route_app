import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
import '../terms_of_service/terms_of_service.dart';
class WeLoggedYou extends StatelessWidget {
  const WeLoggedYou({super.key});

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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                /// LOGO
                Center(
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
                ),
                SizedBox(height: 21),
                Text(
                  'We’ve logged you in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 21),
                SizedBox(
                  child: Text(
                    'You can now continue to Right Route. If you ve forgotten your password, you can choose a new one now or update it from your account Settings another time.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 29),

                // ======================== BUTTON ======================
                /// CONTINUE BUTTON
                GestureDetector(
                  onTap: () {
                    // controller.verifyOtp();
                    // Get.dialog(
                    //   TermsModal(),
                    //   barrierDismissible: true,
                    // );
                    Get.toNamed(AppRoutes.individualTeam);
                    print('Its clicked ');
                  },
                  child: Container(
                    width: 392,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CONTINUE',
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

                SizedBox(height: 25),

                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.changePassword);
                  },
                  child: Container(
                    width: 392,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.medGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CHANGE PASSWORD',
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
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
