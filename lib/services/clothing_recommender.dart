import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/weather_data.dart';

// ─── Sensitivity ────────────────────────────────────────────────────────────

enum SensitivityType { normal, sensitiveCold, sensitiveHot, sensitiveBoth }

double _applySensitivity(double feelsLike, SensitivityType s) {
  switch (s) {
    case SensitivityType.normal:
      return feelsLike;
    case SensitivityType.sensitiveCold:
      return feelsLike - 3;
    case SensitivityType.sensitiveHot:
      return feelsLike + 3;
    case SensitivityType.sensitiveBoth:
      if (feelsLike < 15) return feelsLike - 3;
      if (feelsLike >= 22) return feelsLike + 3;
      return feelsLike;
  }
}

// ─── TodayWeatherProfile ────────────────────────────────────────────────────

class TodayWeatherProfile {
  final double worstFeelsLike;
  final double bestFeelsLike;
  final double feelsLikeRange;
  final double maxWindSpeed;
  final double maxWindGust;
  final double maxRain1h;
  final double maxSnow1h;
  final double maxPop;
  final double maxUvi;
  final double maxDewPoint;
  final int minVisibility;
  final int maxHumidity;
  final List<int> hasRainHours;
  final List<int> hasSnowHours;
  final int? rainStartHour;
  final int worstHour;
  final double tempDropMax;
  final List<int> worstWeatherIds;
  final double currentVsWorstDiff;

  TodayWeatherProfile({
    required this.worstFeelsLike,
    required this.bestFeelsLike,
    required this.feelsLikeRange,
    required this.maxWindSpeed,
    required this.maxWindGust,
    required this.maxRain1h,
    required this.maxSnow1h,
    required this.maxPop,
    required this.maxUvi,
    required this.maxDewPoint,
    required this.minVisibility,
    required this.maxHumidity,
    required this.hasRainHours,
    required this.hasSnowHours,
    this.rainStartHour,
    required this.worstHour,
    required this.tempDropMax,
    required this.worstWeatherIds,
    required this.currentVsWorstDiff,
  });
}

// ─── ClothingRecommendation ─────────────────────────────────────────────────

class ClothingRecommendation {
  final String message;
  final List<String> items;

  ClothingRecommendation({required this.message, required this.items});
}

// ─── ClothingRecommender ────────────────────────────────────────────────────

class ClothingRecommender {
  Map<String, dynamic> _data = {};
  final _random = Random();

  Future<void> initialize() async {
    final jsonString =
        await rootBundle.loadString('assets/data/clothing_logic.json');
    _data = jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // ── Build today's weather profile from hourly data ──

  TodayWeatherProfile buildTodayProfile(
    WeatherData current,
    List<HourlyWeather> hourly,
    SensitivityType sensitivity,
  ) {
    final now = current.localNow;
    // Filter hours from now until end of day (next 24h max)
    final todayHours = hourly.where((h) {
      return !h.time.isBefore(now);
    }).toList();

    if (todayHours.isEmpty) {
      // Fallback: use current data only
      final correctedFL =
          _applySensitivity(current.feelsLike, sensitivity);
      return TodayWeatherProfile(
        worstFeelsLike: correctedFL,
        bestFeelsLike: correctedFL,
        feelsLikeRange: 0,
        maxWindSpeed: current.windSpeed,
        maxWindGust: current.windSpeed,
        maxRain1h: 0,
        maxSnow1h: 0,
        maxPop: 0,
        maxUvi: current.uvi,
        maxDewPoint: current.dewPoint ?? 0,
        minVisibility: current.visibility ?? 10000,
        maxHumidity: current.humidity,
        hasRainHours: [],
        hasSnowHours: [],
        rainStartHour: null,
        worstHour: now.hour,
        tempDropMax: 0,
        worstWeatherIds: [current.weatherId],
        currentVsWorstDiff: 0,
      );
    }

    // Apply sensitivity correction to all hourly feels_like
    final correctedFeelsLikes = todayHours
        .map((h) => _applySensitivity(h.feelsLike, sensitivity))
        .toList();

    double worstFL = correctedFeelsLikes.reduce(min);
    double bestFL = correctedFeelsLikes.reduce(max);
    double maxWind = todayHours.map((h) => h.windSpeed).reduce(max);
    double maxGust =
        todayHours.map((h) => h.windGust ?? h.windSpeed).reduce(max);
    double maxRain = todayHours.map((h) => h.rain1h ?? 0.0).reduce(max);
    double maxSnow = todayHours.map((h) => h.snow1h ?? 0.0).reduce(max);
    double maxPop = todayHours.map((h) => h.pop).reduce(max);
    double maxUvi = todayHours.map((h) => h.uvi).reduce(max);
    double maxDew =
        todayHours.map((h) => h.dewPoint ?? 0.0).reduce(max);
    int minVis =
        todayHours.map((h) => h.visibility ?? 10000).reduce(min);
    int maxHum = todayHours.map((h) => h.humidity).reduce(max);

    // Rain / snow hours
    List<int> rainHours = [];
    List<int> snowHours = [];
    int? rainStart;
    for (final h in todayHours) {
      if ((h.rain1h ?? 0) > 0 || (h.weatherId >= 200 && h.weatherId <= 531)) {
        rainHours.add(h.time.hour);
        rainStart ??= h.time.hour;
      }
      if ((h.snow1h ?? 0) > 0 || (h.weatherId >= 600 && h.weatherId <= 622)) {
        snowHours.add(h.time.hour);
      }
    }

    // Worst hour (lowest feels_like)
    int worstIdx = 0;
    for (int i = 1; i < correctedFeelsLikes.length; i++) {
      if (correctedFeelsLikes[i] < correctedFeelsLikes[worstIdx]) {
        worstIdx = i;
      }
    }
    int worstHour = todayHours[worstIdx].time.hour;

    // Temp drop max: biggest consecutive drop
    double tempDrop = 0;
    for (int i = 1; i < correctedFeelsLikes.length; i++) {
      final drop = correctedFeelsLikes[i - 1] - correctedFeelsLikes[i];
      if (drop > tempDrop) tempDrop = drop;
    }

    // Worst weather IDs (most severe)
    final worstIds = todayHours.map((h) => h.weatherId).toSet().toList();

    // Current vs worst diff
    final currentCorrected =
        _applySensitivity(current.feelsLike, sensitivity);
    final cvwDiff = (currentCorrected - worstFL).abs();

    return TodayWeatherProfile(
      worstFeelsLike: worstFL,
      bestFeelsLike: bestFL,
      feelsLikeRange: bestFL - worstFL,
      maxWindSpeed: maxWind,
      maxWindGust: maxGust,
      maxRain1h: maxRain,
      maxSnow1h: maxSnow,
      maxPop: maxPop,
      maxUvi: maxUvi,
      maxDewPoint: maxDew,
      minVisibility: minVis,
      maxHumidity: maxHum,
      hasRainHours: rainHours,
      hasSnowHours: snowHours,
      rainStartHour: rainStart,
      worstHour: worstHour,
      tempDropMax: tempDrop,
      worstWeatherIds: worstIds,
      currentVsWorstDiff: cvwDiff,
    );
  }

  // ── Main recommendation entry point ──

  ClothingRecommendation getRecommendation(
    WeatherData current,
    List<HourlyWeather> hourly,
    DailyWeather? today,
    List<WeatherAlert>? alerts,
    SensitivityType sensitivity,
  ) {
    final profile = buildTodayProfile(current, hourly, sensitivity);

    // ── Layer 1: Alert override ──
    if (alerts != null && alerts.isNotEmpty) {
      final alertResult = _checkAlerts(alerts);
      if (alertResult != null) return alertResult;
    }

    // ── Layer 2: Base outfit by corrected worst feels_like ──
    final baseOutfit = _selectBaseOutfit(profile.worstFeelsLike);
    List<String> items = List<String>.from(baseOutfit['items'] as List);
    List<String> messages = [];

    // Pick one random base message
    final baseMessages = List<String>.from(baseOutfit['messages'] as List);
    messages.add(baseMessages[_random.nextInt(baseMessages.length)]);

    // Layering strategy if big temp swing
    if (profile.currentVsWorstDiff > 10) {
      items.add('얇은 레이어 (겹쳐 입기용)');
    }

    // ── Layer 3: Modifiers ──
    final modifierMessages = <String>[];
    final modifiers = _data['modifiers'] as Map<String, dynamic>? ?? {};

    // Evaluate modifiers in priority order
    final orderedKeys = [
      // Temperature modifiers
      'feels_like_big_swing',
      'feels_like_moderate_swing',
      'warm_now_cold_later',
      'cold_now_warm_later',
      // Rain modifiers
      'rain_heavy_today',
      'rain_with_wind_today',
      'rain_today',
      'upcoming_rain_timing',
      // Wind modifiers
      'very_strong_wind_today',
      'strong_wind_today',
      // Other
      'snow_today',
      'high_dewpoint_today',
      'high_uvi_today',
      'low_visibility_today',
    ];

    for (final key in orderedKeys) {
      if (!modifiers.containsKey(key)) continue;
      final mod = modifiers[key] as Map<String, dynamic>;
      if (_evaluateModifier(key, mod, profile, current, sensitivity)) {
        // Add items
        if (mod['add_items'] != null) {
          for (final item in (mod['add_items'] as List)) {
            if (!items.contains(item as String)) items.add(item);
          }
        }
        // Remove items
        if (mod['remove_items'] != null) {
          for (final item in (mod['remove_items'] as List)) {
            items.remove(item as String);
          }
        }
        // Collect modifier messages
        final mMsgs = List<String>.from(mod['messages'] as List);
        modifierMessages.add(mMsgs[_random.nextInt(mMsgs.length)]);
      }
    }

    // ── Layer 4: Combine messages (max 3 sentences total) ──
    // Take up to 2 modifier messages
    final selectedModMsgs = modifierMessages.take(2).toList();
    messages.addAll(selectedModMsgs);

    // Replace placeholders
    String combined = messages.take(3).join(' ');
    combined = combined
        .replaceAll('{rain_start_hour}',
            profile.rainStartHour?.toString() ?? '?')
        .replaceAll('{worst_hour}', profile.worstHour.toString())
        .replaceAll(
            '{worst_feels_like}', profile.worstFeelsLike.round().toString());

    return ClothingRecommendation(message: combined, items: items);
  }

  // ── Layer 1 helpers ──

  ClothingRecommendation? _checkAlerts(List<WeatherAlert> alerts) {
    final alertsOverride =
        _data['alerts_override'] as Map<String, dynamic>? ?? {};

    // Check each alert type in priority order
    final sortedTypes = alertsOverride.entries.toList()
      ..sort((a, b) =>
          ((a.value as Map)['priority'] as int? ?? 99)
              .compareTo((b.value as Map)['priority'] as int? ?? 99));

    for (final entry in sortedTypes) {
      final config = entry.value as Map<String, dynamic>;
      final keywords = List<String>.from(config['keywords'] as List);
      for (final alert in alerts) {
        final combined =
            '${alert.event} ${alert.description}'.toLowerCase();
        for (final kw in keywords) {
          if (combined.contains(kw.toLowerCase())) {
            final msgs = List<String>.from(config['messages'] as List);
            final items = config['items'] != null
                ? List<String>.from(config['items'] as List)
                : <String>[];
            return ClothingRecommendation(
              message: msgs[_random.nextInt(msgs.length)],
              items: items,
            );
          }
        }
      }
    }
    return null;
  }

  // ── Layer 2 helpers ──

  Map<String, dynamic> _selectBaseOutfit(double worstFeelsLike) {
    final baseOutfits =
        _data['base_outfits'] as Map<String, dynamic>? ?? {};

    for (final entry in baseOutfits.entries) {
      final outfit = entry.value as Map<String, dynamic>;
      final range = List<num>.from(outfit['temp_range'] as List);
      if (worstFeelsLike >= range[0] && worstFeelsLike < range[1]) {
        return outfit;
      }
    }
    // Fallback: if nothing matched, pick extreme_hot or extreme_cold
    if (worstFeelsLike >= 33) {
      return baseOutfits['extreme_hot'] as Map<String, dynamic>;
    }
    return baseOutfits['extreme_cold'] as Map<String, dynamic>;
  }

  // ── Layer 3 helpers ──

  bool _evaluateModifier(
    String key,
    Map<String, dynamic> mod,
    TodayWeatherProfile p,
    WeatherData current,
    SensitivityType sensitivity,
  ) {
    final cond = mod['condition'] as Map<String, dynamic>? ?? {};

    switch (key) {
      case 'rain_today':
        final range = _getRange(cond['today_max_rain_1h']);
        return range != null && _inRange(p.maxRain1h, range);
      case 'rain_heavy_today':
        final range = _getRange(cond['today_max_rain_1h']);
        return range != null && _inRange(p.maxRain1h, range);
      case 'rain_with_wind_today':
        final rainRange = _getRange(cond['today_max_rain_1h']);
        final windRange = _getRange(cond['today_max_wind_speed']);
        return rainRange != null &&
            _inRange(p.maxRain1h, rainRange) &&
            windRange != null &&
            _inRange(p.maxWindSpeed, windRange);
      case 'upcoming_rain_timing':
        return p.rainStartHour != null && p.hasRainHours.isNotEmpty;
      case 'snow_today':
        final range = _getRange(cond['today_max_snow_1h']);
        return range != null
            ? _inRange(p.maxSnow1h, range)
            : p.hasSnowHours.isNotEmpty;
      case 'high_dewpoint_today':
        final range = _getRange(cond['today_max_dew_point']);
        return range != null && _inRange(p.maxDewPoint, range);
      case 'high_uvi_today':
        final range = _getRange(cond['today_max_uvi']);
        return range != null && _inRange(p.maxUvi, range);
      case 'low_visibility_today':
        final range = _getRange(cond['today_min_visibility']);
        return range != null && _inRange(p.minVisibility.toDouble(), range);
      case 'feels_like_big_swing':
        final range = _getRange(cond['feels_like_range']);
        return range != null && _inRange(p.feelsLikeRange, range);
      case 'feels_like_moderate_swing':
        final range = _getRange(cond['feels_like_range']);
        return range != null && _inRange(p.feelsLikeRange, range);
      case 'warm_now_cold_later':
        final currentFL =
            _applySensitivity(current.feelsLike, sensitivity);
        return currentFL > p.worstFeelsLike &&
            (currentFL - p.worstFeelsLike) >= 8 &&
            p.worstHour > current.localNow.hour;
      case 'cold_now_warm_later':
        final currentFL =
            _applySensitivity(current.feelsLike, sensitivity);
        return currentFL < p.bestFeelsLike &&
            (p.bestFeelsLike - currentFL) >= 8;
      case 'strong_wind_today':
        final range = _getRange(cond['today_max_wind_speed']);
        return range != null && _inRange(p.maxWindSpeed, range);
      case 'very_strong_wind_today':
        final range = _getRange(cond['today_max_wind_speed']);
        return range != null && _inRange(p.maxWindSpeed, range);
      default:
        return false;
    }
  }

  List<double>? _getRange(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => (e as num).toDouble()).toList();
    }
    return null;
  }

  bool _inRange(double value, List<double> range) {
    return value >= range[0] && value < range[1];
  }
}
