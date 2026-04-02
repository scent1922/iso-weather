import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  // ── helpers ──────────────────────────────────────────────────────────────

  String _compassDir(int deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  String _uviLevel(double uvi) {
    if (uvi < 3) return '낮음';
    if (uvi < 6) return '보통';
    if (uvi < 8) return '높음';
    return '매우높음';
  }

  String _visibilityKm(int meters) {
    final km = meters / 1000.0;
    return km >= 1 ? '${km.toStringAsFixed(1)} km' : '$meters m';
  }

  String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _fmtHourly(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _weekdayKo(DateTime dt) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[dt.weekday - 1];
  }

  String _weatherIcon(int id) {
    if (id == 800) return '☀️';
    if (id > 800) return '☁️';
    if (id >= 700) return '🌫️';
    if (id >= 600) return '❄️';
    if (id >= 500) return '🌧️';
    if (id >= 300) return '🌦️';
    if (id >= 200) return '⛈️';
    return '🌤️';
  }

  double _tempDisplay(double celsius, bool useCelsius) =>
      useCelsius ? celsius : celsius * 9 / 5 + 32;

  String _tempStr(double celsius, bool useCelsius) {
    final val = _tempDisplay(celsius, useCelsius);
    return '${val.round()}°${useCelsius ? 'C' : 'F'}';
  }

  // ── glassmorphism container ───────────────────────────────────────────────

  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── detail grid card ──────────────────────────────────────────────────────

  Widget _detailCard({
    required String icon,
    required String value,
    required String label,
  }) {
    const shadow = [
      Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x99000000)),
    ];
    return _glassContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: shadow,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
              shadows: shadow,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── hourly card ───────────────────────────────────────────────────────────

  Widget _hourlyCard(HourlyWeather h, bool useCelsius) {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _fmtHourly(h.time),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(_weatherIcon(h.weatherId), style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            _tempStr(h.temp, useCelsius),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Color(0x99000000)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── daily row ─────────────────────────────────────────────────────────────

  Widget _dailyRow(
    DailyWeather d,
    bool useCelsius,
    double weekMin,
    double weekMax,
  ) {
    final rangeSpan = weekMax - weekMin;
    final barStart = rangeSpan == 0 ? 0.0 : (d.tempMin - weekMin) / rangeSpan;
    final barEnd = rangeSpan == 0 ? 1.0 : (d.tempMax - weekMin) / rangeSpan;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Day label
                SizedBox(
                  width: 28,
                  child: Text(
                    _weekdayKo(d.date),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Color(0x99000000)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Icon
                Text(_weatherIcon(d.weatherId),
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                // Min temp
                SizedBox(
                  width: 36,
                  child: Text(
                    _tempStr(d.tempMin, useCelsius),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                // Range bar
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final total = constraints.maxWidth;
                    return Stack(
                      children: [
                        // Background track
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // Filled bar
                        Positioned(
                          left: total * barStart,
                          width: total * (barEnd - barStart),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(width: 8),
                // Max temp
                SizedBox(
                  width: 36,
                  child: Text(
                    _tempStr(d.tempMax, useCelsius),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── section title ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x99000000)),
          ],
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    // If no data, show loading indicator
    if (weather.data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final data = weather.data!;
    final useCelsius = settings.useCelsius;

    // Compute weekly min/max for the range bar
    double weekMin = data.daily.isNotEmpty ? data.daily.first.tempMin : 0;
    double weekMax = data.daily.isNotEmpty ? data.daily.first.tempMax : 1;
    for (final d in data.daily) {
      if (d.tempMin < weekMin) weekMin = d.tempMin;
      if (d.tempMax > weekMax) weekMax = d.tempMax;
    }

    // Local sunrise/sunset with timezone offset
    final sunriseLocal = data.sunrise
        .toUtc()
        .add(Duration(seconds: data.timezoneOffset));
    final sunsetLocal = data.sunset
        .toUtc()
        .add(Duration(seconds: data.timezoneOffset));

    // ── detail grid data ──────────────────────────────────────────────────
    final gridItems = [
      _DetailItem(
        icon: '🌡️',
        value: _tempStr(data.feelsLike, useCelsius),
        label: '체감온도',
      ),
      _DetailItem(
        icon: '💧',
        value: '${data.humidity}%',
        label: '습도',
      ),
      _DetailItem(
        icon: '💨',
        value: '${data.windSpeed.toStringAsFixed(1)} m/s\n'
            '${data.windDeg != null ? _compassDir(data.windDeg!) : '-'}',
        label: '풍속/풍향',
      ),
      _DetailItem(
        icon: '🔵',
        value: data.pressure != null ? '${data.pressure} hPa' : '-',
        label: '기압',
      ),
      _DetailItem(
        icon: '☀️',
        value: _uviLevel(data.uvi),
        label: '자외선 (${data.uvi.toStringAsFixed(1)})',
      ),
      _DetailItem(
        icon: '👁️',
        value: data.visibility != null ? _visibilityKm(data.visibility!) : '-',
        label: '가시거리',
      ),
      _DetailItem(
        icon: '🌿',
        value: data.dewPoint != null
            ? _tempStr(data.dewPoint!, useCelsius)
            : '-',
        label: '이슬점',
      ),
      _DetailItem(
        icon: '🌅',
        value: '↑ ${_fmtTime(sunriseLocal)}\n↓ ${_fmtTime(sunsetLocal)}',
        label: '일출/일몰',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Blurred background ──────────────────────────────────────────
          if (weather.imagePath != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Image.asset(
                weather.imagePath!,
                fit: BoxFit.cover,
              ),
            ),

          // Dark scrim for readability
          Container(color: Colors.black.withValues(alpha: 0.35)),

          // ── Scrollable content ──────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Handle bar
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Current weather grid ──────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = gridItems[i];
                        return _detailCard(
                          icon: item.icon,
                          value: item.value,
                          label: item.label,
                        );
                      },
                      childCount: gridItems.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Hourly forecast ───────────────────────────────────────
                if (data.hourly.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _sectionTitle('시간별 날씨'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: data.hourly.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, i) =>
                            SizedBox(
                              width: 72,
                              child: _hourlyCard(data.hourly[i], useCelsius),
                            ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // ── Daily forecast ────────────────────────────────────────
                if (data.daily.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _sectionTitle('주간 날씨'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _dailyRow(
                          data.daily[i],
                          useCelsius,
                          weekMin,
                          weekMax,
                        ),
                        childCount: data.daily.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple data holder for grid items
class _DetailItem {
  final String icon;
  final String value;
  final String label;
  const _DetailItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}
