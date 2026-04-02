import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherInfo extends StatelessWidget {
  final String cityName;
  final double temperature;
  final bool useCelsius;

  const WeatherInfo({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.useCelsius,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy.MM.dd').format(now);
    final tempValue = useCelsius ? temperature : (temperature * 9 / 5 + 32);
    final tempUnit = useCelsius ? '°C' : '°F';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          cityName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 6, color: Color(0x99000000)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xB3FFFFFF),
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${tempValue.round()}$tempUnit',
          style: const TextStyle(
            fontSize: 68,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -2,
            shadows: [
              Shadow(offset: Offset(0, 2), blurRadius: 10, color: Color(0x99000000)),
            ],
          ),
        ),
      ],
    );
  }
}
