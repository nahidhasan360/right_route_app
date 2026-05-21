// file: views/common/reusable_enter_email_screen.dart  (নতুন ফোল্ডারে রাখতে পারো যাতে বোঝা যায় এটা reusable)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/authentication/enter_email_screen/widgets/continue_widgets.dart';

class ReusableEnterEmailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onContinue;
  final Function(String)? onEmailSubmitted;

  const ReusableEnterEmailScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onContinue,
    this.onEmailSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnterEmailController());

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
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15),
                  Container(
                    width: 225,
                    height: 112,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageManager.splashScreenLogo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 21),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 21),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 50,
                      maxHeight: 70,
                      maxWidth: 500,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.medGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: controller.emailController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      cursorColor: Colors.white,
                      cursorHeight: 22,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.only(
                          top: 15,
                          left: 15,
                          right: 10,
                          bottom: 10,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 25),


                  ContinueWidgets(
                    text: buttonText,
                    width: double.infinity,
                    onPressed: () {
                      String email = controller.emailController.text.trim();

                      if (email.isEmpty) {
                        Get.snackbar("Error", "Please enter your email",
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white);
                        return;
                      }

                      onEmailSubmitted?.call(email);
                      onContinue();
                      controller.emailController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EnterEmailController extends GetxController {
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}