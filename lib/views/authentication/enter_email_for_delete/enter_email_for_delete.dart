// lib/views/authentication/enter_email_screen/enter_email_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/authentication/enter_email_screen/widgets/continue_widgets.dart';

class EnterEmailForDelete extends StatelessWidget {
  const EnterEmailForDelete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Safe controller initialization
    final controller = Get.put(EnterEmailForDeleteController());

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15),
                  SizedBox(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your email to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 21),
                      SizedBox(
                        child: Text(
                          "Log in to your Right Route account. If you don't have one, you will be prompted to create one.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
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
                      onChanged: (value) => controller.updateEmail(value),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      cursorColor: Color(0xFFFFFFFF),
                      cursorHeight: 22,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: false,
                        contentPadding: EdgeInsets.only(
                          top: 15,
                          left: 15,
                          right: 10,
                          bottom: 10,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: 25),
                  ContinueWidgets(
                    text: 'CONTINUE',
                    width: double.infinity,
                    onPressed: () {
                      Get.toNamed(AppRoutes.loginAccount);
                      print('button clicked');
                      print('Email: ${controller.emailController.text}');
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

// lib/views/authentication/enter_email_screen/enter_email_controller.dart

class EnterEmailForDeleteController extends GetxController {
  final TextEditingController emailController = TextEditingController();

  RxString email = ''.obs;

  void updateEmail(String value) {
    email.value = value;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
