import 'dart:convert';
import 'package:http/http.dart' as http;
import '../city.dart';

class Geocoding {
  static const String baseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<City>> searchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri =
          Uri.parse('$baseUrl?name=$query&count=10&language=en&format=json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null) {
          List<City> cities = [];
          for (var cityJson in data['results']) {
            cities.add(City.fromJson(cityJson));
          }
          return cities;
        }
      }
      return [];
    } catch (e) {
      print('Error search cities: ' + e.toString());
      return [];
    }
  }

  Future<String?> getCityFromCoordinates(double lat, double lon) async {
    try {
      final uri = Uri.parse(
          '$baseUrl?latitude=$lat&longitude=$lon&count=1&language=en&format=json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null) {
          City city = City.fromJson(data['results'][0]);
          return city.displayName;
        }
      }
      return null;
    } catch (e) {
      print('Error getting city from coordinates: ' + e.toString());
      return null;
    }
  }
}
