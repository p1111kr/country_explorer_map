import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  static const String _baseUrl = 'restcountries.com';
  static const Duration _timeout = Duration(seconds: 10);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Throws [ApiException] for any non-200 status code.
  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        message: _parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['message'] as String?) ??
          'Unexpected error (${response.statusCode})';
    } catch (_) {
      return 'Request failed with status ${response.statusCode}';
    }
  }

  // Fetch all countries  returns name, flags, region, population.
  Future<List<Country>> fetchAllCountries() async {
    final uri = Uri.https(
      _baseUrl,
      '/v3.1/all',
      {'fields': 'name,flags,flag,region,population,cca3'},
    );

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
          message: 'No internet connection', statusCode: 0);
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out', statusCode: 408);
    } on FormatException {
      throw const ApiException(
          message: 'Received malformed data from the server', statusCode: 422);
    } catch (e) {
      throw ApiException(
          message: 'Something went wrong: ${e.toString()}', statusCode: 500);
    }
  }

  // Search countries by name.
  Future<List<Country>> searchByName(String name) async {
    if (name.trim().isEmpty) return [];

    final uri =
        Uri.https(_baseUrl, '/v3.1/name/${Uri.encodeComponent(name.trim())}');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      // 404 means no results — return empty list instead of throwing
      if (response.statusCode == 404) return [];

      _checkResponse(response);

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
          message: 'No internet connection', statusCode: 0);
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out', statusCode: 408);
    } on FormatException {
      throw const ApiException(
          message: 'Received malformed data from the server', statusCode: 422);
    } catch (e) {
      throw ApiException(
          message: 'Something went wrong: ${e.toString()}', statusCode: 500);
    }
  }

  // Fetch a single country by ISO alpha-3 code.
  Future<Country> fetchByCode(String code) async {
    final uri = Uri.https(_baseUrl, '/v3.1/alpha/${Uri.encodeComponent(code)}');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      _checkResponse(response);

      // The endpoint returns a list even for a single country
      final dynamic body = jsonDecode(response.body);
      if (body is List && body.isNotEmpty) {
        return Country.fromJson(body.first as Map<String, dynamic>);
      } else if (body is Map<String, dynamic>) {
        return Country.fromJson(body);
      }

      throw const ApiException(
          message: 'Country data was empty or unreadable', statusCode: 204);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
          message: 'No internet connection', statusCode: 0);
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out', statusCode: 408);
    } on FormatException {
      throw const ApiException(
          message: 'Received malformed data from the server', statusCode: 422);
    } catch (e) {
      throw ApiException(
          message: 'Something went wrong: ${e.toString()}', statusCode: 500);
    }
  }
}
