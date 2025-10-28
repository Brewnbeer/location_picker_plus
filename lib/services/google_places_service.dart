import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_result.dart';

class GooglePlacesService {
  static GooglePlacesService? _instance;
  static GooglePlacesService get instance => _instance ??= GooglePlacesService._internal();

  GooglePlacesService._internal();

  String? _apiKey;

  /// Initialize the service with your Google Places API key
  void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Search for places using autocomplete
  Future<List<PlacePrediction>> getAutocompletePredictions({
    required String query,
    String? sessionToken,
    String? country, // ISO 3166-1 alpha-2 country code(s) - single code or pipe-separated for multiple
    List<String> types = const [], // establishment, address, geocode, etc.
  }) async {
    if (!isInitialized) {
      throw Exception('Google Places API key not initialized. Call initialize() first.');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$_baseUrl/autocomplete/json').replace(queryParameters: {
        'input': query,
        'key': _apiKey!,
        if (sessionToken != null) 'sessiontoken': sessionToken,
        if (country != null) 'components': 'country:$country',
        if (types.isNotEmpty) 'types': types.join('|'),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>;
          return predictions
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();
        } else {
          throw Exception('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get autocomplete predictions: $e');
    }
  }

  /// Get place details by place ID
  Future<LocationResult?> getPlaceDetails({
    required String placeId,
    String? sessionToken,
    List<String> fields = const [
      'place_id',
      'formatted_address',
      'geometry/location',
      'address_components'
    ],
  }) async {
    if (!isInitialized) {
      throw Exception('Google Places API key not initialized. Call initialize() first.');
    }

    try {
      final uri = Uri.parse('$_baseUrl/details/json').replace(queryParameters: {
        'place_id': placeId,
        'fields': fields.join(','),
        'key': _apiKey!,
        if (sessionToken != null) 'sessiontoken': sessionToken,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];

          return LocationResult.fromGooglePlace(
            result,
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );
        } else {
          throw Exception('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get place details: $e');
    }
  }

  /// Search for nearby places
  Future<List<LocationResult>> nearbySearch({
    required double latitude,
    required double longitude,
    double radius = 5000, // meters
    String? type,
    String? keyword,
  }) async {
    if (!isInitialized) {
      throw Exception('Google Places API key not initialized. Call initialize() first.');
    }

    try {
      final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'key': _apiKey!,
        if (type != null) 'type': type,
        if (keyword != null) 'keyword': keyword,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          return results.map((result) {
            final geometry = result['geometry'];
            final location = geometry['location'];

            return LocationResult.fromGooglePlace(
              result,
              location['lat'].toDouble(),
              location['lng'].toDouble(),
            );
          }).toList();
        } else {
          throw Exception('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search nearby places: $e');
    }
  }

  /// Text search for places
  Future<List<LocationResult>> textSearch({
    required String query,
    String? region, // ccTLD two-character value
  }) async {
    if (!isInitialized) {
      throw Exception('Google Places API key not initialized. Call initialize() first.');
    }

    try {
      final uri = Uri.parse('$_baseUrl/textsearch/json').replace(queryParameters: {
        'query': query,
        'key': _apiKey!,
        if (region != null) 'region': region,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          return results.map((result) {
            final geometry = result['geometry'];
            final location = geometry['location'];

            return LocationResult.fromGooglePlace(
              result,
              location['lat'].toDouble(),
              location['lng'].toDouble(),
            );
          }).toList();
        } else {
          throw Exception('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }

  /// Generate a new session token for billing optimization
  String generateSessionToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Represents a place prediction from autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;
  final List<String> types;

  PlacePrediction({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
    this.types = const [],
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] as Map<String, dynamic>?;

    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: structuredFormatting?['main_text'] as String?,
      secondaryText: structuredFormatting?['secondary_text'] as String?,
      types: List<String>.from(json['types'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      'main_text': mainText,
      'secondary_text': secondaryText,
      'types': types,
    };
  }

  @override
  String toString() => description;
}