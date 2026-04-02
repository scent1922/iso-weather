import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  static const Duration _timeout = Duration(seconds: 10);

  String get _apiKey => dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      throw WeatherException('OpenWeatherMap API 키가 설정되지 않았습니다.');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'exclude': 'minutely,hourly,daily,alerts',
      'units': 'metric',
      'lang': 'ko',
      'appid': _apiKey,
    });

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      } else if (response.statusCode == 401) {
        throw WeatherException('API 키가 유효하지 않습니다.');
      } else {
        throw WeatherException('날씨 데이터를 가져올 수 없습니다. (${response.statusCode})');
      }
    } on http.ClientException {
      throw WeatherException('네트워크 연결을 확인해주세요.');
    }
  }

  Future<GeocodingResult?> searchCity(String query) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') return null;

    final uri = Uri.parse('https://api.openweathermap.org/geo/1.0/direct')
        .replace(queryParameters: {
      'q': query,
      'limit': '1',
      'appid': _apiKey,
    });

    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        if (list.isEmpty) return null;
        final item = list.first as Map<String, dynamic>;
        return GeocodingResult(
          name: item['local_names']?['ko'] as String? ?? item['name'] as String,
          nameEn: item['name'] as String,
          lat: (item['lat'] as num).toDouble(),
          lon: (item['lon'] as num).toDouble(),
          country: item['country'] as String? ?? '',
        );
      }
    } catch (_) {}
    return null;
  }
}

class GeocodingResult {
  final String name;
  final String nameEn;
  final double lat;
  final double lon;
  final String country;

  GeocodingResult({
    required this.name,
    required this.nameEn,
    required this.lat,
    required this.lon,
    required this.country,
  });
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
