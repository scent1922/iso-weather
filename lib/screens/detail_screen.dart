import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  String _compassDir(int deg) {
    const dirs = ['북', '북동', '동', '남동', '남', '남서', '서', '북서'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  String _uviLevel(double uvi) {
    if (uvi < 3) return '낮음';
    if (uvi < 6) return '보통';
    if (uvi < 8) return '높음';
    return '매우높음';
  }

  String _uviDesc(double uvi) {
    if (uvi < 3) return '자외선 걱정 없어요';
    if (uvi < 6) return '외출 시 자외선 차단 권장';
    if (uvi < 8) return '자외선 차단제 필수';
    return '야외 활동을 피하세요';
  }

  String _visibilityKm(int meters) {
    final km = meters / 1000.0;
    return km >= 1 ? '${km.toStringAsFixed(1)} km' : '$meters m';
  }

  String _visibilityDesc(int meters) {
    if (meters >= 10000) return '시야가 매우 좋습니다';
    if (meters >= 5000) return '시야가 양호합니다';
    if (meters >= 1000) return '시야가 다소 제한적입니다';
    return '시야가 매우 나쁩니다';
  }

  String _humidityDesc(int humidity) {
    if (humidity < 30) return '건조합니다. 수분 섭취 권장';
    if (humidity < 60) return '쾌적한 습도입니다';
    if (humidity < 80) return '다소 습합니다';
    return '매우 습합니다';
  }

  String _windDesc(double speed) {
    if (speed < 2) return '바람이 거의 없습니다';
    if (speed < 5) return '산들바람이 붑니다';
    if (speed < 9) return '바람이 다소 강합니다';
    return '강풍이 불고 있습니다';
  }

  String _pressureDesc(int pressure) {
    if (pressure < 1000) return '저기압 — 날씨 변화 가능';
    if (pressure < 1020) return '정상 기압입니다';
    return '고기압 — 맑은 날씨 예상';
  }

  String _feelsLikeDesc(double temp, double feelsLike) {
    final diff = feelsLike - temp;
    if (diff.abs() < 2) return '실제 기온과 비슷합니다';
    if (diff < 0) return '바람으로 더 춥게 느껴집니다';
    return '습도로 더 덥게 느껴집니다';
  }

  String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _weekdayKo(DateTime dt) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[dt.weekday - 1];
  }

  IconData _weatherIconData(int id) {
    if (id == 800) return Icons.wb_sunny_outlined;
    if (id > 800) return Icons.cloud_outlined;
    if (id >= 700) return Icons.blur_on;
    if (id >= 600) return Icons.ac_unit_outlined;
    if (id >= 500) return Icons.water_drop_outlined;
    if (id >= 300) return Icons.grain;
    if (id >= 200) return Icons.flash_on_outlined;
    return Icons.wb_sunny_outlined;
  }

  double _tempDisplay(double celsius, bool useCelsius) =>
      useCelsius ? celsius : celsius * 9 / 5 + 32;

  String _tempStr(double celsius, bool useCelsius) {
    final val = _tempDisplay(celsius, useCelsius);
    return '${val.round()}°${useCelsius ? 'C' : 'F'}';
  }

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

  Widget _detailCard({
    required IconData icon,
    required String value,
    required String label,
    required String description,
  }) {
    const shadow = [
      Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x99000000)),
    ];
    return _glassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xB3FFFFFF), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                  shadows: shadow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: shadow,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
              shadows: shadow,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hourlyCard(HourlyWeather h, bool useCelsius) {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(h.time),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Icon(_weatherIconData(h.weatherId), color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            _tempStr(h.temp, useCelsius),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(offset: Offset(0, 1), blurRadius: 3, color: Color(0x99000000)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyRow(DailyWeather d, bool useCelsius, double weekMin, double weekMax) {
    final rangeSpan = weekMax - weekMin;
    final barStart = rangeSpan == 0 ? 0.0 : (d.tempMin - weekMin) / rangeSpan;
    final barEnd = rangeSpan == 0 ? 1.0 : (d.tempMax - weekMin) / rangeSpan;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    _weekdayKo(d.date),
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(_weatherIconData(d.weatherId), color: Colors.white, size: 18),
                const SizedBox(width: 12),
                SizedBox(
                  width: 36,
                  child: Text(
                    _tempStr(d.tempMin, useCelsius),
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final total = constraints.maxWidth;
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Positioned(
                          left: total * barStart,
                          width: total * (barEnd - barStart).clamp(0.05, 1.0),
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
                SizedBox(
                  width: 36,
                  child: Text(
                    _tempStr(d.tempMax, useCelsius),
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x99000000))],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final settings = ref.watch(settingsProvider);

    if (weather.data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final data = weather.data!;
    final useCelsius = settings.useCelsius;

    double weekMin = data.daily.isNotEmpty ? data.daily.first.tempMin : 0;
    double weekMax = data.daily.isNotEmpty ? data.daily.first.tempMax : 1;
    for (final d in data.daily) {
      if (d.tempMin < weekMin) weekMin = d.tempMin;
      if (d.tempMax > weekMax) weekMax = d.tempMax;
    }

    final gridItems = [
      _DetailGridItem(
        icon: Icons.thermostat_outlined,
        value: _tempStr(data.feelsLike, useCelsius),
        label: '체감온도',
        description: _feelsLikeDesc(data.temp, data.feelsLike),
      ),
      _DetailGridItem(
        icon: Icons.water_drop_outlined,
        value: '${data.humidity}%',
        label: '습도',
        description: _humidityDesc(data.humidity),
      ),
      _DetailGridItem(
        icon: Icons.air,
        value: '${data.windSpeed.toStringAsFixed(1)} m/s',
        label: '풍속 ${data.windDeg != null ? _compassDir(data.windDeg!) : ''}',
        description: _windDesc(data.windSpeed),
      ),
      _DetailGridItem(
        icon: Icons.speed_outlined,
        value: data.pressure != null ? '${data.pressure} hPa' : '-',
        label: '기압',
        description: data.pressure != null ? _pressureDesc(data.pressure!) : '',
      ),
      _DetailGridItem(
        icon: Icons.wb_sunny_outlined,
        value: _uviLevel(data.uvi),
        label: '자외선 ${data.uvi.toStringAsFixed(1)}',
        description: _uviDesc(data.uvi),
      ),
      _DetailGridItem(
        icon: Icons.visibility_outlined,
        value: data.visibility != null ? _visibilityKm(data.visibility!) : '-',
        label: '가시거리',
        description: data.visibility != null ? _visibilityDesc(data.visibility!) : '',
      ),
      _DetailGridItem(
        icon: Icons.dew_point,
        value: data.dewPoint != null ? _tempStr(data.dewPoint!, useCelsius) : '-',
        label: '이슬점',
        description: data.dewPoint != null ? '현재 이슬점 ${data.dewPoint!.round()}°입니다' : '',
      ),
      _DetailGridItem(
        icon: Icons.wb_twilight_outlined,
        value: '${_fmtTime(data.sunrise)} / ${_fmtTime(data.sunset)}',
        label: '일출 / 일몰',
        description: '해가 떠 있는 시간: ${data.sunset.difference(data.sunrise).inHours}시간',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (weather.imagePath != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Image.asset(weather.imagePath!, fit: BoxFit.cover),
            ),
          Container(color: Colors.black.withValues(alpha: 0.35)),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Weather detail grid
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
                          description: item.description,
                        );
                      },
                      childCount: gridItems.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                if (data.hourly.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: _sectionTitle('시간별 날씨')),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: data.hourly.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => SizedBox(
                          width: 72,
                          child: _hourlyCard(data.hourly[i], useCelsius),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                if (data.daily.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: _sectionTitle('주간 날씨')),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _dailyRow(data.daily[i], useCelsius, weekMin, weekMax),
                        childCount: data.daily.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailGridItem {
  final IconData icon;
  final String value;
  final String label;
  final String description;
  const _DetailGridItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.description,
  });
}
