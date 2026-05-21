import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/services/auth_service.dart';
import '../../../../core/constants/api_config/api_config.dart';

/// ═══════════════════════════════════════════════════════════
/// LoginApiService - All Login Related API Calls
/// ═══════════════════════════════════════════════════════════
class LoginApiService {
  // ═══════════════════════════════════════════════════════════
  // 🔐 LOGIN API - FIXED TYPE SAFETY
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> login({
    required String emailToken,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullLoginUrl);

      print('');
      print('═══════════════════════════════════════════════════');
      print('🚀 LOGIN API CALL STARTED');
      print('📍 URL: $url');
      print('═══════════════════════════════════════════════════');

      final requestBody = {'password': password};

      print('📦 Request Body:');
      print('   Password: $password');
      print('');
      print('📋 Headers:');
      print('   X-Email-Token: ${emailToken.substring(0, emailToken.length > 20 ? 20 : emailToken.length)}...');
      print('═══════════════════════════════════════════════════');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Email-Token': emailToken,
        },
        body: jsonEncode(requestBody),
      );

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ LOGIN API RESPONSE RECEIVED');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════');
      print('');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // ✅ Extract data with proper type conversion
        final data = responseData is Map ? responseData : {};

        print('🎉 LOGIN SUCCESS:');
        print('   Access Token: ${data['access_token'] != null ? "Present" : "Missing"}');
        print('   Refresh Token: ${data['refresh_token'] != null ? "Present" : "Missing"}');
        print('   Email: ${data['mail'] ?? data['email'] ?? "N/A"}');
        print('   First Login: ${data['is_first_login'] ?? data['isFirstLogin'] ?? "N/A"}');
        print('═══════════════════════════════════════════════════');

        // ✅ Return with safe type conversion
        return {
          'success': true,
          'data': {
            'access_token': data['access_token']?.toString() ?? data['accessToken']?.toString() ?? data['token']?.toString() ?? '',
            'refresh_token': data['refresh_token']?.toString() ?? data['refreshToken']?.toString() ?? '',
            'mail': data['mail']?.toString() ?? data['email']?.toString() ?? '',
            'name': data['name']?.toString() ?? '',
            'id': data['id']?.toString() ?? '',
            'phone': data['phone']?.toString() ?? '',
            'is_first_login': data['is_first_login'] ?? data['isFirstLogin'] ?? false,
          },
          'message': data['message']?.toString() ?? 'Login successful',
        };
      } else {
        print('❌ LOGIN ERROR');
        print('   Status: ${response.statusCode}');
        print('   Response: ${response.body}');

        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? 'Login failed';

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔴 EXCEPTION in login: $e');
      print('🔴 Stack trace: ${StackTrace.current}');

      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📤 SEND OTP (Trouble Login) - FIXED TYPE SAFETY
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullRequestOtpUrl);

      print('');
      print('═══════════════════════════════════════════════════');
      print('📤 TROUBLE LOGIN - SENDING OTP');
      print('═══════════════════════════════════════════════════');
      print('📧 Email: $email');
      print('📍 Endpoint: $url');

      // Prepare request body
      final requestBody = jsonEncode({'email': email});
      print('📋 Request Body: $requestBody');

      // Get email token if exists (optional for this endpoint)
      final emailToken = await AuthService.getEmailToken();

      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add email token if available
      if (emailToken != null && emailToken.isNotEmpty) {
        headers['X-Email-Token'] = emailToken;
        print('🔑 Email Token: Present');
      }

      print('📋 Headers: ${headers.keys.join(', ')}');

      // Make API call
      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );

      print('');
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // ✅ Safe type handling
        final data = responseData is Map ? responseData : {};

        // Save email token from response with type safety
        final newEmailToken = data['email_token']?.toString() ??
            data['emailToken']?.toString() ??
            data['token']?.toString();

        if (newEmailToken != null && newEmailToken.isNotEmpty) {
          await AuthService.saveEmailToken(newEmailToken);
          print('✅ Email token saved: $newEmailToken');
        }

        // Save email
        await AuthService.saveUserEmail(email);
        print('✅ Email saved: $email');

        print('✅ OTP sent successfully');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': true,
          'message': data['message']?.toString() ?? 'OTP sent successfully',
          'email_token': newEmailToken ?? '',
        };
      } else {
        // Handle error response
        String errorMessage = 'Failed to send OTP';

        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        } catch (e) {
          print('❌ ERROR: Failed to parse JSON response');
          print('❌ Parse error: $e');
          print('❌ Response was: ${response.body}');
          errorMessage = 'Server error. Please try again.';
        }

        print('❌ Error: $errorMessage');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Exception in sendOtp: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ VERIFY OTP (Trouble Login) - FIXED TYPE SAFETY
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullVerifyOtpUrl);

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ TROUBLE LOGIN - VERIFYING OTP');
      print('═══════════════════════════════════════════════════');
      print('🔐 OTP: $otp');

      // Get email token from AuthService
      final emailToken = await AuthService.getEmailToken();
      if (emailToken == null || emailToken.isEmpty) {
        print('❌ Email token not found!');
        return {
          'success': false,
          'message': 'Email token not found. Please request OTP again.',
        };
      }

      print('🎫 Email Token: ${emailToken.substring(0, emailToken.length > 20 ? 20 : emailToken.length)}...');
      print('📍 Endpoint: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Email-Token': emailToken,
        },
        body: jsonEncode({'otp': otp}),
      );

      print('📋 Request Body: {"otp": "$otp"}');
      print('');
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // ✅ Safe type handling
        final data = responseData is Map ? responseData : {};
        final userData = data['user'] is Map ? data['user'] as Map : {};

        print('✅ OTP verified successfully');
        print('═══════════════════════════════════════════════════');
        print('');

        // ✅ Return with safe type conversion
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'OTP verified successfully',
          'data': {
            'access_token': data['access_token']?.toString() ?? '',
            'refresh_token': data['refresh_token']?.toString() ?? '',
            'user': {
              'email': userData['email']?.toString() ?? '',
              'name': userData['name']?.toString() ?? '',
              'id': userData['id']?.toString() ?? '',
              'phone': userData['phone']?.toString() ?? '',
            },
          },
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? 'Failed to verify OTP';

        print('❌ Error: $errorMessage');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Exception in verifyOtp: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}