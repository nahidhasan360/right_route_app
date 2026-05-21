import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../core/constants/services/auth_service.dart';
import 'register_api_service.dart';
import '../privacy_policy/privacy_policy.dart';
import '../terms_of_service/terms_of_service.dart';

class CreatePasswordController extends GetxController {
  final RegisterApiService _apiService = Get.put(RegisterApiService());

  final TextEditingController passwordController = TextEditingController();

  final RxString email = ''.obs;
  final RxString emailToken = ''.obs;

  final RxString password = ''.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isSixChars = false.obs;
  final RxBool hasNumberOrSpecial = false.obs;
  final RxBool useTouchId = true.obs;
  final RxBool agreeTerms = false.obs;
  final RxBool agreePrivacy = false.obs;

  final RxBool isLoading = false.obs;

  final RxString strengthLabel = "".obs;
  final RxDouble strengthProgress = 0.0.obs;
  final Rx<Color> strengthColor = AppColors.medGray.obs;

  bool get isFormValid =>
      isSixChars.value &&
          hasNumberOrSpecial.value &&
          agreeTerms.value &&
          agreePrivacy.value;

  @override
  void onInit() {
    super.onInit();

    // 🔥 Get from arguments
    final args = Get.arguments;
    if (args != null) {
      email.value = args['email'] ?? '';
      emailToken.value = args['token'] ?? '';

      print('📧 Email from arguments: ${email.value}');
      print('🎫 Token from arguments: ${emailToken.value}');
    }

    // 🔥 Fallback to AuthService
    if (email.value.isEmpty) {
      email.value = AuthService.getUserEmail() ?? '';
      print('📧 Email from AuthService: ${email.value}');
    }

    if (emailToken.value.isEmpty) {
      AuthService.getEmailToken().then((token) {
        if (token != null) {
          emailToken.value = token;
          print('🎫 Token from AuthService: $token');
        }
      });
    }

    password.listen((_) {
      validatePassword();
      updatePasswordStrength();
    });
  }

  void validatePassword() {
    isSixChars.value = password.value.length >= 6;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password.value);
    final hasNumberOrChar = RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]').hasMatch(password.value);
    hasNumberOrSpecial.value = hasLetter && hasNumberOrChar;
  }

  void updatePasswordStrength() {
    if (password.value.isEmpty) {
      strengthLabel.value = '';
      strengthProgress.value = 0.0;
      strengthColor.value = Color(0xFF4A4A4A);
      return;
    }

    int strength = 0;
    if (password.value.length >= 6) strength++;
    if (password.value.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password.value)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password.value)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password.value)) strength++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password.value)) strength++;

    if (strength <= 2) {
      strengthLabel.value = 'Weak';
      strengthProgress.value = 0.33;
      strengthColor.value = Color(0xFFE20202);
    } else if (strength <= 4) {
      strengthLabel.value = 'Fair';
      strengthProgress.value = 0.66;
      strengthColor.value = Color(0xFFFFC700);
    } else {
      strengthLabel.value = 'Strong';
      strengthProgress.value = 1.0;
      strengthColor.value = Color(0xFF19D503);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void editEmail() {
    Get.back();
  }

  void viewTermsOfUse() {
    Get.to(() => TermsModal());
  }

  void viewPrivacyPolicy() {
    Get.to(() => PrivacyPolicy());
  }

  Future<void> createAccount() async {
    print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃  CREATE ACCOUNT STARTED                        ┃');
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛');

    if (!isFormValid) {
      Get.snackbar('Error', 'Please complete all requirements',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (emailToken.value.isEmpty) {
      Get.snackbar('Error', 'Email token missing. Please verify email again.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      print('\n🌐 Calling Register API...');
      print('📧 Email: ${email.value}');
      print('🎫 Token: ${emailToken.value}');
      print('🔐 Password: ${password.value}');

      // 🔥 API Call - Token goes in Header
      final result = await _apiService.register(
        emailToken: emailToken.value,
        password: password.value,
        isTouchIdEnabled: useTouchId.value,
        termsAgreed: agreeTerms.value && agreePrivacy.value,
      );

      if (result['success'] == true) {
        final data = result['data'];

        print('\n💾 Saving user data...');

        // Save user info
        await AuthService.saveUserEmail(email.value);
        await AuthService.saveUserId(data['user_id']?.toString() ?? '');
        await AuthService.saveLoginStatus(true);

        print('✅ Registration successful!');
        await AuthService.printUserInfo();

        Get.snackbar('Success', 'Account created successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.toNamed(AppRoutes.individualTeam);

      } else {
        Get.snackbar('Error', result['message'] ?? 'Registration failed',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
      print('┃  CREATE ACCOUNT COMPLETED                      ┃');
      print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n');
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
