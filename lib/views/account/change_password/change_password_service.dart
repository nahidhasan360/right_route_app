import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/services/auth_service.dart';
import '../../../core/constants/api_config/api_config.dart';

class ChangePasswordService {
  // 🔥 Base URL
  // static const String baseUrl = 'http://10.10.7.19:8000';

  // 🔥 Change Password API Call
  static Future<Map<String, dynamic>> changePassword(String newPassword) async {
    try {
      // 🔑 AuthService থেকে Access Token নিচ্ছি
      String? token = await AuthService.getAccessToken();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 API REQUEST - CHANGE PASSWORD');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 URL: ${ApiConfig.fullChangePasswordUrl}');
      print('🔐 New Password: ${newPassword.replaceAll(RegExp(r'.'), '*')}'); // Hidden
      print('🔑 Token: ${token ?? "❌ No token found"}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final response = await http.post(
        Uri.parse(ApiConfig.fullChangePasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'new_password': newPassword,
        }),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 API RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success Response
        final data = jsonDecode(response.body);

        print('✅ SUCCESS: Password changed successfully!\n');

        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
          'data': data,
        };
      } else {
        // ❌ Error Response from Server
        final error = jsonDecode(response.body);

        print('❌ ERROR: $error\n');

        return {
          'success': false,
          'message': error['message'] ?? error['new_password']?.first ?? 'Failed to change password',
        };
      }
    } catch (e) {
      // ❌ Network Error or Exception
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ EXCEPTION OCCURRED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}