import 'package:flutter/material.dart';

class WeatherDetails extends StatelessWidget {
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final bool useCelsius;

  const WeatherDetails({
    super.key,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.useCelsius,
  });

  @override
  Widget build(BuildContext context) {
    final feelsLikeValue = useCelsius ? feelsLike : (feelsLike * 9 / 5 + 32);
    final tempUnit = useCelsius ? '°C' : '°F';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(Icons.thermostat_outlined, '체감 ${feelsLikeValue.round()}$tempUnit'),
        const SizedBox(width: 20),
        _buildItem(Icons.water_drop_outlined, '$humidity%'),
        const SizedBox(width: 20),
        _buildItem(Icons.air, '${windSpeed.toStringAsFixed(1)} m/s'),
      ],
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xB3FFFFFF), size: 15,
          shadows: const [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000))],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xB3FFFFFF),
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
            ],
          ),
        ),
      ],
    );
  }
}
