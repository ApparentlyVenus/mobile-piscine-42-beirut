class CurrentWeather {
  final double temp;
  final int code;
  final double windSpeed;
  final String time;

  CurrentWeather({
    required this.temp,
    required this.code,
    required this.windSpeed,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['temperature_2m']?.toDouble() ?? 0.0,
      code: json['weather_code'] ?? 0,
      windSpeed: json['wind_speed_10m']?.toDouble() ?? 0.0,
      time: json['time'] ?? '',
    );
  }

  static String getWeatherDescription(code) {
    switch (code) {
      case 0:
        return "Clear Sky";
      case 1:
      case 2:
      case 3:
        return "Partly Cloudy";
      case 45:
      case 48:
        return "Foggy";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 71:
      case 73:
      case 75:
        return "Snow";
      case 77:
        return "Snow grains";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      case 85:
      case 86:
        return "Snow showers";
      case 95:
        return "Thunderstorm";
      case 96:
      case 99:
        return "Thunderstorm with hail";
      default:
        return "Unkown";
    }
  }

  String get weather {
    return getWeatherDescription(code);
  }
}

class HourlyWeather {
  final String time;
  final double temp;
  final int code;
  final double windSpeed;

  HourlyWeather({
    required this.temp,
    required this.code,
    required this.windSpeed,
    required this.time,
  });

  String get weather {
    return CurrentWeather.getWeatherDescription(code);
  }

  String get formattedTime {
    try {
      DateTime dt = DateTime.parse(time);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }
}

class DailyWeather {
  final String date;
  final double tempMax;
  final double tempMin;
  final int code;

  DailyWeather(
      {required this.date,
      required this.tempMax,
      required this.tempMin,
      required this.code});

  String get weather {
    return CurrentWeather.getWeatherDescription(code);
  }

  String get formattedTime {
    try {
      DateTime dt = DateTime.parse(date);
      List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
    } catch (e) {
      return date;
    } 
  }
}

class WeatherData {
  final String location;
  final double latitude;
  final double longitude;
  final CurrentWeather? current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.location,
    required this.latitude,
    required this.longitude,
    this.current,
    required this.hourly,
    required this.daily,
  });
}
