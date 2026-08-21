import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';
import '../widgets/weather_widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherService>().getLocationAndWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherService>().getLocationAndWeather();
            },
          ),
        ],
      ),
      body: Consumer<WeatherService>(
        builder: (context, weatherService, _) {
          if (weatherService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (weatherService.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    weatherService.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      weatherService.getLocationAndWeather();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (weatherService.currentWeather == null) {
            return const Center(
              child: Text('No weather data available'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Weather Card
                  CurrentWeatherWidget(
                    weather: weatherService.currentWeather!,
                    location: weatherService.currentLocation,
                  ),
                  const SizedBox(height: 24),

                  // Weather Details Grid
                  WeatherDetailsWidget(
                    weather: weatherService.currentWeather!,
                  ),
                  const SizedBox(height: 24),

                  // 7-Day Forecast
                  if (weatherService.forecast.isNotEmpty) ...
                    [
                      const Text(
                        '7-Day Forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ForecastListWidget(
                        forecast: weatherService.forecast,
                      ),
                      const SizedBox(height: 24),
                    ],

                  // Hourly Forecast
                  if (weatherService.hourlyForecast.isNotEmpty) ...
                    [
                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HourlyForecastWidget(
                        hourly: weatherService.hourlyForecast,
                      ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}