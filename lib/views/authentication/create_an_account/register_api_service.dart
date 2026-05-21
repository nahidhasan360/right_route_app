import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_config/api_config.dart';

class RegisterApiService {
  Future<Map<String, dynamic>> register({
    required String emailToken,
    required String password,
    bool isTouchIdEnabled = false,
    bool termsAgreed = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullRegisterUrl);

      print('═══════════════════════════════════════════════════');
      print('🚀 REGISTER API CALL STARTED');
      print('📍 URL: $url');
      print('═══════════════════════════════════════════════════');

      // 🔥 Request Body (NO email, NO email_token here)
      final requestBody = {
        'password': password,
        'is_touch_id_enabled': isTouchIdEnabled,
        'terms_agreed': termsAgreed,
      };

      print('📦 Request Body:');
      print('   Password: $password');
      print('   Touch ID Enabled: $isTouchIdEnabled');
      print('   Terms Agreed: $termsAgreed');
      print('');
      print('📋 Headers:');
      print('   X-Email-Token: $emailToken');
      print('═══════════════════════════════════════════════════');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Email-Token': emailToken, // 🔥 Token in Header
        },
        body: jsonEncode(requestBody),
      );

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ REGISTER API RESPONSE RECEIVED');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════');
      print('');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        print('🎉 REGISTER SUCCESS:');
        print('   Message: ${data['message']}');
        print('   User ID: ${data['user_id']}');
        print('═══════════════════════════════════════════════════');

        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ REGISTER ERROR');
        print('   Status: ${response.statusCode}');
        print('   Response: ${response.body}');

        return {
          'success': false,
          'message': 'Registration failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔴 EXCEPTION: $e');

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}