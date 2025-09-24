import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:location_picker_plus/models/city_model.dart';
import 'package:location_picker_plus/models/country_model.dart';
import 'package:location_picker_plus/models/state_model.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance =>
      _instance ??= LocationService._internal();

  LocationService._internal();

  List<CountryModel>? _countries;
  List<StateModel>? _states;
  List<CityModel>? _cities;

  Future<List<CountryModel>> loadCountries({
    String assetPath = 'packages/location_picker_plus/assets/country.json',
  }) async {
    if (_countries != null) return _countries!;

    try {
      final String data = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(data);
      _countries = jsonList.map((json) => CountryModel.fromJson(json)).toList();
      return _countries!;
    } catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }

  Future<List<StateModel>> loadStates({
    String assetPath = 'packages/location_picker_plus/assets/state.json',
  }) async {
    if (_states != null) return _states!;

    try {
      final String data = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(data);
      _states = jsonList.map((json) => StateModel.fromJson(json)).toList();
      return _states!;
    } catch (e) {
      throw Exception('Failed to load states: $e');
    }
  }

  Future<List<CityModel>> loadCities({
    String assetPath = 'packages/location_picker_plus/assets/city.json',
  }) async {
    if (_cities != null) return _cities!;

    try {
      final String data = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(data);
      _cities = jsonList.map((json) => CityModel.fromJson(json)).toList();
      return _cities!;
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }

  Future<List<StateModel>> getStatesByCountryId(String countryId) async {
    final states = await loadStates();
    return states.where((state) => state.countryId == countryId).toList();
  }

  Future<List<CityModel>> getCitiesByStateId(String stateId) async {
    final cities = await loadCities();
    return cities.where((city) => city.stateId == stateId).toList();
  }

  Future<CountryModel?> getCountryById(String id) async {
    final countries = await loadCountries();
    try {
      return countries.firstWhere((country) => country.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<StateModel?> getStateById(String id) async {
    final states = await loadStates();
    try {
      return states.firstWhere((state) => state.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<CityModel?> getCityById(String id) async {
    final cities = await loadCities();
    try {
      return cities.firstWhere((city) => city.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CountryModel> searchCountries(String query) {
    if (_countries == null) return [];
    final lowerQuery = query.toLowerCase();
    return _countries!
        .where(
          (country) =>
              country.name.toLowerCase().contains(lowerQuery) ||
              country.sortName.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<StateModel> searchStates(String query, String? countryId) {
    if (_states == null) return [];
    final lowerQuery = query.toLowerCase();
    var filteredStates = _states!.where(
      (state) => state.name.toLowerCase().contains(lowerQuery),
    );

    if (countryId != null) {
      filteredStates = filteredStates.where(
        (state) => state.countryId == countryId,
      );
    }

    return filteredStates.toList();
  }

  List<CityModel> searchCities(String query, String? stateId) {
    if (_cities == null) return [];
    final lowerQuery = query.toLowerCase();
    var filteredCities = _cities!.where(
      (city) => city.name.toLowerCase().contains(lowerQuery),
    );

    if (stateId != null) {
      filteredCities = filteredCities.where((city) => city.stateId == stateId);
    }

    return filteredCities.toList();
  }

  void clearCache() {
    _countries = null;
    _states = null;
    _cities = null;
  }
}
