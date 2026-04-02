import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../services/image_selector.dart';
import '../widgets/clothing_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/particle_overlay.dart';
import '../widgets/weather_background.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/weather_details.dart';
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
        color: Colors.white,
        backgroundColor: Colors.white24,
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
      return _buildErrorScreen(context, ref, weather.errorMessage);
    }

    final data = weather.data!;
    final weatherCategory = ImageSelector.getWeatherCategory(data.weatherId);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
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
                              Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Color(0x80000000)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Search bar
                  CitySearchBar(
                    onSearch: (query) => _handleSearch(context, ref, query),
                  ),

                  const SizedBox(height: 4),

                  // City name, date, weather, temperature
                  WeatherInfo(
                    cityName: weather.city.nameKo,
                    temperature: data.temp,
                    weatherDescription: data.weatherDescription,
                    useCelsius: settings.useCelsius,
                  ),

                  const Spacer(),

                  // Sub-info: feels-like, humidity, wind (between image and card)
                  WeatherDetails(
                    feelsLike: data.feelsLike,
                    humidity: data.humidity,
                    windSpeed: data.windSpeed,
                    useCelsius: settings.useCelsius,
                  ),

                  const SizedBox(height: 12),

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
      ),
    );
  }

  Widget _buildErrorScreen(
      BuildContext context, WidgetRef ref, String? errorMessage) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF5BA8CC)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  '날씨 정보를 불러올 수 없어요',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? '네트워크 연결을 확인하고 다시 시도해주세요.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xCCFFFFFF),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(weatherProvider.notifier).refreshWeather(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    '다시 시도',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5BA8CC),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSearch(BuildContext context, WidgetRef ref, String query) async {
    final message = await ref.read(weatherProvider.notifier).searchCity(query);
    if (message != null && context.mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '알림',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.6,
                        shadows: [
                          Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
