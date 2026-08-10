import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Forecast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherPage(),
    );
  }
}

class Weather {
  const Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final String icon;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> main = json['main'] as Map<String, dynamic>;

    final List<dynamic> weatherList = json['weather'] as List<dynamic>;

    final Map<String, dynamic> weather =
        weatherList.first as Map<String, dynamic>;

    final Map<String, dynamic> system = json['sys'] as Map<String, dynamic>;

    return Weather(
      city: json['name'] as String? ?? 'Unknown',
      country: system['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: main['humidity'] as int? ?? 0,
      description: weather['description'] as String? ?? 'Unknown',
      icon: weather['icon'] as String? ?? '01d',
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const String apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

  final TextEditingController _cityController = TextEditingController();

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchWeather() async {
    final String city = _cityController.text.trim();

    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name.';
        _weather = null;
      });
      return;
    }

    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'OpenWeather API key is not configured.';
        _weather = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Uri url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': city,
        'appid': apiKey,
        'units': 'metric',
      });

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final Weather weather = Weather.fromJson(data);

        if (!mounted) {
          return;
        }

        setState(() {
          _weather = weather;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        throw Exception('City not found.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key.');
      } else {
        throw Exception('Weather service returned an error.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _weather = null;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _weatherIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@4x.png';
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _weather == null ? () async {} : _fetchWeather,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              const Icon(Icons.cloud_outlined, size: 64, color: Colors.blue),

              const SizedBox(height: 12),

              const Text(
                'Check the weather',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter a city to see current weather conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: _cityController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _fetchWeather(),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  prefixIcon: const Icon(Icons.location_city),
                  suffixIcon: IconButton(
                    onPressed: _isLoading ? null : _fetchWeather,
                    icon: const Icon(Icons.search),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _fetchWeather,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _isLoading ? 'Fetching weather...' : 'Get Weather',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              if (_errorMessage != null) _buildErrorCard(),

              if (_weather != null) _buildWeatherCard(),

              if (_weather == null && _errorMessage == null && !_isLoading)
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final Weather weather = _weather!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  '${weather.city}, ${weather.country}',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Image.network(
              _weatherIconUrl(weather.icon),
              width: 130,
              height: 130,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.cloud, size: 100, color: Colors.blue);
              },
            ),

            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              _capitalize(weather.description),
              style: TextStyle(fontSize: 19, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 8),

            Text(
              'Feels like ${weather.feelsLike.round()}°C',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: _WeatherInfo(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WeatherInfo(
                    icon: Icons.thermostat_outlined,
                    label: 'Temperature',
                    value: '${weather.temperature.round()}°C',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _fetchWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.cloud_queue, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Search for a city',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try Kolkata, London, Tokyo or New York.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _WeatherInfo extends StatelessWidget {
  const _WeatherInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
