import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import '../services/clothing_recommender.dart';
import '../services/image_selector.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import 'settings_provider.dart';

enum WeatherStatus { loading, success, error, offline }

class WeatherState {
  final WeatherStatus status;
  final WeatherData? data;
  final City city;
  final String? imagePath;
  final ClothingRecommendation? recommendation;
  final String? errorMessage;
  final DateTime? lastUpdate;

  const WeatherState({
    this.status = WeatherStatus.loading,
    this.data,
    this.city = const City(id: 'seoul', nameKo: '서울특별시', nameEn: 'Seoul', lat: 37.5665, lon: 126.9780),
    this.imagePath,
    this.recommendation,
    this.errorMessage,
    this.lastUpdate,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherData? data,
    City? city,
    String? imagePath,
    ClothingRecommendation? recommendation,
    String? errorMessage,
    DateTime? lastUpdate,
  }) {
    return WeatherState(
      status: status ?? this.status,
      data: data ?? this.data,
      city: city ?? this.city,
      imagePath: imagePath ?? this.imagePath,
      recommendation: recommendation ?? this.recommendation,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final CacheService _cacheService;
  final ClothingRecommender _clothingRecommender;
  final Ref _ref;

  WeatherNotifier(this._ref)
      : _weatherService = WeatherService(),
        _locationService = LocationService(),
        _cacheService = CacheService(),
        _clothingRecommender = ClothingRecommender(),
        super(const WeatherState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheService.initialize();
    await _clothingRecommender.initialize();
    await ImageSelector.initialize();
    await loadWeather();
  }

  Future<void> loadWeather() async {
    state = state.copyWith(status: WeatherStatus.loading);

    try {
      // Determine city
      final settings = _ref.read(settingsProvider);
      City city;

      if (settings.useGps) {
        try {
          final position = await _locationService.getCurrentLocation();
          city = _locationService.getCityFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } catch (_) {
          city = City.findById(settings.selectedCityId);
        }
      } else {
        city = City.findById(settings.selectedCityId);
      }

      // Check cache
      if (_cacheService.isCacheValid() && _cacheService.getCachedCityId() == city.id) {
        final cachedData = _cacheService.getWeatherData();
        if (cachedData != null) {
          _updateState(cachedData, city);
          return;
        }
      }

      // Fetch from API
      final data = await _weatherService.fetchWeather(city.lat, city.lon);
      await _cacheService.saveWeatherData(data, city.id);
      _updateState(data, city);
    } catch (e) {
      // Try cache on error
      final cachedData = _cacheService.getWeatherData();
      if (cachedData != null) {
        final cachedCityId = _cacheService.getCachedCityId() ?? 'seoul';
        final city = City.findById(cachedCityId);
        _updateState(cachedData, city, offline: true);
      } else {
        state = state.copyWith(
          status: WeatherStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  void _updateState(WeatherData data, City city, {bool offline = false}) {
    final now = DateTime.now();
    final imagePath = ImageSelector.getImagePath(
      cityId: city.id,
      now: now,
      weatherCode: data.weatherId,
      sunrise: data.sunrise,
      sunset: data.sunset,
    );
    final recommendation = _clothingRecommender.getRecommendation(data);

    state = WeatherState(
      status: offline ? WeatherStatus.offline : WeatherStatus.success,
      data: data,
      city: city,
      imagePath: imagePath,
      recommendation: recommendation,
      lastUpdate: _cacheService.getLastUpdateTime(),
    );
  }

  Future<void> refreshWeather() async {
    await _cacheService.clearCache();
    await loadWeather();
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref);
});
