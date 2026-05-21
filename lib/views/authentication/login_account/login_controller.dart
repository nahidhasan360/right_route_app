import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../core/constants/services/auth_service.dart';
import 'otp_verification/otp_verification_controller.dart';
import 'login_api_service/login_api_service.dart';

/// ═══════════════════════════════════════════════════════════
/// LoginController - GetX State Management
/// ═══════════════════════════════════════════════════════════
class LoginController extends GetxController {
  final LoginApiService _apiService = LoginApiService();

  // ═══════════════════════════════════════════════════════════
  // OBSERVABLES
  // ═══════════════════════════════════════════════════════════
  final userEmail = ''.obs;
  final emailToken = ''.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;
  final isSendingOtp = false.obs;
  final isTouchIDEnabled = false.obs;

  // Biometric
  final canCheckBiometrics = false.obs;
  final isBiometricSupported = false.obs;
  final availableBiometrics = <BiometricType>[].obs;
  final LocalAuthentication auth = LocalAuthentication();

  // Text Controller
  final passwordController = TextEditingController();

  // ═══════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    initializeBiometrics();
  }

  Future<void> _loadUserData() async {
    // Get email and token from arguments
    final args = Get.arguments;
    if (args != null) {
      userEmail.value = args['email'] ?? '';
      emailToken.value = args['token'] ?? '';
    }

    // Fallback to AuthService
    if (userEmail.value.isEmpty) {
      final savedEmail = AuthService.getUserEmail();
      if (savedEmail != null) userEmail.value = savedEmail;
    }

    if (emailToken.value.isEmpty) {
      final savedToken = await AuthService.getEmailToken();
      if (savedToken != null) emailToken.value = savedToken;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EMAIL MANAGEMENT
  // ═══════════════════════════════════════════════════════════
  void setEmail(String email) {
    userEmail.value = email.trim();
    update();
  }

  void clearEmail() {
    userEmail.value = '';
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD VISIBILITY
  // ═══════════════════════════════════════════════════════════
  void togglePassword() {
    hidePassword.value = !hidePassword.value;
  }

  // ═══════════════════════════════════════════════════════════
  // TOUCH ID TOGGLE
  // ═══════════════════════════════════════════════════════════
  void toggleTouchID(bool value) {
    isTouchIDEnabled.value = value;
    print('✅ Touch ID enabled: $value');
  }

  // ═══════════════════════════════════════════════════════════
  // 📤 SEND OTP & NAVIGATE
  // ═══════════════════════════════════════════════════════════
  Future<void> sendOtpAndNavigate() async {
    print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃  TROUBLE LOGIN - SEND OTP STARTED              ┃');
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛');

    if (userEmail.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSendingOtp.value = true;

    try {
      final result = await _apiService.sendOtp(email: userEmail.value);

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'OTP sent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to OTP screen
        Get.toNamed(
          AppRoutes.otpVerificationScreen,
          arguments: userEmail.value,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to send OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingOtp.value = false;
      print('┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
      print('┃  TROUBLE LOGIN - SEND OTP COMPLETED            ┃');
      print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 LOGIN
  // ═══════════════════════════════════════════════════════════
  Future<void> login() async {
    print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
    print('┃  LOGIN STARTED                                 ┃');
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛');

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (emailToken.value.isEmpty) {
      emailToken.value = await AuthService.getEmailToken() ?? '';
    }

    if (emailToken.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email token missing. Please verify email again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _apiService.login(
        emailToken: emailToken.value,
        password: passwordController.text.trim(),
      );

      if (result['success'] == true) {
        final data = result['data'];

        // Save complete user info using AuthService
        await AuthService.saveUserInfo(
          email: data['mail'] ?? userEmail.value,
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          name: data['name'],
          id: data['id']?.toString(),
          phone: data['phone'],
        );

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (data['is_first_login'] == true) {
          print('🆕 First login - Navigate to onboarding');
        }

        print('🧭 Navigating to Home...');
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Login failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓');
      print('┃  LOGIN COMPLETED                               ┃');
      print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BIOMETRIC AUTHENTICATION
  // ═══════════════════════════════════════════════════════════
  Future<void> initializeBiometrics() async {
    await checkBiometricSupport();
    await checkAvailableBiometrics();
  }

  Future<void> checkBiometricSupport() async {
    try {
      canCheckBiometrics.value = await auth.canCheckBiometrics;
      isBiometricSupported.value = await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics.value = false;
      isBiometricSupported.value = false;
    }
  }

  Future<void> checkAvailableBiometrics() async {
    try {
      List<BiometricType> biometrics = await auth.getAvailableBiometrics();
      availableBiometrics.value = biometrics;
    } catch (e) {
      availableBiometrics.value = [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!canCheckBiometrics.value) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (availableBiometrics.isEmpty) {
        Get.snackbar(
          'Setup Required',
          'Please add fingerprint or face ID in your device settings first',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login to Right Routes',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      if (didAuthenticate) {
        Get.snackbar(
          'Success!',
          'Fingerprint authentication successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 800));
        await login();
        return true;
      } else {
        Get.snackbar(
          'Authentication Failed',
          'Fingerprint not recognized. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during authentication',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
