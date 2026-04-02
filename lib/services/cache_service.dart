import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/weather_data.dart';

class CacheService {
  static const String _boxName = 'weather_cache';
  static const String _dataKey = 'weather_data';
  static const String _timestampKey = 'last_update';
  static const String _cityKey = 'cached_city';
  static const Duration _cacheValidity = Duration(minutes: 30);

  late Box _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> saveWeatherData(WeatherData data, String cityId) async {
    await _box.put(_dataKey, jsonEncode(data.toJson()));
    await _box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    await _box.put(_cityKey, cityId);
  }

  WeatherData? getWeatherData() {
    final jsonString = _box.get(_dataKey) as String?;
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeatherData.fromCache(json);
    } catch (_) {
      return null;
    }
  }

  String? getCachedCityId() => _box.get(_cityKey) as String?;

  bool isCacheValid() {
    final timestamp = _box.get(_timestampKey) as int?;
    if (timestamp == null) return false;

    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(lastUpdate) < _cacheValidity;
  }

  DateTime? getLastUpdateTime() {
    final timestamp = _box.get(_timestampKey) as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> clearCache() async {
    await _box.clear();
  }
}
