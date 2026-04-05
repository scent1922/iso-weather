import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/clothing_recommender.dart';
import '../services/notification_service.dart';

class SettingsState {
  final bool useCelsius;
  final String selectedCityId;
  final bool useGps;
  final bool notificationEnabled;
  final int notificationHour;
  final int notificationMinute;
  final bool particleEnabled;
  final SensitivityType sensitivity;
  final bool onboardingComplete;

  const SettingsState({
    this.useCelsius = true,
    this.selectedCityId = 'seoul',
    this.useGps = true,
    this.notificationEnabled = false,
    this.notificationHour = 7,
    this.notificationMinute = 0,
    this.particleEnabled = true,
    this.sensitivity = SensitivityType.normal,
    this.onboardingComplete = false,
  });

  SettingsState copyWith({
    bool? useCelsius,
    String? selectedCityId,
    bool? useGps,
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    bool? particleEnabled,
    SensitivityType? sensitivity,
    bool? onboardingComplete,
  }) {
    return SettingsState(
      useCelsius: useCelsius ?? this.useCelsius,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      useGps: useGps ?? this.useGps,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      particleEnabled: particleEnabled ?? this.particleEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final NotificationService _notificationService = NotificationService();

  SettingsNotifier() : super(const SettingsState()) {
    _notificationService.initialize();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sensitivityStr = prefs.getString('sensitivity') ?? 'normal';
    state = SettingsState(
      useCelsius: prefs.getBool('useCelsius') ?? true,
      selectedCityId: prefs.getString('selectedCityId') ?? 'seoul',
      useGps: prefs.getBool('useGps') ?? true,
      notificationEnabled: prefs.getBool('notificationEnabled') ?? false,
      notificationHour: prefs.getInt('notificationHour') ?? 7,
      notificationMinute: prefs.getInt('notificationMinute') ?? 0,
      particleEnabled: prefs.getBool('particleEnabled') ?? true,
      sensitivity: _sensitivityFromString(sensitivityStr),
      onboardingComplete: prefs.getBool('onboardingComplete') ?? false,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCelsius', state.useCelsius);
    await prefs.setString('selectedCityId', state.selectedCityId);
    await prefs.setBool('useGps', state.useGps);
    await prefs.setBool('notificationEnabled', state.notificationEnabled);
    await prefs.setInt('notificationHour', state.notificationHour);
    await prefs.setInt('notificationMinute', state.notificationMinute);
    await prefs.setBool('particleEnabled', state.particleEnabled);
    await prefs.setString('sensitivity', state.sensitivity.name);
    await prefs.setBool('onboardingComplete', state.onboardingComplete);
  }

  static SensitivityType _sensitivityFromString(String value) {
    switch (value) {
      case 'sensitiveCold':
        return SensitivityType.sensitiveCold;
      case 'sensitiveHot':
        return SensitivityType.sensitiveHot;
      case 'sensitiveBoth':
        return SensitivityType.sensitiveBoth;
      default:
        return SensitivityType.normal;
    }
  }

  void setUseCelsius(bool value) {
    state = state.copyWith(useCelsius: value);
    _save();
  }

  void setSelectedCity(String cityId) {
    state = state.copyWith(selectedCityId: cityId);
    _save();
  }

  void setUseGps(bool value) {
    state = state.copyWith(useGps: value);
    _save();
  }

  void setNotificationEnabled(bool value) {
    state = state.copyWith(notificationEnabled: value);
    _save();
    if (value) {
      _notificationService.scheduleDailyNotification(
        state.notificationHour,
        state.notificationMinute,
      );
    } else {
      _notificationService.cancelNotification();
    }
  }

  void setNotificationTime(int hour, int minute) {
    state = state.copyWith(notificationHour: hour, notificationMinute: minute);
    _save();
    if (state.notificationEnabled) {
      _notificationService.scheduleDailyNotification(hour, minute);
    }
  }

  void setParticleEnabled(bool value) {
    state = state.copyWith(particleEnabled: value);
    _save();
  }

  void setSensitivity(SensitivityType value) {
    state = state.copyWith(sensitivity: value);
    _save();
  }

  void setOnboardingComplete(bool value) {
    state = state.copyWith(onboardingComplete: value);
    _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
