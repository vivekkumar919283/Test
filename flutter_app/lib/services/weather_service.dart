import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherModel {
  final String main;
  final String description;
  final double temp;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final double windDeg;
  final int visibility;
  final double uvi;
  final int clouds;
  final int? rain;
  final String icon;

  WeatherModel({
    required this.main,
    required this.description,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.visibility,
    required this.uvi,
    required this.clouds,
    this.rain,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      main: json['weather'][0]['main'] ?? 'Unknown',
      description: json['weather'][0]['description'] ?? 'Unknown',
      temp: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      pressure: json['main']['pressure'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      windDeg: (json['wind']['deg'] ?? 0).toDouble(),
      visibility: json['visibility'] ?? 0,
      uvi: (json['uvi'] ?? 0).toDouble(),
      clouds: json['clouds']['all'] ?? 0,
      rain: json['rain']?['1h'],
      icon: json['weather'][0]['icon'] ?? '01d',
    );
  }
}

class ForecastModel {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String main;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int? rain;

  ForecastModel({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.main,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.rain,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['temp']['max'] ?? 0).toDouble(),
      minTemp: (json['temp']['min'] ?? 0).toDouble(),
      main: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      rain: json['rain'],
    );
  }
}

class HourlyForecastModel {
  final DateTime dateTime;
  final double temp;
  final String main;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int? rain;

  HourlyForecastModel({
    required this.dateTime,
    required this.temp,
    required this.main,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.rain,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: (json['temp'] ?? 0).toDouble(),
      main: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      rain: json['rain']?['1h'],
    );
  }
}

class WeatherService extends ChangeNotifier {
  // Using Open-Meteo API (Completely Free, No API Key Required)
  static const String _baseUrl = 'https://api.open-meteo.com/v1';

  WeatherModel? currentWeather;
  List<ForecastModel> forecast = [];
  List<HourlyForecastModel> hourlyForecast = [];
  String? currentLocation;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getLocationAndWeather() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage = 'Location permission denied. Using default location.';
        // Use default location (New York)
        await getWeatherByCoordinates(40.7128, -74.0060);
      } else if (permission == LocationPermission.denied) {
        errorMessage = 'Location permission denied. Using default location.';
        await getWeatherByCoordinates(40.7128, -74.0060);
      } else {
        // Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await getWeatherByCoordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      print('Location error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getWeatherByCoordinates(double latitude, double longitude) async {
    try {
      isLoading = true;
      notifyListeners();

      // Open-Meteo API - Completely Free (No API Key Required!)
      final url = Uri.parse(
        '$_baseUrl/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,weather_code,precipitation'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max'
        '&timezone=auto'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse current weather
        final current = data['current'];
        currentWeather = WeatherModel(
          main: _getWeatherDescription(current['weather_code']),
          description: _getWeatherDescription(current['weather_code']),
          temp: (current['temperature_2m'] ?? 0).toDouble(),
          feelsLike: (current['apparent_temperature'] ?? 0).toDouble(),
          humidity: current['relative_humidity_2m'] ?? 0,
          pressure: 0, // Not available in free tier
          windSpeed: (current['wind_speed_10m'] ?? 0).toDouble(),
          windDeg: 0,
          visibility: 10000,
          uvi: 0,
          clouds: 0,
          rain: current['precipitation'],
          icon: _getWeatherIcon(current['weather_code']),
        );

        // Parse daily forecast
        final daily = data['daily'];
        forecast = [];
        for (int i = 0; i < daily['time'].length && i < 7; i++) {
          forecast.add(
            ForecastModel(
              date: DateTime.parse(daily['time'][i]),
              maxTemp: (daily['temperature_2m_max'][i] ?? 0).toDouble(),
              minTemp: (daily['temperature_2m_min'][i] ?? 0).toDouble(),
              main: _getWeatherDescription(daily['weather_code'][i]),
              icon: _getWeatherIcon(daily['weather_code'][i]),
              humidity: 0,
              windSpeed: (daily['wind_speed_10m_max'][i] ?? 0).toDouble(),
              rain: daily['precipitation_sum'][i]?.toInt(),
            ),
          );
        }

        // Parse hourly forecast
        final hourly = data['hourly'];
        hourlyForecast = [];
        for (int i = 0; i < hourly['time'].length && i < 24; i++) {
          hourlyForecast.add(
            HourlyForecastModel(
              dateTime: DateTime.parse(hourly['time'][i]),
              temp: (hourly['temperature_2m'][i] ?? 0).toDouble(),
              main: _getWeatherDescription(hourly['weather_code'][i]),
              icon: _getWeatherIcon(hourly['weather_code'][i]),
              humidity: 0,
              windSpeed: 0,
              rain: hourly['precipitation'][i]?.toInt(),
            ),
          );
        }

        errorMessage = null;
      } else {
        errorMessage = 'Failed to fetch weather data';
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      print('Weather fetch error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getWeatherByCity(String cityName) async {
    try {
      isLoading = true;
      notifyListeners();

      // Geocode city name to coordinates using Open-Meteo Geocoding API
      final geocodeUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=$cityName'
        '&count=1'
        '&language=en'
        '&format=json'
      );

      final geocodeResponse = await http.get(geocodeUrl).timeout(const Duration(seconds: 10));

      if (geocodeResponse.statusCode == 200) {
        final geocodeData = jsonDecode(geocodeResponse.body);
        if (geocodeData['results'] != null && geocodeData['results'].isNotEmpty) {
          final result = geocodeData['results'][0];
          currentLocation = '${result['name']}, ${result['country']}';
          await getWeatherByCoordinates(
            result['latitude'],
            result['longitude'],
          );
        } else {
          errorMessage = 'City not found';
        }
      } else {
        errorMessage = 'Failed to find city';
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _getWeatherDescription(int weatherCode) {
    // WMO Weather interpretation codes
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode == 1 || weatherCode == 2) return 'Mainly clear';
    if (weatherCode == 3) return 'Overcast';
    if (weatherCode == 45 || weatherCode == 48) return 'Foggy';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Drizzle';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode == 80 || weatherCode == 81 || weatherCode == 82) return 'Rain showers';
    if (weatherCode == 85 || weatherCode == 86) return 'Snow showers';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain';
    if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String _getWeatherIcon(int weatherCode) {
    // Map WMO codes to emoji
    if (weatherCode == 0) return '☀️';
    if (weatherCode == 1 || weatherCode == 2) return '⛅';
    if (weatherCode == 3) return '☁️';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 67) return '���️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode == 85 || weatherCode == 86) return '🌨️';
    if (weatherCode >= 95 && weatherCode <= 99) return '⛈️';
    return '🌤️';
  }
}