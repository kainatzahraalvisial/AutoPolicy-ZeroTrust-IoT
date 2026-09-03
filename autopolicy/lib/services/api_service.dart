import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService({this.baseUrl = 'https://api.autopolicy.cyber-defense.local/v1'});

  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _headers.remove('Authorization');
  }

  // Simulated REST request wrapper with mock latency
  Future<Map<String, dynamic>> get(String path) async {
    if (kDebugMode) {
      print('[REST-GET] $baseUrl$path');
    }
    await Future.delayed(const Duration(milliseconds: 640)); // Realistic network latency
    return {'status': 'success', 'code': 200};
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    if (kDebugMode) {
      print('[REST-POST] $baseUrl$path with payload: ${jsonEncode(body)}');
    }
    await Future.delayed(const Duration(milliseconds: 800));
    return {'status': 'success', 'code': 201, 'data': body};
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    if (kDebugMode) {
      print('[REST-PUT] $baseUrl$path with payload: ${jsonEncode(body)}');
    }
    await Future.delayed(const Duration(milliseconds: 700));
    return {'status': 'success', 'code': 200, 'data': body};
  }

  Future<Map<String, dynamic>> delete(String path) async {
    if (kDebugMode) {
      print('[REST-DELETE] $baseUrl$path');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return {'status': 'success', 'code': 200};
  }
}
