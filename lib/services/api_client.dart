import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central HTTP client for the HRMS backend API.
class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
  return 'http://10.0.2.2:3000';  // Android emulator
}
    return 'http://localhost:3000';
  }

  static const Duration _timeout = Duration(seconds: 15);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─────────────────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Try again.');
    }
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Try again.');
    }
  }

  static Future<Map<String, dynamic>> multipartPost(
    String path,
    Map<String, String> fields,
    String fileFieldName,
    File file,
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      
      // Add text fields
      request.fields.addAll(fields);
      
      // Add file
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        fileFieldName,
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      final responseStream = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(responseStream);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Try again.');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] as String? ?? 'Request failed',
      statusCode: response.statusCode,
    );
  }
}

/// Typed exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException [$statusCode]: $message'
      : 'ApiException: $message';
}
