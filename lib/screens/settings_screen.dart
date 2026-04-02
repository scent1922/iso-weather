import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('설정', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSection('일반'),

          _buildSwitchTile(
            title: '온도 단위',
            subtitle: settings.useCelsius ? '섭씨 (°C)' : '화씨 (°F)',
            value: settings.useCelsius,
            onChanged: (v) => notifier.setUseCelsius(v),
          ),

          _buildSwitchTile(
            title: '현재 위치 사용',
            subtitle: 'GPS 기반 자동 도시 판별',
            value: settings.useGps,
            onChanged: (v) {
              notifier.setUseGps(v);
              ref.read(weatherProvider.notifier).loadWeather();
            },
          ),

          ListTile(
            title: const Text('도시 선택', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              City.findById(settings.selectedCityId).nameKo,
              style: const TextStyle(color: Colors.white60),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () => _showCityPicker(context, ref, settings.selectedCityId),
          ),

          const Divider(color: Colors.white12),
          _buildSection('날씨 표시'),

          _buildSwitchTile(
            title: '날씨 애니메이션',
            subtitle: '눈/비 파티클 효과',
            value: settings.particleEnabled,
            onChanged: (v) => notifier.setParticleEnabled(v),
          ),

          const Divider(color: Colors.white12),
          _buildSection('알림'),

          _buildSwitchTile(
            title: '매일 아침 알림',
            subtitle: '옷차림 추천 알림',
            value: settings.notificationEnabled,
            onChanged: (v) => notifier.setNotificationEnabled(v),
          ),

          if (settings.notificationEnabled)
            ListTile(
              title: const Text('알림 시간', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                '${settings.notificationHour.toString().padLeft(2, '0')}:${settings.notificationMinute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => _showTimePicker(context, ref, settings),
            ),

          const Divider(color: Colors.white12),
          _buildSection('앱 정보'),

          const ListTile(
            title: Text('버전', style: TextStyle(color: Colors.white)),
            subtitle: Text('1.0.0', style: TextStyle(color: Colors.white60)),
          ),
          const ListTile(
            title: Text('크레딧', style: TextStyle(color: Colors.white)),
            subtitle: Text('Minicast by scent1922', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF90CAF9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFF90CAF9),
    );
  }

  void _showCityPicker(BuildContext context, WidgetRef ref, String currentCityId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '도시 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ...City.supportedCities.map((city) => ListTile(
              title: Text(city.nameKo, style: const TextStyle(color: Colors.white)),
              subtitle: Text(city.nameEn, style: const TextStyle(color: Colors.white60)),
              trailing: city.id == currentCityId
                  ? const Icon(Icons.check, color: Color(0xFF90CAF9))
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setSelectedCity(city.id);
                ref.read(weatherProvider.notifier).loadWeather();
                Navigator.pop(context);
              },
            )),
          ],
        );
      },
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref, SettingsState settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.notificationHour, minute: settings.notificationMinute),
    );
    if (time != null) {
      ref.read(settingsProvider.notifier).setNotificationTime(time.hour, time.minute);
    }
  }
}
