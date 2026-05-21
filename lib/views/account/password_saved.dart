import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class PasswordSaved extends StatelessWidget {
  const PasswordSaved({super.key});

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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
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
                SizedBox(height: 25),

                /// LOGO
                Center(
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: SvgPicture.asset(
                      SvgManager.blueIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 21),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        'Your new Right Route password is saved',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Divider(color: AppColors.dividerColor, thickness: 1),
                    SizedBox(height: 34),

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

      bottomNavigationBar: CustomNavbar(),
    );
  }
}
