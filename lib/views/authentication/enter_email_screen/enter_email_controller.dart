import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../core/constants/services/auth_service.dart';
import 'check_email_api_service.dart';

class EnterEmailController extends GetxController {
  final CheckEmailApiService _apiService = Get.put(CheckEmailApiService());

  var email = "".obs;
  final emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  final RxString message = ''.obs;
  final RxString action = ''.obs;
  final RxBool exists = false.obs;
  final RxString emailToken = ''.obs;
  final RxString userEmail = ''.obs;

  Future<void> checkEmail() async {
    print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃  CHECK EMAIL FUNCTION STARTED                  ┃');
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛');

    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter email address',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final result = await _apiService.checkEmail(emailController.text.trim());

      if (result['success'] == true) {
        final data = result['data'];

        message.value = data['message'] ?? '';
        action.value = data['action'] ?? '';
        exists.value = data['exists'] ?? false;
        emailToken.value = data['email_token'] ?? '';
        userEmail.value = data['EMAIL'] ?? '';

        print('\n💾 Data Stored in Controller:');
        print('   Email: ${userEmail.value}');
        print('   Token: ${emailToken.value}');

        // 🔥 Save to AuthService
        if (emailToken.value.isNotEmpty) {
          await AuthService.saveEmailToken(emailToken.value);
          print('✅ Email Token saved to AuthService');
        }

        if (userEmail.value.isNotEmpty) {
          await AuthService.saveUserEmail(userEmail.value);
          print('✅ Email saved to AuthService');
        }

        if (action.value == 'LOGIN') {
          Get.snackbar('Success', message.value,
              backgroundColor: Colors.green, colorText: Colors.white);

          Get.toNamed(AppRoutes.loginAccount, arguments: {
            'email': userEmail.value,
            'token': emailToken.value,
          });
        } else if (action.value == 'REGISTER') {
          Get.snackbar('Info', 'User not found. Please register.',
              backgroundColor: Colors.orange, colorText: Colors.white);

          // 🔥 Pass email and token to Create Account
          Get.toNamed(AppRoutes.createAccountScreen, arguments: {
            'email': userEmail.value,
            'token': emailToken.value,
          });
        }
      } else {
        Get.snackbar('Error', result['message'] ?? 'Something went wrong',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
      print('┃  CHECK EMAIL COMPLETED                         ┃');
      print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}