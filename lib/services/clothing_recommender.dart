import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/clothing_case.dart';
import '../models/weather_data.dart';

class ClothingRecommender {
  List<ClothingCase> _cases = [];
  final _random = Random();

  Future<void> initialize() async {
    final jsonString = await rootBundle.loadString('assets/data/clothing_logic.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    _cases = (json['cases'] as List)
        .map((e) => ClothingCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ClothingRecommendation getRecommendation(WeatherData weather) {
    final tempRange = _getTempRange(weather.feelsLike);
    final windLevel = _getWindLevel(weather.windSpeed);
    final humidityLevel = _getHumidityLevel(weather.humidity);
    final weatherCategory = _getWeatherCategory(weather.weatherId);

    final matchedCases = _cases.where((c) {
      final cond = c.conditions;
      if (cond.tempRange != 'any' && cond.tempRange != tempRange) return false;
      if (!_matchesList(cond.weather, weatherCategory)) return false;
      if (!_matchesList(cond.wind, windLevel)) return false;
      if (!_matchesList(cond.humidity, humidityLevel)) return false;
      return true;
    }).toList();

    if (matchedCases.isEmpty) {
      return ClothingRecommendation(
        message: '오늘 하루도 좋은 하루 보내세요!',
        items: [],
      );
    }

    matchedCases.sort((a, b) => a.priority.compareTo(b.priority));
    final selected = matchedCases.first;
    final message = selected.messages[_random.nextInt(selected.messages.length)];

    return ClothingRecommendation(
      message: message,
      items: selected.items,
    );
  }

  bool _matchesList(List<String> conditions, String value) {
    if (conditions.contains('any')) return true;
    return conditions.contains(value);
  }

  String _getTempRange(double feelsLike) {
    if (feelsLike < -10) return 'below_minus_10';
    if (feelsLike < -5) return 'minus_10_to_minus_5';
    if (feelsLike < 0) return 'minus_5_to_0';
    if (feelsLike < 5) return '0_to_5';
    if (feelsLike < 10) return '5_to_10';
    if (feelsLike < 15) return '10_to_15';
    if (feelsLike < 20) return '15_to_20';
    if (feelsLike < 25) return '20_to_25';
    if (feelsLike < 30) return '25_to_30';
    return 'above_30';
  }

  String _getWindLevel(double windSpeed) {
    if (windSpeed < 3) return 'low';
    if (windSpeed <= 8) return 'normal';
    return 'high';
  }

  String _getHumidityLevel(int humidity) {
    if (humidity < 40) return 'low';
    if (humidity <= 70) return 'normal';
    return 'high';
  }

  String _getWeatherCategory(int code) {
    if (code >= 200 && code <= 531) return 'rain';
    if (code >= 600 && code <= 622) return 'snow';
    if (code >= 701 && code <= 781) return 'fog';
    if (code == 800) return 'clear';
    if (code >= 801 && code <= 804) return 'cloudy';
    return 'clear';
  }
}

class ClothingRecommendation {
  final String message;
  final List<String> items;

  ClothingRecommendation({required this.message, required this.items});
}
