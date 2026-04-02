import 'package:flutter/services.dart';

class ImageSelector {
  static final Set<String> _existingAssets = {};
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      for (final asset in assets) {
        if (asset.startsWith('assets/images/cities/')) {
          _existingAssets.add(asset);
        }
      }
    } catch (_) {
      // AssetManifest may not be available in all contexts
    }
    _initialized = true;
  }

  static String getImagePath({
    required String cityId,
    required DateTime now,
    required int weatherCode,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final season = _getSeason(now.month);
    final timeOfDay = _getTimeOfDay(now, sunrise, sunset);
    final weather = _getWeatherCategory(weatherCode);

    // Try exact match first, then fallbacks
    final candidates = [
      '${cityId}_${season}_${timeOfDay}_$weather',
      '${cityId}_${season}_${timeOfDay}_clear',
      '${cityId}_${season}_day_clear',
      '${cityId}_spring_day_clear',
    ];

    for (final candidate in candidates) {
      final path = 'assets/images/cities/$candidate.webp';
      if (_existingAssets.isEmpty || _existingAssets.contains(path)) {
        return path;
      }
    }

    return 'assets/images/cities/${cityId}_spring_day_clear.webp';
  }

  static String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  static String _getTimeOfDay(DateTime now, DateTime sunrise, DateTime sunset) {
    if (now.isAfter(sunrise) && now.isBefore(sunset)) return 'day';
    return 'night';
  }

  static String _getWeatherCategory(int code) {
    if (code >= 200 && code <= 531) return 'rain';
    if (code >= 600 && code <= 622) return 'snow';
    if (code >= 701 && code <= 781) return 'fog';
    if (code == 800) return 'clear';
    if (code >= 801 && code <= 804) return 'cloudy';
    return 'clear';
  }

  static String getWeatherCategory(int code) => _getWeatherCategory(code);
}
