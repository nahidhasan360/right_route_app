import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../../core/constants/services/auth_service.dart';
import '../send_otp_service/Trouble_Login_Otp_send.dart';
import '../send_otp_service/send_otp_verify.dart';


class OtpVerificationController extends GetxController {
  // API Service
  final _apiService = TroubleLoginOtpVerifyService();

  final TextEditingController otpController = TextEditingController();
  final RxString otp = ''.obs;
  final RxBool isLoading = false.obs;

  String email = '';

  @override
  void onInit() {
    super.onInit();

    // Get email from arguments or AuthService
    email = Get.arguments ?? '';

    if (email.isEmpty) {
      email = AuthService.getUserEmail() ?? '';
    }

    print('');
    print('═══════════════════════════════════════════════════');
    print('🔵 OTP VERIFICATION CONTROLLER INITIALIZED');
    print('═══════════════════════════════════════════════════');
    print('📧 Email: $email');

    // ✅ Check if email token exists
    _checkEmailToken();

    print('═══════════════════════════════════════════════════');
    print('');
  }

  // ✅ Check if email token is available
  Future<void> _checkEmailToken() async {
    final emailToken = await AuthService.getEmailToken();

    if (emailToken != null && emailToken.isNotEmpty) {
      print('✅ Email Token Found: ${emailToken.substring(0, emailToken.length > 20 ? 20 : emailToken.length)}...');
    } else {
      print('⚠️ WARNING: Email Token NOT Found!');
      print('⚠️ This will cause verification to fail');
      print('⚠️ Make sure OTP was sent successfully first');
    }
  }

  void onOtpChanged(String value) {
    otp.value = value;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ VERIFY OTP
  // ═══════════════════════════════════════════════════════════
  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter 6-digit OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════');
      print('🔐 STARTING OTP VERIFICATION');
      print('═══════════════════════════════════════════════════');
      print('📧 Email: $email');
      print('🔢 OTP: ${otp.value}');

      // ✅ Double check email token before API call
      final emailToken = await AuthService.getEmailToken();
      if (emailToken == null || emailToken.isEmpty) {
        print('❌ Email Token Missing!');
        Get.snackbar(
          'Error',
          'Session expired. Please request OTP again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('✅ Email Token Available for API call');
      print('🌐 Calling Verify OTP API...');

      // Call API to verify OTP
      final result = await _apiService.verifyOtp(otp: otp.value);

      if (result['success'] == true) {
        final data = result['data'];

        print('✅ OTP VERIFIED SUCCESSFULLY!');
        print('💾 Saving user data...');

        // Save tokens
        if (data['access_token'] != null) {
          await AuthService.saveAccessToken(data['access_token']);
          print('✅ Access token saved');
        }

        if (data['refresh_token'] != null) {
          await AuthService.saveRefreshToken(data['refresh_token']);
          print('✅ Refresh token saved');
        }

        // Save user data if provided
        if (data['user'] != null) {
          final user = data['user'];
          if (user['email'] != null) {
            await AuthService.saveUserEmail(user['email']);
            print('✅ User email saved: ${user['email']}');
          }
          if (user['name'] != null) {
            await AuthService.saveUserName(user['name']);
            print('✅ User name saved: ${user['name']}');
          }
          if (user['id'] != null) {
            await AuthService.saveUserId(user['id'].toString());
            print('✅ User ID saved: ${user['id']}');
          }
        }

        // Set login status
        await AuthService.saveLoginStatus(true);
        print('✅ Login status set to true');

        // Clear email token after successful verification
        await AuthService.saveEmailToken('');
        print('✅ Email token cleared');

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Print user info for debugging
        await AuthService.printUserInfo();

        // Navigate to home or weLoggedYou screen
        await Future.delayed(const Duration(seconds: 1));

        print('🧭 Navigating to home screen...');
        Get.offAllNamed(AppRoutes.weLoggedYou); // or AppRoutes.homeNewRoutes

        print('═══════════════════════════════════════════════════');
        print('');

      } else {
        print('❌ OTP VERIFICATION FAILED');
        print('❌ Error: ${result['message']}');
        print('═══════════════════════════════════════════════════');
        print('');

        Get.snackbar(
          'Error',
          result['message'] ?? 'Invalid OTP. Please try again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ EXCEPTION IN VERIFY OTP: $e');
      print('═══════════════════════════════════════════════════');
      print('');

      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔄 RESEND OTP
  // ═══════════════════════════════════════════════════════════
  Future<void> resendOtp() async {
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════');
      print('🔄 RESENDING OTP');
      print('═══════════════════════════════════════════════════');
      print('📧 Email: $email');

      // Use TroubleLoginOtpService to resend
      final sendOtpService = TroubleLoginOtpService();
      final result = await sendOtpService.sendOtp(email: email, emailToken: '');

      if (result['success'] == true) {
        otpController.clear();
        otp.value = '';

        print('✅ OTP Resent Successfully');
        print('═══════════════════════════════════════════════════');
        print('');

        Get.snackbar(
          'Success',
          'OTP has been resent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('❌ Failed to Resend OTP: ${result['message']}');
        print('═══════════════════════════════════════════════════');
        print('');

        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to resend OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Exception in Resend OTP: $e');
      print('═══════════════════════════════════════════════════');
      print('');

      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Don't dispose controller here when using GetX
    super.onClose();
  }
}