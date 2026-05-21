import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../utils/assets_manager.dart';
import '../../global_widgets/custom_navbar.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({super.key});

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
              mainAxisAlignment: MainAxisAlignment.start,
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
                SizedBox(height: 39),
                Text(
                  'Contact Support',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    height: 1.14,
                    letterSpacing: 1,
                  ),
                ),

                Divider(color: AppColors.dividerColor, thickness: 1),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Please contact us at ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),
                      TextSpan(
                        text: 'help@rightroute.com',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),
                    ],
                  ),
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
