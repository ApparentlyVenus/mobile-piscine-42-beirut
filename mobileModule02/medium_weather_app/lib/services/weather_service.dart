import 'dart:convert';
import 'package:http/http.dart' as http;
import '../weather.dart';

class Weather {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData?> getWeather(double lat, double lon, String location) async {
    try {
      final uri = Uri.parse('$baseUrl?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,weather_code,wind_speed_10m'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        '&timezone=auto');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        CurrentWeather? current;
        if (data['current'] != null) {
          current = CurrentWeather.fromJson(data['current']);
        }

        List<HourlyWeather> hourly = [];
        if (data['hourly'] != null) {
          var hourlyData = data['hourly'];
          int count = (hourlyData['time'] as List).length;
          int limit = count > 24 ? 24 : count;

          for (int i = 0; i < limit; i++) {
            hourly.add(
              HourlyWeather(
                temp: hourlyData['temperature_2m'][i]?.toDouble() ?? 0.0,
                code: hourlyData['weather_code'][i] ?? 0,
                windSpeed: hourlyData['weather_code'][i]?.toDouble() ?? 0.0,
                time: hourlyData['time'][i]
                )
            );
          }
        }

        List<DailyWeather> daily = [];

        if (data['daily'] != null) {
          var dailyData = data['daily'];
          int count = (dailyData['time'] as List).length;
          int limit = count > 7 ? 7 : count;
          
          for (int i = 0; i < limit; i++) {
            daily.add(
              DailyWeather(
                date: dailyData['time'][i],
                tempMax: dailyData['temperature_2m_max'][i]?.toDouble() ?? 0.0,
                tempMin: dailyData['temperature_2m_min'][i]?.toDouble() ?? 0.0,
                code: dailyData['weather_code'][i] ?? 0,
              )
            ); 
          } 
        } 

        return WeatherData(
          location: location,
          latitude: lat,
          longitude: lon,
          current: current,
          hourly: hourly,
          daily: daily,
        );
      }
    } catch(e) {
      print('Error fetching weather: $e');
      return null;
    }
  }
}
