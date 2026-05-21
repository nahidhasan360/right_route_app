import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/views/authentication/enter_email_screen/widgets/continue_widgets.dart';
import '../../enter_email_screen/widgets/email_input_field.dart';

class EmailEdit extends StatelessWidget {
  final controller = Get.put(EmailEditController());

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
            child: SafeArea(
              child: Column(
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
                        'Enter your email to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 21),
                      Text(
                        "Log in to your Route Pilot account. If you don't have one, you will be prompted to create one.",
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

                  // নতুন widget use করলাম
                  EmailInputField(
                    controller: controller.editEmailController,
                    hintText: "Email",
                    onChanged: (value) {
                      // optional: real-time validation
                    },
                  ),

                  SizedBox(height: 25),
                  ContinueWidgets(
                    text: 'CONTINUE',
                    width: double.infinity,
                    onPressed: () {
                      Get.toNamed(AppRoutes.loginAccount);
                      print('button clicked');
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

class EmailEditController extends GetxController {
  final editEmailController = TextEditingController();

  @override
  void onClose() {
    // Controller dispose করা important
    editEmailController.dispose();
    super.onClose();
  }
}
