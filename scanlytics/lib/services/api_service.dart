import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://scanlytic-ai-health-app.onrender.com';

  // Override with --dart-define=API_BASE_URL=http://<host>:5000 when needed.
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _configuredApiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );
  static const String _configuredApiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '5000',
  );

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_configuredBaseUrl);
    }
    if (apiUrl.isNotEmpty) {
      return _normalizeBaseUrl(apiUrl);
    }
    if (_configuredApiHost.isNotEmpty) {
      return 'http://${_configuredApiHost.trim()}:${_configuredApiPort.trim()}';
    }
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps host machine localhost to 10.0.2.2.
      return 'http://10.0.2.2:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:5000';
    }
    return 'http://localhost:5000';
  }

  static Uri _endpoint(String path) => Uri.parse(baseUrl).resolve(path);
  static Uri get predictUrl => _endpoint('predict');

  static Future<Map<String, dynamic>> predictRisk(
    String patientId,
    String patientName,
    List<double> features,
  ) async {
    try {
      final url = predictUrl;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': patientId,
          'patient_name': patientName,
          'features': features,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final lowerBody = response.body.toLowerCase();
        final contractHint = lowerBody.contains('missing required input fields')
            ? ' The app reached a different backend contract. Verify --dart-define=API_HOST points to this laptop running backend/app.py.'
            : '';
        final errorMsg =
            'Server error (${response.statusCode}): ${response.body}$contractHint';
        print('\n[API ERROR] $errorMsg\n');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('\n[API EXCEPTION] $e\n');
      throw Exception(
        'Connection error: $e. Set --dart-define=API_HOST=<your-laptop-ip> or --dart-define=API_BASE_URL=http://<your-laptop-ip>:5000',
      );
    }
  }

  static Future<List<dynamic>> getDoctorDashboard() async {
    try {
      final url = _endpoint('doctor/dashboard');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['patients'] as List<dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('\n[API EXCEPTION] $e\n');
      throw Exception(
        'Connection error: $e. Set --dart-define=API_HOST=<your-laptop-ip> or --dart-define=API_BASE_URL=http://<your-laptop-ip>:5000',
      );
    }
  }

  static Future<bool> deleteAllPatients() async {
    try {
      final url = _endpoint('doctor/dashboard/all');
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Delete all error: $e');
      return false;
    }
  }

  static Future<bool> deletePatient(String patientId) async {
    try {
      final url = _endpoint('doctor/dashboard/$patientId');
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }
}
