import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SavePlace {
  final String placename;
  final double latitude;
  final double longitude;
  int? id;

  SavePlace(
      {required this.placename,
      required this.latitude,
      required this.longitude,
      this.id});

  factory SavePlace.fromJson(Map<String, dynamic> json) {
    return SavePlace(
      placename: json['placename'],
      latitude: double.tryParse(json['latitude']) ?? 0.0,
      longitude:
          double.tryParse(json['longitude']) ?? 0.0, // json['longitude'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placename': placename,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'id': id,
    };
  }
}

class SavePlaceApi {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Replace with your Laravel app URL

  // Save a new place for a passenger
  static Future<SavePlace> savePlace(
      {required String passengerId, required SavePlace place}) async {
    final url = Uri.parse('$baseUrl/passengers/$passengerId/saveplaces');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(place.toJson()));

    if (response.statusCode == 201) {
      return SavePlace.fromJson(jsonDecode(response.body)['saveplace']);
    } else {
      throw Exception('Failed to save place: ${response.body}');
    }
  }

  // Update a saved place
  static Future<SavePlace> updatePlace({required SavePlace place}) async {
    final url = Uri.parse('$baseUrl/saveplaces/${place.id}');
    final response = await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'placename': place.placename,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'id': place.id,
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return SavePlace.fromJson(jsonDecode(response.body)['saveplace']);
    } else {
      throw Exception('Failed to update place: ${response.body}');
    }
  }

  // Delete a saved place
  static Future<bool> deletePlace(String saveplaceId) async {
    final url = Uri.parse('$baseUrl/saveplaces/$saveplaceId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete place: ${response.body}');
    }
    return true;
  }

  // Get all saved places for a passenger
  static Future<List<SavePlace>> getSavedPlaces(String passengerId) async {
    final url = Uri.parse('$baseUrl/passengers/$passengerId/saveplaces');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return (List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['saveplaces']))
          .map((placeJson) => SavePlace.fromJson(placeJson))
          .toList(); //  jsonDecode(response.body)['saveplaces'];
    } else {
      throw Exception('Failed to fetch saved places: ${response.body}');
    }
  }
}
