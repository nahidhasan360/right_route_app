import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_config/api_config.dart';

class CheckEmailApiService {
  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final url = Uri.parse(ApiConfig.fullCheckEmailUrl);

      // 🔵 API Request Debug
      print('═══════════════════════════════════════════════════');
      print('🚀 API CALL STARTED');
      print('📍 URL: $url');
      print('📧 Email: $email');
      print('═══════════════════════════════════════════════════');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      // 🟢 API Response Debug
      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ API RESPONSE RECEIVED');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════');
      print('');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Success Response Debug
        print('🎉 SUCCESS - Data Parsed:');
        print('   Message: ${data['message']}');
        print('   Action: ${data['action']}');
        print('   Exists: ${data['exists']}');
        print('   Email: ${data['EMAIL']}');
        print('   Token: ${data['email_token']}');
        print('═══════════════════════════════════════════════════');

        return {
          'success': true,
          'data': data,
        };
      } else {
        // ❌ Error Response Debug
        print('');
        print('═══════════════════════════════════════════════════');
        print('❌ API ERROR');
        print('📊 Status Code: ${response.statusCode}');
        print('📦 Response: ${response.body}');
        print('═══════════════════════════════════════════════════');

        return {
          'success': false,
          'message': 'Failed to check email',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      // 🔴 Exception Debug
      print('');
      print('═══════════════════════════════════════════════════');
      print('🔴 EXCEPTION CAUGHT');
      print('❌ Error: $e');
      print('═══════════════════════════════════════════════════');

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}