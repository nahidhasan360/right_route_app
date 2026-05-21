import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class AccountDelete extends StatelessWidget {
  const AccountDelete({super.key});

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
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Right Route account has been deleted',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 13),
                    Divider(color: AppColors.dividerColor, thickness: 1),
                    SizedBox(height: 15),
                    Text(
                      'Please be sure to cancel your paid subscription at the app store you purchased it from.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 290),

                    ButtonReusable(
                      onPressed: () => Get.toNamed(AppRoutes.getStartedScreen),
                      text: 'EXIT',
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
