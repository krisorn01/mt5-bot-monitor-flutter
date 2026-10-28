import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'models.dart';

const String kDefaultBaseUrl = 'http://127.0.0.1:5581';

String defaultBaseUrl() => kIsWeb ? Uri.base.origin : kDefaultBaseUrl;

/// Thin REST client for the Python bridge API. All endpoints are GET + JSON.
class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl(),
        _client = client ?? http.Client();

  String baseUrl;
  final http.Client _client;

  /// Overridable so tests can return fixed JSON.
  Future<dynamic> getJson(String path) async {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final res = await _client
        .get(Uri.parse('$base$path'))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<BotStatus> status() async =>
      BotStatus.fromJson(Map<String, dynamic>.from(await getJson('/api/status') as Map));

  Future<Summary> summary() async =>
      Summary.fromJson(Map<String, dynamic>.from(await getJson('/api/summary') as Map));

  Future<List<Trade>> trades({int limit = 30}) async =>
      ((await getJson('/api/trades?limit=$limit')) as List)
          .map((e) => Trade.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

  Future<List<SignalRow>> signals({int limit = 50}) async =>
      ((await getJson('/api/signals?limit=$limit')) as List)
          .map((e) => SignalRow.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

  Future<CircuitBreaker> circuitBreaker() async => CircuitBreaker.fromJson(
      Map<String, dynamic>.from(await getJson('/api/circuit-breaker') as Map));

  Future<LicenseInfo> license() async =>
      LicenseInfo.fromJson(Map<String, dynamic>.from(await getJson('/api/license') as Map));
}
