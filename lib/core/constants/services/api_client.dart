import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'auth_service.dart';
import '../api_config/api_config.dart';
import '../../../core/routes/all_routes.dart';

/// ═══════════════════════════════════════════════════════════
/// Central API Client with Token Interception & Refresh Logic
/// ═══════════════════════════════════════════════════════════
class ApiClient {
  static final http.Client _client = http.Client();
  static bool _isRefreshing = false;

  /// Private helper to get the authorization headers
  static Future<Map<String, String>> _getAuthHeaders({
    Map<String, String>? customHeaders,
    bool requireAuth = true,
  }) async {
    final headers = customHeaders ?? {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// ═══════════════════════════════════════════════════════════
  /// POST Request
  /// ═══════════════════════════════════════════════════════════
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(customHeaders: headers, requireAuth: requireAuth);
    
    var response = await _client.post(
      url,
      headers: authHeaders,
      body: body,
      encoding: encoding,
    );

    if (requireAuth && response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request with new token
        final newAuthHeaders = await _getAuthHeaders(customHeaders: headers, requireAuth: requireAuth);
        response = await _client.post(
          url,
          headers: newAuthHeaders,
          body: body,
          encoding: encoding,
        );
      }
    }

    return response;
  }

  /// ═══════════════════════════════════════════════════════════
  /// GET Request
  /// ═══════════════════════════════════════════════════════════
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(customHeaders: headers, requireAuth: requireAuth);

    var response = await _client.get(
      url,
      headers: authHeaders,
    );

    if (requireAuth && response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request with new token
        final newAuthHeaders = await _getAuthHeaders(customHeaders: headers, requireAuth: requireAuth);
        response = await _client.get(
          url,
          headers: newAuthHeaders,
        );
      }
    }

    return response;
  }

  /// ═══════════════════════════════════════════════════════════
  /// MULTIPART Request (for file uploads)
  /// ═══════════════════════════════════════════════════════════
  static Future<http.StreamedResponse> sendMultipartRequest(
      http.MultipartRequest request, {bool requireAuth = true}) async {
    if (requireAuth) {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // We can't simply retry a MultipartRequest if it fails because streams are single-use.
    // However, for this architecture, we will attempt the request once. 
    // Ideally, multipart requests should pre-validate tokens.
    var response = await _client.send(request);

    // Note: To fully retry multipart requests, you would need to recreate the request object.
    return response;
  }

  /// ═══════════════════════════════════════════════════════════
  /// Token Refresh Logic
  /// ═══════════════════════════════════════════════════════════
  static Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    try {
      _isRefreshing = true;
      print('🔄 Attempting to refresh token...');

      final refreshToken = await AuthService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token found. Logging out.');
        _forceLogout();
        return false;
      }

      // Prepare request (Form-data format as per Postman screenshot)
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.fullRefreshTokenUrl));
      request.fields.addAll({
        'refresh': refreshToken,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        
        if (data['success'] == true && data['data'] != null) {
          final tokenData = data['data'];
          
          if (tokenData['access'] != null) {
            await AuthService.saveAccessToken(tokenData['access']);
            print('✅ Access token successfully refreshed');
          }
          if (tokenData['refresh'] != null) {
            await AuthService.saveRefreshToken(tokenData['refresh']);
          }
          
          return true;
        }
      }

      print('❌ Failed to refresh token. Status: ${response.statusCode}');
      _forceLogout();
      return false;

    } catch (e) {
      print('❌ Exception during token refresh: $e');
      _forceLogout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static void _forceLogout() {
    AuthService.logout();
    Get.offAllNamed(AppRoutes.splashScreen); // Redirect to login/splash
    Get.snackbar(
      'Session Expired',
      'Please log in again to continue.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
