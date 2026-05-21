import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../utils/assets_manager.dart';
import '../login_account/login_controller.dart';
import '../login_account/login_binding.dart';
import '../login_account/reusable_enter_email-screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Common Text Styles
     TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontFamily: 'League Gothic',
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 1,
    );

     TextStyle bodyStyle = TextStyle(
       color: Colors.white,
       fontSize: 20,
       fontFamily: 'Lato',
       fontWeight: FontWeight.w500,
       height: 1.40,
    );

    const TextStyle subBodyStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      height: 1.44,
    );

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
                SizedBox(height: 40,),
              /// Sticky Logo
              Container(
                width: 225,
                height: 112,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ImageManager.splashScreenLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              /// Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),

                      /// Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text.rich(
                          TextSpan(
                            text:
                            'EXPERIENCE THE EASE OF\nAUTOMATED VISUAL AND VOICE\nGUIDED PERMITTED ROUTE\nNAVIGATION',
                            style: titleStyle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 19),

                      /// Description
                      SizedBox(
                        width: 330,
                        child: Text(
                          'Start automated routing with your 7-\nday free trial, then \$14.99/mo for\nindividuals.',
                          style: bodyStyle.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 19),

                      /// Companies Info
                      SizedBox(
                        width: 263,
                        child: Text(
                          'Companies: See pricing tiers\nafter sign-up.',
                          style: subBodyStyle.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 19),

                      /// Get Started Button
                      CustomButton(
                        text: "Get Started",
                        fontSize: 24,
                        onPressed: () {
                          Get.toNamed(AppRoutes.enterEmailScreen);
                        },
                      ),
                      SizedBox(height: 130),

                      /// Already a Subscriber
                      SizedBox(
                        width: 160,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already a Subscriber?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,

                                ),
                              ),
                              TextSpan(
                                text: 'SIGN IN ',
                                style: TextStyle(
                                  color: AppColors.purple,
                                  fontSize: 20,
                                  fontFamily: 'League Gothic',
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(() =>

                                        Get.toNamed(AppRoutes.loginAccount),


                                    //     ReusableEnterEmailScreen(
                                    //   title: 'Enter your email to continue',
                                    //   subtitle: 'Log in to your Route Route account. If you don’t have one, you will be prompted to create one.',
                                    //   buttonText: 'CONTINUE',
                                    //   onContinue: () {
                                    //     Get.toNamed(AppRoutes.loginAccount);
                                    //   },
                                    //   onEmailSubmitted: (ema*il) {
                                    //     Get.find<LoginController>().setEmail(email);
                                    //     print("Saved email for login: $email");
                                    //   },
                                    //
                                    // ),
                                    //   binding: LoginBinding(),


                                    );
                                  },
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
