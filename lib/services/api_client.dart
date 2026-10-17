import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/app_user.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  String? _token;
  String? get token => _token;

  /// 1. Auth - Login
  Future<AppUser> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim(),
            'password': password.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    final body = _decode(response);
    final dynamic rawData = body['data'];

    // دعم استخراج الـ accessToken والأشكال المختلفة الممكنة للتوكن
    _token = (rawData is Map ? rawData['accessToken']?.toString() : null) ??
        body['accessToken']?.toString() ??
        body['token']?.toString() ??
        body['access_token']?.toString() ??
        body['jwt']?.toString() ??
        (rawData is Map ? rawData['token']?.toString() : null);

    if (_token == null || _token!.isEmpty) {
      throw ApiException('Login response did not contain a valid accessToken.');
    }

    final userData = body['user'] ??
        (rawData is Map ? rawData['user'] : null) ??
        rawData ??
        body;
    return AppUser.fromJson(Map<String, dynamic>.from(userData as Map));
  }

  /// 2. Auth - Send WhatsApp OTP
  Future<void> sendOtp({
    required String phone,
  }) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.apiBaseUrl}/kyc/phone/send-otp'),
          headers: _headers,
          body: jsonEncode({
            'phone': phone.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    print('SEND-OTP STATUS CODE: ${response.statusCode}');
    print('SEND-OTP RESPONSE BODY: ${response.body}');

    _decode(response);
  }

  /// 3. Auth - Verify WhatsApp Code (تم تعديل الـ Body ليرسل الـ code فقط حسب متطلبات السيرفر)
  Future<AppUser> verifyOtpAndRegister({
    required String phone,
    required String otp,
  }) async {
    final Map<String, dynamic> requestBody = {
      'code': otp.trim(),
    };

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiBaseUrl}/kyc/phone/verify'),
          headers: _headers,
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 15));

    print('VERIFY STATUS CODE: ${response.statusCode}');
    print('VERIFY RESPONSE BODY: ${response.body}');

    final body = _decode(response);
    final dynamic rawData = body['data'];

    // التحقق مرن واستخراج التوكن في حال توفره بالاستجابة
    final updatedToken =
        (rawData is Map ? rawData['accessToken']?.toString() : null) ??
            body['accessToken']?.toString() ??
            body['token']?.toString() ??
            body['access_token']?.toString();

    if (updatedToken != null && updatedToken.isNotEmpty) {
      _token = updatedToken;
    }

    final userData = body['user'] ??
        (rawData is Map ? rawData['user'] : null) ??
        rawData ??
        body;

    return AppUser.fromJson(Map<String, dynamic>.from(userData as Map));
  }

  /// 4. Dashboard
  Future<Map<String, dynamic>> dashboard() async {
    final response = await http
        .get(
          Uri.parse('${AppConfig.apiBaseUrl}/dashboard'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);
    if (decoded is Map) {
      final Map<String, dynamic> safeMap = {};
      decoded.forEach((key, value) {
        safeMap[key.toString()] = value;
      });
      return safeMap;
    } else if (decoded is List) {
      return {'data': decoded};
    }
    return {};
  }

  /// 5. Dynamic Resources List
  Future<List<Map<String, dynamic>>> list(String resource) async {
    final response = await http
        .get(
          Uri.parse('${AppConfig.apiBaseUrl}/$resource'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    final body = _decode(response);
    dynamic listData = body['data'] ?? body[resource] ?? body;

    if (listData is Map) {
      listData = listData.values.firstWhere((e) => e is List, orElse: () => []);
    }

    if (listData is List) {
      return listData
          .map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          })
          .where((map) => map.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// 6. Get Single Resource
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http
        .get(
          Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    final body = _decode(response);
    final dynamic data = body['data'] ?? body;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return body;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null && _token!.isNotEmpty)
          'Authorization': 'Bearer $_token',
      };

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        body = {'data': decoded};
      } else if (decoded is Map) {
        decoded.forEach((key, value) {
          body[key.toString()] = value;
        });
      }
    } catch (_) {
      throw ApiException(
        'The server returned an unreadable response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final rawMessage = body['message'] ?? body['error'] ?? 'Request failed';
      String errorMessage = 'Request failed';
      if (rawMessage is String) {
        errorMessage = rawMessage;
      } else if (rawMessage is Map) {
        errorMessage =
            rawMessage['message']?.toString() ?? rawMessage.toString();
      } else {
        errorMessage = rawMessage.toString();
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
    return body;
  }

  void logout() => _token = null;
}
