import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../services/image_selector.dart';
import '../widgets/clothing_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/particle_overlay.dart';
import '../widgets/weather_background.dart';
import '../widgets/weather_info.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => ref.read(weatherProvider.notifier).refreshWeather(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _buildContent(context, ref, weather, settings),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    WeatherState weather,
    SettingsState settings,
  ) {
    if (weather.status == WeatherStatus.loading && weather.data == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (weather.status == WeatherStatus.error && weather.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white38, size: 64),
            const SizedBox(height: 16),
            Text(
              weather.errorMessage ?? '날씨 데이터를 불러올 수 없습니다.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(weatherProvider.notifier).refreshWeather(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final data = weather.data!;
    final weatherCategory = ImageSelector.getWeatherCategory(data.weatherId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        if (weather.imagePath != null)
          WeatherBackground(imagePath: weather.imagePath!),

        // Particle overlay
        ParticleOverlay(
          weatherType: weatherCategory,
          enabled: settings.particleEnabled,
        ),

        // Content overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Top bar: offline banner + settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (weather.status == WeatherStatus.offline)
                      OfflineBanner(lastUpdate: weather.lastUpdate)
                    else
                      const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        _slideRoute(const SettingsScreen()),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                          shadows: [
                            Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // City name, date, temperature
                WeatherInfo(
                  cityName: weather.city.nameKo,
                  temperature: data.temp,
                  useCelsius: settings.useCelsius,
                ),

                const Spacer(),

                // Clothing recommendation
                if (weather.recommendation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: ClothingCard(message: weather.recommendation!.message),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
