import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherInfo extends StatefulWidget {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String weatherDescription;
  final bool useCelsius;

  const WeatherInfo({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherDescription,
    required this.useCelsius,
  });

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy.MM.dd').format(now);
    final tempValue =
        widget.useCelsius ? widget.temperature : (widget.temperature * 9 / 5 + 32);
    final feelsLikeValue =
        widget.useCelsius ? widget.feelsLike : (widget.feelsLike * 9 / 5 + 32);
    final tempUnit = widget.useCelsius ? '°C' : '°F';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // City name
          Text(
            widget.cityName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 6,
                    color: Color(0x99000000)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            dateStr,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xB3FFFFFF),
              shadows: [
                Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Color(0x80000000)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Weather description
          Text(
            widget.weatherDescription,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Color(0xCCFFFFFF),
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Color(0x80000000)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main temperature
          Text(
            '${tempValue.round()}$tempUnit',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 68,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -2,
              shadows: [
                Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 10,
                    color: Color(0x99000000)),
              ],
            ),
          ),

          // Feels-like temperature
          Text(
            '체감 ${feelsLikeValue.round()}$tempUnit',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Color(0xB3FFFFFF),
              shadows: [
                Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Color(0x80000000)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Humidity and wind row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop_outlined,
                  color: Color(0xB3FFFFFF), size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.humidity}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xB3FFFFFF),
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Color(0x80000000)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.air, color: Color(0xB3FFFFFF), size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.windSpeed.toStringAsFixed(1)} m/s',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xB3FFFFFF),
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Color(0x80000000)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
