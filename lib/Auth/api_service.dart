import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ride_app/compont/placeSearchWidget.dart';
import 'package:ride_app/driver.dart';
import 'package:ride_app/passenger.dart';
import 'package:ride_app/request_ride.dart';

class ApiService {
  final String passengerBaseUrl = 'http://127.0.0.1:8000/api/passenger';
  final String driverBaseUrl = 'http://127.0.0.1:8000/api/driver';
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  Future<List<Passenger>> getPassengers() async {
    try {
      final response =
          await http.get(Uri.parse(passengerBaseUrl), headers: _headers);
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
        Uri.parse('$passengerBaseUrl/$id'),
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
        Uri.parse(passengerBaseUrl),
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

  Future<Passenger> updatePassenger(Passenger passenger) async {
    try {
      final response = await http.put(
        Uri.parse('$passengerBaseUrl/${passenger.id}'),
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
        Uri.parse('$passengerBaseUrl/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete passenger');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Driver>> sendRequestToDriver(
      RequestRide trip, String passengerID) async {
    try {
      final response = await http.get(Uri.parse("$driverBaseUrl/get_driver"),
          headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final drivers = (data['driver'] as List)
            .map((driverJson) => Driver.fromJson(driverJson))
            .toList();
        return drivers;
      } else {
        throw Exception('Failed to fetch passengers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Driver>> getDriverAround(Place currentLocation) async {
    try {
      final response = await http.post(
        Uri.parse('$driverBaseUrl/get_driver'),
        headers: _headers,
        body: json.encode(currentLocation.toJSON()),
      );

      // debugPrint('Response status: ${response.statusCode}');
      // debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final drivers = (data['drivers'] as List?)
                  ?.map((driverJson) => Driver.fromJson(driverJson))
                  .toList() ??
              [];

          return drivers;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch drivers');
        }
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getDriverAround: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Driver?> getDriverById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$driverBaseUrl/get_driver/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final driverJson = json.decode(response.body)['driver'];
        return Driver.fromJson(driverJson);
      } else {
        throw Exception('Failed to get driver');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Place?> getDriverCoordinates(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$driverBaseUrl/get_driver_coordinates/$id'),
        headers: _headers,
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body getDriverCoordinates: ${response.body}');
      if (response.statusCode == 200) {
        final driverJson = json.decode(response.body)['coordinates'];
        return Place(
            displayName: driverJson['displayName'],
            latitude: double.parse(driverJson['latitude']),
            longitude: double.parse(driverJson['longitude']));
      } else {
        throw Exception('Failed to get driver');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
