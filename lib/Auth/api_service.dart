import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ride_app/passenger.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api/passenger';
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  Future<List<Passenger>> getPassengers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final passengers = (data['passengers'] as List)
            .map((passengerJson) => Passenger.fromJson(passengerJson))
            .toList();
        return passengers;
      } else {
        throw Exception('Failed to fetch passengers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Passenger?> getPassenger(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final passengerJson = json.decode(response.body)['passenger'];
        return Passenger.fromJson(passengerJson);
      }
      return null;
      // throw Exception('Failed to get passenger');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Passenger> createPassenger(Passenger passenger) async {
    try {
      debugPrint('Sending passenger data: ${json.encode(passenger.toJson())}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(passenger.toJson()),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['passenger'] != null) {
          return Passenger.fromJson(responseData['passenger']);
        } else {
          throw Exception('Invalid response format: passenger data is null');
        }
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Failed to create passenger: $errorMessage');
      }
    } catch (e) {
      debugPrint('Error creating passenger: $e');
      throw Exception('Error creating passenger: $e');
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error';
    } catch (e) {
      return 'Status code: ${response.statusCode}, Body: ${response.body}';
    }
  }

  Future<Passenger> updatePassenger(String id, Passenger passenger) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: json.encode(passenger.toJson()),
      );
      if (response.statusCode == 200) {
        final passengerJson = json.decode(response.body)['passenger'];
        return Passenger.fromJson(passengerJson);
      } else {
        throw Exception('Failed to update passenger');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deletePassenger(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete passenger');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
