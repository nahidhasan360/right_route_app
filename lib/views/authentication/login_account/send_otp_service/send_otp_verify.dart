import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/services/auth_service.dart';
import '../../../../core/constants/api_config/api_config.dart';

class TroubleLoginOtpVerifyService {

  // ═══════════════════════════════════════════════════════════
  // ✅ VERIFY OTP (Trouble Login)
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════');
    print('✅ TROUBLE LOGIN - VERIFYING OTP');
    print('═══════════════════════════════════════════════════');
    print('🔐 OTP: $otp');

    try {
      // Get email token from AuthService
      final emailToken = await AuthService.getEmailToken();

      if (emailToken == null || emailToken.isEmpty) {
        print('❌ Email token not found in AuthService');
        throw Exception('Email token not found. Please request OTP again.');
      }

      print('🎫 Email Token Retrieved: ${emailToken.substring(0, emailToken.length > 20 ? 20 : emailToken.length)}...');

      // ✅ Prepare headers with X-Email-Token
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Email-Token': emailToken, // ✅ Email token from AuthService
      };

      // Prepare body
      final body = jsonEncode({
        'otp': otp,
      });

      print('📍 Endpoint: ${ApiConfig.fullVerifyOtpUrl}');
      print('📋 Headers: ${headers.keys.join(", ")}');
      print('📋 Request Body: $body');

      // Make API call
      final response = await http.post(
        Uri.parse(ApiConfig.fullVerifyOtpUrl),
        headers: headers,
        body: body,
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');

      // Show response preview
      final responsePreview = response.body.length > 500
          ? '${response.body.substring(0, 500)}...'
          : response.body;
      print('📄 Response Body: $responsePreview');

      // Check if response is HTML
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print('❌ ERROR: Server returned HTML instead of JSON');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Endpoint used: ${ApiConfig.fullVerifyOtpUrl}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': 'Server error. Please check API endpoint. Status: ${response.statusCode}',
        };
      }

      // Try to parse JSON
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('❌ ERROR: Failed to parse JSON response');
        print('❌ Parse error: $e');
        print('❌ Response was: ${response.body}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ OTP verified successfully');
        print('✅ Response data keys: ${data.keys.join(", ")}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'data': data,
        };
      } else {
        final errorMessage = data['message'] ?? data['error'] ?? 'Failed to verify OTP';

        print('❌ Error Response: $errorMessage');
        print('❌ Status Code: ${response.statusCode}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      print('❌ Server returned invalid JSON format');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Server returned invalid data format',
      };
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      print('❌ Network or connection issue');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      print('❌ Unexpected Exception: $e');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
}